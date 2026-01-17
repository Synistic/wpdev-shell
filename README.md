# wpdev - WordPress Development Environment

A simple CLI tool to spin up isolated WordPress development environments using Docker. Each site runs in its own set of containers with full file access for local editing.

## Features

- **One command setup**: `wpdev new mysite 8085` creates a complete WordPress environment
- **Multiple environments**: Run several WordPress sites simultaneously on different ports
- **Local file editing**: WordPress files are accessible at `~/wpdev/sites/<name>/html/`
- **WP-CLI included**: Run WP-CLI commands directly via `wpdev wp <name> <command>`
- **Mailpit integration**: Catch all outgoing emails for testing
- **German locale by default**: Configured for German WordPress installations (easily customizable)
- **Large file support**: Configured for imports up to 3GB (All-in-One WP Migration ready)

## Requirements

- Docker and Docker Compose
- Bash shell
- Linux/macOS/WSL2

## Installation

### 1. Clone the repository

```bash
cd ~
git clone https://github.com/Synistic/wpdev.git
```

### 2. Make the script executable

```bash
chmod +x ~/wpdev/wpdev
```

### 3. Add to PATH

Add the following line to your `~/.bashrc` (or `~/.zshrc` for Zsh):

```bash
export PATH="$PATH:$HOME/wpdev"
```

Then reload your shell:

```bash
source ~/.bashrc
```

### 4. Verify installation

```bash
wpdev help
```

## Usage

### Create a new environment

```bash
wpdev new mysite 8085
```

This creates:
- WordPress at `http://localhost:8085`
- Mailpit UI at `http://localhost:10085`
- Admin login: `admin` / `admin`

### List all environments

```bash
wpdev list
```

### Start/Stop an environment

```bash
wpdev stop mysite
wpdev start mysite
```

### View logs

```bash
wpdev logs mysite
```

### Open shell in container

```bash
wpdev shell mysite
```

### Run WP-CLI commands

Full WP-CLI access without needing to enter the container:

```bash
# Plugin management
wpdev wp mysite plugin list
wpdev wp mysite plugin install woocommerce --activate
wpdev wp mysite plugin deactivate akismet

# Theme management
wpdev wp mysite theme list
wpdev wp mysite theme activate flavor

# User management
wpdev wp mysite user list
wpdev wp mysite user create bob bob@example.com --role=editor

# Database operations
wpdev wp mysite db export backup.sql
wpdev wp mysite db import backup.sql
wpdev wp mysite search-replace 'https://old-domain.com' 'http://localhost:8085'

# Cache & maintenance
wpdev wp mysite cache flush
wpdev wp mysite rewrite flush
wpdev wp mysite cron event run --due-now

# Options & config
wpdev wp mysite option get siteurl
wpdev wp mysite option update blogname "My Test Site"
```

### Delete an environment

```bash
wpdev delete mysite
```

## File Structure

After creating a site, you'll find:

```
~/wpdev/sites/mysite/
├── html/                  # WordPress files (editable!)
│   ├── wp-admin/
│   ├── wp-content/
│   │   ├── plugins/
│   │   ├── themes/
│   │   └── uploads/
│   ├── wp-includes/
│   └── wp-config.php
├── docker-compose.yml
├── Dockerfile
├── entrypoint.sh
├── nginx.conf
├── php.conf.d/
│   └── custom.ini
└── .env
```

Edit files directly in `~/wpdev/sites/mysite/html/` with your favorite editor or IDE!

## Configuration

### PHP Settings

Edit `template/php.conf.d/custom.ini` to change PHP settings:

```ini
upload_max_filesize = 3G
post_max_size = 3G
memory_limit = 512M
max_execution_time = 600
```

### Nginx Settings

Edit `template/nginx.conf` for web server configuration.

### WordPress Setup

Edit `template/entrypoint.sh` to customize:
- Default plugins installed
- Default theme
- WordPress locale
- Default settings

## Port Allocation

When you create a site with port `8085`:
- WordPress: `8085`
- Mailpit SMTP: `9085` (port + 1000)
- Mailpit UI: `10085` (port + 2000)

## Importing Sites

1. Create a new environment: `wpdev new clientsite 8090`
2. Open WordPress admin: `http://localhost:8090/wp-admin`
3. Go to **Tools > Import**
4. Use **All-in-One WP Migration** (pre-installed) to import your backup

## Automatic Setup Features

When creating a new environment, wpdev automatically:

1. **Sets ACL permissions** - Your user gets full read/write access to all files while www-data remains the owner (required for Docker)
2. **Configures git safe.directory** - Plugin directories are added to git's safe.directory, so you can work with git repos inside wp-content/plugins without permission errors

## Troubleshooting

### Permission issues with files

The setup uses ACLs to grant both your user and www-data access to files. If you need to manually fix an existing site:

```bash
# Set ACL permissions for your user
sudo setfacl -R -m u:$(whoami):rwX ~/wpdev/sites/mysite
sudo setfacl -R -d -m u:$(whoami):rwX ~/wpdev/sites/mysite

# Check current ACLs
getfacl ~/wpdev/sites/mysite/html/
```

### Git not showing repo in plugins folder

If git shows "unsafe repository" errors, add the directory to safe.directory:

```bash
git config --global --add safe.directory ~/wpdev/sites/mysite/html/wp-content/plugins/your-plugin
```

### Container won't start

Check the logs:

```bash
wpdev logs mysite
```

### MySQL connection issues

The healthcheck ensures MySQL is ready before WordPress starts. If issues persist:

```bash
cd ~/wpdev/sites/mysite
docker compose down
docker compose up -d
```

### Reset an environment

```bash
wpdev delete mysite
wpdev new mysite 8085
```

## Architecture

Each environment consists of 4 containers:

| Container | Image | Purpose |
|-----------|-------|---------|
| wordpress | Custom (PHP-FPM Alpine) | WordPress + WP-CLI |
| nginx | nginx:alpine | Web server |
| db | mysql:8.0 | Database |
| mailpit | axllent/mailpit | Email catching |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - feel free to use this for any purpose.

## Credits

Built with Docker, WordPress, WP-CLI, Nginx, MySQL, and Mailpit.
