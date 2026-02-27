import type { Plugin } from "@opencode-ai/plugin"

export const gitCiCd: Plugin = async ({ $, directory }) => {
  return {
    "tool.execute.before": async (input, output, { client }) => {
      if (input.tool !== "bash") return

      const cmd = output.args.command as string
      if (!cmd.includes("git push")) return

      const workflowsPath = `${directory}/.github/workflows`
      const workflowsExist = await $`test -d ${workflowsPath}`.then(() => true).catch(() => false)

      if (!workflowsExist) return

      const currentBranch = await $`git branch --show-current`.then(r => r.stdout.toString().trim()).catch(() => "")

      const branchMatch = cmd.match(/git\s+push\s+(?:origin\s+)?(\S+)/)
      const pushedBranch = branchMatch?.[1]

      if (!pushedBranch) return
      if (pushedBranch !== currentBranch) return

      const ghExists = await $`which gh`.then(() => true).catch(() => false)

      if (!ghExists) {
        const msg = "GitHub Actions found but gh CLI not installed. Check with user if CI/CD passed before continuing developing."
        await client.app.log({ body: { level: "warn", message: msg } })
        throw new Error(msg)
      }

      const runResult = await $`gh run list --branch ${pushedBranch} -L 1 --json status,conclusion`.catch(() => null)

      if (!runResult) return

      try {
        const runs = JSON.parse(runResult.stdout.toString()) as Array<{
          status: string
          conclusion: string | null
        }>

        if (runs.length === 0) return

        const latestRun = runs[0]

        if (latestRun.status === "completed" && latestRun.conclusion === "failure") {
          const msg = "GitHub Actions failed for latest run. Check with user if CI/CD passed before continuing developing."
          await client.app.log({ body: { level: "warn", message: msg } })
          throw new Error(msg)
        }
      } catch {
        return
      }
    },
  }
}
