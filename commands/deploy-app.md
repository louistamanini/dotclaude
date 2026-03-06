Deploy a GitHub repo via Docker with automatic Cloudflare tunnel routing, firewall rules, and Uptime Kuma monitoring. Argument: `$1` = repo URL (required), `$2` = target directory (default `/home/dev/projects/`).

## Process

### Step 1 — Validate prerequisites

- Source `/opt/server-infra/.env` and verify the following variables exist and are non-empty:
  - `CLOUDFLARE_API_TOKEN` (needs DNS:Edit + Tunnel:Edit permissions)
  - `CLOUDFLARE_ACCOUNT_ID`
  - `CLOUDFLARE_ZONE_ID` (zone inamat.ovh)
  - `UPTIME_KUMA_USERNAME` / `UPTIME_KUMA_PASSWORD`
- If any are missing → STOP, tell the user which ones to add to `/opt/server-infra/.env`
- Verify Docker daemon is running (`docker info`)
- Verify network `dev` exists (`docker network inspect dev`)
- Verify cloudflared container is running (`docker ps --filter name=cloudflared`)
- Verify `/opt/server-infra/apps/` exists — create it if absent
- Parse arguments:
  - `$1` = repo URL (required — if missing, ask for it)
  - `$2` = target directory (default `/home/dev/projects/`)

### Step 2 — Clone the repository

- Extract repo name from the URL (last path segment, strip `.git` suffix)
- Check if `{target-dir}/{repo-name}` already exists:
  - If yes → ask: pull latest, use as-is, or abort
- `git clone {url} {target-dir}/{repo-name}`

### Step 3 — Analyze the stack

- Read README.md and configuration files in the cloned repo
- Detect the stack using this priority order:
  1. `docker-compose.yml` / `docker-compose.yaml` / `compose.yaml` → existing compose setup
  2. `Dockerfile` → custom image, no compose
  3. `package.json` → detect framework: Next.js, Nuxt, Angular, Vite, plain Node
  4. `requirements.txt` / `pyproject.toml` / `Pipfile` → detect framework: Django, Flask, FastAPI
  5. `composer.json` → Laravel, Symfony, or plain PHP
  6. `go.mod` → Go application
  7. `Cargo.toml` → Rust application
  8. `Gemfile` → Ruby / Rails
  9. `index.html` (root) → static site
- Identify required services (database, cache, object storage, etc.)
- Present the analysis to the user and ask for confirmation before proceeding

### Step 4 — Ask deployment details

Ask the user these questions (use AskUserQuestion, all at once):

- **Subdomain**: suggest `{repo-name}.inamat.ovh`, ask for confirmation or alternative
- **Environment variables**: if `.env.example` exists in the repo, show its contents and ask the user to provide values for each variable
- **Mode**: production (build + optimized serve) or development (hot-reload, source maps)

### Step 5 — Allocate ports

- Read `/opt/server-infra/apps/port-registry.json`
  - If it does not exist, create it with this seed:
    ```json
    {
      "ranges": {
        "istya": { "start": 8100, "end": 8109 }
      },
      "apps": {}
    }
    ```
- Cross-check with `docker ps --format '{{.Ports}}'` |to detect actually used ports
- Allocate a block of 10 ports starting from the next available slot at 8200+ (i.e., 8200-8209, 8210-8219, etc.)
- Register the allocation in `port-registry.json` under `apps.{app-name}`:
  ```json
  { "start": 8200, "end": 8209, "subdomain": "{sub}.inamat.ovh" }
  ```
- The app's main HTTP port is the first port in the block (`start`)

### Step 6 — Create Docker config (server-side wrapper)

Create the directory `/opt/server-infra/apps/{app-name}/`.

**NEVER modify any file inside the cloned repository** (sole exception: copy `.env.example` → `.env` in the repo if the app requires it — this file is universally gitignored).

Choose one of 3 strategies based on what the project provides:

**Case A — Project has its own docker-compose:**
- Create `/opt/server-infra/apps/{app-name}/override.yml` that:
  - Adds network `dev` (external) to all services
  - Remaps exposed ports to `127.0.0.1:{allocated-port}:{internal-port}`
  - Injects environment variables from Step 4
- The app will be started with:
  ```bash
  docker compose -f {repo-path}/docker-compose.yml -f /opt/server-infra/apps/{app-name}/override.yml up -d --build
  ```

**Case B — Project has a Dockerfile but no compose:**
- Create `/opt/server-infra/apps/{app-name}/docker-compose.yml` that:
  - Builds from the project's Dockerfile (`build: {repo-path}`)
  - Connects to network `dev` (external)
  - Maps ports to `127.0.0.1:{allocated-port}:{internal-port}`
  - Sets environment variables from Step 4

**Case C — No Dockerfile, no compose:**
- Create `/opt/server-infra/apps/{app-name}/docker-compose.yml` that:
  - Uses the appropriate base image (node:22-alpine, python:3.12-slim, php:8.3-fpm, nginx:alpine, etc.)
  - Mounts the project directory as a volume
  - Sets working_dir to the mount point
  - Runs install + start commands appropriate to the stack (e.g., `npm ci && npm start`)
  - Connects to network `dev` (external)
  - Maps ports to `127.0.0.1:{allocated-port}:{internal-port}`
  - Sets environment variables from Step 4

In all cases, also create `/opt/server-infra/apps/{app-name}/.env` with:
- All user-provided env vars from Step 4
- Allocated port numbers
- `NODE_ENV=production` / equivalent for the detected stack (if production mode)

### Step 7 — Start Docker services

- Run the appropriate `docker compose up -d --build` command for the chosen case (A/B/C)
- Poll `docker compose ps` until all containers show healthy or running (max 120s, check every 5s)
- If a container exits or fails:
  - Show `docker compose logs --tail=50`
  - STOP — ask the user how to proceed
- Once running, verify local response: `curl -sf http://127.0.0.1:{allocated-port}` (allow non-200 but check TCP reachability)

### Step 8 — Configure Cloudflare tunnel route

Use the Cloudflare API with the token from `.env`. Tunnel ID: `d8983175-3eaf-4e50-938c-7e2843e8751e`.

1. **GET current tunnel config:**
   ```
   GET https://api.cloudflare.com/client/v4/accounts/{account_id}/cfc_tunnel/{tunnel_id}/configurations
   ```
   Extract the current `ingress` array.

2. **Check idempotence:** if a rule for `{sub}.inamat.ovh` already exists, skip to DNS step (or ask to update).

3. **Insert new ingress rule** BEFORE the catch-all (`"service": "http_status:404"`):
   ```json
   { "hostname": "{sub}.inamat.ovh", "service": "http://{container-name}:{internal-port}" }
   ```
   (Use the container name — cloudflared is on the `dev` network and resolves it.)

4. **PUT updated config:**
   ```
   PUT https://api.cloudflare.com/client/v4/accounts/{account_id}/cfc_tunnel/{tunnel_id}/configurations
   ```
   Verify `"success": true`.

5. **Create DNS CNAME record:**
   ```
   POST https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records
   { "type": "CNAME", "name": "{sub}", "content": "d8983175-3eaf-4e50-938c-7e2843e8751e.cfargotunnel.com", "proxied": true }
   ```
   Check idempotence first (GET existing records for that name). Verify `"success": true`.

### Step 9 — Configure firewall

- Ports are already bound to `127.0.0.1` (Step 6) — this is the primary security layer
- Add defense-in-depth nftables rules:
  ```bash
  nft add table inet app_firewall 2>/dev/null
  nft add chain inet app_firewall input '{ type filter hook input priority 0; policy accept; }' 2>/dev/null
  nft add rule inet app_firewall input tcp dport {port-start}-{port-end} ip saddr != 127.0.0.1 ip saddr != 172.16.0.0/12 drop
  ```
- Persist the ruleset: `nft list ruleset > /etc/nftables.conf`
- If permission denied → warn the user and provide the exact sudo commands to run

### Step 10 — Add Uptime Kuma monitoring

- Check if `uptime-kuma-api` Python package is installed (`pip3 show uptime-kuma-api`)
  - If not → install it: `pip3 install uptime-kuma-api`
- Write and run a Python script that:
  - Connects to Uptime Kuma at `http://localhost:3001`
  - Logs in with `UPTIME_KUMA_USERNAME` / `UPTIME_KUMA_PASSWORD` from `.env`
  - Adds an HTTP(s) monitor for `https://{sub}.inamat.ovh` with a friendly name
  - Sets check interval to 60 seconds
- If Uptime Kuma is unreachable → warn and provide manual instructions (URL, type, interval)

### Step 11 — Verify public access and summarize

- Test `curl -sI https://{sub}.inamat.ovh` (retry up to 30s for DNS propagation)
- Display final summary:
  ```
  Deployment complete
  ---
  URL:         https://{sub}.inamat.ovh
  Project:     {repo-path}
  Wrapper:     /opt/server-infra/apps/{app-name}/
  Ports:       {start}-{end} (main: {start})
  Containers:  {list from docker compose ps}
  Monitoring:  Uptime Kuma ✓
  Mode:        {production|development}
  ```
- If the public URL does not respond, warn and suggest checking `docker compose logs` and Cloudflare dashboard

## Rules

- **Repository integrity**: NEVER modify, create, or delete any file inside the cloned repository — sole exception: copying `.env.example` → `.env` (universally gitignored)
- **Infrastructure safety**: NEVER modify `/opt/server-infra/compose.yaml`, NEVER remove existing Cloudflare ingress rules, NEVER expose ports on `0.0.0.0`
- **Error handling**: if Docker build/start or Cloudflare API calls fail → STOP and show logs, do NOT retry automatically
- **Idempotence**: always check for existing hostname/CNAME/port allocation before creating — avoid duplicates
- **Network**: all app containers must join the `dev` Docker network so cloudflared can route to them by container name

_Self-improvement and Execution discipline rules are defined in ~/.claude/CLAUDE.md and apply automatically._
