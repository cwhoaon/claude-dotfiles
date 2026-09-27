<!-- research-sync:start -->
# Research context

Research context lives in `docs/research/`. This directory is a **separate git repo** and is gitignored by the parent repo.

@docs/research/idea.md
@docs/research/open_questions.md

`decisions.md` and `experiments.md` grow long and are not auto-loaded. Read them directly when you need past rationale or results.

## Research rules
- Follow the tags in `idea.md`: `[confirmed]` may be used as a premise, `[hypothesis]` is under test, `[rejected]` must **never** be used as a premise for code.
- If an implementation seems to conflict with the documented hypotheses or method, point it out before writing code.
- Never guess or fabricate experimental numbers. If unknown, write `TBD`.
- Propose any change to `docs/research/` as a diff first, and apply it only after approval.
- Do not run git commands on `docs/research/` outside `/log-exp`, `/sync-out`, and `/tidy-notes`, which commit their own changes. Never push.
- Session routine (user-invoked skills; suggest them to the user, do not reproduce their steps): start `/sync-in` · after experiments `/log-exp` · before ending `/sync-out` · periodically `/tidy-notes`.
<!-- research-sync:end -->
