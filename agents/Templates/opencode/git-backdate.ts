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

function extractDateFromEnv(cmd: string): string | null {
  const committerMatch = cmd.match(/GIT_COMMITTER_DATE=["']([^"']+)["']/)
  const authorMatch = cmd.match(/GIT_AUTHOR_DATE=["']([^"']+)["']/)
  const dateFlagMatch = cmd.match(/--date=["']([^"']+)["']/)

  if (!committerMatch) return null

  const committerDate = committerMatch[1]
  const authorDate = authorMatch?.[1] ?? dateFlagMatch?.[1]

  if (!authorDate) return null

  if (committerDate !== authorDate) {
    throw new Error("GIT_COMMITTER_DATE and GIT_AUTHOR_DATE must match")
  }

  return committerDate.split(" ")[0]
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

export const gitBackdate: Plugin = async ({ $ }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return

      const cmd = output.args.command as string
      if (!cmd.includes("git") || !cmd.includes("commit")) return
      if (cmd.includes("git commit --amend")) return

      const date = extractDateFromEnv(cmd)
      if (!date) {
        throw new Error(
          "Must provide date via GIT_COMMITTER_DATE and (GIT_AUTHOR_DATE or --date)\n\n" +
          "Example:\n" +
          "  GIT_COMMITTER_DATE=\"2025-01-15 09:23\" GIT_AUTHOR_DATE=\"2025-01-15 09:23\" git commit -m \"feat: add feature\""
        )
      }

      const dateMatch = date.match(/^(\d{4})-(\d{2})-(\d{2})$/)
      if (!dateMatch) {
        throw new Error("Date must be in YYYY-MM-DD format")
      }

      const [, year, month, day] = dateMatch
      const hourMatch = cmd.match(/GIT_COMMITTER_DATE=["']([^"']+)["']/)
      if (!hourMatch) {
        throw new Error("Cannot parse time from GIT_COMMITTER_DATE")
      }

      const fullDatetime = hourMatch[1]
      const timeMatch = fullDatetime.match(/(\d{2}):(\d{2})/)
      if (!timeMatch) {
        throw new Error("Time must be in HH:MM format")
      }

      const [, hour, minute] = timeMatch
      const minuteNum = parseInt(minute, 10)

      if ([0, 15, 30, 45].includes(minuteNum)) {
        throw new Error(
          "Cannot use quarter hours (:00, :15, :30, :45)\n\n" +
          "Use organic times like :07, :23, :38, :52"
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
            `Cannot commit before or within 1 minute of last commit (${lastCommitDateStr})\n\n` +
            "Evaluate the development time needed for these changes.\n" +
            "Add at least 1 minute to the last commit date."
          )
        }

        const oneMonthMs = 30 * 24 * 60 * 60 * 1000
        if (diffMs > oneMonthMs) {
          throw new Error(
            `Cannot commit more than 1 month since last commit (${lastCommitDateStr.split(" ")[0]})\n\n` +
            "Evaluate if this is realistic or rollback to an earlier state."
          )
        }
      }

      const dayOfWeek = commitDate.getDay()
      if (dayOfWeek === 0 || dayOfWeek === 6) {
        throw new Error("Cannot commit on weekends")
      }

      const hourNum = parseInt(hour, 10)
      if (hourNum < 8 || hourNum >= 19) {
        throw new Error("Cannot commit outside work hours (08:00-19:00)")
      }

      const msgMatch = cmd.match(/-m\s+["']([^"']+)["']/)
      if (!msgMatch) {
        throw new Error("Commit message must be provided with -m flag")
      }

      const message = msgMatch[1]

      if (/[^\x20-\x7E]/.test(message)) {
        throw new Error("Commit message must be ASCII only")
      }

      if (message.includes("\n")) {
        throw new Error("Commit message must be single line")
      }

      if (!CONVENTIONAL_PATTERN.test(message)) {
        throw new Error(
          "Must follow conventional format: type: message or type(scope): message\n\n" +
          "Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert\n" +
          "Example: feat(auth): add login or fix: resolve bug"
        )
      }

      const filesWithEmojis = await checkFilesForEmojis($)
      if (filesWithEmojis.length > 0) {
        throw new Error(
          `Files contain emojis: ${filesWithEmojis.join(", ")}\n\n` +
          "Remove emojis for clean portable text files"
        )
      }
    },
  }
}
