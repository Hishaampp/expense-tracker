# Working on this repository

## Branches

The project uses GitHub Flow.

- `main` is always green and always releasable. Nobody commits to it
  directly; changes arrive through pull requests.
- Every piece of work gets its own short-lived branch from `main`:

| Prefix | For | Example |
|---|---|---|
| `feature/` | New behaviour | `feature/phase-3-android-capture` |
| `fix/` | A bug fix | `fix/paste-duplicate-ref` |
| `chore/` | Tooling, CI, dependencies | `chore/git-workflow` |
| `docs/` | Documentation only | `docs/privacy-policy` |
| `refactor/` | Code change with no behaviour change | `refactor/quick-add-state` |

A large phase may be split into several feature branches, each with its
own pull request.

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(capture): queue Android notifications natively
fix(parser): ignore bank names inside UPI ids
test(home): cover the 2x text layout
chore(ci): run the parser package tests
docs(design): record where Back sits
```

Keep each commit focused, and explain why in the body when it isn't
obvious.

## Pull requests

1. Push the branch and open a pull request into `main`.
2. Fill in the template: what and why, how it was checked, screenshots for
   UI changes, and the privacy checklist.
3. The `ci` check must pass. It runs `tool/ci.sh`, the same script you run
   locally.
4. Merge with **Squash and merge**, so `main` gets one commit per pull
   request. Then delete the branch.

## Versions and tags

Each completed phase is tagged on `main` with an annotated tag:

| Tag | Phase |
|---|---|
| `v0.0.1` | 0: project setup |
| `v0.1.0` | 1: core money tracking and redesign |
| `v0.2.0` | 2: parser, paste and share |
| `v0.3.0` | 3: Android auto-capture |
| … | … |
| `v1.0.0` | 8: first store release |

The app's version in `pubspec.yaml` follows the tag.

## Before you push

```bash
tool/ci.sh
```

It checks generated code and the database schema snapshot, formatting,
the analyzer (infos count as errors), all tests in random order, the parser
package's tests, and the Android manifests (no SMS permissions in `play`, no
internet in any release build).
