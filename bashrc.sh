export AUTOJUMP_KEEP_SYMLINKS=1
[[ -f ~/.autojump/etc/profile.d/autojump.bash ]] && source ~/.autojump/etc/profile.d/autojump.bash
source ~/.dotfiles/git-completion-1.7.2.2.bash

export PS1='\[\e[1m\]\h:\W$(__git_ps1 " (%s)") \$ \[\e[0m\]'

export PATH=$HOME/bin:/usr/local/bin:$PATH

alias clean="rm -f *~ *# *.orig"
alias e='emacsclient -n'
alias l='ls'
alias ll='ls -al'
alias reinit="source ~/.bash_profile"

export CCACHE=ccache
