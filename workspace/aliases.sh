# alias cl="clear;ls --group-directories-first -lahtF --time-style=\"+%d-%m-%Y %H:%M:%S\" --color"
# alias cls="clear;ls -a --group-directories-first  --time-style=\"+%d-%m-%Y %H:%M:%S\" --color"
alias cl="clear && exa --long --header --classify --group-directories-first --sort=oldest --group --extended --all"
alias cls="cl --grid"

alias vi=vim

alias ptide="perltidy -b -bext='/' -nt -bl -sbl -l=2000 -act=0 -syn -sfp -isbc"
alias code="code ."
alias drmall='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'
alias drmall_untagged='docker rmi $(docker images -aq -f dangling=true)'
alias dci="clear && docker images"
alias dupall="sh ~/.dotfiles/update-docker-images.sh"

alias apu="sudo apt update"
alias apup="sudo apt -fy full-upgrade"
alias apr="sudo apt -fy autoremove"
alias apfu="apu && apup && apr"

alias sdo='sudo zsh -s'
alias tailf="tail -f"

alias clip='xclip -sel clip'

alias pubclip='cat ~/.ssh/id_rsa.pub | clip'

alias gptm='git push origin --tags && git push origin master'

alias q=quasar

alias upnode="clear && yarn global add @vue/cli && yarn global add @vue/cli-init && yarn global add @quasar/cli && yarn global add @adonisjs/cli"

alias reload="exec ${SHELL} -l"

weather() {
    city="$1"

    if [ -z "$city" ]; then
        city="London"
    fi

    eval "curl http://wttr.in/${city}"
}

commit() {
    commitMessage="$1"

    if [ "$commitMessage" = "" ]; then
        commitMessage=":pencil: Small changes"
    fi

    git add .
    eval "git commit -a -m '${commitMessage}'"
}

mktouch() {
	mkdir -p "$(dirname "$1")" && touch "$1"
}

#   extract:  Extract most know archives with one command
#   ---------------------------------------------------------
    extract () {
        if [ -f $1 ] ; then
          case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
             esac
         else
             echo "'$1' is not a valid file"
         fi
    }

# Curl JSON
function jcurl() {
    curl "$@" | jq '.'
}
function gi() { curl -sLw "\n" https://www.gitignore.io/api/$@ ;}

addDateLog() {
    while IFS= read -r line; do
        printf '%s - %s\n' "$(date +"%Y-%m-%d %T")" "$line";
    done
}
