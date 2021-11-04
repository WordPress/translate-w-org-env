#!/bin/bash

# This scripts tries to emulate the VVV one, available at
# https://github.com/WordPress/meta-environment/blob/59c83e865c7d37e6fa1700bfef7150929a8586a3/wordpressorg.test/provision/vvv-init.sh#L88

# Load the helper functions
source ./helper-functions.sh

SITE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

SVN_PLUGINS=( akismet bbpress debug-bar debug-bar-cron email-post-changes speakerdeck-embed supportflow syntaxhighlighter two-factor wordpress-importer )
WPCLI_PLUGINS=( jetpack tinymce-code-element wp-multibyte-patch )
WP_LOCALES=( ja es_ES )

# Get a copy from GlotPress and Meta only if the folder doesn't exist
[[ -d glotpress.git ]] || git clone https://github.com/GlotPress/GlotPress-WP.git glotpress.git
[[ -d meta.git ]] || git clone https://github.com/wordpress/wordpress.org meta.git

# Create some folders
printf "Creating some folders"
mkdir -p wp-content/languages
rm -rf wp-content/languages                #todo: remove it in production
mkdir -p wp-content/languages/themes
mkdir -p wp-content/languages/plugins

printf "Installing translations into the core"
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
