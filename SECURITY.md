# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| latest  | Yes       |
| < latest| No        |

Only the latest released version receives security patches.

## Reporting a Vulnerability

The Coinbase team takes security seriously. Please do not file a public issue.

Report vulnerabilities through our [HackerOne program](https://hackerone.com/coinbase)
or via [GitHub private vulnerability reporting](https://github.com/coinbase/cdp-swift/security/advisories/new).

## CVE Patch SLA

| Severity | Patch Deadline | Action                   |
|----------|----------------|--------------------------|
| Critical | 72 hours       | Hotfix release, advisory |
| High     | 7 days         | Patch release, advisory  |
| Medium   | 30 days        | Next scheduled release   |
| Low      | 90 days        | Best effort              |

Timelines start from confirmed vulnerability, not initial report.

## Supply Chain Security

Every release includes:
- **SBOM** (CycloneDX): Lists all bundled dependencies with versions and hashes
- **SBOM signature** (cosign): Cryptographic attestation via Sigstore
- **XCFramework signature** (cosign): Signed xcframework zip via Sigstore
- **SLSA provenance**: Build provenance attestation via GitHub Artifact Attestations
- **SCA scan**: All dependencies checked against NVD/OSV before release
- **Code signing**: XCFramework signed with Apple Developer ID

Release assets attached to each GitHub Release:
- `CDPCore.xcframework.zip` — Signed xcframework binary
- `CDPCore.xcframework.zip.bundle` — cosign signature for xcframework
- `CDPCore.dSYMs.zip` — Debug symbols
- `cdpcore-<version>.cdx.json` — CycloneDX SBOM
- `cdpcore-<version>.cdx.json.bundle` — cosign signature for SBOM

### Verify XCFramework Signature

```bash
cosign verify-blob \
  --bundle CDPCore.xcframework.zip.bundle \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp "github.com/coinbase/cdp-swift-internal" \
  CDPCore.xcframework.zip
```

### Verify SLSA Build Provenance

```bash
gh attestation verify CDPCore.xcframework.zip --repo coinbase/cdp-swift-internal
```

This confirms the artifact was built by the official CI pipeline from the source repository.

### Verify SBOM Signature

```bash
cosign verify-blob \
  --bundle cdpcore-<version>.cdx.json.bundle \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp "github.com/coinbase/cdp-swift-internal" \
  cdpcore-<version>.cdx.json
```
