import type { Plugin } from "@opencode-ai/plugin"

const CONVENTIONAL_PATTERN = /^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9/_-]+\))?: .+/

function hasEmojis(content: string): boolean {
  for (const char of content) {
    const code = char.codePointAt(0)!
    if (
      (code >= 0x1F300 && code <= 0x1F9FF) ||
      (code >= 0x1F600 && code <= 0x1F64F) ||
      (code >= 0x2600 && code <= 0x27BF) ||
      (code >= 0x1F900 && code <= 0x1F9FF)
    ) {
      return true
    }
  }
  return false
}

const BACKDATE_REQUIREMENTS = `
This is a backdated repository. All commits must follow these rules:

REQUIREMENTS:
1. Date: Must provide GIT_COMMITTER_DATE and (GIT_AUTHOR_DATE or --date), both must match
2. Time format: HH:MM (24-hour)
3. Quarter hours: Cannot use :00, :15, :30, :45 - use organic times like :07, :23, :38, :52
4. Minimum gap: At least 1 minute after last commit
5. Maximum gap: Cannot be more than 1 month since last commit
6. Work hours: Mon-Fri 08:00-18:59
7. Weekends: Cannot commit on weekends
8. Commit message: Single line, no emojis, conventional format (type: message or type(scope): message)
9. Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
10. Staged files: Cannot contain emojis

EXAMPLE:
  GIT_COMMITTER_DATE="2025-01-15 09:23" GIT_AUTHOR_DATE="2025-01-15 09:23" git commit -m "feat: add feature"
`

function extractDateFromEnv(cmd: string): { date: string; time: string } | null {
  const committerMatch = cmd.match(/GIT_COMMITTER_DATE=["']([^"']+)["']/)
  const authorMatch = cmd.match(/GIT_AUTHOR_DATE=["']([^"']+)["']/)
  const dateFlagMatch = cmd.match(/--date=["']([^"']+)["']/)

  if (!committerMatch) return null

  const committerDate = committerMatch[1]
  const authorDate = authorMatch?.[1] ?? dateFlagMatch?.[1]

  if (!authorDate) return null

  if (committerDate !== authorDate) {
    throw new Error(
      `OpenCode Hook - Bash tool (git commit)\n` +
      `GIT_COMMITTER_DATE and GIT_AUTHOR_DATE must match.\n` +
      `Current: GIT_COMMITTER_DATE="${committerDate}" GIT_AUTHOR_DATE="${authorDate}"\n` +
      BACKDATE_REQUIREMENTS
    )
  }

  const parts = committerDate.split(" ")
  return { date: parts[0], time: parts[1]?.split(":").slice(0, 2).join(":") || "" }
}

async function getLastCommitDate($: typeof import("bun").$): Promise<string | null> {
  const lastCommit = await $`git log -1 --format=%ai`
  const output = lastCommit.stdout.toString().trim()
  return output || null
}

async function getStagedFiles($: typeof import("bun").$): Promise<string[]> {
  const result = await $`git diff --cached --name-only`
  const output = result.stdout.toString().trim()
  return output ? output.split("\n").filter(Boolean) : []
}

async function checkFilesForEmojis($: typeof import("bun").$): Promise<string[]> {
  const staged = await getStagedFiles($)
  const filesWithEmojis: string[] = []

  for (const file of staged) {
    const content = await $`cat ${file}`.catch(() => ({ stdout: { toString: () => "" } }))
    if (hasEmojis(content.stdout.toString())) {
      filesWithEmojis.push(file)
    }
  }

  return filesWithEmojis
}

function validateCommitMessage(message: string): string | null {
  if (hasEmojis(message)) {
    return "Commit message cannot contain emojis"
  }
  if (message.includes("\n")) {
    return "Commit message must be single line"
  }
  if (!CONVENTIONAL_PATTERN.test(message)) {
    return "Must follow conventional format: type: message or type(scope): message"
  }
  return null
}

export const gitBackdate: Plugin = async ({ $ }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return

      const cmd = output.args.command as string
      if (!cmd.includes("git") || !cmd.includes("commit")) return
      if (cmd.includes("git commit --amend")) return

      const dateInfo = extractDateFromEnv(cmd)
      if (!dateInfo) {
        const msgMatch = cmd.match(/-m\s+["']([^"']+)["']/)
        const currentMsg = msgMatch?.[1] || "(no message provided)"
        throw new Error(
          `OpenCode Hook - Bash tool (git commit)\n` +
          `No date provided.\n` +
          `Current message: "${currentMsg}"\n` +
          BACKDATE_REQUIREMENTS
        )
      }

      const { date, time } = dateInfo
      const dateMatch = date.match(/^(\d{4})-(\d{2})-(\d{2})$/)
      if (!dateMatch) {
        throw new Error(
          `OpenCode Hook - Bash tool (git commit)\n` +
          `Invalid date format: ${date}\n` +
          `Date must be YYYY-MM-DD\n` +
          BACKDATE_REQUIREMENTS
        )
      }

      const [, year, month, day] = dateMatch
      const timeMatch = time.match(/^(\d{2}):(\d{2})$/)
      if (!timeMatch) {
        throw new Error(
          `OpenCode Hook - Bash tool (git commit)\n` +
          `Invalid time format: ${time}\n` +
          `Time must be HH:MM (24-hour)\n` +
          BACKDATE_REQUIREMENTS
        )
      }

      const [, hour, minute] = timeMatch
      const minuteNum = parseInt(minute, 10)

      if ([0, 15, 30, 45].includes(minuteNum)) {
        throw new Error(
          `OpenCode Hook - Bash tool (git commit)\n` +
          `Cannot use quarter hours (:00, :15, :30, :45)\n` +
          `Current time: ${time}\n` +
          `Use organic times like :07, :23, :38, :52\n` +
          BACKDATE_REQUIREMENTS
        )
      }

      const commitDate = new Date(`${year}-${month}-${day}T${hour}:${minute}:00`)
      const lastCommitDateStr = await getLastCommitDate($)

      if (lastCommitDateStr) {
        const lastCommit = new Date(lastCommitDateStr)
        const diffMs = commitDate.getTime() - lastCommit.getTime()
        const diffSeconds = diffMs / 1000

        if (diffSeconds < 60) {
          throw new Error(
            `OpenCode Hook - Bash tool (git commit)\n` +
            `Cannot commit before or within 1 minute of last commit.\n` +
            `Last commit: ${lastCommitDateStr}\n` +
            `Requested: ${date} ${time}\n` +
            `Evaluate the development time needed for these changes.\n` +
            `Add at least 1 minute to the last commit date.\n` +
            BACKDATE_REQUIREMENTS
          )
        }

        const oneMonthMs = 30 * 24 * 60 * 60 * 1000
        if (diffMs > oneMonthMs) {
          throw new Error(
            `OpenCode Hook - Bash tool (git commit)\n` +
            `Cannot commit more than 1 month since last commit.\n` +
            `Last commit: ${lastCommitDateStr.split(" ")[0]}\n` +
            `Requested: ${date}\n` +
            `Evaluate if this is realistic or rollback to an earlier state.\n` +
            BACKDATE_REQUIREMENTS
          )
        }
      }

      const dayOfWeek = commitDate.getDay()
      if (dayOfWeek === 0 || dayOfWeek === 6) {
        throw new Error(
          `OpenCode Hook - Bash tool (git commit)\n` +
          `Cannot commit on weekends.\n` +
          `Requested: ${date} (${dayOfWeek === 0 ? "Sunday" : "Saturday"})\n` +
          `Commits must be Mon-Fri\n` +
          BACKDATE_REQUIREMENTS
        )
      }

      const hourNum = parseInt(hour, 10)
      if (hourNum < 8 || hourNum >= 19) {
        throw new Error(
          `OpenCode Hook - Bash tool (git commit)\n` +
          `Cannot commit outside work hours (08:00-19:00).\n` +
          `Requested: ${time}\n` +
          `Work hours are Mon-Fri 08:00-18:59\n` +
          BACKDATE_REQUIREMENTS
        )
      }

      const msgMatch = cmd.match(/-m\s+["']([^"']+)["']/)
      if (!msgMatch) {
        throw new Error(
          `OpenCode Hook - Bash tool (git commit)\n` +
          `Commit message must be provided with -m flag.\n` +
          BACKDATE_REQUIREMENTS
        )
      }

      const message = msgMatch[1]
      const msgError = validateCommitMessage(message)
      if (msgError) {
        throw new Error(
          `OpenCode Hook - Bash tool (git commit)\n` +
          `${msgError}\n` +
          `Current message: "${message}"\n` +
          BACKDATE_REQUIREMENTS
        )
      }

      const filesWithEmojis = await checkFilesForEmojis($)
      if (filesWithEmojis.length > 0) {
        throw new Error(
          `OpenCode Hook - Bash tool (git commit)\n` +
          `Staged files contain emojis.\n` +
          `Files: ${filesWithEmojis.join(", ")}\n` +
          `Remove emojis for clean portable text files.\n` +
          BACKDATE_REQUIREMENTS
        )
      }
    },
  }
}
