# Decision policy

## Record durable intent

Record a decision when both conditions hold:

1. It constrains future changes across a boundary, owner, protocol, data lifecycle, security property, infrastructure choice, or system-wide quality attribute.
2. A capable future agent could not reliably reconstruct the intended constraint by inspecting the code alone.

Question size and diff size are not criteria. A one-line authority change can require an ADR; a large mechanical migration can merely reference one.

## Preserve stable questions

Each record owns one stable question. Prefer improving or revising that record over adding another document. Create a new semantic ID only when a new question appears or an old question must be split or merged.

Use these statuses:

- `proposed`: an explicit candidate not yet authoritative.
- `accepted`: current intent that implementations must respect.
- `superseded`: replaced by one or more linked records.
- `retired`: no longer applicable because its context disappeared.

For supersession, populate `supersedes` on the replacement and `superseded_by` on the replaced record. Keep both relations consistent. A chain may retain `superseded` intermediate records, but every terminal replacement must be `accepted`; a `proposed` or `retired` record cannot displace current intent.

## Write useful content

- Phrase the current decision and invariants normatively.
- Record only alternatives future agents are likely to reconsider.
- Name tests, linters, schemas, or review points that enforce the decision.
- For accepted records, declare at least one repository-relative `enforcement` check when a deterministic source assertion is available. Use `must_contain` and `must_not_contain` for explicit tokens, and keep behavioral meaning in tests or other executable checks.
- When deterministic enforcement is not appropriate, declare `enforcement_exception` with `manual`, `not-applicable`, or `deferred` status, a concrete reason, evidence, and observable revisit conditions. Never leave an accepted ADR silently unenforced.
- State observable conditions that justify reopening the decision.
- Keep implementation narration and chronological meeting notes out of the record.

## Resolve conflicts

When code conflicts with an accepted record, determine whether the code is wrong or the intent changed. Fix code when the record still represents the user's intent. Revise or supersede the ADR only after the changed intent is established. If neither is supported, return `clarify` rather than choosing silently.
