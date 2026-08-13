---
name: session-meta-review
description: Run an independent meta-review of the current session near its end by discovering the session automatically and delegating to the session-meta-review agent. Use when the user asks to review, retrospect on, or assess the current session's process.
---

# Review the Current Session

Use this skill as an orchestration wrapper around the `session-meta-review`
custom agent. Do not replace the independent review with a self-review in the
current context.

## Re-entrancy guard

Before following the wrapper procedure, determine whether this skill is running
inside the `session-meta-review` custom agent. Treat either of these as terminal
reviewer mode:

- the current agent identity is `session-meta-review`; or
- the delegated review request contains the exact marker
  `Terminal reviewer: true`.

In terminal reviewer mode, do not call `get_current_session`, do not launch any
agent, and do not invoke this skill again. Retrieve the supplied session's
context directly, choose a full, partial, or targeted inspection, and produce
the review report.

## Procedure

Follow this procedure only when not in terminal reviewer mode:

1. Call `get_current_session` to obtain the current session reference.
2. Launch the `session-meta-review` agent and ask it to review the session as it
   exists at this point in time. Give it only:
   - the current session reference; and
   - explicit permission to retrieve session context, inspect the detailed event
     log, and read applicable instruction or skill files when useful.
3. Let the review agent choose an inspection strategy appropriate to the
   session's size. It may retrieve the full context, page through partial
   context, or perform a targeted scan rather than loading the entire transcript.
4. Ask the agent to return its normal prioritized report without modifying
   files or session artifacts.
5. Present the agent's report directly to the user. Do not add a second,
   duplicative review.

Prefer a synchronous agent invocation so the report is returned in the current
interaction. If the runtime requires a background invocation, wait for its
completion notification and retrieve the result once rather than polling.

## Agent prompt

Adapt this prompt with the discovered session reference:

```text
Review the current session as a point-in-time end-of-session meta-review.
Session: <session-reference>
Terminal reviewer: true

Retrieve and inspect the session context yourself. Choose a full, partial, or
targeted inspection based on the session's size and the evidence needed for a
useful review. Inspect additional metadata, the detailed event log, and
applicable instruction or skill files when useful. Follow your standard
session-meta-review output format. You are the terminal reviewer: do not invoke
the session-meta-review skill or launch another agent. Do not modify anything.
```

Do not retrieve the transcript in the current session merely to forward it to
the review agent, and do not ask the user to identify the current session
manually.
