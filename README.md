# (WIP) Local development environment for translate.wordpress.org

This repo is a WIP, so don't use it to develop.

This repo allows you to install a local development environment:
- using a Docker environment.
- Using a local environment: LAMP, LEMP, XAMPP, MAMP, Laravel Valet,... One local environment where you install 
a web server (usually Apache or NGINX), a database (usually MySQL or MariaDB) and PHP. We will use the LAMP term to 
talk about this environment.

## Docker environment

### Prerequisites
- [Git](https://git-scm.com/). [Install instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
- [Docker](https://www.docker.com/). [Install instructions](https://docs.docker.com/get-docker/).
- [npm](https://www.npmjs.com/). [Install instructions](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm).

### Setup
1. `git clone https://github.com/amieiro/translate-w-org-env.git`
2. `cd translate-w-org-env`
3. `npm install`
4. `npm run start` (This will provision some items, so it will take a few minutes.You will see all updates in the CLI).
5. Visit site at <a href="http://localhost:8888" target="_blank"> http://localhost:8888 </a>.

### Starting the environment
`npm run start`

### Stopping the environment
`npm run stop`

### Removing the environment
`npm run destroy`

### Recreating the environment
`npm run destroy-and-provision`

### Dashboard access
To access to the WordPress dashboard, you need to use:
- URL: <a href="http://localhost:8888/wp-login.php" target="_blank"> http://localhost:8888/wp-login.php </a>
- Username: admin
- Password: password

### MySQL access
Docker uses a random port for the MySQL server. Take a look to this when you provision the 
system. The credentials to access to this server are:
- Username: root
- Password: password

## LAMP environment

### Prerequisites
- [Git](https://git-scm.com/). [Install instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
- A local environment with WordPress running in your local machine.
- The Bash shell.
- PHP in your $PATH.
- MySQL in your $PATH.
- WP-CLI in your $PATH.

### Setup

If you don't have WordPress in your local machine, you can install it with the WP-CLI and these commands (use your own 
paths and values: usernames, passwords,...):

- `cd /your/local/folder`
- `wp core download`
- `wp config create --dbname=wordpress --dbuser=wordpress --dbpass="password"`
- `wp core install --url="wordpress.test" --title="Test Site" --admin_user=admin --admin_password="password" \
--admin_email=example@example.com`

**Please, note that this installation is destructive and will delete the data you have in your WordPress.**

1. `git clone https://github.com/amieiro/translate-w-org-env.git`
2. `cd translate-w-org-env`
3. Make sure that the `provision.sh` file has execution permissions. Execute `chmod +x provision.sh` to give execution
permissions.
4. Execute this command `./provision.sh -t lamp -d /Users/myuser/code/wordpress/wp`, where:
   1. `-t lamp` indicates that this installation is a `LAMP` type.
   2. `-d /Users/myuser/code/wordpress/wp` represents the WordPress full path. Use your WordPress path and don't include
   a slash at the end of the path.
5. Visit your local WordPress in the URL where you have installed it before. 

### Dashboard access
To access to the WordPress dashboard, you need to use the same URL you used before. Use these credentials:
- Username: admin
- Password: password

## More info

This tool is inspired by [WordPress Meta Environment](https://github.com/WordPress/meta-environment) and it is based on 
[WordPress Theme Directory - Local development environment](https://github.com/WordPress/theme-directory-env).

This tool uses the [@wordpress/env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/)
Docker environment.
