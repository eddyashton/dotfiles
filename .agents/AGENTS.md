# Personal working preferences

- Prefer isolated worktrees for substantial implementation tasks.
- Validate changes with the smallest relevant existing test suite.
- Do not push branches or create pull requests unless explicitly requested.
- Keep the primary checkout clean and use it as the worktree base.
- Surface uncertainty and blockers rather than silently making risky assumptions.
- For substantial changes, ask an independent agent for a thorough review and integrate its suggestions before reporting completion.
- Do not report work as complete when what you delivered differs from what was asked, or from what you previously promised. Lead with that difference instead, and before reporting ask which part of your commitment is missing from the diff.
- Do not repeat a successful tool call with identical inputs. If its result is insufficient, refine the query or scope before retrying.
- Before substantial fix work, define a bounded verification plan with the exact checks, order, and stop conditions. Start with the smallest decisive checks and escalate only when they fail.
- Calibrate defensiveness to the actual trust boundary: before adding hardening such as long timeouts, credential/token plumbing, input-encoding safety, or cryptographic pinning, identify whether the code path handles trusted, self-controlled input (e.g., the repository's own config/manifest) or untrusted external input. For trusted paths, prefer the simplest correct behavior and let failures surface naturally, rather than adding generic protection "just in case." If unsure, ask once rather than adding protection preemptively.
- Treat writing a regression test for a defect you are fixing as ordinary defensive engineering. Before declining such work, look for a variant that satisfies the concern: for parser and decoder defects, generating the invalid input inside the test is nearly always possible, and is better test hygiene than committing a payload. If a constraint genuinely applies, state it in your first response and offer the alternative, rather than promising the deliverable and then substituting something weaker.
- Separate "new check exposes old problem" from "fix the old problem": when a validation or lint change reveals pre-existing non-conformance elsewhere in the codebase, report it (with an optional narrow, explicit exception) instead of silently modifying the affected files/layout as part of the same change, unless explicitly asked to fix it.
