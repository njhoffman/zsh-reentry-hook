

[[ -o interactive ]] || return
autoload -Uz add-zsh-hook || { print "can't add zsh hook!"; return }

if stat --version &> /dev/null && [[ -n "$(stat --version |& grep -q -e "core\|GNU")" ]] ; then
else
fi

add-zsh-hook preexec reentry_hook
