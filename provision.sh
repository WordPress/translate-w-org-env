#!/bin/bash

# This scripts tries to emulate the VVV one, available at
# https://github.com/WordPress/meta-environment/blob/59c83e865c7d37e6fa1700bfef7150929a8586a3/wordpressorg.test/provision/vvv-init.sh#L88

RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
RESET=`tput sgr0`

function print_header() {
  echo ''
  echo '******************************************************************************************'
  echo "$1"
  echo '******************************************************************************************'
  echo ''
}

function check_if_path_exists() {
  echo "${YELLOW}Checking if the path exists.${RESET}"
  if [ -n "$1" ]; then
    if [ ! -d "$1" ]; then
      echo "${RED}The path $1 doesn't exist.${RESET}"
      exit
    else
      echo "${GREEN}The path $1 exists.${RESET}"
    fi
  else
      echo "${RED}You need to provide the path where WordPress is installed on your machine. ${RESET}"
      exit
  fi
}

function check_if_php_is_installed() {
  echo "${YELLOW}Checking if PHP is installed in the path provided.${RESET}"
  type php
  if [ $? -ne 0 ]; then
    echo "${RED}You need PHP installed on your machine. Check if PHP is installed and the binary in your \$PATH environment variable.${RESET}"
    exit
  else
    echo "${GREEN}PHP is installed.${RESET}"
  fi
}

function check_if_mysql_is_installed() {
  echo "${YELLOW}Checking if MySQL is installed in the path provided.${RESET}"
  type mysql
  if [ $? -ne 0 ]; then
    echo "${RED}You need MySQL installed on your machine. Check if MySQL is installed and the binary in your \$PATH environment variable.${RESET}"
    exit
  else
    echo "${GREEN}MySQL is installed.${RESET}"
  fi
}

function check_if_wp_cli_is_installed() {
  echo "${YELLOW}Checking if WP-CLI is installed in the path provided.${RESET}"
  wp --info
  if [ $? -ne 0 ]; then
    echo "${RED}You need the WP-CLI installed on your machine. Check if WP-CLI is installed and the binary in your \$PATH environment variable.${RESET}"
    exit
  else
    echo "${GREEN}WP-CLI is installed.${RESET}"
  fi
}

function check_if_wp_is_installed() {
  echo "${YELLOW}Checking if WordPress is installed in the path provided.${RESET}"
  wp core is-installed --path=$1
  if [ $? -ne 0 ]; then
    echo "${RED}The path $1 has not a WordPress installation.${RESET}"
    exit
  else
    echo "${GREEN}WordPress is installed at $1.${RESET}"
  fi
}

function ask_if_the_user_wants_to_reset_wordpress() {
  read -p "${RED}We are going to reset your WordPress. Are you sure? {y/n}${RESET}" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${GREEN}Resetting your WordPress.${RESET}"
  else
    echo "${GREEN}Stopping the script.${RESET}"
    exit
  fi
}

function reset_wordpress() {
  echo "${YELLOW}Resetting the database.${RESET}"
  wp db reset --path=$1 --yes
  echo "${GREEN}Database reset.${RESET}"
}

function install_wordpress() {
  echo "${YELLOW}Installing WordPress.${RESET}"
  wp core install --path=$1 --url=$2 --title="Translation local environment" \
  --admin_user=admin --admin_password=password --admin_email=info@example.test
  echo "${GREEN}WordPress installed.${RESET}"
  echo "${YELLOW}Updating WordPress.${RESET}"
  wp core update --path=$1
  echo "${GREEN}WordPress updated.${RESET}"
  echo "${YELLOW}Deactivating and uninstalling all plugins.${RESET}"
  wp plugin deactivate --all --path=$1
  wp plugin uninstall --all --skip-delete --path=$1
  echo "${GREEN}Plugins and deactivated and uninstalled.${RESET}"
  echo "${YELLOW}Updating themes.${RESET}"
  wp theme update --all --path=$1
  echo "${GREEN}Themes updated.${RESET}"
}

function clone_repos() {
  # Get a copy from GlotPress and Meta only if the folder doesn't exist
  # Pull the repo looking for updates
  echo "${YELLOW}Cloning and/or pulling GlotPress repo.${RESET}"
  [[ -d glotpress.git ]] || git clone https://github.com/GlotPress/GlotPress-WP.git glotpress.git
  cd glotpress.git
  git config pull.ff only
  git pull
  cd -
  echo "${GREEN}GlotPress repo cloned and/or updated.${RESET}"
  echo "${YELLOW}Cloning and/or pulling meta repo.${RESET}"
  [[ -d meta.git ]] || git clone https://github.com/wordpress/wordpress.org meta.git
  cd meta.git
  git config pull.ff only
  git pull
  cd -
  echo "${GREEN}Meta repo cloned and/or updated.${RESET}"
}

function copy_repos() {
  # Do the same that the mappings in the .wp-env.json file
  echo "${YELLOW}Coping some items from the repos to WordPress.${RESET}"
  cp -f -R ./meta.git/wordpress.org/public_html/wp-content/mu-plugins $1/wp-content/
  cp -f -R ./meta.git/wordpress.org/public_html/wp-content/plugins $1/wp-content/
  cp -f -R ./meta.git/wordpress.org/public_html/wp-content/themes $1/wp-content/
  cp -f -R ./meta.git/wordpress.org/public_html/wp-content/upgrade $1/wp-content/
  cp -f -R ./meta.git/wordpress.org/public_html/wp-content/uploads $1/wp-content/
  cp -f -R ./glotpress.git/ $1/wp-content/plugins/glotpress
  cp -f -R ./meta.git/global.wordpress.org/public_html/wp-content/themes/rosetta $1/wp-content/themes/
  cp ./.wp-env/.htaccess $1/
  echo "${GREEN}Items copied.${RESET}"
}

function set_environment_variables() {
  wp config set WP_ENVIRONMENT_TYPE local --path=$1
  wp config set WPORGPATH $1/wp-content/themes/pub/wporg/inc/ --path=$1
  wp config set GP_URL_BASE '/' --path=$1
  wp config set GP_TMPL_PATH $1/wp-content/plugins/wporg-gp-customizations/templates/ --path=$1
  wp config set FEATURE_2021_GLOBAL_HEADER_FOOTER false --raw --path=$1
}

# Todo: add in the meta.git .gitignore file all the files that have been copied to it

while getopts "ht:d:p:m:w:" opt; do
  case ${opt} in
      h )
        echo "Usage:"
        echo "    \"./provision.sh\" to deploy a Docker environment"
        echo "    \"./provision.sh -t lamp -p /Users/myuser/code/wordpress/wp\" to deploy a lamp environment at \"/Users/myuser/code/wordpress/wp\""
        exit 0
        ;;
      t )
        TYPE=$OPTARG
        ;;
      d )
        PROJECT_PATH=$OPTARG
        ;;
  esac
done

# This constant will be empty if the environment is local. In the Docker environment will be used to store the
# npm command
WP_CLI_PREFIX="npm run wp-env run cli"
# This constant will be empty if the environment is Docker. In the LAMP environment it will be used to store
# the WordPress path
WP_CLI_SUFFIX=""

if [ "$TYPE" == "lamp" ]; then
  check_if_path_exists $PROJECT_PATH
  check_if_php_is_installed
  check_if_mysql_is_installed
  check_if_wp_cli_is_installed
  check_if_wp_is_installed $PROJECT_PATH
  ask_if_the_user_wants_to_reset_wordpress
  LOCAL_URL=`wp option get siteurl --path=$PROJECT_PATH`
  reset_wordpress $PROJECT_PATH
  install_wordpress $PROJECT_PATH $LOCAL_URL
  clone_repos
  copy_repos $PROJECT_PATH
  set_environment_variables $PROJECT_PATH
  WP_CLI_PREFIX=""
  WP_CLI_SUFFIX="--path=$PROJECT_PATH"
fi

SITE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
WPCLI_PLUGINS=( debug-bar debug-bar-cron query-monitor stop-emails )
PLUGINS_TO_TRANSLATE=( akismet bbpress blogger-importer blogware-importer wpcat2tag-importer debug-bar \
  dotclear-importer greymatter-importer livejournal-importer movabletype-importer opml-importer rss-importer \
  stp-importer textpattern-importer theme-check tumblr-importer utw-importer user-switching wordpress-importer )
META_TO_TRANSLATE=( browsehappy forums rosetta wordcamp-theme plugins themes )
APPS_TO_TRANSLATE=( android ios wordcamp-android )


# Set the permalinks format, because GlotPress needs it
print_header "Updating the permalinks format"
if [ "$TYPE" == "lamp" ]; then
  $WP_CLI_PREFIX wp rewrite structure /%postname%/ --hard $WP_CLI_SUFFIX
else
  $WP_CLI_PREFIX wp rewrite structure '/%postname%/' '"--hard"' $WP_CLI_SUFFIX
fi

# Enable the rosetta theme
# To see the available themes, execute: npm run wp-env run cli wp theme list
print_header "Enabling the rosetta theme"
$WP_CLI_PREFIX wp theme activate rosetta $WP_CLI_SUFFIX
print_header "Importing the translation tables"
$WP_CLI_PREFIX wp db import tmp/translate_tables.sql $WP_CLI_SUFFIX
# Remove this table, because the old dump hasn't some fields
if [ "$TYPE" == "lamp" ]; then
  $WP_CLI_PREFIX wp db query 'DROP TABLE translate_project_translation_status' $WP_CLI_SUFFIX
else
  $WP_CLI_PREFIX wp db query '""DROP TABLE translate_project_translation_status""' $WP_CLI_SUFFIX
fi
$WP_CLI_PREFIX wp db import tmp/translate_project_translation_status.sql $WP_CLI_SUFFIX

print_header "Updating the database prefix for GlotPress as variable in the wp-config.php"
if [ "$TYPE" == "lamp" ]; then
  $WP_CLI_PREFIX wp config set gp_table_prefix translate_ --type=variable $WP_CLI_SUFFIX
else
  $WP_CLI_PREFIX wp config set gp_table_prefix translate_ \"--type=variable\" $WP_CLI_SUFFIX
fi

print_header "Updating the site name"
if [ "$TYPE" == "lamp" ]; then
  $WP_CLI_PREFIX wp option update blogname translate.wordpress.local $WP_CLI_SUFFIX
  $WP_CLI_PREFIX wp option update blogdescription 'WordPress.org translation system' $WP_CLI_SUFFIX
else
  $WP_CLI_PREFIX wp option update blogname \'translate.wordpress.local\' $WP_CLI_SUFFIX
  $WP_CLI_PREFIX wp option update blogdescription \'WordPress.org translation system\' $WP_CLI_SUFFIX
fi

## Todo: try to update this on the source code
print_header "Updating some files that have been modified for the local environment"
if [ "$TYPE" == "lamp" ]; then
  cp -v tmp/class-index.php $PROJECT_PATH/wp-content/plugins/wporg-gp-routes/inc/routes/class-index.php
  cp -v tmp/functions.php $PROJECT_PATH/wp-content/themes/pub/wporg/functions.php
  cp -v tmp/header.php $PROJECT_PATH/wp-content/themes/pub/wporg/inc/header.php
else
  cp tmp/class-index.php ./meta.git/wordpress.org/public_html/wp-content/plugins/wporg-gp-routes/inc/routes/class-index.php
  cp tmp/functions.php meta.git/wordpress.org/public_html/wp-content/themes/pub/wporg/functions.php
  cp tmp/header.php meta.git/wordpress.org/public_html/wp-content/themes/pub/wporg/inc/header.php
fi

print_header "Creating some new users"
if [ "$TYPE" == "lamp" ]; then
  $WP_CLI_PREFIX wp user create translator01 translator01@example.com --user_pass=password --role=subscriber $WP_CLI_SUFFIX
else
  $WP_CLI_PREFIX wp user create translator01 translator01@example.com '"--user_pass=password"' '"--role=subscriber"' $WP_CLI_SUFFIX
fi

# See https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/#installing-a-plugin-or-theme-on-the-development-instance
# This if executes the plugin installation with docker-compose on Linux systems and with npm on Mac
# This only works if we have 1 folder inside ~/wp-env
# Todo: get the ~/wp-env folder where is the WordPress Docker configuration if the user has more than one Docker installation
print_header "Installing and activating some plugins"
if [ "$TYPE" == "lamp" ]; then
  $WP_CLI_PREFIX wp plugin install --activate ${WPCLI_PLUGINS[@]} $WP_CLI_SUFFIX
elif [ -d "~/wp-env" ]; then
  WPENV_PATH=$(ls ~/wp-env -1 | head -1)
  cd ~/wp-env/$WPENV_PATH
  docker-compose run --rm -u $(id -u) -e HOME=/tmp cli plugin install --activate ${WPCLI_PLUGINS[@]}
  cd -
else
  $WP_CLI_PREFIX wp plugin install '"--activate"' ${WPCLI_PLUGINS[@]} $WP_CLI_SUFFIX
fi

# To see the GlotPress plugins, execute: npm run wp-env run cli wp plugin list | grep gp
print_header "Activating GlotPress and its plugins"
$WP_CLI_PREFIX wp plugin activate glotpress wporg-gp-js-warnings wporg-gp-routes wporg-gp-custom-stats \
wporg-gp-custom-warnings wporg-gp-help wporg-gp-plugin-directory wporg-gp-slack-integrations wporg-gp-theme-directory \
wporg-gp-translation-fixer wporg-gp-translation-suggestions wporg-gp-customizations glotpress-translate-bridge $WP_CLI_SUFFIX

print_header "Downloading and importing the WordPress strings"
# Download the WordPress po file and import it
curl -o tmp/po/wordpress-dev.po https://translate.wordpress.org/projects/wp/dev/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated
$WP_CLI_PREFIX wp glotpress import-originals wp/dev tmp/po/wordpress-dev.po $WP_CLI_SUFFIX
curl -o tmp/po/continents.po https://translate.wordpress.org/projects/wp/dev/cc/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated
$WP_CLI_PREFIX wp glotpress import-originals wp/dev/cc tmp/po/continents.po $WP_CLI_SUFFIX
curl -o tmp/po/admin.po https://translate.wordpress.org/projects/wp/dev/admin/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated
$WP_CLI_PREFIX wp glotpress import-originals wp/dev/admin tmp/po/admin.po $WP_CLI_SUFFIX
curl -o tmp/po/admin-network.po https://translate.wordpress.org/projects/wp/dev/admin/network/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated
$WP_CLI_PREFIX wp glotpress import-originals wp/dev/admin/network tmp/po/admin-network.po $WP_CLI_SUFFIX

print_header "Downloading and importing some plugin strings"
# Some plugins or readme will fail, because it doesn't have the stable version
for plugin in "${PLUGINS_TO_TRANSLATE[@]}"
do :
  curl -o "tmp/po/${plugin}-dev.po" "https://translate.wordpress.org/projects/wp-plugins/${plugin}/dev/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  $WP_CLI_PREFIX wp glotpress import-originals wp-plugins/$plugin/dev tmp/po/$plugin-dev.po $WP_CLI_SUFFIX
  $WP_CLI_PREFIX wp glotpress import-originals wp-plugins/$plugin/stable tmp/po/$plugin-dev.po $WP_CLI_SUFFIX
  curl -o "tmp/po/${plugin}-dev-readme.po" "https://translate.wordpress.org/projects/wp-plugins/${plugin}/dev-readme/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  $WP_CLI_PREFIX wp glotpress import-originals wp-plugins/$plugin/dev-readme tmp/po/$plugin-dev-readme.po $WP_CLI_SUFFIX
  $WP_CLI_PREFIX wp glotpress import-originals wp-plugins/$plugin/stable-readme tmp/po/$plugin-dev-readme.po $WP_CLI_SUFFIX
done

print_header "Downloading and importing some meta strings"
for element in "${META_TO_TRANSLATE[@]}"
do :
  curl -o "tmp/po/${element}.po" "https://translate.wordpress.org/projects/meta/${element}/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  $WP_CLI_PREFIX wp glotpress import-originals meta/$element tmp/po/$element.po $WP_CLI_SUFFIX
done

print_header "Downloading and importing some apps strings"
for element in "${APPS_TO_TRANSLATE[@]}"
do :
  curl -o "tmp/po/${element}.po" "https://translate.wordpress.org/projects/apps/${element}/dev/es/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  $WP_CLI_PREFIX wp glotpress import-originals apps/$element/dev tmp/po/$element.po $WP_CLI_SUFFIX
  curl -o "tmp/po/${element}-release-notes.po" "https://translate.wordpress.org/projects/apps/${element}/release-notes/es/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  $WP_CLI_PREFIX wp glotpress import-originals apps/$element/release-notes tmp/po/$element-release-notes.po $WP_CLI_SUFFIX
done

print_header "Removing the .po files"
rm tmp/po/*.po

# Set the permalinks format, because GlotPress needs it
print_header "Updating the rewrite structure"
if [ "$TYPE" == "lamp" ]; then
  $WP_CLI_PREFIX wp rewrite structure /%postname%/ --hard $WP_CLI_SUFFIX
  $WP_CLI_PREFIX wp rewrite flush --hard $WP_CLI_SUFFIX
else
  $WP_CLI_PREFIX wp rewrite structure '"/%postname%/"' '"--hard"' $WP_CLI_SUFFIX
  $WP_CLI_PREFIX wp rewrite flush '"--hard"' $WP_CLI_SUFFIX
fi

print_header "Running the cron"
if [ "$TYPE" == "lamp" ]; then
  $WP_CLI_PREFIX wp cron event run --due-now $WP_CLI_SUFFIX
else
  $WP_CLI_PREFIX wp cron event run '"--due-now"' $WP_CLI_SUFFIX
fi