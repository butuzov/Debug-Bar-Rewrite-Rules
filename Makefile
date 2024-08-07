# Manual
# make - runs wordpress
# make

WP_SVN_USER ?= Butuzov
WP_SVN_PASS ?= nopass
WPCLI_CONTINER_NAME := wp-cli
WPAPP_CONTINER_NAME := wordpress

# ----------------------------------------------------------------

all: up wp-install wp-plugins

# ----------------------------------------------------------------
wp-install:
	docker compose run  \
			--rm "$(WPCLI_CONTINER_NAME)" wp core install \
			--allow-root \
			--url=127.0.0.1:8080 \
			--title=development \
			--admin_user=root \
			--admin_password=root \
			--admin_email=root@root.com

## Install debug bar and developer
wp-plugins:
	docker compose run  \
		--rm "$(WPCLI_CONTINER_NAME)" wp plugin install \
		--activate --allow-root --force \
		https://downloads.wordpress.org/plugin/debug-bar.1.1.6.zip \
		https://downloads.wordpress.org/plugin/developer.1.2.6.zip

# ----------------------------------------------------------------

## Start all containers (in background) for development
up:
	docker-compose  up --no-recreate -d
	@sleep 10

## Destroy Setup
down:
	docker-compose  down -v

# ----------------------------------------------------------------

# Install packages required by NPM
npm:
	npm install

# Runs NPM Gulp builder
# builds css/js and generate hashes files.
gulp: npm
	npm run gulp

# Test gitattributes
export:
	git archive --format=tar --prefix=development/ --output="archive.tar" develop

# ----------------------------------------------------------------

deployer:
	rm -rf cd wp-plugins-deploy
	git clone https://github.com/butuzov/wp-plugins-deploy

deploy-existing: deployer
	./wp-plugins-deploy/wp-deploy.sh \
		--git=https://github.com/butuzov/Debug-Bar-Rewrite-Rules \
		--svn=http://plugins.svn.wordpress.org/debug-bar-rewrite-rules \
		--user="$(WP_SVN_USER)" --pass="$(WP_SVN_PASS)" -f

deploy:
	./wp-plugins-deploy/wp-deploy.sh \
		--git=https://github.com/butuzov/Debug-Bar-Rewrite-Rules \
		--svn=http://plugins.svn.wordpress.org/debug-bar-rewrite-rules \
		--user="$(WP_SVN_USER)" --pass="$(WP_SVN_PASS)"
