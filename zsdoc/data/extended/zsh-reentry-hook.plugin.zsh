#!/usr/bin/env zsh
# Plugin that re-enters working directory
# if it has been removed and re-created.
# http://github.com/RobSis/zsh-reentry-hook

[[ -o interactive ]] || return #interactive only
autoload -Uz add-zsh-hook || { print "can't add zsh hook!"; return }

if stat --version &> /dev/null && [[ -n "$(stat --version |& grep -q -e "core\|GNU")" ]] ; then
	reentry_hook_stat () {
		stat -c '%h' .
	}
else
	# Assume that we are dealing with a BSD variant.
	reentry_hook_stat () {
		stat -f '%l' .
	}
fi

reentry_hook() {
    if [[ `reentry_hook_stat` -eq 0 && -d "$PWD" ]]; then
        builtin cd .
			elif [[ `reentry_hook_stat` -eq 0 && ! -d "$PWD" ]]; then
				print -P "%F{red}Warning:%f Current directory '$PWD' has been removed and cannot be re-entered."
				builtin cd "$HOME"
    fi
}

add-zsh-hook preexec reentry_hook


# Add to HOOK the given FUNCTION.
# HOOK is one of chpwd, precmd, preexec, periodic, zshaddhistory,
# zshexit, zsh_directory_name (the _functions subscript is not required).
#
# With -d, remove the function from the hook instead; delete the hook
# variable if it is empty.
#
# -D behaves like -d, but pattern characters are active in the
# function name, so any matching function will be deleted from the hook.
#
add-zsh-hook() {
# Add to HOOK the given FUNCTION.
# HOOK is one of chpwd, precmd, preexec, periodic, zshaddhistory,
# zshexit, zsh_directory_name (the _functions subscript is not required).
#
# With -d, remove the function from the hook instead; delete the hook
# variable if it is empty.
#
# -D behaves like -d, but pattern characters are active in the
# function name, so any matching function will be deleted from the hook.
#
# Without -d, the FUNCTION is marked for autoload; -U is passed down to
# autoload if that is given, as are -z and -k.  (This is harmless if the
# function is actually defined inline.)

emulate -L zsh

local -a hooktypes
hooktypes=(
  chpwd precmd preexec periodic zshaddhistory zshexit
  zsh_directory_name
)
local usage="Usage: add-zsh-hook hook function\nValid hooks are:\n  $hooktypes"

local opt
local -a autoopts
integer del list help

while getopts "dDhLUzk" opt; do
  case $opt in
    (d)
    del=1
    ;;

    (D)
    del=2
    ;;

    (h)
    help=1
    ;;

    (L)
    list=1
    ;;

    ([Uzk])
    autoopts+=(-$opt)
    ;;

    (*)
    return 1
    ;;
  esac
done
shift $(( OPTIND - 1 ))

if (( list )); then
  typeset -mp "(${1:-${(@j:|:)hooktypes}})_functions"
  return $?
elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 )); then
  print -u$(( 2 - help )) $usage
  return $(( 1 - help ))
fi

local hook="${1}_functions"
local fn="$2"

if (( del )); then
  # delete, if hook is set
  if (( ${(P)+hook} )); then
    if (( del == 2 )); then
      set -A $hook ${(P)hook:#${~fn}}
    else
      set -A $hook ${(P)hook:#$fn}
    fi
    # unset if no remaining entries --- this can give better
    # performance in some cases
    if (( ! ${(P)#hook} )); then
      unset $hook
    fi
  fi
else
  if (( ${(P)+hook} )); then
    if (( ${${(P)hook}[(I)$fn]} == 0 )); then
      typeset -ga $hook
      set -A $hook ${(P)hook} $fn
    fi
  else
    typeset -ga $hook
    set -A $hook $fn
  fi
  autoload $autoopts -- $fn
fi
}
