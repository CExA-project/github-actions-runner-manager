# GitHub Actions Runner manager

Manage GitHub Actions Runner like a SysV init script.

## Objective

This manager aims to "demonize" GitHub Actions Runner in an environment where Systemd cannot be used.

## Install

```sh
make
```

Default installation prefix is `$HOME/.local`, to change it:

```sh
PREFIX=path/to/dir make
```

## Use

The manager can simply be run by calling:

```sh
manage-ghar <optional arguments> <subcommand> <path of the runner>
```

Like a SysV init script, the manager accepts the subcommands `start`, `stop`, `restart`, and `status`.

Please check the documentation of the command for more help.
