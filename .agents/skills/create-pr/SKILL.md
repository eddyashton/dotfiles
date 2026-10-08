---
name: create-pr
description: Create a PR, including a draft, using project style: merge main first, use the repository PR template, and match existing PR titles without invented prefixes.
---

# Create a Pull Request

Replace the plugin's default workflow with these project-style adjustments.
Prefer `gh` CLI. Keep this as lightweight as the builtin workflow; do not add
extra audits, full test runs, polling, or repeated checks just to open a PR.

1. Inspect the current branch and changes. If task-owned changes are uncommitted,
   use the `commit` skill first so merging is safe. Preserve unrelated changes.
2. Invoke `merge-main` before opening the PR. Follow that skill rather than
   duplicating its merge, push, or synchronization checks. Never rebase or
   force-push.
3. Validate and review the merged change using existing task evidence. Do not
   rerun a successful build or test if the covered code is unchanged; run only
   checks needed for upstream changes or conflict resolutions. Report blockers.
4. Read the repository's PR template and use its headings and prompts for the
   body. Keep answers brief, include relevant validation, and use `Closes #123`
   only for fully resolved issues.
5. Match existing PR title style using examples already in context, or a small
   recent PR sample if needed. Do not invent Conventional Commit or area prefixes.
   For CCF:
   `Return JSON errors for forwarding timeouts`, not
   `rpc: Return JSON errors for forwarding timeouts`.
6. Create the PR with explicit repository, base, head, title, and body. Honor
   draft requests and avoid duplicate PRs. Add any repository-required changelog
   PR reference once the number exists, commit and push that edit without
   amending, then report the PR link.
