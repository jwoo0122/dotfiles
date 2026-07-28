---
name: clarify-and-plan
description: User-facing entry point for a coding workflow that inspects repository and ADR facts, repeatedly resolves material ambiguity, reconciles durable architectural intent, and defines observable acceptance before implementation. Use when the user invokes clarify-and-plan or when a request needs its intent resolved before a change; continue until consequential choices are resolved, then chain internally into ADR maintenance and execution without requiring another user invocation.
---

# Clarify and Plan

Turn an ambiguous request into a bounded implementation brief and reconcile any durable architectural decisions before implementation.

This skill is the sole user-facing entry point for the workflow. Own the workflow from entry through the authorized delivery boundary, and chain into `maintain-architecture-decisions` and `execute-to-pr` internally. Never ask the user to invoke another skill.

## Establish authority before anything else

Record two authority boundaries and keep them fixed unless the user changes them:

```text
mode: read-only | change
delivery_boundary: answer | plan | local-change | commit | draft-pr
```

- Do not turn an explanation, diagnosis, review, research, plan-only, or status request into a repository change.
- When a change request does not mention commit or remote delivery, default to `local-change` without asking. Require explicit user authority for `commit` and `draft-pr`. Permission to edit files never implies permission to commit, push, or open a pull request.
- Stop at a higher-priority instruction, permission, credential, or destructive-action boundary and report the exact boundary.

## Load evidence before asking

Before asking a question:

1. Read active repository instructions and the user's scope limits.
2. Read `adr/index.yaml` when it exists and load only decisions relevant to likely paths, scopes, topics, and linked records. Do not create `adr/` just to begin clarification.
3. When an ADR system exists, run `<maintain-architecture-decisions skill root>/scripts/adr check --root <repository-root>` against the unmodified baseline. A baseline failure is evidence to surface, not a defect caused by the new task.
4. Inspect relevant code, tests, public interfaces, conventions, and Git state.
5. Separate facts established by that evidence from choices only the user can make.

Ask only for unresolved material choices. Do not ask the user to restate an accepted ADR or decide file placement, naming, internal APIs, or conventions that repository evidence already determines.

## Maintain a transient decision queue

For each unresolved choice, track internally:

- the decision and why different answers matter;
- plausible interpretations and their trade-offs;
- dependencies on earlier answers;
- whether it blocks implementation or ADR reconciliation;
- the answer, evidence, or disclosed low-impact assumption;
- affected acceptance checks and ADR IDs.

Keep the queue in conversation or plan state, never in the repository. Reorder it after each answer and after new evidence. Do not create permanent task databases, question logs, or issue records unless the user requests them.

## Run the grilling loop

Repeat until no material ambiguity remains:

1. Select the unresolved choice with the greatest behavioral impact, divergence between answers, and cost of reversing later.
2. Ask dependent questions sequentially so the next question reflects the previous answer.
3. Batch a small set of independent questions when their answers do not constrain one another and answering together reduces needless turns.
4. Offer concrete interpretations and the material trade-off instead of asking a broad preference question.
5. If an answer remains vague, contradicts earlier intent, or conflicts with repository evidence or an accepted ADR, narrow the distinction and ask again.
6. Infer or disclose a reversible, low-impact assumption when it does not materially change the result.
7. Reinspect the repository or ADRs whenever an answer exposes a fact that can be verified there.

Do not target a fixed number of questions, and do not treat request size alone as a reason to ask or to skip asking. Do not start implementation because the interview feels long. Also do not continue asking once remaining uncertainty is immaterial, assumptions are visible, and acceptance can distinguish success from failure.

Read [the grilling loop](references/grilling-loop.md) when answers remain vague, decisions multiply, or the stopping condition is unclear.

## Reconcile architectural intent

After the user resolves consequential choices, determine whether any answer expresses persistent architectural intent that code inspection alone could not reliably recover and that future changes should respect.

- Use `none` for local implementation choices and routine bug fixes.
- Use `reference` when an existing ADR already expresses the governing intent.
- Use `reconcile` when the same decision needs improvement or revision, a genuinely new decision question exists, or an accepted decision is superseded or retired.
- Prefer revising the record that owns the same decision question over creating a chronological duplicate.
- Preserve explicit relationships when a decision is split, merged, challenged, or reversed.
- Never silently violate, rewrite, or bypass an accepted decision to make the requested change easier.

When `mode=change`, activate `maintain-architecture-decisions` and reconcile the records before implementation. Keep ADR writes under this single coordinator role. For a read-only or plan-only request, include the proposed ADR action in the brief without mutating the repository.

Do not let ADR reconciliation silently decide an unresolved product or architecture choice. Return to the grilling loop instead.

## Produce the implementation brief

Skip this section when the delivery boundary is `answer`; a read-only request is answered with evidence, not with a brief. Otherwise state a compact handoff:

```text
Goal:
Required behavior:
Constraints and non-goals:
Assumptions:
Acceptance checks:
Relevant ADR IDs and invariants:
ADR action:
Delivery boundary:
Implementation units:
```

Map every important behavior to an observable automated check or, when automation is disproportionate, an explicit manual check. Prefer existing tests, regression tests, type checks, linters, builds, and concrete API, CLI, UI, data, or performance assertions.

## Exit and continue

Exit only when:

- no material blocking decision remains;
- contradictions and accepted-ADR conflicts are resolved or explicitly blocked;
- assumptions and non-goals are visible;
- the outcome is bounded and acceptance checks can distinguish success from failure;
- durable architectural intent is reconciled or proposed within the authorized scope; and
- implementation units have enough context to start.

Then continue according to the authorized delivery boundary:

- For `answer`, perform the bounded inspection yourself, return the evidenced answer, and report any proposed ADR action without mutating the repository. Do not produce an implementation brief and do not activate an implementation stage.
- For `plan`, return the brief itself as the deliverable, including the proposed ADR action, and stop.
- For `local-change`, `commit`, or `draft-pr`, activate `execute-to-pr` immediately with the brief, the relevant ADR subset, and the explicit delivery boundary.

Ask again only when required authority or a material decision is still missing, or when the next action is irreversible, destructive, or scope-expanding beyond what the user authorized. If implementation later exposes a new material ambiguity, return to this loop.
