# Security scanning configuration

Configuration for the three scanners the [CI/CD standard](../../standards/ci-cd.md)
requires. Each file is copied to the **root** of a repository, where the scanner
finds it automatically, both locally and in the reusable
[`security.yml`](../../.github/workflows/security.yml) workflow.

| File | Tool | Requirement | Gate |
| --- | --- | --- | --- |
| [`.gitleaks.toml`](.gitleaks.toml) | [gitleaks](https://github.com/gitleaks/gitleaks) | K22-CI-20 | Any secret, anywhere in history |
| [`trivy.yaml`](trivy.yaml) | [Trivy](https://trivy.dev/) | K22-CI-21 | HIGH or CRITICAL vulnerability in a lock file |
| — | [OSV-Scanner](https://google.github.io/osv-scanner/) | K22-CI-21 | Any dependency flagged malicious (`MAL-` advisory) |
| [`zizmor.yml`](zizmor.yml) | [zizmor](https://docs.zizmor.sh/) | K22-CI-23 | Workflow finding of medium severity or above |
| — | [actionlint](https://github.com/rhysd/actionlint) | K22-CI-23 | Any workflow error |

## Installing the tools

| Tool | Windows | macOS | Linux |
| --- | --- | --- | --- |
| gitleaks | `winget install Gitleaks.Gitleaks` | `brew install gitleaks` | release binary |
| Trivy | `winget install AquaSecurity.Trivy` | `brew install trivy` | release binary |
| zizmor | `uv tool install zizmor` | `brew install zizmor` | `uv tool install zizmor` |
| actionlint | `winget install rhysd.actionlint` | `brew install actionlint` | release binary |
| OSV-Scanner | `winget install Google.OSVScanner` | `brew install osv-scanner` | release binary |

On Windows, winget puts command shims in `%LOCALAPPDATA%\Microsoft\WinGet\Links`.
If `trivy` or `actionlint` is not found in an already-open shell, open a new one or
add that folder to `PATH`.

## Running them locally

Run from the repository root; these are the same checks CI runs.

```sh
gitleaks git . --redact --verbose          # every commit
gitleaks dir . --redact                    # working tree, including uncommitted files
trivy fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 .
osv-scanner scan source --recursive .     # look for MAL- IDs: malicious packages
zizmor --min-severity medium .
actionlint
```

The pre-commit configuration in [`configs/pre-commit`](../pre-commit) runs gitleaks,
zizmor, and actionlint on every commit, so most findings never reach CI.

## Handling findings

- **Secret found:** rotate it first, then remove it. Rewriting history does not
  un-leak a pushed secret ([K22-REPO-04](../../standards/repository.md#required-files)).
- **Vulnerable dependency:** update it. If no fixed version exists and the code path
  is not reachable, record an exception and add a dated `.trivyignore` entry citing it.
- **Malicious package:** remove it immediately, treat every machine and CI run that
  installed it as compromised, and rotate any credential those environments could
  reach. A `MAL-` finding is never excepted.
- **Workflow finding:** fix the workflow. zizmor's documentation for each audit
  explains the safe pattern.

## Pinned scanner versions

The reusable workflows run gitleaks, Trivy, and OSV-Scanner as containers pinned by
digest, and zizmor and actionlint by exact version with checksum verification.
Dependabot updates pinned actions; the container digests in the workflows are bumped
with each standards release:

| Scanner | Pinned as |
| --- | --- |
| gitleaks | `ghcr.io/gitleaks/gitleaks:v8.30.1@sha256:c00b6bd0…` |
| Trivy | `ghcr.io/aquasecurity/trivy:0.75.0@sha256:af6acf9a…` |
| OSV-Scanner | `ghcr.io/google/osv-scanner:v2.6.0@sha256:afd83885…` |
| zizmor | `uvx zizmor@1.30.1` |
| actionlint | `1.7.12`, SHA-256 verified |
