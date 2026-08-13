---
name: revive-pr
description: Safely revive or update an existing pull request branch from its current base while preserving clean shared history. Use when asked to revive, refresh, update, or bring an existing PR up to date, especially a contributor or fork PR.
---

# Revive an Existing Pull Request

Preserve the original PR branch history unless the user explicitly requests a
rewrite. For a published or shared branch, merge the current base branch into
the original PR branch rather than rebasing it.

## Inspect Before Updating

1. Identify the PR's base branch, head branch, head repository owner, and
   current head SHA.
2. Fetch the base branch and the untouched original PR branch.
3. Inspect the commit graph and working tree before changing history.
4. Collect existing review feedback and CI failures.

## Update the Original PR Branch

Work from the original PR branch:

```bash
git fetch <base-remote> <base-branch>
git fetch <pr-remote> <pr-branch>
git switch <pr-branch>
git merge <base-remote>/<base-branch>
```

Equivalently, while on the original PR branch:

```bash
git pull <base-remote> <base-branch>
```

Resolve conflicts by preserving the PR's intent and adapting it to current
base-branch APIs and patterns. Apply review feedback, diagnose failures, and
run the smallest relevant build, tests, and checks.

## History Safety

- Do not rebase or otherwise rewrite a published/shared PR branch unless the
  user explicitly approves a history rewrite.
- Never reconnect separately rebased work to the old PR tip with
  `git merge -s ours`. This grafts both histories together, duplicates topic
  commits, and can expose base commits individually in the PR commit list.
- Do not push until the user has approved pushing when they asked for a
  ready-for-review checkpoint first.
- Before pushing, inspect both the tree and history:

  ```bash
  git status --porcelain
  git log --graph --oneline --decorate <base-remote>/<base-branch>...HEAD
  git rev-list --left-right --count <base-remote>/<base-branch>...HEAD
  ```

- If GitHub CLI is available, verify the rendered PR commit list:

  ```bash
  gh pr view <number> --json commits --jq '.commits[].messageHeadline'
  ```

## Repair Malformed Published History

If an incorrect history was already published:

1. Preserve the current malformed head under a local backup branch.
2. Recreate the branch from the untouched original PR tip.
3. Merge the current base branch normally.
4. Reapply the already validated topic changes.
5. Compare the corrected tree with the validated tree and rerun relevant
   validation.
6. Obtain explicit user approval for the rewrite.
7. Replace the remote with an exact lease:

   ```bash
   git push \
     --force-with-lease=refs/heads/<pr-branch>:<known-remote-sha> \
     <pr-remote> HEAD:<pr-branch>
   ```

Never use plain `--force`.
