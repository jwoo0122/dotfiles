---
name: execute-to-pr
description: Internal execution stage for the chained coding workflow. Use after clarify-and-plan establishes a clear, authorized change, then implement it, run the architecture-decision conformance gate, verify the result, and stop at the user's explicit local, commit, or draft-PR boundary. Do not present this as a direct user entry point or use it for read-only requests or when the user forbids implementation.
user-invocable: false
---

# Execute and Deliver

Carry an authorized, sufficiently clear change through verified delivery. Own the whole intent, the verification evidence, and the delivery boundary.

## Check entry conditions

Start only when all are true:

- the user requested a codebase change;
- the outcome and scope are sufficiently clear;
- no material blocking decision remains;
- observable acceptance checks are known;
- relevant accepted ADRs have been read and any architectural conflict has been reconciled;
- the authorized delivery boundary is explicit; and
- active instructions permit implementation.

Return to `clarify-and-plan` if implementation exposes a material unresolved decision.

## Establish a safe Git baseline

Inspect status, branch, upstream, remotes, and the repository's default branch before editing.

- Record which pre-existing changes belong to the user. Never discard, rewrite, stage, or commit unrelated user work.
- Do not include unrelated changes in tests, formatting, staging, commits, or the pull request.
- If isolation is not reliable, stop and explain the collision.
- For `local-change`, preserve the current branch and worktree; do not create or switch branches merely to edit locally.
- For `commit` or `draft-pr`, create a focused work branch when on a default or protected branch, unless the harness already provided an isolated task branch or worktree.
- Never switch branches in a way that risks uncommitted user work.

## Implement

Make the smallest coherent change that satisfies the brief. Keep edits surgical: preserve existing repository style, and do not add features, abstractions, dependencies, or documents the requested outcome does not need.

Read [the implementation loop](references/implementation-loop.md) when production behavior or tests must change.

Reserve every `adr/**` path for the architecture-decision writer role described in `maintain-architecture-decisions`. Do not edit those paths while implementing.

## Verify

Run the ADR conformance gate before and after implementation. A failing gate is unfinished work until code, an explicit enforcement exception, or authorized ADR intent is reconciled.

- Run targeted checks while iterating, then every repository-required pre-delivery check that applies to the changed area.
- Capture command names and outcomes.
- Never weaken, delete, skip, or rewrite a relevant check merely to obtain a pass.
- Treat a failing required check as unfinished. If a failure is pre-existing, prove that from the baseline or an untouched area; do not merely label it pre-existing.
- Do not edit verification configuration or snapshots unless the requested behavior legitimately changes them and the diff is reviewed.

Before delivery, inspect the complete task diff for:

- missed requirements and edge cases;
- accidental API or behavior changes;
- unrelated files or broad formatting churn;
- secrets, generated artifacts, debug output, or temporary files;
- test assertions that cannot fail for the regression.

## Review independently when impact warrants it

That inspection is self-review and is sufficient for an ordinary bounded change. When the change is architecturally significant, security-sensitive, or expensive to reverse, obtain a review from a context that did not write the change before delivery, even when the diff is small. That context may be a subagent, a separate session, or the user.

Give it the brief, the relevant ADRs, the raw task diff, and the verification evidence rather than the implementer's summary. Keep it read-only; a reviewer does not patch the files it is judging. Require each finding to identify its evidence, the violated requirement or invariant, and the consequence. Decide which findings are valid, fix those, and rerun the affected checks.

## Reconcile architecture decisions

Reassess the completed diff against the relevant ADR subset before delivery.

- If it follows an accepted decision, do not edit the ADR merely to restate the implementation.
- If an accepted decision's scope, invariant, consequence, or enforcement pointer became stale, invoke `maintain-architecture-decisions`.
- If the implementation would reverse or contradict accepted intent, stop and return to `clarify-and-plan`; never rewrite the ADR after the fact to justify the code.
- Rerun the conformance gate after any ADR reconciliation and before the selected delivery boundary.

## Stop or deliver at the authorized boundary

Follow [Git and PR guardrails](references/git-and-pr-guardrails.md).

1. For `local-change`, stop after implementation, ADR reconciliation, and verification.
2. For `commit`, stage only task-owned paths or hunks, confirm the staged diff, and create the minimum coherent commit set in repository style. Do not push.
3. For `draft-pr`, perform the commit steps, push the current branch without force, create a draft pull request with a concise summary and exact verification evidence, and query the provider to confirm its URL and draft state.

Never escalate `local-change` to commit or `commit` to push merely because tools and credentials are available. Never force-push, rewrite published history, bypass repository protections, or fabricate a remote result.

Prefer an available purpose-built GitHub integration; otherwise use authenticated `gh`. Do not fabricate a URL when authentication, remote access, or PR tooling is unavailable.

## Report the outcome

Return:

- a concise change summary;
- verification commands and pass/fail results, including the ADR conformance gate;
- any ADR created, revised, superseded, or deliberately left unchanged after reconciliation;
- commit identifier when the boundary included a commit;
- draft pull request URL and confirmed draft state when the boundary was `draft-pr`; or
- the exact blocking condition and completed local state.

If the requested outcome is incomplete, report the precise blocker instead of claiming completion.
