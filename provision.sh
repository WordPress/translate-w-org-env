#!/bin/bash

# This scripts tries to emulate the VVV one, available at
# https://github.com/WordPress/meta-environment/blob/59c83e865c7d37e6fa1700bfef7150929a8586a3/wordpressorg.test/provision/vvv-init.sh#L88

function print_header() {
  echo ''
  echo '******************************************************************************************'
  echo "$1"
  echo '******************************************************************************************'
  echo ''
}

# Todo: add in the meta.git .gitignore file all the files that have been copied to it

SITE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
WPCLI_PLUGINS=( debug-bar debug-bar-cron query-monitor stop-emails )
PLUGINS_TO_TRANSLATE=( akismet bbpress blogger-importer blogware-importer wpcat2tag-importer debug-bar \
  dotclear-importer greymatter-importer livejournal-importer movabletype-importer opml-importer rss-importer \
  stp-importer textpattern-importer theme-check tumblr-importer utw-importer user-switching wordpress-importer )
META_TO_TRANSLATE=( browsehappy forums rosetta wordcamp-theme plugins themes )
APPS_TO_TRANSLATE=( android ios wordcamp-android )


# Set the permalinks format, because GlotPress needs it
print_header "Updating the permalinks format"
npm run wp-env run cli wp rewrite structure '"/%postname%/"' '"--hard"'

# Enable the rosetta theme
# To see the available themes, execute: npm run wp-env run cli wp theme list
print_header "Enabling the rosetta theme"
npm run wp-env run cli wp theme activate rosetta

print_header "Importing the translation tables"
npm run wp-env run cli wp db import tmp/translate_tables.sql
# Remove this table, because the old dump hasn't some fields
npm run wp-env run cli wp db query '""DROP TABLE translate_project_translation_status""'
npm run wp-env run cli wp db import tmp/translate_project_translation_status.sql

print_header "Updating the database prefix for GlotPress as variable in the wp-config.php"
npm run wp-env run cli wp config set gp_table_prefix translate_ \"--type=variable\"

print_header "Updating the site name"
npm run wp-env run cli wp option update blogname \'translate.wordpress.local\'
npm run wp-env run cli wp option update blogdescription \'WordPress.org translation system\'

## Todo: try to update this on the source code
print_header "Updating some files that have been modified for the local environment"
cp tmp/class-index.php ./meta.git/wordpress.org/public_html/wp-content/plugins/wporg-gp-routes/inc/routes/class-index.php
cp tmp/functions.php meta.git/wordpress.org/public_html/wp-content/themes/pub/wporg/functions.php
cp tmp/header.php meta.git/wordpress.org/public_html/wp-content/themes/pub/wporg/inc/header.php

print_header "Creating some new users"
npm run wp-env run cli wp  user create translator01 translator01@example.com '"--user_pass=password"' '"--role=subscriber"'
npm run wp-env run cli wp  user create translator02 translator02@example.com '"--user_pass=password"' '"--role=subscriber"'
npm run wp-env run cli wp  user create translator03 translator03@example.com '"--user_pass=password"' '"--role=subscriber"'
npm run wp-env run cli wp  user create translator04 translator04@example.com '"--user_pass=password"' '"--role=subscriber"'
npm run wp-env run cli wp  user create translator05 translator05@example.com '"--user_pass=password"' '"--role=subscriber"'

print_header "Installing and activating some plugins"
npm run wp-env run cli wp plugin install '"--activate"' ${WPCLI_PLUGINS[@]}

# To see the GlotPress plugins, execute: npm run wp-env run cli wp plugin list | grep gp
print_header "Activating GlotPress and its plugins"
npm run wp-env run cli wp plugin activate glotpress wporg-gp-js-warnings wporg-gp-routes wporg-gp-custom-stats \
wporg-gp-custom-warnings wporg-gp-help wporg-gp-plugin-directory wporg-gp-slack-integrations wporg-gp-theme-directory \
wporg-gp-translation-fixer wporg-gp-translation-suggestions wporg-gp-customizations glotpress-translate-bridge

print_header "Downloading and importing the WordPress strings"
# Download the WordPress po file and import it
npm run wp-env run cli curl '"-o"' tmp/po/wordpress-dev.po https://translate.wordpress.org/projects/wp/dev/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated
npm run wp-env run cli wp glotpress import-originals '"wp/dev"' tmp/po/wordpress-dev.po
npm run wp-env run cli curl '"-o"' tmp/po/continents.po https://translate.wordpress.org/projects/wp/dev/cc/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated
npm run wp-env run cli wp glotpress import-originals '"wp/dev/cc"' tmp/po/continents.po
npm run wp-env run cli curl '"-o"' tmp/po/admin.po https://translate.wordpress.org/projects/wp/dev/admin/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated
npm run wp-env run cli wp glotpress import-originals '"wp/dev/admin"' tmp/po/admin.po
npm run wp-env run cli curl '"-o"' tmp/po/admin-network.po https://translate.wordpress.org/projects/wp/dev/admin/network/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated
npm run wp-env run cli wp glotpress import-originals '"wp/dev/admin/network"' tmp/po/admin-network.po

print_header "Downloading and importing some plugin strings"
# Some plugins or readme will fail, because it doesn't have the stable version
for plugin in "${PLUGINS_TO_TRANSLATE[@]}"
do :
  curl -o "tmp/po/${plugin}-dev.po" "https://translate.wordpress.org/projects/wp-plugins/${plugin}/dev/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  npm run wp-env run cli wp glotpress import-originals "wp-plugins/${plugin}/dev" "tmp/po/${plugin}-dev.po"
  npm run wp-env run cli wp glotpress import-originals "wp-plugins/${plugin}/stable" "tmp/po/${plugin}-dev.po"
  curl -o "tmp/po/${plugin}-dev-readme.po" "https://translate.wordpress.org/projects/wp-plugins/${plugin}/dev-readme/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  npm run wp-env run cli wp glotpress import-originals "wp-plugins/${plugin}/dev-readme" "tmp/po/${plugin}-dev-readme.po"
  npm run wp-env run cli wp glotpress import-originals "wp-plugins/${plugin}/stable-readme" "tmp/po/${plugin}-dev-readme.po"
done

print_header "Downloading and importing some meta strings"
for element in "${META_TO_TRANSLATE[@]}"
do :
  curl -o "tmp/po/${element}.po" "https://translate.wordpress.org/projects/meta/${element}/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  npm run wp-env run cli wp glotpress import-originals "meta/${element}" "tmp/po/${element}.po"
done

print_header "Downloading and importing some apps strings"
for element in "${APPS_TO_TRANSLATE[@]}"
do :
  curl -o "tmp/po/${element}.po" "https://translate.wordpress.org/projects/apps/${element}/dev/es/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  npm run wp-env run cli wp glotpress import-originals "apps/${element}/dev" "tmp/po/${element}.po"
  curl -o "tmp/po/${element}-release-notes.po" "https://translate.wordpress.org/projects/apps/${element}/release-notes/es/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  npm run wp-env run cli wp glotpress import-originals "apps/${element}/release-notes" "tmp/po/${element}-release-notes.po"
done

print_header "Removing the .po files"
rm tmp/po/*.po

# Set the permalinks format, because GlotPress needs it
print_header "Updating the rewrite structure"
npm run wp-env run cli wp rewrite structure '"/%postname%/"' '"--hard"'
npm run wp-env run cli wp rewrite flush '"--hard"'

print_header "Running the cron"
npm run wp-env run cli wp cron event run '"--due-now"'
