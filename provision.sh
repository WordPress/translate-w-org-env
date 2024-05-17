#!/bin/bash -e

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
  git checkout develop
  cd -
  echo "${GREEN}GlotPress repo cloned and/or updated.${RESET}"
  echo "${YELLOW}Cloning and/or pulling meta repo.${RESET}"
  [[ -d meta.git ]] || git clone https://github.com/wordpress/wordpress.org meta.git
  cd meta.git
  git config pull.ff only
  git pull
  git checkout trunk
  cd -
  echo "${GREEN}Meta repo cloned and/or updated.${RESET}"
  echo "${YELLOW}Cloning and/or pulling meta repo.${RESET}"
  [[ -d wporg-mu-plugins.git ]] || git clone https://github.com/wordpress/wporg-mu-plugins wporg-mu-plugins.git
  cd wporg-mu-plugins.git
  git config pull.ff only
  git pull
  git checkout trunk
  npm install
  npm run build
  echo "${GREEN}WordPress.org mu-plugins repo cloned and/or updated.${RESET}"
  cd -
}

function copy_repos() {
  project_path=$1
  shift
  plugins_to_translate=$@
  # Do the same that the mappings in the .wp-env.json file
  echo "${YELLOW}Copying some items from the repos to WordPress.${RESET}"
  rm -rf $project_path/wp-content/themes $project_path/wp-content/mu-plugins $project_path/wp-content/plugins
  mkdir -p $project_path/wp-content/themes/pub $project_path/wp-content/plugins $project_path/wp-content/mu-plugins
  ln -s `pwd`/wporg-mu-plugins.git/mu-plugins/ $project_path/wp-content/mu-plugins/pub-sync
  cp tmp/_loader.php $project_path/wp-content/mu-plugins
  for plugin in $plugins_to_translate; do
    ln -s `pwd`/meta.git/wordpress.org/public_html/wp-content/plugins/$plugin $project_path/wp-content/plugins/$plugin
  done
  ln -s `pwd`/meta.git/global.wordpress.org/public_html/wp-content/mu-plugins/roles $project_path/wp-content/plugins/roles
  ln -s `pwd`/meta.git/wordpress.org/public_html/wp-content/themes $project_path/wp-content/themes
  ln -s `pwd`/glotpress.git/ $project_path/wp-content/plugins/glotpress
  ln -s `pwd`/meta.git/wordpress.org/public_html/wp-content/themes/pub/wporg $project_path/wp-content/themes/pub/
  cp ./.wp-env/.htaccess $project_path/
  echo "${GREEN}Items copied.${RESET}"
}

function set_environment_variables() {
  wp config set WP_ENVIRONMENT_TYPE local --path=$1
  wp config set WPORGPATH $1/wp-content/themes/pub/wporg/inc/ --path=$1
  wp config set GP_URL_BASE '/' --path=$1
  wp config set GP_TMPL_PATH $1/wp-content/plugins/wporg-gp-customizations/templates/ --path=$1
  wp config set FEATURE_2021_GLOBAL_HEADER_FOOTER false --raw --path=$1
  wp config set WP_CORE_STABLE_BRANCH '6.3' --raw --path=$1
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
CURL_OPTIONS="--fail --retry 3 --compressed"

SITE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
WPCLI_PLUGINS=( debug-bar debug-bar-cron query-monitor stop-emails laravel-dd )
PLUGINS_TO_TRANSLATE=( akismet bbpress blogger-importer wpcat2tag-importer debug-bar \
  dotclear-importer greymatter-importer livejournal-importer movabletype-importer opml-importer rss-importer \
  stp-importer textpattern-importer theme-check tumblr-importer utw-importer user-switching wordpress-importer )
META_TO_TRANSLATE=( browsehappy forums rosetta wordcamp-theme plugins themes )
APPS_TO_TRANSLATE=( android ios wordcamp-android )
TRANSLATE_PLUGINS=( glotpress-translate-bridge wp-i18n-teams wporg-gp-custom-stats wporg-gp-custom-errors wporg-gp-custom-warnings wporg-gp-customizations wporg-gp-help wporg-gp-js-warnings wporg-gp-plugin-directory wporg-gp-routes wporg-gp-slack-integrations wporg-gp-theme-directory wporg-gp-translation-fixer wporg-gp-translation-suggestions )

if [ "$TYPE" == "lamp" ]; then
  check_if_path_exists $PROJECT_PATH
  check_if_php_is_installed
  check_if_mysql_is_installed
  check_if_wp_cli_is_installed
  check_if_wp_is_installed $PROJECT_PATH
  ask_if_the_user_wants_to_reset_wordpress
  LOCAL_URL=`wp option --skip-plugins get siteurl --path=$PROJECT_PATH`
  reset_wordpress $PROJECT_PATH
  install_wordpress $PROJECT_PATH $LOCAL_URL
  clone_repos
  copy_repos $PROJECT_PATH ${TRANSLATE_PLUGINS[@]}
  set_environment_variables $PROJECT_PATH
  WP_CLI_PREFIX=""
  WP_CLI_SUFFIX="--path=$PROJECT_PATH"
fi



# Set the permalinks format, because GlotPress needs it
print_header "Updating the permalinks format"
if [ "$TYPE" == "lamp" ]; then
  $WP_CLI_PREFIX wp rewrite structure /%postname%/ --hard $WP_CLI_SUFFIX
else
  $WP_CLI_PREFIX wp rewrite structure '/%postname%/' '"--hard"' $WP_CLI_SUFFIX
fi

# Enable the rosetta theme
# To see the available themes, execute: npm run wp-env run cli wp theme list
print_header "Enabling the wporg theme"
$WP_CLI_PREFIX wp theme activate pub/wporg $WP_CLI_SUFFIX
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
$WP_CLI_PREFIX wp plugin activate glotpress roles/rosetta-roles ${TRANSLATE_PLUGINS[@]} $WP_CLI_SUFFIX

print_header "Downloading and importing the WordPress strings"
# Download the WordPress po file and import it
test -f tmp/po/wordpress-dev.po || curl $CURL_OPTIONS -o tmp/po/wordpress-dev.po https://translate.wordpress.org/projects/wp/dev/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated
$WP_CLI_PREFIX wp glotpress import-originals wp/dev tmp/po/wordpress-dev.po $WP_CLI_SUFFIX
test -f tmp/po/continents.po || curl $CURL_OPTIONS -o tmp/po/continents.po https://translate.wordpress.org/projects/wp/dev/cc/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated
$WP_CLI_PREFIX wp glotpress import-originals wp/dev/cc tmp/po/continents.po $WP_CLI_SUFFIX
test -f tmp/po/admin.po || curl $CURL_OPTIONS -o tmp/po/admin.po https://translate.wordpress.org/projects/wp/dev/admin/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated
$WP_CLI_PREFIX wp glotpress import-originals wp/dev/admin tmp/po/admin.po $WP_CLI_SUFFIX
test -f tmp/po/admin-network.po || curl $CURL_OPTIONS -o tmp/po/admin-network.po https://translate.wordpress.org/projects/wp/dev/admin/network/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated
$WP_CLI_PREFIX wp glotpress import-originals wp/dev/admin/network tmp/po/admin-network.po $WP_CLI_SUFFIX

print_header "Downloading and importing some core translations"
for i in 6.3 6.4; do
  test -f tmp/po/wp-$i-es.po || curl $CURL_OPTIONS -o tmp/po/wp-$i-es.po "https://translate.wordpress.org/projects/wp/$i.x/es/default/export-translations/?filters%5Btranslated%5D=yes&filters%5Bstatus%5D=current"
done

for lang in af ar bg ckb cs da de el es et fr fa fi gl he hi hr hu id it lt lv ja ka ko mk ml mn mr nl pl pt ro ru sk sv tr uk vi zh-cn zh-tw; do
  test -f tmp/po/wp-dev-$lang.po || curl $CURL_OPTIONS -o tmp/po/wp-dev-$lang.po "https://translate.wordpress.org/projects/wp/dev/$lang/default/export-translations/?filters%5Btranslated%5D=yes&filters%5Bstatus%5D=current"
  $WP_CLI_PREFIX wp glotpress translation-set import wp/dev $lang tmp/po/wp-dev-$lang.po $WP_CLI_SUFFIX
done

print_header "Downloading and importing some plugin strings"
# Some plugins or readme will fail, because it doesn't have the stable version, so disable the error out option temporarily.
set +e
for plugin in "${PLUGINS_TO_TRANSLATE[@]}"
do :
  test -f "tmp/po/${plugin}-dev.po" || curl $CURL_OPTIONS -o "tmp/po/${plugin}-dev.po" "https://translate.wordpress.org/projects/wp-plugins/${plugin}/dev/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  $WP_CLI_PREFIX wp glotpress import-originals wp-plugins/$plugin/dev tmp/po/$plugin-dev.po $WP_CLI_SUFFIX
  #$WP_CLI_PREFIX wp glotpress import-originals wp-plugins/$plugin/stable tmp/po/$plugin-dev.po $WP_CLI_SUFFIX
  test -f "tmp/po/${plugin}-dev-readme.po" || curl $CURL_OPTIONS -o "tmp/po/${plugin}-dev-readme.po" "https://translate.wordpress.org/projects/wp-plugins/${plugin}/dev-readme/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  $WP_CLI_PREFIX wp glotpress import-originals wp-plugins/$plugin/dev-readme tmp/po/$plugin-dev-readme.po $WP_CLI_SUFFIX
  #$WP_CLI_PREFIX wp glotpress import-originals wp-plugins/$plugin/stable-readme tmp/po/$plugin-dev-readme.po $WP_CLI_SUFFIX
done
set -e

print_header "Downloading and importing some meta strings"
for element in "${META_TO_TRANSLATE[@]}"
do :
  test -f "tmp/po/${element}.po" || curl $CURL_OPTIONS -o "tmp/po/${element}.po" "https://translate.wordpress.org/projects/meta/${element}/gl/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  $WP_CLI_PREFIX wp glotpress import-originals meta/$element tmp/po/$element.po $WP_CLI_SUFFIX
done

print_header "Downloading and importing some apps strings"
for element in "${APPS_TO_TRANSLATE[@]}"
do :
  test -f "tmp/po/${element}.po" || curl $CURL_OPTIONS -o "tmp/po/${element}.po" "https://translate.wordpress.org/projects/apps/${element}/dev/es/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
  $WP_CLI_PREFIX wp glotpress import-originals apps/$element/dev tmp/po/$element.po $WP_CLI_SUFFIX
  test -f curl "tmp/po/${element}-release-notes.po" || curl $CURL_OPTIONS -o "tmp/po/${element}-release-notes.po" "https://translate.wordpress.org/projects/apps/${element}/release-notes/es/default/export-translations/?filters%5Bstatus%5D=current_or_waiting_or_fuzzy_or_untranslated"
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
