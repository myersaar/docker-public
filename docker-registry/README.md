# Docker Registry

Private Docker registry (HTTP, no TLS). Reachable from the host and over Tailscale.

## Access

| From              | Registry API (push/pull) | Web UI        |
|-------------------|---------------------------|---------------|
| This host (local) | `localhost:5000`          | —             |
| Over Tailscale    | `100.81.148.52:5000`      | `http://100.81.148.52` |

The web UI (docker-registry-ui) is bound only to the Tailscale IP, so it is not reachable from localhost.

## Client setup (insecure registry)

Use HTTP, so each Docker client must allow this registry as insecure.

### On this host (where the registry runs)

Add to `/etc/docker/daemon.json` (create the file if needed):

```json
{
  "insecure-registries": [
    "localhost:5000",
    "100.81.148.52:5000"
  ]
}
```

Then restart Docker: `sudo systemctl restart docker` (or restart Docker Desktop on Mac).

### On other machines (over Tailscale)

1. Ensure the machine is on the same Tailscale network and can reach `100.81.148.52`.
2. Add to Docker daemon config (e.g. `/etc/docker/daemon.json` or Docker Desktop → Docker Engine):

```json
{
  "insecure-registries": ["100.81.148.52:5000"]
}
```

3. Restart Docker.

## Usage

```bash
# Tag and push
docker tag myimage:latest localhost:5000/myimage:latest
docker push localhost:5000/myimage:latest

# From another machine over Tailscale
docker tag myimage:latest 100.81.148.52:5000/myimage:latest
docker push 100.81.148.52:5000/myimage:latest

# Pull
docker pull localhost:5000/myimage:latest
docker pull 100.81.148.52:5000/myimage:latest
```

## Setup

Run from this directory:

```bash
./setup.sh
docker compose up -d
```

To use a different base directory: `BASE_DIR=/path/to/registry ./setup.sh` (and update volume paths in `docker-compose.yaml` to match).
