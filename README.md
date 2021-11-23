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
4. `npm run start` (This will provision some items, so it will take a few minutes.You will see all updates in the CLI).
5. Visit backend at <a href="http://localhost:8888/wp-admin/options-permalink.php" target="_blank"> http://localhost:8888/wp-admin/options-permalink.php </a>
and reload the page. Use `admin/password` as credentials.
6. Visit site at <a href="http://localhost:8888" target="_blank"> http://localhost:8888 </a>

## Stopping the environment
`npm run wp-env stop`

## Removing the environment
`npm run wp-env destroy`

## Recreating the environment
`npm run wp-env destroy-and-provision`

## Dashboard access
To access to the WordPress dashboard, you need to use:
- URL: <a href="http://localhost:8888/wp-login.php" target="_blank"> http://localhost:8888/wp-login.php </a>
- Username: admin
- Password: password

## MySQL access
Docker uses a random port for the MySQL server. Take a look to this when you provision the 
system. The credentials to access to this server are:
- Username: root
- Password: password

## More info

This tool is inspired by [WordPress Meta Environment](https://github.com/WordPress/meta-environment) and it is based on 
[WordPress Theme Directory - Local development environment](https://github.com/WordPress/theme-directory-env).

This tool uses the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/)
Docker environment.