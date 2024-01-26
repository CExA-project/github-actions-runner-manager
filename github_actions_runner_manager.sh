#!/bin/bash

set -eu

PID_FILE="runner.pid"
LOG_FILE="runner.log"
DEFAULT_RUNNER_DIR="./actions_runner"

# directory of the script, see https://stackoverflow.com/a/4774063/19422971
SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

start () {
    local runner_path="$1"
    local state_path="$2"

    if [[ -f $state_path/$PID_FILE ]]
    then
        # the runner is already running
        echo "The runner is already running"
        exit 2
    fi

    # running as a service, see https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service
    echo "Starting runner"
    cd "$runner_path"
    bin/runsvc.sh >>$state_path/$LOG_FILE 2>&1 &

    # create pid file
    echo "Creating pid file"
    echo $! >$state_path/$PID_FILE
}

stop () {
    local state_path="$1"

    if [[ ! -f $state_path/$PID_FILE ]]
    then
        # the runner is not running
        echo "The runner is not running"
        exit 2
    fi

    echo "Stopping runner"
    kill -SIGTERM $(cat $state_path/$PID_FILE)

    echo "Removing pid file"
    rm -f $state_path/$PID_FILE
}

status () {
    local state_path="$1"

    if [[ -f $state_path/$PID_FILE ]]
    then
        echo "Runner started"
    else
        echo "Runner stopped"
    fi
}

usage () {
    cat <<EOF
Manage GitHub Actions Runner like a SysV init script

github_actions_runner_manager.sh [-r PATH] [-s PATH] [-h] {start|stop|restart|status}

Optional arguments:
    -r PATH
        Path to GitHub Actions Runner directory. Default to $DEFAULT_RUNNER_DIR in the script directory.
    -s PATH
        Path to the state directory of the manager (where PID and log files are stored). Default to the script directory.
    -h
        Show this help message and exit.

Subcommands:
    start
        Start the runner, it cannot be started twice. Runner's PID is stored in $PID_FILE and logs are outputed in $LOG_FILE, within the state directory.
    stop
        Stop the runner.
    restart
        Stop and start the runner.
    status
        Tell if the runner is running.
EOF
}

main () {
    # default arguments
    local runner_path="$SCRIPT_PATH/$DEFAULT_RUNNER_DIR"
    local state_path="$SCRIPT_PATH"

    # process optional arguments
    while getopts ":hr:s:" option
    do
        case $option in
            "h")
                usage
                exit 0
                ;;
            "r")
                runner_path="$OPTARG"
                ;;
            "s")
                state_path="$(realpath $OPTARG)"
                ;;
            *)
                echo "Unknown option $OPTARG"
                usage
                exit 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    # process mandatory argument
    if [[ -n "${1+_}" ]]
    then
        local cmd="$1"
        case $cmd in
            "start")
                start "$runner_path" "$state_path"
                exit 0
                ;;
            "stop")
                stop "$state_path"
                exit 0
                ;;
            "restart")
                stop "$state_path"
                sleep 1
                start "$runner_path" "$state_path"
                exit 0
                ;;
            "status")
                status "$state_path"
                exit 0
                ;;
            *)
                echo "Unknown subcommand $cmd"
                usage
                exit 1
                ;;
        esac
    fi

    # no arguments
    usage
    exit 0
}

main "$@"
