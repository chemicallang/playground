# Chemical Playground — operations quick reference
#
# One-time server setup (interactive; asks for the server address and lets
# ssh-copy-id prompt for the password):
#
#   ./scripts/setup-server.sh
#
# The setup script provisions Ubuntu 24.04, creates the `playground`/`deploy`
# users, installs Docker/nginx, hardens SSH, deploys the binary and can update
# the GitHub Actions secrets. It is safe to re-run, including against a new
# server.
#
# Deploy the latest release (key-only; uses deploy.env):
#
#   ./deploy.sh --use-release
#
# Deploy a specific release:
#
#   ./deploy.sh --use-release --version v1.5.21
#
# Restart the service:
#
#   ./restart.sh
#
# Logs / status:
#
#   ssh playground 'sudo journalctl -u playground.service -n 100 --no-pager'
#   ssh playground 'sudo systemctl status playground.service --no-pager'
#
# Clean stale workspaces manually:
#
#   ssh playground 'sudo /usr/local/bin/playground-cleanup'
#
# The systemd unit and helper scripts are installed by setup-server-remote.sh:
#
#   /etc/systemd/system/playground.service
#   /usr/local/bin/run-playground.sh
#   /usr/local/bin/playground-cleanup
#   /usr/local/sbin/playground-restart
#
# The app runs as the uid-1000 account (because the binary's sandbox uses
# `--user 1000:1000`), listens on 127.0.0.1:8080 behind nginx, and is reachable
# only through the reverse proxy.
