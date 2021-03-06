# Copyright (c) 2010, Huy Nguyen, http://www.huyng.com
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided 
# that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, this list of conditions 
#       and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#       following disclaimer in the documentation and/or other materials provided with the distribution.
#     * Neither the name of Huy Nguyen nor the names of contributors
#       may be used to endorse or promote products derived from this software without 
#       specific prior written permission.
#       
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.


# USAGE: 
# sb bookmarkname - saves the curr dir as bookmarkname
# cb bookmarkname - jumps to the that bookmark
# cb b[TAB] - tab completion is available
# pb bookmarkname - prints the bookmark
# pb b[TAB] - tab completion is available
# db bookmarkname - deletes the bookmark
# db [TAB] - tab completion is available
# ob bookmarkname - open bookmark in finder
# ob [TAB] - tab completion is available
# lb - list all bookmarks

# setup file to store bookmarks
if [ ! -n "$SDIRS" ]; then
    SDIRS=~/.sdirs
fi
touch $SDIRS

RED="0;31m"
GREEN="0;33m"

# save current directory to bookmarks
function sb {
    check_help $1

	b="$1"
	# if no bookmark, then use current directory name
	if [[ -z "$1"  || "$1" == "." ]]; then
		# get basename of current working directory
		b=${PWD##*/}  
		# replace all - with _
		b=`echo $b | sed s/-/_/g`
		echo "Using current directory name for bashmark: $b"
	fi

	_bookmark_name_valid "$b"
    if [ -z "$exit_message" ]; then
        _purge_line "$SDIRS" "export DIR_$b="
        CURDIR=$(echo $PWD| sed "s#^$HOME#\$HOME#g")
        echo "export DIR_$b=\"$CURDIR\"" >> $SDIRS
    fi
}

# jump to bookmark
function cb {
    check_help $1
    source $SDIRS

    # vj: split $1 into saved part and any sub dir
    ROOTB=$(echo "$1" | cut -d '/' -f1)
    SUBDIRS=$(echo "$1" | cut -d '/' -f2-)

    target="$(eval $(echo echo $(echo \$DIR_$ROOTB)))"

    # somehow if no subdirs are given, the value of ROOTB and SUBDIRS is the same on ubuntu. But it seems ok on mac.
    if [[ ! -z $SUBDIRS && $SUBDIRS != $ROOTB ]]; then
        target="$target/$SUBDIRS"
    fi

    if [ -d "$target" ]; then
        cd "$target"
    elif [ ! -n "$target" ]; then
        echo -e "\033[${RED}WARNING: '${1}' bashmark does not exist\033[00m"
		echo "Available bookmarks:"
		lb
		return 1
    else
        echo -e "\033[${RED}WARNING: '${target}' does not exist\033[00m"
		return 1
    fi
}

# print bookmark
function pb {
    check_help $1
    source $SDIRS
    echo "$(eval $(echo echo $(echo \$DIR_$1)))"
}

# delete bookmark
function db {
    check_help $1
    _bookmark_name_valid "$@"
    if [ -z "$exit_message" ]; then
        _purge_line "$SDIRS" "export DIR_$1="
        unset "DIR_$1"
    fi
}

# print out help for the forgetful
function check_help {
    if [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ] ; then
        echo ''
        echo 'sb <bookmark_name> - Saves the current directory as "bookmark_name"'
        echo 'cb <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
        echo 'pb <bookmark_name> - Prints the directory associated with "bookmark_name"'
        echo 'db <bookmark_name> - Deletes the bookmark'
        echo 'ob <bookmark_name> - Open bookmark in Finder (mac only)'
        echo 'lb                 - Lists all available bookmarks'
        kill -SIGINT $$
    fi
}

# list bookmarks with dirnam
function lb {
    check_help $1
    source $SDIRS
        
    # if color output is not working for you, comment out the line below '\033[1;32m' == "red"
    env | sort | awk '/^DIR_.+/{split(substr($0,5),parts,"="); printf("\033[0;33m%-20s\033[0m %s\n", parts[1], parts[2]);}'
    
    # uncomment this line if color output is not working with the line above
    # env | grep "^DIR_" | cut -c5- | sort |grep "^.*=" 
}
# list bookmarks without dirname
function _l {
    source $SDIRS
    env | grep "^DIR_" | cut -c5- | sort | grep "^.*=" | cut -f1 -d "=" 
}

# added from https://github.com/huyng/bashmarks/pull/52
# open bookmark in mac
function ob {
    check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        open "$target"
    elif [ ! -n "$target" ]; then
        echo -e "\033[${RED}WARNING: '${1}' bashmark does not exist\033[00m"
    else
        echo -e "\033[${RED}WARNING: '${target}' does not exist\033[00m"
    fi
}

# validate bookmark name
function _bookmark_name_valid {
    exit_message=""
    if [ -z $1 ]; then
        exit_message="bookmark name required"
        echo $exit_message
    elif [ "$1" != "$(echo $1 | sed 's/[^A-Za-z0-9_]//g')" ]; then
        exit_message="bookmark name is not valid"
        echo $exit_message
    fi
}

# completion command
# function _comp {
#     local curw
#     COMPREPLY=()
#     curw=${COMP_WORDS[COMP_CWORD]}
#     COMPREPLY=($(compgen -W '`_l`' -- $curw))
#     return 0
# }

# added subdirectory completion command from https://github.com/huyng/bashmarks/pull/55/commits/b406997b4c3879e74a1d010fcd31d1b2ea08986e
# completion command: doesn't work properly for me yet.
function _comp {
    local curw
    COMPREPLY=()
    curw=${COMP_WORDS[COMP_CWORD]}

    mark=$(echo $curw | sed 's/\/.*$//')
    target="$(eval $(echo echo $(echo \$DIR_$mark)))"
    if [[ $curw == *\/* ]] && [ -d "$target" ]; then
      afterMark=${curw#*"/"}
      depth=$(echo $afterMark | tr -cd "/" | wc -c)
      if [ "$depth" -gt "0" ]; then
        lastDir=$(echo "$afterMark" | cut -d "/" -f -$depth)
      else
        lastDir=""
      fi
      list=$(find $target/$lastDir -maxdepth 1 -type d| sed "s#$target#$mark#")

      COMPREPLY=($(compgen -W '$list' -- $curw))
    else
      COMPREPLY=($(compgen -W '`_l`' -- $curw))
    fi

    return 0
}

# ZSH completion command
function _compzsh {
    reply=($(_l))
}

# safe delete line from sdirs
function _purge_line {
    if [ -s "$1" ]; then
        # safely create a temp file
        t=$(mktemp -t bashmarks.XXXXXX) || exit 1
        trap "/bin/rm -f -- '$t'" EXIT

        # purge line
        sed "/$2/d" "$1" > "$t"
        /bin/mv "$t" "$1"

        # cleanup temp file
        /bin/rm -f -- "$t"
        trap - EXIT
    fi
}

# bind completion command for cb,pb,db (cd to bookmark, print bookmark, delete bookmark) to _comp
if [ $ZSH_VERSION ]; then
    compctl -K _compzsh cb
    compctl -K _compzsh pb
    compctl -K _compzsh db
    compctl -K _compzsh ob
else
    shopt -s progcomp
    complete -F _comp cb 
    complete -F _comp pb
    complete -F _comp db
    complete -F _comp ob
fi
