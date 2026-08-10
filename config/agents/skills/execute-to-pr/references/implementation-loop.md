# Implementation loop

Use this discipline when production behavior or its tests must change.

## Select the observable seam

Prefer an existing public API, CLI boundary, user-visible DOM/accessibility surface, persistence boundary, or stable module interface. Do not invent a new seam only to make a test convenient. Infer established seams from the repository and relevant ADRs; ask the user only when choosing a seam would change a public contract or durable architectural intent.

## Work in vertical red-green slices

1. Establish a check that can fail for the missing behavior. For a bug, reproduce it when practical.
2. Observe the check fail for the expected reason.
3. Make the smallest production change that satisfies that behavior.
4. Observe the targeted check pass.
5. Continue with the next independently observable behavior.

Avoid tests coupled only to private implementation details, mocks that merely repeat the production code, and assertions that would pass without the requested behavior.

## Preserve design quality

- Keep interfaces smaller than the implementation hidden behind them.
- Put behavior behind an existing boundary when one already owns it.
- Create a new boundary only when it localizes a durable concept or policy, not for speculative flexibility.
- Prefer changes that can later be deleted or replaced behind one seam.
- Follow accepted ADR invariants and surface conflicts before implementation.

Run narrow checks while iterating and all applicable repository gates before delivery.
