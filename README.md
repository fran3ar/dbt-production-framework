# dbt-production-framework

Production-grade analytics engineering pipeline built with **dbt**, **PostgreSQL**, **Docker Compose**, and **GitHub Actions CI/CD**.

## Architecture Overview
- **Staging Layer (`stg_*`)**: Direct views providing type normalization, deduplication, and schema validation.
- **Core Star Schema**:
  - Dimensions (`d_*`): Master entity models including product classification and target margins.
  - Facts (`f_*`): Granular order metrics with margin calculations and financial rollups.
- **Automated Delivery**: Built as a multi-stage Docker artifact served via hardened Nginx on port `8082`.

## Local / Host Execution
```bash
docker compose up -d --build
```
Access the docs portal at `http://localhost:8082`.

## CI/CD
On every push/PR to `main`, [`.github/workflows/ci-cd.yml`](.github/workflows/ci-cd.yml) runs `dbt seed`/`run`/`test` against a disposable Postgres service container.

On push to `main` (or a manual run via *Actions → CI/CD → Run workflow*), a `deploy` job SSHes into the host that serves the docs and runs `git pull && docker compose up -d --build` **there** — the image is built on that host, not on the GitHub-hosted runner, since only that host's network path/security group is trusted to reach the real database.

**One-time setup on the target host**, before the first deploy:
```bash
git clone https://github.com/fran3ar/dbt-production-framework.git ~/dbt-production-framework
```

Required repo secrets (*Settings → Secrets and variables → Actions*):
- `EC2_HOST`, `EC2_USER`, `EC2_SSH_KEY` — SSH access to the deploy host.
- `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_PORT`, `DB_NAME`, `DB_SCHEMA` — written into a `.env` file on the host on every deploy (`chmod 600`, never committed).

`DB_USER`/`DB_PASSWORD` are passed into the Docker build as BuildKit secret mounts (not `ARG`/`ENV`), so they're never written into an image layer, `docker history`, or the build cache — only `dbt`'s in-container process sees them at build time. Once deployed, the docs are reachable at `http://<EC2_HOST>:8082`.
