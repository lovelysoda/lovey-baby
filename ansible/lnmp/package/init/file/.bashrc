# .bashrc
# User specific aliases and functions
alias vi='vim'
alias rm='/usr/local/bin/rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias dstat='dstat -cndymlp -N total -D total 5 25'
# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
export LANG=en_US.UTF-8
export PS1='[\u@\H \W]\\$ '
