# pre-commit configuration

[`.pre-commit-config.yaml`](.pre-commit-config.yaml) is the local half of the CI gates:
it stops secrets, unsafe workflows, malformed commit messages, and unsigned-off
commits before they leave your machine. It works with
[pre-commit](https://pre-commit.com/) and with its faster drop-in
[prek](https://github.com/j178/prek).

## One-time setup per machine

```sh
uv tool install pre-commit        # or: brew install pre-commit / prek
```

Sign every commit (required by `protect-main`, [K22-REPO-20](../../standards/repository.md#branch-and-tag-protection)).
SSH signing is the simplest; use the same key you push with or a dedicated one:

```sh
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

Then add the **public** key to GitHub as a **Signing key** (Settings → SSH and GPG
keys → New SSH key → Key type: Signing key), so GitHub shows commits as *Verified*.

Sign off every commit for the DCO ([K22-CI-01](../../standards/ci-cd.md#required-checks)):
use `git commit -s`, or make it automatic for a repository with a
`prepare-commit-msg` hook, or set an alias:

```sh
git config --global alias.cs "commit -s"
```

## Setup per repository

Copy `.pre-commit-config.yaml` to the repository root, uncomment the blocks for its
languages, and install both hook types:

```sh
pre-commit install --hook-type pre-commit --hook-type commit-msg
pre-commit run --all-files        # first run, and after changing the config
```

## Keeping hooks current

```sh
pre-commit autoupdate --freeze    # updates and re-pins every hook to a commit SHA
```

Review the diff like any other dependency update before committing it.

## What runs when

| Stage | Hooks |
| --- | --- |
| `pre-commit` | file hygiene, no direct commits to `main`, gitleaks, zizmor, actionlint, language hooks |
| `commit-msg` | Conventional Commits header, DCO `Signed-off-by` line |
