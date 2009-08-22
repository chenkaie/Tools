#!/bin/bash

# Filename:      vim2html.bash
# Description:   Convert source code to html using vim
# Maintainer:    Jeremy Cantrell <jmcantrell@gmail.com>
# Last Modified: Sun 2009-03-08 00:57:35 (-0500)

# REQUIREMENTS: bash-utils

# Vim is really good at recognizing filetypes and highlighting the syntax in a
# myriad of colorschemes. Vim is also good at turning that highlighted code
# into HTML. The only missing piece was making this process parameter driven
# and scriptable. That's what this script is intended to solve.


# FUNCTIONS {{{1

cleanup() #{{{2
{
    rm -f "$TMP_FILE"
}

usage_exit() #{{{2
{
    cat >&2 <<-EOF
Usage: $SCRIPT_NAME [options] input_file [output_file]
Creates HTML exports of source code via vim.

    -h              Display this help message.

    -i              Interactive. Prompt for certain actions.
    -v              Be verbose.

    -f FILETYPE     Use FILETYPE as vim filetype.
    -n              Output line numbers.
    -t              Use tidy to cleanup HTML.
    -c COLORSCHEME  Use COLORSCHEME as vim colorscheme.
    -l              Use light background.
    -L              List available vim colorschemes.

EOF
    exit ${1:-0}
}

error_exit() #{{{2
{
    msg-error "$1"
    exit ${2:-1}
}

colorscheme_list() #{{{2
{
    (
        find "$VIM_HOME/colors" -name "*.vim" 2>/dev/null
        find "$HOME/.vim/colors" -name "*.vim" 2>/dev/null
    ) | awk -F'/' '{print $NF}' | sed 's/\.vim$//' | sort | uniq
}

# VARIABLES {{{1

SCRIPT_NAME=$(basename "$0" .bash)
VIM_CMD="vim -n -u NONE"
VIM_HOME=/usr/share/vim/vimcurrent
COLORSCHEME=inkpot
BACKGROUND=dark
TMP_FILE=$(mktemp)

# COMMAND-LINE OPTIONS {{{1

while getopts ":hifvqf:ntc:lL" options; do
    case $options in
        i) export INTERACTIVE=1 ;;
        f) export INTERACTIVE=0 ;;
        v) export VERBOSE=1 ;;
        q) export VERBOSE=0 ;;

        f) FILETYPE=$OPTARG ;;
        n) LINE_NUMBERS=1 ;;
        t) TIDY=1 ;;
        c) COLORSCHEME=$OPTARG ;;
        l) BACKGROUND=light ;;
        L) colorscheme_list; exit 0 ;;

        h) usage_exit 0 ;;
        *) usage_exit 1 ;;
    esac
done && shift $(($OPTIND - 1))

trap cleanup INT TERM EXIT

# ERROR-CHECKING {{{1

[[ -d $VIM_HOME ]] ||
    VIM_HOME="$(find /usr/share/vim -mindepth 1 -maxdepth 1 \
        -type d -name "vim*" 2>/dev/null | sort -r | head -n1)"

[[ "$VIM_HOME" ]] || error_exit "Could not find Vim home directory"

INFILE=$1

[[ $INFILE ]]    || error_exit "Input file not provided"
[[ -f $INFILE ]] || error_exit "Input file does not exist or is not a regular file"

OUTFILE=$2

[[ $OUTFILE ]] || OUTFILE=${INFILE##*/}.html


if interactive && [[ -f $OUTFILE ]]; then
    question "Overwrite '$OUTFILE'?" || exit 1
fi

# BUILD CONVERSION SCRIPT {{{1

: >$TMP_FILE

cat >>$TMP_FILE<<-EOF
set nocompatible
syntax on
set t_Co=256
set expandtabs
set tabstop=4
set background=$BACKGROUND
let html_ignore_folding = 1
let html_use_css = 0
EOF

(
    [[ $FILETYPE ]]     && echo "set ft=$FILETYPE"
    [[ $LINE_NUMBERS ]] && echo "set nu"
    [[ $COLORSCHEME ]]  && echo "colorscheme $COLORSCHEME"
) >>$TMP_FILE

cat >>$TMP_FILE<<-EOF
runtime! syntax/2html.vim
w! $OUTFILE
q!
q!
EOF
#}}}

verbose && msg-info "Converting file '$INFILE' to '$OUTFILE'"
$VIM_CMD -S "$TMP_FILE" "$INFILE" >/dev/null 2>&1
sed -i "s%<title>.*</title>%<title>$(basename "$INFILE")</title>%" "$OUTFILE"

if [[ $TIDY ]]; then
    verbose && msg-info "Cleaning HTML file '$OUTFILE'"
    tidy --tidy-mark no -utf8 -f /dev/null -clean -asxhtml -o "$OUTFILE" "$OUTFILE"
fi
