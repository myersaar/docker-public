# Docker Registry

Private Docker registry (HTTP at the origin). Reachable locally and can be published through Cloudflare Tunnel.

## Access

| From                | Registry API (push/pull)     | Web UI                          |
|---------------------|------------------------------|----------------------------------|
| This host (local)   | `localhost:5000`             | `http://localhost:5080`         |
| Through Cloudflare  | `https://registry.petulantpickle.com` | `https://registry-ui.petulantpickle.com`  |

The web UI binds to `127.0.0.1:5080` by default. The `registry` and `registry-ui` containers also join the external `proxy-net` network so `cloudflared` can reach them directly.

## Client setup

### Local host access (HTTP / insecure registry)

Because the origin registry is plain HTTP on `localhost:5000`, Docker on the host machine must allow it as an insecure registry.

Add to `/etc/docker/daemon.json` (create the file if needed):

```json
{
  "insecure-registries": [
    "localhost:5000"
  ]
}
```

Then restart Docker: `sudo systemctl restart docker` (or restart Docker Desktop on Mac).

### Cloudflare hostname access (HTTPS)

If you expose the registry API through Cloudflare Tunnel on a public hostname such as `registry.petulantpickle.com`, Docker clients can use that HTTPS hostname directly and do not need the insecure-registry setting for that hostname.

Do not expose the registry API publicly unless you also add authentication or restrict it with Cloudflare controls. The registry in this repo is otherwise open.

## Usage

```bash
# Tag and push
docker tag myimage:latest localhost:5000/myimage:latest
docker push localhost:5000/myimage:latest

# If you expose the API through Cloudflare
docker tag myimage:latest registry.petulantpickle.com/myimage:latest
docker push registry.petulantpickle.com/myimage:latest

# Pull
docker pull localhost:5000/myimage:latest
docker pull registry.petulantpickle.com/myimage:latest
```

## Setup

1. Create the shared Docker network if you do not already have it:

```bash
docker network create proxy-net
```

2. In this directory, copy `.env.example` to `.env` and set `REGISTRY_UI_PUBLIC_URL` to the public Cloudflare hostname for the UI, for example `https://registry-ui.petulantpickle.com`.

3. In `cloudflare-tunnel`, copy `.env.example` to `.env` and set your `TUNNEL_TOKEN`.

4. In the Cloudflare Zero Trust dashboard, add public hostnames to the tunnel:

- `registry.petulantpickle.com` -> `http://registry:5000`
- `registry-ui.petulantpickle.com` -> `http://registry-ui:80` (optional, only if you want the browser UI)

5. Start the services:

```bash
./setup.sh
docker compose up -d
```

Then start the tunnel stack from `cloudflare-tunnel`:

```bash
docker compose up -d
```

To use a different base directory: `BASE_DIR=/path/to/registry ./setup.sh` (and update volume paths in `docker-compose.yaml` to match).
