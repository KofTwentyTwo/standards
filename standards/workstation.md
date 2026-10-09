# Workstation standard

How a machine used to write, sign, or release KofTwentyTwo software is set up. The
[`setup/`](../setup) scripts implement this standard on Windows, macOS, and Linux and
check a machine against it; running them is the expected way to comply.

## Setup

**K22-WS-01 (MUST)** A development machine is set up, and re-checked after major
changes and at the annual access review, with `setup/Install-Workstation.ps1`
(through the bootstrap for its OS). A machine that cannot run it meets each requirement
below by hand.
*Why:* one repeatable setup instead of a checklist from memory. *Verified by:*
`Install-Workstation.ps1 -CheckOnly`.

**K22-WS-02 (MUST)** These tools are installed and kept current: git, GitHub CLI,
PowerShell 7, uv, Node.js LTS, gitleaks, Trivy, OSV-Scanner, actionlint, zizmor,
pre-commit, 1Password, and the 1Password CLI, plus the toolchain of every language
profile the maintainer works in.
*Why:* the local hooks and checks are the same ones CI runs
([`K22-CI-03`](ci-cd.md#required-checks)). *Verified by:* `-CheckOnly`.

## Keys and secrets live in 1Password

1Password is KofTwentyTwo's password manager and SSH agent. Keys are **created in
1Password** and never exist as files.

**K22-WS-10 (MUST)** Every SSH key (GitHub authentication, commit signing, deploy keys,
server access) is generated inside 1Password and used through the 1Password SSH agent.
No private key is stored in `~/.ssh` or anywhere else on disk; a key found on disk is
moved into 1Password (import it, or replace it with a new key) and the file deleted.
*Why:* a key file can be copied by any process running as the user, by backups, and by
malware; a key in 1Password is released only through the agent, with the user's
approval. *Verified by:* `-CheckOnly` (private keys on disk). *Maps to:*
[`K22-SEC-14`](../policies/security-program.md#secrets-and-credentials).

**K22-WS-11 (MUST)** Commits and tags are signed with an SSH key from 1Password
(`gpg.format = ssh`, `gpg.ssh.program` = 1Password's `op-ssh-sign`), and that key is
registered on GitHub as a **signing** key.
*Why:* *Verified* commits ([`K22-SDLC-14`](../policies/sdlc.md#build)) without a signing
key on disk. *Verified by:* `-CheckOnly` (git signing); GitHub shows the commit as
Verified.

**K22-WS-12 (MUST)** Secrets a tool needs at run time (API tokens, registry keys) are
read from 1Password when needed, with `op run`, `op read`, or `op://` references in an
environment file, never stored in shell profiles, `.env` files, or tool configuration.
*Why:* nothing to leak from a dotfile or a screen share. *Verified by:* gitleaks; review.

**K22-WS-13 (SHOULD)** The 1Password SSH agent is configured to ask for approval per
application, and 1Password locks with the operating system.
*Why:* a malicious process cannot silently use a key. *Verified by:* annual review.

## Machine security baseline

**K22-WS-20 (MUST)** The machine meets the [security program](../policies/security-program.md#development-environment)
baseline: full-disk encryption (BitLocker, FileVault, or LUKS), firewall on, malware
protection on (Windows), automatic OS updates, and a screen lock.
*Why:* a lost or compromised workstation must not expose source, sessions, or keys.
*Verified by:* `-CheckOnly` (disk encryption, firewall, malware protection).

## Running the setup

| OS | Command |
| --- | --- |
| Windows | `& ([scriptblock]::Create((irm https://raw.githubusercontent.com/KofTwentyTwo/standards/main/setup/bootstrap.ps1)))` |
| macOS, Linux | `curl -fsSL https://raw.githubusercontent.com/KofTwentyTwo/standards/main/setup/bootstrap.sh \| bash` |

Add arguments after the command, for example `-Languages dotnet,java -SigningKey GitHub
-RegisterSigningKey`. See the [README](../README.md#set-up-your-machine) for the
options, the inspect-before-running variant, and pinning to a release.

On Linux the script installs tools with Homebrew; install 1Password and PowerShell 7
from their official Linux packages first
([1Password](https://support.1password.com/install-linux/),
[PowerShell](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-linux)).
