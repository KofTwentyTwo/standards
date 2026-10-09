# Contributing to {{PROJECT_NAME}}

Thanks for helping. This project follows the
[KofTwentyTwo standards](https://github.com/KofTwentyTwo/standards); this page is the
short version of what they ask of a contribution.

## Before you start

For anything beyond a small fix, open an issue first so the approach can be agreed
before you invest time. Questions and proposals are welcome in
[Issues](https://github.com/KofTwentyTwo/{{REPO}}/issues).

## Setup

{{Prerequisites, and the exact commands to build, test, and check formatting. These
are the same commands CI runs.}}

```sh
{{build}}
{{test}}
{{format / lint check}}
```

Install the git hooks once per clone. They run the same secret, workflow, and
commit-message checks CI does:

```sh
pre-commit install --hook-type pre-commit --hook-type commit-msg
```

## Workflow

1. Branch from `main` with a short-lived topic branch named `<type>/<short-description>`,
   for example `feat/export-csv` or `fix/42-crash-on-empty-folder`.
2. Commit with [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
   (`feat: ...`, `fix(scope): ...`). Every commit is **signed** and **signed off**:
   `git commit -S -s` (see *Sign-off* below).
3. Open a pull request against `main`. Its title must itself be a Conventional Commit
   header: pull requests are **squash-merged**, so the title becomes the commit
   message on `main`.
4. Every required check must pass, and every review thread must be resolved, before
   the pull request merges.

## What makes a contribution acceptable

- The build has **zero warnings**, and format and lint checks are clean.
- New behavior has tests; a bug fix has a test that fails without the fix.
- Coverage does not drop below the project's gate.
- User-visible changes update the docs in the same pull request.
- No secrets, credentials, or personal data, ever.
- New dependencies are justified in the pull request description.

## Checks that gate a merge

| Check | What it verifies |
| --- | --- |
| `pr / title` | The PR title is a Conventional Commit header |
| `pr / dco` | Every commit is signed off |
| `pr / dependency-review` | Added dependencies have no known vulnerabilities and an allowed license |
| `security / secrets`, `security / sca`, `security / workflows` | No secrets, no vulnerable dependencies, safe workflows |
| `codeql / analyze (...)` | No high-severity static analysis findings |
| {{language checks, e.g. `ci / build-test`}} | {{build, tests, coverage, format}} |

## Sign-off (Developer Certificate of Origin)

By signing off a commit you certify the
[Developer Certificate of Origin 1.1](https://developercertificate.org/): that you
wrote the change, or otherwise have the right to submit it under the project's
license. `git commit -s` appends the sign-off:

```text
Signed-off-by: Your Name <your.email@example.com>
```

The name and email must match the commit author. To add missing sign-offs to a
branch, run `git rebase --signoff main` and force-push the branch.

## AI-assisted contributions

AI coding tools are welcome. You remain the author: you must understand, test, and be
able to explain every line you submit, and you sign it off as your own. Note
substantial AI assistance in the pull request description.

## License

By contributing, you agree that your contributions are licensed under the project's
[MIT License](LICENSE).
