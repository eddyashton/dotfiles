---
name: merge-main
description: Merge the current upstream and latest origin/main into the current branch, resolve conflicts without rebasing, validate the result, and push. Use when the user asks to pull main into their branch, merge main, or update their branch without rewriting history.
---

# Merge Main Into the Current Branch

Update the current branch with both its upstream branch and the latest
`origin/main` by creating merges, then push the result. This workflow
intentionally preserves branch history and must not be replaced with a rebase.

## Safety Rules

- Never rebase, reset, force-push, or skip Git hooks.
- Never stash or discard uncommitted work implicitly.
- Do not switch branches: update the branch that was current when the skill was
  invoked.
- If a conflict resolution is ambiguous, ask the user rather than choosing one
  side wholesale.
- Preserve the intent of the current branch, its upstream, and `origin/main`
  when resolving conflicts.

## Workflow

1. Inspect the current branch, worktree, configured remotes, and upstream:

   ```bash
   git status --short --branch
   git branch --show-current
   git remote -v
   git rev-parse --abbrev-ref --symbolic-full-name '@{u}'
   ```

2. Require a named current branch and a clean worktree.
   - If the repository is in detached HEAD state, stop and explain.
   - If tracked or untracked changes are present, do not pull. Ask whether the
     user wants to commit them with the `commit` skill or handle them manually.

3. Confirm that the `origin` remote exists. Record whether the current branch
   has an upstream. Use `main` as the base branch unless the user explicitly
   named another remote or base branch.

4. If the current branch has an upstream, pull it into the current branch
   first:

   ```bash
   git pull --no-rebase
   ```

   This incorporates remote changes to the feature branch before merging the
   base, avoiding a predictable non-fast-forward rejection when pushing later.

5. Pull the base branch into the current branch with merge semantics:

   ```bash
   git pull --no-rebase origin main
   ```

   The explicit `--no-rebase` is required because local Git configuration may
   otherwise turn `git pull origin main` into a rebase.

6. If either pull reports conflicts:
   - Inspect every conflicted file and the relevant surrounding code.
   - Resolve each conflict so the current branch preserves the intent of both
     sides of that merge.
   - Stage only the resolved files:

     ```bash
     git add <resolved-files>
     ```

   - Complete the merge:

     ```bash
     git merge --continue
     ```

   - If the merge cannot be resolved safely, leave the conflict state intact
     and ask the user how to proceed. Only run `git merge --abort` if the user
     asks to abandon the update.

7. If conflict resolution changed executable code, run the smallest existing
   targeted tests, build, or lint checks that cover the resolved areas. Do not
   invent new validation tooling.

8. Push the current branch:
   - If it already has an upstream, run:

     ```bash
     git push
     ```

   - If it has no upstream, publish the current branch to `origin`:

     ```bash
     git push -u origin HEAD
     ```

   - If the push is rejected because the upstream advanced after step 4, do not
     force-push. Repeat the upstream pull from step 4, resolve any conflicts,
     rerun affected validation, and push again.

## Validation

After the push succeeds:

1. Fetch all configured remotes so validation uses current remote state:

   ```bash
   git fetch --all
   ```

2. Verify that the fetched base is an ancestor of the current branch:

   ```bash
   git merge-base --is-ancestor origin/main HEAD
   ```

3. Verify that the worktree is clean:

   ```bash
   git status --porcelain
   ```

4. Verify that the current branch and its upstream have no commits outstanding:

   ```bash
   git rev-list --left-right --count 'HEAD...@{u}'
   ```

   The expected result is `0 0`.

## Examples

- "Merge main into my branch" means:

  ```bash
  git pull --no-rebase
  git pull --no-rebase origin main
  git push
  ```

- "Sync my branch" remains the built-in tracking-branch workflow. Do not invoke
  this skill unless the request mentions merging or pulling the base branch
  into the current branch without rebasing.
