FROM wordpress:php8.2-fpm-alpine

# Install WP-CLI and dependencies
RUN apk add --no-cache bash mysql-client less acl

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy custom entrypoint
COPY entrypoint.sh /usr/local/bin/wpdev-entrypoint.sh
RUN chmod +x /usr/local/bin/wpdev-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/wpdev-entrypoint.sh"]
CMD ["php-fpm"]
