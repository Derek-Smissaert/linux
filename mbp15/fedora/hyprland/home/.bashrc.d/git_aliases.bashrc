alias glog='git log --oneline --all --graph'
alias gcommit='git commit -m'
alias ginfo='git status'
alias gbranches="git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'"

alias galiases='echo glog gcommit ginfo gbranches'
