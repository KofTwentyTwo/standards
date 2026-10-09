#!/usr/bin/env bash
# macOS and Linux bootstrap for a KofTwentyTwo workstation (standards/workstation.md).
# Installs Homebrew and PowerShell 7 if needed, then runs Install-Workstation.ps1 from
# the same ref of KofTwentyTwo/standards, passing through every argument.
#
#   curl -fsSL https://raw.githubusercontent.com/KofTwentyTwo/standards/main/setup/bootstrap.sh | bash -s -- -Languages dotnet
#
# Set K22_REF to a release tag for a reproducible setup.
set -euo pipefail

ref="${K22_REF:-main}"
os="$(uname -s)"

if ! command -v brew > /dev/null 2>&1; then
   echo "Installing Homebrew..."
   # Captured first so a failed download stops the script (set -e) instead of running nothing.
   installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   NONINTERACTIVE=1 /bin/bash -c "${installer}"
   for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
      if [[ -x "${candidate}" ]]; then
         environment="$("${candidate}" shellenv)"
         eval "${environment}"
         break
      fi
   done
fi

if ! command -v pwsh > /dev/null 2>&1; then
   echo "Installing PowerShell 7..."
   if [[ "${os}" == "Darwin" ]]; then
      brew install --cask powershell
   else
      echo "Install PowerShell 7 for your distribution, then run this again:" >&2
      echo "  https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-linux" >&2
      exit 1
   fi
fi

script="$(mktemp -t install-workstation.XXXXXX).ps1"
trap 'rm -f "${script}"' EXIT
url="https://raw.githubusercontent.com/KofTwentyTwo/standards/${ref}/setup/Install-Workstation.ps1"
echo "Downloading ${url}"
curl -fsSL "${url}" -o "${script}"

pwsh -NoLogo -NoProfile -File "${script}" "$@"
