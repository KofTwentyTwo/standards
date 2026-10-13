# MSI builder release recovery

The signed v1.2.0 tag is reserved by a preflight failure: its annotation omitted
the required MINOR-release checklist. No1.2.0 assets were published. Preserve
that tag and recover through a new1.2.1 release proposal and signed tag.

The optional MSI implementation is unchanged from merged PR47. Hosted checks
and40 signing regressions pass; native MSI compilation and the actual wrapped
extraction body preserve all6 signed fixture application binaries. Production
MSI signing, installation and distributed-payload verification remain mandatory.

Before tagging the recovery, complete and link the release checklist, retain full
conformance/scanning evidence and verify main/release-proposal gates. Include the
checklist URL in the signed annotation even for this PATCH recovery. Publish only
after its protected deployment and verify all actual bundle hashes/provenance.

This preserves existing EXE callers, signing identity/profile/trust, branch/tag
protections and public1.1.2 assets. No account onboarding is repeated.
