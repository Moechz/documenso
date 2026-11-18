# Changelog

All notable user-visible changes to the Documenso TOS application package.

## 2.22.0-3 — 2026-11-18

### Fixed
- Re-submitted for the listing review of `2.22.0-1`; `2.22.0-2` was withdrawn so that only
  one version is under review at a time.
- Chinese (`zh-cn`, `zh-hk`) descriptions described a completely different application — a
  leftover from the packaging template. They now describe Documenso, its first-start
  behaviour and the data location (the C9/F5 finding).
- The wrapper now generates the two data-encryption keys
  (`NEXT_PRIVATE_ENCRYPTION_KEY`, `NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY`) on first start.
  Without them every background job aborted with “Missing encryption key” (visible in
  `docker logs documensodocker`), so document sealing, signing reminders and recipient
  expiry did not run.
- Key material in `/data` is created with `umask 077` (`0600`); files written by an older
  iteration are tightened on start-up.
- Health check now probes `/api/health`, which reports the database and the signing
  certificate, instead of `/` (the landing page answered 302 while the database was still
  migrating).
- The stale compose header comment (personal mirror) and the copied `probe` block in
  `tosapp.json` (beaverhabits digest/cmd) were replaced with the real image metadata.
- README: image, release tag, asset names and the runtime file manifest brought in line
  with `2.22.0-3`.

### Changed
- `config.ini` `help` now points at the privacy policy
  (`https://github.com/Moechz/documenso/blob/main/PRIVACY.md`), so the policy travels with
  the package metadata; the issue tracker link stays in the README and the website copy of
  the policy is linked from the app description.

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
