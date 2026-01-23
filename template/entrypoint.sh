#!/bin/bash
set -e

# Function to wait for MySQL using bash TCP check
wait_for_mysql() {
    echo "Waiting for MySQL to be ready..."
    local max_tries=60
    local tries=0
    while [ $tries -lt $max_tries ]; do
        if (echo > /dev/tcp/db/3306) 2>/dev/null; then
            echo "MySQL port is open!"
            sleep 3  # Give MySQL a moment to fully accept connections
            return 0
        fi
        tries=$((tries + 1))
        sleep 2
    done
    echo "Warning: Could not confirm MySQL is ready after $max_tries attempts"
    return 1
}

cd /var/www/html

# Download WordPress core if not present
if [ ! -f /var/www/html/wp-includes/version.php ]; then
    echo "Downloading WordPress..."
    wp core download --locale=de_DE --allow-root
fi

# Wait for MySQL
wait_for_mysql

# Create wp-config.php if it doesn't exist
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${WORDPRESS_DB_NAME:-wordpress}" \
        --dbuser="${WORDPRESS_DB_USER:-wordpress}" \
        --dbpass="${WORDPRESS_DB_PASSWORD:-wordpress}" \
        --dbhost="${WORDPRESS_DB_HOST:-db}" \
        --locale=de_DE \
        --allow-root
fi

# Check if WordPress is already installed
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."

    # Install WordPress with German locale
    wp core install \
        --url="http://localhost:${WP_PORT:-8080}" \
        --title="${WP_SITE_NAME:-WordPress Dev}" \
        --admin_user=admin \
        --admin_password=admin \
        --admin_email=admin@local.test \
        --locale=de_DE \
        --allow-root

    echo "Cleaning up default content..."

    # Delete sample post (ID 1) and sample page (ID 2)
    wp post delete 1 2 --force --allow-root 2>/dev/null || true

    # Delete sample comment
    wp comment delete 1 --force --allow-root 2>/dev/null || true

    # Delete Hello Dolly and Akismet plugins
    wp plugin delete hello akismet --allow-root 2>/dev/null || true

    # Keep only one theme (twentytwentyfive), delete others
    wp theme delete twentytwentythree twentytwentyfour --allow-root 2>/dev/null || true

    echo "Installing All-in-One WP Migration..."
    wp plugin install all-in-one-wp-migration --activate --allow-root

    echo "Configuring German settings..."
    wp option update timezone_string "Europe/Berlin" --allow-root
    wp option update date_format "d.m.Y" --allow-root
    wp option update time_format "H:i" --allow-root
    wp option update start_of_week 1 --allow-root

    echo "WordPress setup complete!"
    echo "========================================"
    echo "Login: admin / admin"
    echo "URL: http://localhost:${WP_PORT:-8080}"
    echo "========================================"
else
    echo "WordPress already installed, skipping setup."
fi

# Fix permissions using ACLs
echo "Setting file permissions..."
chown -R www-data:www-data /var/www/html

# Add ACL for host user (UID passed via environment)
# Note: setfacl may fail on macOS-mounted volumes, which is fine - Docker Desktop handles permissions
if [ -n "$HOST_UID" ]; then
    echo "Setting ACL permissions for host user (UID: $HOST_UID)..."
    setfacl -R -m u:$HOST_UID:rwx /var/www/html 2>/dev/null || true
    setfacl -R -d -m u:$HOST_UID:rwx /var/www/html 2>/dev/null || true
fi

# Execute the CMD (php-fpm)
exec "$@"
