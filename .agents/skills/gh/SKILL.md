---
name: gh
description: Patterns for invoking the GitHub CLI (gh) from agents, focused on PR review (state, description, diff, checks) and diagnosing failed Actions runs (logs). Covers structured JSON output, pagination, repo targeting, and gh api fallback.
---

# Reference

## Interactivity policy

`gh` already does the right thing in non-TTY contexts: no pager, no ANSI
color, and it errors fast instead of prompting. No need to set `GH_PAGER`
or pass `--no-pager` (doesn't exist).

## Parsing JSON

- `--json field1,field2,...` for structured output; run with `--json` and
  no field list to print all available fields for that command.
- `--jq '<expr>'` filters without piping to a separate `jq`.
- `--template '<go-template>'` shapes text output (alongside `--json`).
  `-T`/`--template` collides with the body-template flag on some create
  commands (e.g. `gh pr create -T`) — check `--help` if unsure.

## Repo targeting

`gh` infers the repo from the cwd's git remotes. Pass `-R OWNER/REPO`
(`--repo`) to override.

## Pull requests: state, description, diff, checks

- `gh pr view [<number>|<url>|<branch>]` — no arg uses the PR for the
  current branch. For latest state + description in one call:
  `gh pr view <n> --json number,title,body,state,isDraft,headRefName,headRefOid,mergeStateStatus,reviewDecision,statusCheckRollup,url`
  (`headRefOid` is the head commit SHA — there is no `headSha` field).
  Add `commits`, `files`, `reviews`, `latestReviews` only when actually
  needed, they're heavier. `-c/--comments` gets issue-level PR comments
  (not review-thread comments — see below).
- `gh pr list [-s open|closed|merged|all] [-A author] [-B base] [-H head] [-L N]`
  — default state is open, default limit 30. `--search "<query>"` takes
  one quoted string scoped to the repo (GitHub search syntax).
- `gh pr diff <n> [--name-only] [--patch]` — view changes without
  checking out. `gh pr checkout <n>` switches branch;
  `gh pr checkout <n> --worktree <path>` checks out into a separate
  worktree instead.
- `gh pr checks [<n>] [--watch [--fail-fast]] [--required]` — CI status.
  `--json name,state,bucket,link` (`bucket` is `pass|fail|pending|skipping|cancel`,
  derived from `state`). Prefer this (or `statusCheckRollup` from
  `pr view --json`) over scraping human output to detect failures; follow
  a failed check's `link`, or jump to the run/job diagnosis flow below.
- Review-thread (inline code review) comments aren't exposed via `--json`;
  fall back to `gh api --paginate repos/{owner}/{repo}/pulls/{n}/comments`.

## Diagnosing failed Actions runs

1. Find the run: `gh run list [-b branch] [-w workflow] [-s status] [-c SHA] [-L N]`
   (default limit 20). Filter `-s failure` to shortlist. For a PR's runs,
   use the PR's `headRefName`/`headRefOid` as `-b`/`-c`, or open
   `gh pr checks <n>` and follow a check's `link`.
2. Inspect the run: `gh run view <run-id> [-v]` shows job/step status;
   `-v/--verbose` includes steps. `--json jobs` gives per-job
   `conclusion`/steps programmatically. Note: `gh run view` doesn't
   support fine-grained PATs (no `checks:read` scope available); use a
   classic PAT, OAuth token, or `GITHUB_TOKEN` if auth fails here.
3. Get logs for just what failed: `gh run view <run-id> --log-failed`
   (whole run) or add `-j/--job <job-id>` to scope to one job. Use
   `--log` for full logs when `--log-failed` output isn't enough context.
4. `gh run view <run-id> --exit-status` — non-zero exit if the run
   failed/was cancelled; useful for scripted gating.
5. `gh run watch <run-id> [--exit-status]` to follow an in-progress run
   rather than polling `run list`.
6. Artifacts (e.g. test reports, coverage): `gh run download <run-id>
   [-n artifact-name] [-D dir]`.

## Fall back to `gh api` for anything `--json` doesn't expose

- Arbitrary GraphQL: `gh api graphql -f query='...' -F var=value`.
- Pagination beyond `-L`: `gh api --paginate <path>`, combine with `--jq`
  (and `--slurp` to assemble one array). List commands (`pr list`,
  `run list`) don't expose `totalCount` via `--json`; use
  `gh api graphql` if you need a true total.
- `{owner}/{repo}` placeholders are filled in from the cwd's detected
  remote; pass literal values for determinism outside a repo checkout.

## Other notes

- `gh auth status` — active host(s), user, token source (no `--json`
  support).
- `NO_COLOR`, `CLICOLOR_FORCE`, `GH_FORCE_TTY` are honored; leave
  `GH_FORCE_TTY` unset in agent contexts unless you specifically want
  TTY-style output (colors, tables, pager, interactivity).
- Bots author as GitHub Apps: `--author dependabot` matches nothing on
  `pr list`/`gh search prs`. Use `--app dependabot` or
  `--author "dependabot[bot]"`.
- Issue/discussion workflows (types, sub-issues, `gh discussion ...`,
  `gh repo read-file`/`read-dir`) are out of scope here; run
  `gh issue --help` / `gh discussion --help` if that need comes up.
