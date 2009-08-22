#!/bin/bash
# simple script for switching directory between branches and trunk.
#
# svnb/svnt directory switch function works for current path like
#       /home/work/project/trunk
#       /home/work/project/branches
#       /home/work/project/branches/feature
#   
# goto branch:
#    svnb [branch-name]
#
# branch list completion:
#    svnb <tab>   
#
# goto trunk:
#    svnt
#
function _basedir()
{
    local base_dir=` echo $(pwd) | perl -pe "s{(branches|trunk).*$}{}"`
    if [[ ! $base_dir =~ /$ ]] ; then
        local base_dir=$base_dir"/"
    fi
    echo $base_dir
}

function svnb()
{
    cd $( _basedir )"branches/$1"
}

function svnt()
{
    cd $( _basedir )"trunk/"
}


function _branches()
{
    local branches=`ls $(_basedir)/branches`
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=()
    COMPREPLY=( $( compgen -W '$branches' -- $cur ) )
}
complete -F _branches svnb
