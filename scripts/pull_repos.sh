#!/bin/bash

function print_header() {
  echo ''
  echo '******************************************************************************************'
  echo $1
  echo '******************************************************************************************'
  echo ''
}
print_header "Cloning and/or pulling GlotPress and WordPress.org"
# Get a copy from GlotPress and Meta only if the folder doesn't exist
# Pull the repo looking for updates
[[ -d glotpress.git ]] || git clone https://github.com/GlotPress/GlotPress-WP.git glotpress.git
cd glotpress.git
git config pull.ff only
git pull
cd -
[[ -d meta.git ]] || git clone https://github.com/wordpress/wordpress.org meta.git
cd meta.git
git config pull.ff only
git pull
cd -
# todo: remove the wporg-mu-plugins.git clone and the other commands when we have the first beta version
[[ -d wporg-mu-plugins.git ]] || git clone https://github.com/WordPress/wporg-mu-plugins wporg-mu-plugins.git
cd wporg-mu-plugins.git
git config pull.ff only
git pull
npm install
npm run build
cd -
