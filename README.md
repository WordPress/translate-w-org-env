# (WIP) Local development environment for translate.wordpress.org

This repo is a WIP, so don't use it to develop.

## Prerequisites
- Git
- Docker
- Node/NPM

## Setup
1. `git clone https://github.com/amieiro/translate-w-org-env.git`
2. `cd translate-w-org-env`
3. `npm install`
4. `npm run start` (This will provision some items, so it will take a few minutes.You will see all updates in the CLI).
5. Visit site at <a href="http://localhost:8888" target="_blank"> http://localhost:8888 </a>

## Starting the environment
`npm run start`

## Stopping the environment
`npm run stop`

## Removing the environment
`npm run destroy`

## Recreating the environment
`npm run destroy-and-provision`

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

## Dependencies

These are the dependencies:
- [Git](https://git-scm.com/). [Install instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
- [Docker](https://www.docker.com/). [Install instructions](https://docs.docker.com/get-docker/).
- [npm](https://www.npmjs.com/). [Install instructions](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm).

## More info

This tool is inspired by [WordPress Meta Environment](https://github.com/WordPress/meta-environment) and it is based on 
[WordPress Theme Directory - Local development environment](https://github.com/WordPress/theme-directory-env).

This tool uses the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/)
Docker environment.
