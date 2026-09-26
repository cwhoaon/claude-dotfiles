# Coding rules (deep learning research code)

## 1. Reuse before writing
Near-duplicate code makes experiments hard to compare.
- Search for existing implementations first; reuse or extend them.
- Never create a second version of: data loading/preprocessing, model construction,
  train/eval loops, metrics, checkpointing, logging, visualization/debug utilities.
- Put new logic in the best-fitting module, or a small new module with one responsibility.
- Keep entry-point scripts thin (argument parsing and wiring only).
- If a file would grow too large or mix responsibilities, refactor it slightly first.

## 2. Simplicity and surgical changes
- Minimum code that solves the problem: no unrequested features, options, or abstractions,
  and no handling for impossible cases.
- Every changed line should trace to the request. Match the existing style.
- Don't reformat or "improve" adjacent code; mention unrelated issues instead of fixing them.
- Remove only what your own change made unused; leave pre-existing dead code.

## 3. PyTorch code
- Annotate tensor shapes with named dims, e.g. `# (B, T, D)`; define each dim letter once.
- No hidden broadcasting: make it explicit with `unsqueeze`, `expand`, or `einsum`.
- In `forward()`, trace every step with a shape comment, so the full pass is readable top to bottom.
- Comment the purpose of each step, not the obvious syntax. Favor readability over cleverness.
- Point out numerical-stability issues where relevant (log-sum-exp, eps placement, fp16/bf16
  overflow, normalization) and how the code handles them.

## 4. Experiment integrity
- Don't change default hyperparameters, seeds, data splits, preprocessing, or metric
  definitions unless asked. If existing results would change, say so and keep the old default.
- Don't use the test split for tuning or model selection.
- Check changes with the cheapest run that exercises them (unit test, tiny-batch
  forward/backward, a few debug steps), not full training.

## 5. Definition of done
Turn non-trivial requests into a checkable goal before starting:
- Bug fix: a test or script reproducing the bug now passes.
- Feature: a test or smoke run exercising it passes.
- Refactor: tests pass, and outputs match the old code on a fixed seed and batch.

Finish the whole task; no stubs or TODOs in place of requested functionality.

## 6. Coding summary
In the final summary of a coding task, also state which existing code you reused and where
the new logic went.
