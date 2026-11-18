# documenso-for-tos

> TerraMaster TOS 7 App Center — **Docker application** package for
> [Documenso](https://github.com/documenso/documenso).

## What this is

A four-file TOS Docker application archive (`documensodocker.tar.gz`) that installs
Documenso on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`, id `documensodocker`)
- `documensodocker.lang` — 23-language superset (TOS requires 14)
- `documensodocker.svg` — application icon (274 bytes, 2 SVG elements)
- `docker-compose.yml` — two services (Documenso + PostgreSQL), image
  `documenso/documenso:v2.22.0`

## How it works

| | |
|---|---|
| Container image | `documenso/documenso:v2.22.0` (Docker Hub, the official upstream image, used unmodified; amd64) |
| Open | `http://<NAS-IP>:8155/` (container port 3000) |
| Runs as | non-root, `user: "1000:1000"` |
| Persistent data | `/data` → `/Volume1/DockerAppData/documensodocker/data`, `/var/lib/postgresql/data` → `/Volume1/DockerAppData/documensodocker/db` |
| Logs | `docker logs documensodocker` (stdout/stderr) |



## Privacy

This application runs entirely on your NAS. **The developer does not collect, receive or
have access to any data processed by the application.** There is no telemetry, no analytics
and no account.

| Topic | Detail |
|---|---|
| Data processed | The application's configuration, database, caches and logs, plus any files you create with it. |
| Where it is stored | The application data folder (`/Volume1/DockerAppData/documensodocker/`) on your NAS. Nothing is uploaded to the developer. |
| Retention period | Until **you** delete it. Logs are rotated or size-limited by the application; uninstalling keeps the data unless you tick “delete data”. |
| Your rights | **Access / export**: copy the data folder. **Correct**: change the values in the web UI. **Delete**: uninstall with “delete data”, or remove the folder after stopping the container. |
| Deletion channel | Delete the folder yourself, or email **moechz@163.com** (answered within 30 days). |
| Security measures | Container runs as uid 1000 (never root), no `privileged`, no host network, no `cap_add`, no Docker socket, one published port; image tag pinned and refreshed on upstream fixes. |
| Children | Not directed at children. |

**Full privacy policy:** [PRIVACY.md](PRIVACY.md) —
<https://github.com/Moechz/documenso/blob/main/PRIVACY.md> — and the website version at
<https://www.moechz.com/privacy.html>.

## Third-party services (API disclosure)

The developer operates no server in this path. The application contacts only the services
**you configure**, plus (optionally) an update check and the image registry.

| Service | Endpoint | Data sent | Destination / region |
|---|---|---|---|
| SMTP server (only if configured) | the host you enter | signing e-mail: recipient, subject, body with the signing link | your mail provider |
| Telemetry (**disabled by default**) | `https://eu.i.posthog.com` | app version, installation ID, node ID only | PostHog, EU |
| Image pull | `registry-1.docker.io` | anonymous pull | Docker Hub, US |

See `PRIVACY.md` §6 for the full table. Disable any integration in the app's settings if you
do not want it.

## Licence and attributions

| Component | Licence | Notes |
|---|---|---|
| Documenso | AGPL-3.0 | upstream application, used unmodified inside the image |
| Container image `documenso/documenso:v2.22.0` | see the image's own metadata | pulled from Docker Hub at install time |
| This packaging | GPL-3.0 (see `LICENSE`) | compose file, metadata, translations, icon |

“Documenso”, “TerraMaster” and “TOS” are trademarks of their respective owners. This is an
independent community package by Moechz and is not affiliated with the upstream project or
TerraMaster. Full details: [NOTICE.md](NOTICE.md).

## Design highlights

- **Non-root.** `user: "1000:1000"`; verified on real hardware (the container reports uid 1000).
- **Entrypoint wrapper**: the upstream image is built to run as root and keeps state in root-owned paths, so the compose file replaces the entrypoint with `src/entrypoint.sh`, which makes the service run as an unprivileged user. See that file for the details.
- **Fixed image tag, never `:latest`**, Docker Hub only, no `privileged`, no `network_mode: host`, and no Docker socket, no `cap_add`.
- **Health check** on `/api/health`, which reports the database and the signing certificate, so a
  half-migrated instance is never marked healthy (180 s start period for the first migration).
- **Deterministic build**: GNU tar with uid/gid 0 and zeroed timestamps, gzip without a timestamp, plus the review-standards self-check above.

## Runtime file manifest

Everything the application writes on the NAS lives inside its own data
directory; the container-internal `/tmp` is discarded with the container. The
table lists what is created and how it behaves. Nothing else is written.

| Path | Purpose | Created when | Growth bound | Lifecycle |
|---|---|---|---|---|
| `/Volume1/DockerAppData/documensodocker/data` | `nextauth_secret`, `encryption_key`, `encryption_key_secondary`, `signing.p12`, `signing_pass` and the application's own uploads — mode 0600 | on first start | bounded by your own data | persistent; kept on uninstall unless you ask to delete it |
| `/Volume1/DockerAppData/documensodocker/db` | PostgreSQL 16 cluster (`PGDATA=/var/lib/postgresql/data/pgdata`): users, documents, audit trail | on first start | bounded by your own data | persistent; kept on uninstall unless you ask to delete it |

## Build

```bash
scripts/build.sh                  # -> out/documensodocker.tar.gz + .sha256
scripts/build.sh 2.22.0-2   # packaging iteration bump
scripts/build.sh 2.22.0-3          # current iteration
scripts/build.sh 2.22.0-3 x86_64   # explicit platform (the upstream image is amd64 only)
```

The build stages the four files, substitutes the version/platform placeholders,
embeds `src/entrypoint.sh` into the compose file (escaping every `$` as `$$`), removes CRLF/BOM/AppleDouble, then runs
`tools/verify.py`, a review-standards self-check (archive layout, JSON validity,
required fields, 14+ language coverage, version consistency, Docker-Hub-only
images, fixed tag, reserved/recommended host ports, non-root user, per-service
healthcheck/TZ/restart, data path below the application data root, never the
`/Volume*` wildcard, comment-free sequence blocks, `x-app-meta` position, no
literal secrets and the SVG size/element limits).

## Local verification

```bash
./TOSAppSelfTestingTool -c out/documensodocker.tar.gz   # official spec check
bash test/install-and-verify.sh                  # on-device E2E (needs root)
```

> Docker applications cannot be side-loaded through the App Center's manual
> install page (it accepts `.deb` only); the official self-testing tool's `-i`
> mode or `docker compose` are the only ways to install one for testing.

## Store submission checklist

1. Public GitHub repo (code + README only).
2. Release **tag `v2.22.0-3`**, assets `documensodocker_x86_64.tar.gz` +
   `documensodocker_x86_64.tar.gz.sha256` (Docker asset naming: `<app_id>_<arch>.tar.gz`).
3. Developer platform → Add Application: ID `documensodocker`, package type Docker,
   repository URL, architecture `x86_64`.
4. Version Management → Add Version `2.22.0-3` → automated validation → review.


## Limitations

- The application runs inside a container; data lives in the application data directory (`/Volume1/DockerAppData/documensodocker/`) as described above.

---

Packaged for TOS 7 by Moechz. Upstream image used unmodified from Docker Hub.

## Support

- Issues and questions: <https://github.com/Moechz/documenso/issues>
- Email: moechz@163.com
- Privacy: [PRIVACY.md](PRIVACY.md) · Licence: [NOTICE.md](NOTICE.md)
