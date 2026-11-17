# Changelog

All notable user-visible changes to the Documenso TOS application package.

## 2.22.0-2 — 2026-11-17

### Changed
- Official Docker Hub image `documenso/documenso:v2.22.0` replaces the personal mirror
  (trusted registry).
- Telemetry disabled by default (`DOCUMENSO_DISABLE_TELEMETRY=true`) and disclosed in the
  privacy policy.
- A self-signed PKCS#12 signing certificate is generated on first start, so document
  signing works without manual setup; replace `data/signing.p12` to use your own.
- Health check start period raised to 180 s for the first database migration.
- Description aligned with the delivered functionality (official image, certificate,
  SMTP note).
- Added `PRIVACY.md`, `NOTICE.md` and the README compliance sections.

## 2.22.0-1 — 2026-11-14

### Added
- First release. Documenso (`moechz/documenso:v2.22.0`, Docker Hub official image, unmodified)
  packaged as a TOS 7 Docker application, published on port 8155 and running
  as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/documensodocker/`.
