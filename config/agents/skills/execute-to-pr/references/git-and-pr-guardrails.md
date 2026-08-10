# Git and PR guardrails

## Before staging

- Compare current status with the baseline captured before edits.
- Inspect every candidate path and use hunk-level staging when a file mixes user and task changes.
- Exclude local configuration, credentials, logs, caches, and temporary artifacts.

## Before committing

- Inspect the staged diff, not only the working-tree diff.
- Confirm staged tests actually exercise the requested behavior.
- Do not amend or squash commits you did not create unless the user explicitly requests history editing.

## Before pushing

- Confirm the branch is not the protected/default branch unless repository policy explicitly allows it.
- Confirm the upstream remote is the intended repository.
- Never use `--force` or `--force-with-lease` in this workflow.

## Draft pull request body

Include:

```markdown
## Summary
- <behavioral change>

## Verification
- `<command>` — passed

## Notes
- <assumption, limitation, or manual check, if any>
```

Use the repository's PR template when present. Keep template-required sections and fill them rather than replacing the template.

After creation, query the PR through the same provider and verify that it is a draft.
