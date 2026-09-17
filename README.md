# translate-w-org-env

**This repository is archived.** The local development environment for translate.wordpress.org now lives in the WordPress.org Meta repository as [`environments/translate`](https://github.com/WordPress/wordpress.org/tree/trunk/environments/translate), which landed in September 2026 (meta [r15165](https://meta.trac.wordpress.org/changeset/15165), see [#8368](https://meta.trac.wordpress.org/ticket/8368)). Issues and pull requests opened here are no longer monitored.

## Where to go now

```bash
git clone https://github.com/WordPress/wordpress.org.git
cd wordpress.org/environments
npm install
npm run translate:env start
```

- **Setup and usage:** the [Environments Guide](https://github.com/WordPress/wordpress.org/blob/trunk/environments/README.md), which also covers the plugin directory, theme directory, make, handbook, jobs, openverse, browsehappy, and SSO stacks.
- **Bug reports and feature requests:** [Meta Trac](https://meta.trac.wordpress.org/), component [Translate Site & Plugins](https://meta.trac.wordpress.org/newticket?component=Translate+Site+%26+Plugins).
- **Contributing:** open a pull request against the [Meta Git mirror](https://github.com/WordPress/wordpress.org) and reference the Trac ticket. A Meta committer commits the patch to SVN, which closes the PR automatically.

## What changed

The replacement runs on PHP 8.4 rather than 7.4 and mounts the `wporg-gp-*` plugins straight from the Meta checkout, so there is no longer a `pull_repos.sh` step cloning Meta, GlotPress, wporg-parent-2021 and wporg-mu-plugins into the working tree. It also adds things this environment never had: GlotPress and Translation Events schema bootstrapping, the `wporg-gp-custom-stats` tables and a stats rebuild, on-demand string imports for any plugin or theme (`npm run translate:import -- plugin akismet`), seeded demo Translation Events, and a separate test environment running the Translation Events PHPUnit suite (`npm run translate:test`).

One capability was retired rather than ported: the `provision.sh -t lamp` path, which provisioned an existing LAMP/MAMP/Valet WordPress instead of Docker. The Meta environments are wp-env only and require Docker.

## History

This repository holds the environment's history from 2023 through its last commit in July 2024. It stays available read-only for reference and for links from older discussions.
