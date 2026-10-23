# playground
This includes the code for chemical playground

### Requirements

You must have docker installed on your machine, This project will try to use docker from the command line, it creates containers of chemical to run user code

### Limitations

These limitations will be addressed in upcoming chemical releases

1 - on windows, you must use mode `debug_complete`

2 - on linux, you must use mode `debug` or `release`

3 - use `--no-cache` when compiling the lab file

For windows:
```
./chemical.exe build.lab --mode debug_complete --no-cache
```

For linux:
```
./chemical build.lab --mode debug --no-cache
```

### Building & Running (scripts)

Convenience scripts live in `scripts/`. Each has a bash and a PowerShell mirror. They auto-locate the Chemical compiler under the repo root (`cmake-build-debug/` or `build/`) and run with the repo root as working directory so dev asset paths (`lang/compiled/playground/src/assets/...`) resolve.

Build the server binary:
```
./scripts/build.sh            # or: pwsh scripts/build.ps1
```

Run the server (builds first unless `--no-build`):
```
./scripts/serve.sh            # or: pwsh scripts/serve.ps1
./scripts/serve.sh --no-build
```
The app listens on port 8080 by default.

### Server setup (production)

The production server is the `chemicallang.com` origin: nginx terminates TLS,
proxies to the playground binary on `127.0.0.1:8080`, and the binary runs user
code in Docker.

Run the interactive setup from this machine:

```bash
./scripts/setup-server.sh
```

It asks for the server address and SSH login, then uses `ssh-copy-id` so the
server password is typed into ssh's own prompt — the script never reads or
stores it. It verifies the SSH host-key fingerprint before connecting.

What it does on Ubuntu 24.04 (x86_64):

- installs security updates, Docker, nginx, certbot, ufw, fail2ban, acl
- creates a non-root `admin` user (key-only, passwordless sudo) and a `deploy`
  user (key-only, sudo limited to restarting the service)
- creates the uid-1000 service account required by the binary's
  `--user 1000:1000` sandbox, plus `/home/playground/app`
- installs a hardened `playground.service`, cleanup/health timers and a narrow
  restart wrapper
- configures nginx HTTP/HTTPS, rate-limits `/submit`, and pins the app to
  loopback
- enables UFW (22/80/443 only), fail2ban, unattended upgrades, journald limits
  and basic sysctl hardening
- deploys the latest `pg-linux-x64-tcc` release and both PNG assets
- runs a real `/submit` compile round-trip through Docker
- optionally updates the `chemicallang/playground` GitHub Actions secrets
  (`DEPLOY_SSH_KEY`, `DEPLOY_KNOWN_HOSTS`, `DEPLOY_USER`, `DEPLOY_HOST`,
  `DEPLOY_PORT`, `DEPLOY_PATH`) and removes `DEPLOY_PASSWORD`

TLS is issued with Let's Encrypt. The default account email is
`support@chemicallang.com`; override it with `--email`. Choose Cloudflare
DNS-01 to issue the certificate before DNS cutover, or HTTP-01 after the A
records point at the new server. To issue/reinstall the certificate later:

```bash
./scripts/setup-server.sh --tls-only
```

Deployments use the same key-only configuration:

```bash
./deploy.sh --use-release
```

Restart the service without deploying:

```bash
ssh playground 'sudo /usr/local/sbin/playground-restart'
```

`deploy.sh` handles a fresh server: it only rotates `playground` to
`playground.old` when the current binary exists, and rolls back if the restart
fails. The old `DEPLOY_PASSWORD`/`sshpass` path is gone.

Re-running `setup-server.sh` against a new server reuses the same operator and
deploy keys, updates the pinned `known_hosts` entry, rewrites the local
`deploy.env`, and updates the GitHub secrets.

> The playground executes untrusted code. The Docker socket is effectively
> root-equivalent, so keep this host dedicated to the playground and keep the
> deploy key protected.

### Tests

Tests live in `tests/` and are annotated with `@test`. They are a separate build flavor: `chemical.mod` compiles `src/` always, `src/app/` (the real server main) only in app mode, and `tests/` only when building with `--test`. The test binary ships its own `tests/main.ch` that dispatches to the shared `test_runner`.

Build and run the unit/integration suite (validation, versions, docker helpers, SSR pages, live endpoints over loopback):
```
./scripts/test.sh             # or: pwsh scripts/test.ps1
./scripts/test.sh --test-names "test_valid_simple_name"   # run by name
./scripts/test.sh --no-build                              # reuse previous binary
```

Boot the real server and probe every route over HTTP (always exits cleanly):
```
./scripts/playground-build-test.sh              # or: pwsh scripts/playground-build-test.ps1
PLAYGROUND_TEST_PORT=8123 ./scripts/playground-build-test.sh
```

### Project layout

```
chemical.mod          # module definition; app/test source switching lives here
src/                  # shared code (pages, components, validation, docker, versions)
app/main.ch           # server entry point — compiled only when NOT building with --test
tests/                # @test sources + tests/main.ch — compiled only with --test
scripts/              # build/test/serve scripts (bash + PowerShell)
```