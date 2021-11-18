#!/bin/bash

# This scripts tries to emulate the VVV one, available at
# https://github.com/WordPress/meta-environment/blob/59c83e865c7d37e6fa1700bfef7150929a8586a3/wordpressorg.test/provision/vvv-init.sh#L88

# Load the helper functions
source ./helper-functions.sh
# Todo: check that the software is installed: npm, git, curl,...
# Todo: add in the meta.git .gitignore file all the files that have been copied to it

SITE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SVN_PLUGINS=( akismet bbpress debug-bar debug-bar-cron query-monitor email-post-changes speakerdeck-embed supportflow syntaxhighlighter two-factor wordpress-importer )
WPCLI_PLUGINS=( jetpack tinymce-code-element wp-multibyte-patch )
WP_LOCALES=( ja es_ES )

print_header "Cloning and/or pulling GlotPress and WordPress.org"
# Get a copy from GlotPress and Meta only if the folder doesn't exist
# Pull the repo looking for updates
[[ -d glotpress.git ]] || git clone https://github.com/GlotPress/GlotPress-WP.git glotpress.git
cd glotpress.git
git config --local pull.ff only
git pull
cd -
[[ -d meta.git ]] || git clone https://github.com/wordpress/wordpress.org meta.git
cd meta.git
git config --local pull.ff only
git pull
git pull
cd -
# todo: remove the meta-environment-vvv.git clone and the other commands when we have the first beta version
[[ -d meta-environment-vvv.git ]] || git clone https://github.com/WordPress/meta-environment meta-environment-vvv.git
cd meta-environment-vvv.git
git config --local pull.ff only
git pull
cd -

# Set the permalinks format, because GlotPress needs it
print_header "Updating the permalinks format"
npm run wp-env run cli wp option update permalink_structure '\/\%postname\%\/'

# Enable the rosetta theme
# To see the available themes, execute: npm run wp-env run cli wp theme list
print_header "Enabling the rosetta theme"
npm run wp-env run cli wp theme activate rosetta

print_header "Importing the translation tables"
npm run wp-env run cli wp db import tmp/translate_tables.sql

print_header "Updating the database prefix for GlotPress as variable in the wp-config.php"
npm run wp-env run cli wp config set gp_table_prefix translate_ \"--type=variable\"

print_header "Updating the site name"
npm run wp-env run cli wp option update blogname "translate.wordpress.local"

## Todo: try to update this on the source code
print_header "Updating some files that have been modified for the local environment"
cp tmp/class-index.php ./meta.git/wordpress.org/public_html/wp-content/plugins/wporg-gp-routes/inc/routes/class-index.php
cp tmp/functions.php meta.git/wordpress.org/public_html/wp-content/themes/pub/wporg/functions.php
cp tmp/header.php meta.git/wordpress.org/public_html/wp-content/themes/pub/wporg/inc/header.php

print_header "Downloading some plugins"
for i in "${SVN_PLUGINS[@]}"
do :
	svn co https://plugins.svn.wordpress.org/$i/trunk ./meta.git/wordpress.org/public_html/wp-content/plugins/$i
done
print_header "Activating some plugins"
npm run wp-env run cli wp plugin activate ${SVN_PLUGINS[@]}
print_header "Installing and activating some plugins"
npm run wp-env run cli wp plugin install \"--activate\" ${WPCLI_PLUGINS[@]}

# To see the GlotPress plugins, execute: npm run wp-env run cli wp plugin list | grep gp
print_header "Activating GlotPress and its plugins"
npm run wp-env run cli wp plugin activate glotpress wporg-gp-js-warnings wporg-gp-routes wporg-gp-custom-warnings wporg-gp-help wporg-gp-plugin-directory wporg-gp-slack-integrations wporg-gp-theme-directory wporg-gp-translation-fixer wporg-gp-translation-suggestions wporg-gp-customizations

# Create some folders
echo "Creating some folders"
mkdir -p wp-content/languages
rm -rf wp-content/languages                #todo: remove it in production
mkdir -p wp-content/languages/themes
mkdir -p wp-content/languages/plugins

echo "Installing translations into the core"
npm run wp-env run cli wp language core install ${WP_LOCALES[@]}
npm run wp-env run cli wp language core update # Get plugin/theme translations

echo "Installing translations from translate.wordpress.org..."
for locale in "${WP_LOCALES[@]}"
do :
  gplocale=${locale%_*}

	wme_download_pomo "${gplocale}" "meta/rosetta" "$SITE_DIR/wp-content/languages/plugins/rosetta-${locale}"
	wme_download_pomo "${gplocale}" "meta/themes" "$SITE_DIR/wp-content/languages/plugins/wporg-themes-${locale}"
	wme_download_pomo "${gplocale}" "meta/plugins-v3" "$SITE_DIR/wp-content/languages/plugins/wporg-plugins-${locale}"
	wme_download_pomo "${gplocale}" "meta/forums" "$SITE_DIR/wp-content/languages/themes/wporg-forums-${locale}"
	wme_download_pomo "${gplocale}" "meta/p2-breathe" "$SITE_DIR/wp-content/languages/themes/p2-breathe-${locale}"
	wme_download_pomo "${gplocale}" "meta/o2" "$SITE_DIR/wp-content/languages/themes/o2-${locale}"
done