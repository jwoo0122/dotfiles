# Architecture decisions

This directory is a living map of architectural intent, not a chronological decision log.

- Read `index.yaml` first and load only relevant records.
- Preserve `.adr-system.yaml`; it identifies the owning schema and version.
- Name records by stable decision question: `records/<scope>/<question>.md`.
- Improve or revise an existing record when its question is unchanged.
- Create a record only for a new architectural question.
- Treat accepted decisions as current but revisable intent.
- Keep supersession links bidirectional.
- Declare deterministic source checks in each accepted record under `enforcement`, or document an explicit `enforcement_exception` with status, reason, evidence, and revisit conditions.
- Run `skills/maintain-architecture-decisions/scripts/adr check` after `validate`; it reads the declared repository files and exits non-zero on a mismatch or undocumented exception.
- Rebuild and validate the index with `skills/maintain-architecture-decisions/scripts/adr` after edits. The launcher selects a Python interpreter that can import PyYAML and does not install packages.

Records capture intent that code alone does not reliably reveal. Local implementation details and routine changes do not belong here.
