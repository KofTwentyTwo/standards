# {{PROJECT_NAME}}

{{ONE_LINE_DESCRIPTION}}

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/KofTwentyTwo/{{REPO}}/badge)](https://scorecard.dev/viewer/?uri=github.com/KofTwentyTwo/{{REPO}})
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

| | |
| --- | --- |
| **Tier** | Product <!-- or Internal; see KofTwentyTwo standards policies/README.md#scope --> |
| **Standards** | Conforms to [KofTwentyTwo standards](https://github.com/KofTwentyTwo/standards) {{STANDARDS_VERSION}} |
| **Latest release** | [Releases](https://github.com/KofTwentyTwo/{{REPO}}/releases/latest) |

## Install

{{How to get the released software: download, package manager, or dependency line.}}

## Usage

{{User guide for all basic functionality, or a link to it.}}

## Building from source

Prerequisites:

- {{toolchain and version, e.g. .NET 10 SDK (pinned by global.json)}}
- {{other SDKs, frameworks, or system libraries}}

```sh
{{build command}}
{{test command}}
```

Dependencies are declared in {{manifest}} and locked in {{lock file}}; see
[CONTRIBUTING.md](CONTRIBUTING.md) for the full local workflow.

## Verifying a release

Every release asset has a build-provenance attestation and is listed in
`SHA256SUMS`:

```sh
gh attestation verify <asset> --repo KofTwentyTwo/{{REPO}}
sha256sum --check SHA256SUMS
```

## Support

{{Which versions are supported and until when; must match SECURITY.md.}}

## Security

Report vulnerabilities privately; see [SECURITY.md](SECURITY.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) © {{YEAR}} James Maes
