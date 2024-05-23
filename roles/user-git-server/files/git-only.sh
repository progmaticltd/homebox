#!/bin/sh
#
## ---
## This script allow git access to user repositories.
## Git repositories are automatically created on first push.
## Valid repository names should start with a letter, followed
## by alphanumeric or hyphen, underscore and dot characters
## Repositories are stored in /home/archives by default.
##
## Example of repository creation:
## $ git remote add personal git.DOMAIN:repo-name.git
## $ git push --all --tags personal
##
## To list your repositories:
## ssh git.DOMAIN repo list
## ---
#

# Error codes
SUCCESS=0
NO_CMD=10
NO_PATH=20
NO_ROOT=30
INVALID_NAME=40
SYS_ERROR=50

usage() {
    domain=$(hostname -d)
    sed -En 's/^## ?//p' "$0" | sed "s/DOMAIN/$domain/" 1>&2
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit $SUCCESS
fi

if [ -n "$SSH_CONNECTION" ] && [ -z "$SSH_ORIGINAL_COMMAND" ]; then
    echo "Your key can only be used for git" 1>&2
    usage
    exit $NO_CMD
fi

# Get the user running the script
calling_user=$(whoami)

# This shouldn't be run by root
if [ "$calling_user" = "root" ]; then
    echo "This script should not be run by root" 1>&2
    usage
    exit $NO_ROOT
fi

# Log the command run
logger "Running $SSH_ORIGINAL_COMMAND for user '$calling_user' (from $SSH_CLIENT)"

# Do not create world readable files and directories
umask 077

# Set the git root directory
git_root_dir="/home/archives/$calling_user/git"
git_repo_dir="$git_root_dir/repositories"

if [ ! -d "$git_repo_dir" ]; then
    mkdir -p "$git_repo_dir"
fi

# Simple command to list the existing repositories
if [ "$SSH_ORIGINAL_COMMAND" = "repo list" ]; then
    repos=$(ls -1 "${git_repo_dir}")

    if [ "$repos" = "" ]; then
        echo "No repositories found" | colorize --attr=bold default -
        exit $SUCCESS
    fi

    headers="Repository,Size,Accessed,Modified"
    summary="---|---|---|---"

    for repo in $repos; do
        du=$(du -sh "$git_repo_dir/$repo" | sed -E 's/\t.*//g')
        accessed=$(stat -c "%x" "$git_repo_dir/$repo" | sed 's/\..*//g')
        modified=$(stat -c "%y" "$git_repo_dir/$repo" | sed 's/\..*//g')
        line="$repo|$du|$accessed|$modified"
        summary="$summary\n$line\n"
    done

    echo "Repositories list" | colorize --attr=bold default -
    echo "$summary" | column -s '|' -N "$headers" -t -o ' | ' | colorize --clean-all -

    exit $SUCCESS
fi

# Everything should run in this directory
cd "$git_repo_dir" || exit $SYS_ERROR

# This block automatically creates the git directory the first time we push
is_push=$(echo "$SSH_ORIGINAL_COMMAND" | grep -E -c '^git-receive-pack.*')

if [ "$is_push" = "1" ]; then

    # Check if the folder exists
    repo_path=$(echo "$SSH_ORIGINAL_COMMAND" | head -n 1 | cut -f 2 -d ' ' | tr -d "'")

    # Make sure we don't pass the home directory
    if expr "$repo_path" : ".*~.*" >/dev/null; then
        echo "Do not specify the user path for your git repository" 1>&2
        usage
        exit $NO_PATH
    fi

    if expr "$repo_path" : ".*/.*" >/dev/null; then
        echo "Do not specify any absolute path for your git repository" 1>&2
        usage
        exit $NO_PATH
    fi

    # Cleanup the repository name
    repo_name=$(echo "$repo_path" | sed -E "s:[^a-zA-Z]*([a-zA-Z][a-zA-Z0-9_\.-]+).*:\1:")

    # Make sure the repository name was clean
    if [ "$repo_path" != "$repo_name" ]; then
        echo "The name $repo_path is not valid, use '$repo_name' instead." 1>&2
        echo "Valid repository name should start by a letter, then alphanumeric or (-) (_) and (.)"  1>&2
        usage
        exit $INVALID_NAME
    fi

    if [ ! -d "$repo_name" ]; then
        logger "Creating new repository '$repo_name'"
        git init --bare "$repo_name" >/dev/null 2>&1
    fi

fi

exec git-shell -c "$SSH_ORIGINAL_COMMAND"
