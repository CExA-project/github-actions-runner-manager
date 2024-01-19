# GitHub Actions Runner manager

Manage GitHub Actions Runner like a SysV init script.

## Objective

This manager aims to "demonize" GitHub Actions Runner in an environment where Systemd cannot be used.

## Execution

The manager can simply be run by calling:

```sh
./github_actions_runner_manager.sh <arguments>
```

Like a SysV init script, the manager accepts the subcommands `start`, `stop`, `restart`, and `status`.

Please check the documentation of the command for more help.
