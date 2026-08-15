---
name: lucy
description: Delegate independent, bounded coding tasks to Lucy as an external sub-agent through the lucy exec interface.
---

# Lucy sub-agent

Use Lucy for a self-contained task that can return a useful result without sharing the parent conversation. Good tasks have a narrow scope, explicit constraints, and a verifiable deliverable. Keep tightly coupled work in the parent.

## Delegate

1. Choose an independent, bounded task. State the expected result, allowed files or read-only scope, and checks to run.
2. Set Lucy's working directory deliberately. Prefer a subshell so the parent process does not change directory.
3. Tell Lucy not to delegate further. Do not create recursive Lucy or sub-agent chains.
4. Run `lucy exec` and check its exit status before using its answer.
5. Return only Lucy's final answer and the small amount of metadata the parent needs. Do not paste raw JSONL events, tool calls, or tool output into the parent context.

For a one-shot task, keep the normal final-answer output:

```sh
(
  cd /absolute/path/to/worktree || exit 1
  lucy exec 'Inspect the authentication change. Do not edit files or delegate. Report only concrete correctness risks with file references.'
)
status=$?
if [ "$status" -ne 0 ]; then
  echo "Lucy failed with exit status $status" >&2
  exit "$status"
fi
```

## Continue a session

Request structured output only when the task may need a follow-up. Capture it rather than printing it into the parent transcript, check the exit status, and retain the returned `session_id`:

```sh
result="$(
  cd /absolute/path/to/worktree || exit 1
  lucy exec --output json 'Implement the bounded parser fix in src/parser.rs, run its focused tests, and do not delegate.'
)"
status=$?
if [ "$status" -ne 0 ]; then
  echo "Lucy failed with exit status $status" >&2
  exit "$status"
fi

session_id="$(printf '%s' "$result" | jq -er '.session_id')" || exit 1
```

Resume that exact session for related follow-up work:

```sh
follow_up="$(
  cd /absolute/path/to/worktree || exit 1
  lucy exec --session "$session_id" --output json 'Address the failing focused test, rerun it, and summarize the final diff. Do not delegate.'
)"
status=$?
if [ "$status" -ne 0 ]; then
  echo "Lucy resume failed with exit status $status" >&2
  exit "$status"
fi
```

Decode the structured result outside the model transcript and pass back only the final assistant answer. Never run two processes against the same `session_id` concurrently. Independent sessions may run in parallel only when their work and write scopes do not conflict.

Reserve `--jsonl` for an adapter that intentionally consumes streaming events or manages an interactive multi-turn process. Do not use raw JSONL for ordinary delegation; `lucy exec` is the finite sub-agent boundary.
