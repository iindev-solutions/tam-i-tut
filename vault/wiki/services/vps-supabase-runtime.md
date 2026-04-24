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

## Runtime Validation Flow

From repository root:

```bash
npx supabase start
npx supabase migration up --local
npx supabase db lint --local --fail-on error
npx supabase test db supabase/tests/rls --local
```

Optional status checks:

```bash
npx supabase status
npx supabase migration list --local
```

Stop stack when done:

```bash
npx supabase stop
```

## Current Validation Scope

1. execute migrations `001`–`020`
2. confirm RLS policies compile and apply
3. run RLS and guard tests under `supabase/tests/rls/`

## Known Gaps

- test files under `supabase/tests/rls/` are scaffold-level and require concrete assertions before final pass

## Failure Handling

1. capture exact SQL error and migration filename
2. patch minimal migration file
3. re-run `npx supabase migration up --local`
4. repeat until lint + test pass
