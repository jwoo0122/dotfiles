# Grilling loop

Use this reference when consequential ambiguity survives the first question or the stopping condition is uncertain.

## Find material choices

Prioritize choices about:

- externally visible behavior and failure semantics;
- domain or system ownership and authoritative data;
- compatibility, migration, retention, and deletion;
- security, privacy, reliability, and performance invariants;
- boundaries between services, packages, deployment units, or external consumers;
- measurable acceptance and scope choices that multiply implementation cost.

Infer file placement, naming, package commands, formatting, established internal APIs, and other low-cost implementation details from repository evidence.

## Respect question dependencies

Ask sequentially when a later question's valid options depend on an earlier answer. For example, establish the system of record before asking how replicas behave during failure.

Batch independent questions when each can be answered without knowing the others. Keep the batch focused on consequential choices; do not turn it into a general questionnaire.

## Recover from vague or conflicting answers

1. Restate the most plausible interpretations.
2. Name the single consequence that differs between them.
3. Ask for the missing condition or a choice between those interpretations.
4. If the answer conflicts with code or an ADR, show the concrete conflict and determine whether the evidence is stale or the intended decision changed.

Do not repeat the original broad question, silently select an interpretation, or rewrite an ADR to make the conflict disappear.

## Test whether grilling can stop

Stop when all are true:

- another reasonable interpretation would not materially change behavior, scope, risk, compatibility, or acceptance;
- remaining assumptions are reversible, low impact, and disclosed;
- important behavior has an observable success or failure check;
- relevant accepted ADRs are either followed or deliberately reconciled; and
- implementation units are bounded and can be started independently.

Continue when any material decision is merely implied, an answer still admits divergent outcomes, or implementation would force a worker to invent product or architectural intent.

## Make acceptance observable

| Vague outcome | Observable boundary |
|---|---|
| “Fast enough” | A named workload and agreed latency or throughput threshold |
| “Handles errors” | A named failure returns a specific result and leaves specified state unchanged |
| “Looks correct” | A DOM, accessibility, or screenshot assertion at named viewports |
| “Backward compatible” | Existing contract checks plus a fixture for the prior public input |
| “Secure” | Named actors, protected capability or data, and denied/allowed outcomes |
