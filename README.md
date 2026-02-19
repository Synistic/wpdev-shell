# wpdev-shell

Bash CLI to spin up isolated WordPress development environments using Docker.

> **Note:** This is the original shell-based version. The active successor is [wpdev](https://github.com/Synistic/wpdev), rewritten in TypeScript.

## Features

- Single command setup: `wpdev new mysite 8085`
- Run multiple WordPress sites on different ports
- Local file editing at `~/wpdev/sites/<name>/html/`
- WP-CLI integration via `wpdev wp <name> <command>`
- Mailpit for email testing
- Pre-configured for large imports (All-in-One WP Migration)

## Requirements

- Docker and Docker Compose
- Bash shell (Linux/macOS/WSL2)

## Installation

```bash
git clone https://github.com/Synistic/wpdev-shell.git ~/wpdev
chmod +x ~/wpdev/wpdev
```

Add to your PATH:

```bash
echo 'export PATH="$PATH:$HOME/wpdev"' >> ~/.zshrc
source ~/.zshrc
```

## Usage

```bash
wpdev new mysite 8085    # Create environment (WordPress at :8085, Mailpit at :10085)
wpdev list               # List all environments
wpdev start mysite       # Start
wpdev stop mysite        # Stop
wpdev wp mysite ...      # Run WP-CLI commands
wpdev shell mysite       # Open container shell
wpdev logs mysite        # View logs
wpdev delete mysite      # Remove environment
```

## Port Allocation

| Service | Port |
|---------|------|
| WordPress | `<port>` |
| Mailpit SMTP | `<port> + 1000` |
| Mailpit UI | `<port> + 2000` |

## Architecture

Each site runs 4 containers: WordPress (PHP-FPM Alpine), Nginx, MySQL 8.0, and Mailpit.

Files are stored at `~/wpdev/sites/<name>/` with full host filesystem access via ACL permissions.

## License

MIT
