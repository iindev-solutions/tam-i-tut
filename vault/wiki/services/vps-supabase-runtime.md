# VPS Supabase Runtime Playbook

## Purpose

Run migration and policy validation on VPS Docker environment since local machine has no Docker.

## Preconditions

- VPS has SSH access
- repo cloned on VPS
- Node.js + npm installed
- Docker Engine installed and running

## One-Time Docker Setup (Ubuntu example)

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
```

Re-login after `usermod`.

## One-Time Node.js Setup (Ubuntu example)

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt-get install -y nodejs
node -v
npm -v
npx -v
```

## Runtime Validation Flow

From repository root:

```bash
npx -y supabase start
npx -y supabase migration up --local
npx -y supabase db lint --local --fail-on error
npx -y supabase test db supabase/tests/rls --local
```

Optional status checks:

```bash
npx -y supabase status
npx -y supabase migration list --local
```

Stop stack when done:

```bash
npx -y supabase stop
```

## Current Validation Scope

1. execute migrations `001`–`020`
2. confirm RLS policies compile and apply
3. run RLS and guard tests under `supabase/tests/rls/`

## Latest Validation Snapshot (2026-04-24)

- VPS: `iind-vps`
- Runtime path: `/srv/tam-i-tut`
- `migration up --local`: up to date
- `db lint --local --fail-on error`: no schema errors
- `test db supabase/tests/rls --local`: PASS (`Files=9, Tests=80`)

## Known Gaps

- CI is not yet wired to run VPS-equivalent DB tests automatically on each merge

## Low-Disk VPS Notes

Observed on 10GB VPS: first full `supabase start` can fail with `no space left on device` during image extraction.

Practical recovery sequence:

```bash
# stop stack if partially started
npx -y supabase stop || true

# cleanup only when you are sure no critical docker workloads are using stopped images
docker image prune -a -f

# verify free space
df -h /
```

Then retry `npx -y supabase start`.

## Failure Handling

1. capture exact SQL error and migration filename
2. patch minimal migration file
3. re-run `npx supabase migration up --local`
4. repeat until lint + test pass
