#!/bin/bash

# Filename:      gitty.bash
# Description:   Manages git repositories.
# Maintainer:    Jeremy Cantrell <jmcantrell@gmail.com>
# Last Modified: Tue 2009-03-24 15:15:54 (-0400)

# REQUIREMENTS:
#     bash-utils
#     python-misc:
#         relative-path.py


# DOCUMENTATION {{{1

# This app simply makes bulk actions against a bunch of repositories easy.  The
# feature that I use the most, is for deployment. It supports automatic
# deployment of files in a repo and/or the ability to run a custom deployment
# script. So you can do the following for a single repo:

#     gitty -P myrepo deploy

# Or this for all repos:

#     gitty deploy

# Other actions, such as pull, push, status, etc, are performed in a similar
# fashion; either against a single repo, or all of them.

# To get started with a new or existing repo, do the following:

#     gitty -Niv

# This is the most user-friendly way to add a repo, because it will prompt you
# for most actions and be the most descriptive about what's going on. Of
# course, if you're a masochist, you can leave of -i and -v and have no
# interactivity and have no clue what's going on.

# You can also extend gitty with your own actions by adding *.bash files to
# ~/.gitty/plugins. The files must be valid bash syntax, and contain functions
# that begin with "gitty_". For example, the file myplugin.bash in
# plugins directory might contain the following code:

#     gitty_myaction()
#     {
#         gitty_load "$1" || return 1
#         # You now have all of the gitty profile's variables (directory, etc)
#
#         # DO YOUR WORK HERE
#     }

# You now have "myaction" as an available gitty action, and it should show up
# along with the builtin actions in the help message (-h).


# FUNCTIONS {{{1

cleanup() #{{{2
{
    rm -f "$TMP_FILE"
}

load_plugins() #{{{2
{
    local dir=$CONFIG_DIR/plugins
    local plugin
    [[ -d $dir ]] || mkdir -p "$dir"
    for plugin in $dir/*.bash; do
        [[ -f $plugin ]] || continue
        source "$plugin"
    done
}

usage_exit() #{{{2
{
    cat >&2 <<-EOF
Usage: $SCRIPT_NAME [OPTIONS]
Perform various operations on git projects.

    -h            Display this help message.

    -i            Interactive. Prompt for certain actions.
    -f            Don't prompt.
    -v            Be verbose.
    -q            Be quiet.

    -C DIRECTORY  Use DIRECTORY for configuration.
                  Default: $CONFIG_DIR

    -P PROFILE    Use PROFILE for action.
    -N            Create new profile.
    -L            List profiles.
    -D            Delete profile.
    -E            Edit profile.

    -t            Truncate old archive files.

    -A ACTION     Perform ACTION.

Where ACTION is one of the following:

$(for a in $(gitty_actions); do echo "    $a"; done)

EOF
    exit ${1:-0}
}

error_exit() #{{{2
{
    msg-error "$1"
    exit ${2:-1}
}


# BUILTIN ACTIONS {{{1

gitty_load() #{{{2
{
    local profile=$1

    if [[ ! $profile ]]; then
        msg-error "Profile not provided"
        return 1
    fi

    eval "$(profile -A load -P "$profile")"
}

gitty_pull() #{{{2
{
    local profile=$1

    gitty_load "$profile" || return 1

    if [[ ! $origin ]]; then
        msg-warn "Origin not provided. Pull will not occur."
        return 0
    fi

    if [[ ! $directory ]]; then
        msg-error "Local directory not provided"
        return 1
    fi

    if [[ ! -d $directory/.git ]]; then
        question -c -p "Clone profile '$profile'?" || return 0
        msg-info -c "Cloning profile '$profile'"
        if [[ -e $directory ]]; then
            msg-error "Local directory already exists"
            return 1
        fi
        verbose-execute git clone "$origin" "$directory" || return 1
        return 0
    fi

    question -c -p "Pull profile '$profile'?" || return 0
    msg-info -c "Pulling profile '$profile'"

    local OPWD=$PWD; cd "$directory"
    verbose-execute git pull
    cd "$OPWD"
}

gitty_push() #{{{2
{
    local profile=$1

    gitty_load "$profile" || return 1

    if truth "$read_only"; then
        msg-warn -c "Profile '$profile' is read-only. Push will not occur."
        return 0
    fi

    if [[ ! $origin ]]; then
        msg-warn "Origin not provided. Push will not occur."
        return 0
    fi

    if [[ ! $directory ]]; then
        msg-error "Local directory not provided"
        return 1
    fi

    if [[ ! -d $directory/.git ]]; then
        msg-error "Profile '$profile' is not under source control"
        return 1
    fi

    question -c -p "Push profile '$profile'?" || return 0
    msg-info -c "Pushing profile '$profile'"

    local OPWD=$PWD; cd "$directory"
    verbose-execute git push
    cd "$OPWD"
}

gitty_commit() #{{{2
{
    local profile=$1

    gitty_load "$profile" || return 1

    if truth "$read_only"; then
        msg-warn -c "Profile '$profile' is read-only. Commit will not occur."
        return 0
    fi

    if [[ ! $directory ]]; then
        msg-error "Local directory not provided"
        return 1
    fi

    if [[ ! -d $directory/.git ]]; then
        msg-error "Profile '$profile' is not under source control"
        return 1
    fi

    question -c -p "Commit '$profile'?" || return 0
    msg-info -c "Committing profile '$profile'"

    local OPWD=$PWD; cd "$directory"
    verbose-execute git commit -a -v
    cd "$OPWD"
}

gitty_status() #{{{2
{
    local profile=$1

    gitty_load "$profile" || return 1

    if [[ ! $directory ]]; then
        msg-error "Local directory not provided"
        return 1
    fi

    if [[ ! -d $directory/.git ]]; then
        msg-error "Profile '$profile' is not under source control"
        return 1
    fi

    msg-info "Getting status for profile '$profile'"

    local OPWD=$PWD; cd "$directory"
    verbose-execute git status
    cd "$OPWD"
}

gitty_archive() #{{{2
{
    local profile=$1

    gitty_load "$profile" || return 1

    if ! truth "$archive"; then
        msg-warn -c "Profile '$profile' is not set to archive."
        return 0
    fi

    if [[ ! $directory ]]; then
        msg-error "Local directory not provided"
        return 1
    fi

    if [[ ! $archive_directory ]]; then
        msg-warn -c "No archive directory set for '$profile'"
        return 1
    fi

    if [[ ! -d $directory/.git ]]; then
        msg-error "Profile '$profile' is not under source control"
        return 1
    fi

    mkdir -p "$archive_directory"

    question -c -p "Do you want to archive '$profile'?" || return 1

    local archive_file=$archive_directory/$profile-$(date +%Y%m%d%H%M%S).tar.gz
    local archive_file_current=$archive_directory/$profile.tar.gz

    msg-info -c "Exporting profile '$profile'"

    local OPWD=$PWD; cd "$directory"

    git archive --format=tar --prefix="$profile/" $archive_branch | gzip >$archive_file
    ln -sf "$archive_file" "$archive_file_current"

    if truth $TRUNCATE; then
        if question -c -p "Do you want to remove the old archives for profile '$profile'?"; then
            find "$archive_directory" -type f -name "$profile-*" \! -wholename "$archive_file" -exec rm -f {} \; >/dev/null 2>&1
        fi
    fi

    cd "$OPWD"
}

gitty_diff() #{{{2
{
    local profile=$1

    gitty_load "$profile" || return 1

    if [[ ! $directory ]]; then
        msg-error "Local directory not provided"
        return 1
    fi

    if [[ ! -d $directory/.git ]]; then
        msg-error "Profile '$profile' is not under source control"
        return 1
    fi

    msg-info -c "Getting diff for profile '$profile'"

    local OPWD=$PWD; cd "$directory"
    verbose-execute git diff
    cd "$OPWD"
}

gitty_check() #{{{2
{
    local profile=$1

    gitty_load "$profile" || return 1

    if [[ ! $directory ]]; then
        msg-error "Local directory not provided"
        return 1
    fi

    if [[ ! -d $directory/.git ]]; then
        msg-error "Profile '$profile' is not under source control"
        return 1
    fi

    msg-info -c "Checking health for profile '$profile'"

    local OPWD=$PWD; cd "$directory"
    verbose-execute git fsck
    verbose-execute git count-objects
    verbose-execute git gc
    cd "$OPWD"
}

gitty_deploy() #{{{2
{
    local profile=$1

    gitty_load "$profile" || return 1

    if ! truth "$deploy"; then
        msg-warn -c "Profile '$profile' is not set to deploy"
        return 0
    fi

    if [[ ! $directory ]]; then
        msg-error "Local directory not provided"
        return 1
    fi

    if [[ ! -d $directory/.git ]]; then
        msg-error "Profile '$profile' is not under source control"
        return 1
    fi

    if [[ ! $deploy_directory ]]; then
        msg-error "Deploy directory not provided"
        return 1
    fi

    msg-info -c "Deploying profile '$profile'"

    local redirect file name

    local OPWD=$PWD;
    [[ $deploy_directory ]] && cd "$deploy_directory"
    local source_dir=$(relative-path "$directory")

    if truth "$deploy_auto"; then
        for file in $source_dir/*; do
            [[ -e $file ]] || continue
            name=$(basename "$file")
            if [[ $deploy_excludes && -f $directory/$deploy_excludes ]]; then
                grep -qvf "$directory/$deploy_excludes" <<<$name || continue
            fi
            if [[ $deploy_auto_substitution ]]; then
                name=$(sed "$deploy_auto_substitution" <<<$name)
            fi
            question -c -p "Deploy file '$file' to '$name'?" || continue
            verbose-execute $deploy_auto_command "$file" "$name"
        done
    fi

    if [[ $deploy_script && -x $directory/$deploy_script ]]; then
        if question -c -p "Run deployment script?'"; then
            verbose-execute $directory/$deploy_script
        fi
    fi

    cd "$OPWD"
}

gitty_actions() #{{{2
{
    declare -F | awk '{print $NF}' | grep '^gitty_' | sed 's/^gitty_//' | sort
}


# VARIABLES {{{1

SCRIPT_NAME=$(basename "$0" .bash)
TMP_FILE=$(mktemp) || error_exit "Could not create temp file"

# Disable GUI mode for dialogs
export GUI_DISABLED=1


# PROFILE OPTIONS {{{1

export EDITOR=$(first "$(git config core.editor)" "$GIT_EDITOR" "$VISUAL" "$EDITOR" "vi")
export PROFILE_NAME=$SCRIPT_NAME
export PROFILE_DEFAULT=$(cat <<-EOF
origin=git@localhost:your-project.git
directory=~/development/your-project
# read_only=0
# archive=0
# archive_directory=~/development/archive
# archive_branch=master
# deploy=0
# deploy_directory=~/bin
# deploy_script=.deploy
# deploy_excludes=.deploy-excludes
# deploy_auto=0
# deploy_auto_command='ln -sfv'
# deploy_auto_substitution='s/^/./'
EOF)
CONFIG_DIR=$(profile -A view -V CONFIG_DIR)


# COMMAND-LINE OPTIONS {{{1

while getopts ":hifvqtC:NDLEP:A:" options; do
    case $options in
        i) export INTERACTIVE=1 ;;
        f) export INTERACTIVE=0 ;;
        v) export VERBOSE=1 ;;
        q) export VERBOSE=0 ;;

        t) TRUNCATE=1 ;;

        C) export CONFIG_DIR=$OPTARG ;;

        A) ACTION=$OPTARG ;;

        P) PROFILE=$OPTARG ;;
        N) PROFILE_ACTION=create ;;
        L) PROFILE_ACTION=list ;;
        D) PROFILE_ACTION=delete ;;
        E) PROFILE_ACTION=edit ;;

        h) usage_exit 0 ;;
        *) usage_exit 1 ;;
    esac
done && shift $(($OPTIND - 1))


# PROFILE ACTIONS {{{1

if [[ $PROFILE_ACTION ]]; then
    profile -A "$PROFILE_ACTION" -P "$PROFILE"
    exit 0
fi

load_plugins || error_exit "Could not load plugins"


# For simplicity, the action can be specified as the last argument
[[ $ACTION ]] || ACTION=$1

type -P git >/dev/null || error_exit "Git is not available"

gitty_actions | grep -q "^$ACTION$" || error_exit "Invalid gitty action '$ACTION'"

trap cleanup INT TERM EXIT


# PROFILE CONTENT ACTIONS {{{1
OIFS=$IFS; IFS=$'\n'
for profile in $(profile -A list -P "$PROFILE"); do
    IFS=$OIFS
    gitty_$ACTION "$profile" || msg-error "Could not perform action '$ACTION'"
    verbose && echo >&2  # Separate each iteration, but only if verbose
done
