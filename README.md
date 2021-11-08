# (WIP) Local development environment for translate.wordpress.org

This repo is a WIP, so don't use it to develop.

## Prerequisites
- Git
- Docker
- Node/NPM

## Setup
1. `git clone https://github.com/amieiro/translate-w-org-env.git`
2. `cd translate-w-org-env.git`
3. `npm install`
4. `npm run start` (This will provision some items).
5. Visit site at <a href="http://localhost:8888" target="_blank">http://localhost:8888</a>.


## Stopping Environment
`npm run wp-env stop`

## Removing Environment
`npm run wp-env destroy`

## Dashboard access
To access to the WordPress dashboard, you need to use:
- URL: <a href="http://localhost:8888/wp-login.php" target="_blank">http://localhost:8888/wp-login.php</a>
- Username: admin
- Password: password

## MySQL access
Docker uses a random port for the MySQL server. Take a look to this when you provision the 
system. The credentials to access to this server are:
- Username: root
- Password: password

## Get the wp-config.php data
`npm run wp-env run cli wp config get`

## More info

This tool is inspired by [WordPress Meta Environment](https://github.com/WordPress/meta-environment) and it is based on 
[WordPress Theme Directory - Local development environment](https://github.com/WordPress/theme-directory-env).

This tool uses the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/)
Docker environment.