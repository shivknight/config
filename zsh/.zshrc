# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/shiv.pande/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git docker ssh-agent terraform)


zstyle :omz:plugins:ssh-agent identities shiv.pande@salesforce.com
zstyle :omz:plugins:ssh-agent agent-forwarding identities shiv.pande@salesforce.com
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
alias vi="vim"
alias vim="nvim"

function setup-pcs-dev-env() {
  export PCS_METRICS=${PCS_METRICS:=none}
  export TESTMODE=${TESTMODE:=1}
  export AWS_ACCESS_KEY_ID=123
  export AWS_DEFAULT_REGION=us-west-2
  export AWS_SECRET_ACCESS_KEY=asdf
  export AWS_SQS_QUEUE=asdf123
  export HYDRATED_BOM_SQS_QUEUE=blah
  export HEROKU_API_KEY=${HEROKU_API_KEY:=dummy_heroku_key}

  cat <<HERE
    Setting env:
    AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
    PCS_METRICS=${PCS_METRICS:=none}
    TESTMODE=${TESTMODE:=1}
    AWS_ACCESS_KEY_ID=123
    AWS_DEFAULT_REGION=us-west-2
    AWS_SECRET_ACCESS_KEY=asdf
    AWS_SQS_QUEUE=asdf123
    HYDRATED_BOM_SQS_QUEUE=blah
    HEROKU_API_KEY=${HEROKU_API_KEY:=dummy_heroku_key}
HERE
}


set -o vi
bindkey "^R" history-incremental-search-backward
bindkey "^?" backward-delete-char
[[ -n ${key[Backspace]} ]] && bindkey "${key[Backspace]}" backward-delete-char

SAVEHIST=100000

function salt-host () {
  env=$1
  host=$2
  salt_host=
  if [[ $env == prod ]]; then
    domain=cloudhub.io
    salt_host=$(ssh salt.$env.$domain "sudo salt-key -L" | grep $host)
  else
    domain=msap.io
    salt_host=$(ssh -J bastion.$env.$domain salt.$env.$domain "sudo salt-key -L" | grep $host)
  fi
  echo $salt_host
  echo $salt_host |head -1| pbcopy
}

# Setup tab and window title functions for iterm2
# iterm behaviour: until window name is explicitly set, it'll always track tab title.
# So, to have different window and tab titles, iterm_window() must be called
# first. iterm_both() resets this behaviour and has window track tab title again).
# Source: http://superuser.com/a/344397
set_iterm_name() {
  mode=$1; shift
  echo -ne "\033]$mode;$@\007"
}
iterm_both () { set_iterm_name 0 $@; }
iterm_tab () { set_iterm_name 1 $@; }
iterm_window () { set_iterm_name 2 $@; }

if [[ -f /usr/local/share/chtf/chtf.sh ]]; then
    source "/usr/local/share/chtf/chtf.sh"
fi

autoload zmv

unsetopt share_history

[ -f ~/$ZSH/custom/fzf.zsh ] && source $ZSH/custom/fzf.zsh

[ -f ~/$ZSH/custom/zsh-histdb/history-timer.zsh ] && source $ZSH/custom/zsh-histdb/history-timer.zsh
[ -f ~/$ZSH/custom/zsh-histdb/sqlite-history.zsh ] && source $ZSH/custom/zsh-histdb/sqlite-history.zsh
[ -f ~/$ZSH/custom/zsh-histdb/histdb-interactive.zsh ] && source $ZSH/custom/zsh-histdb/histdb-interactive.zsh
#bindkey '^r' _histdb-isearch
autoload -Uz add-zsh-hook
#add-zsh-hook precmd histdb-update-outcome

function gov-keycloak-multiprovider () {
#  for e in gbuild gstg gstg-rt gprod gprod-rt gbuild-mst gstg-mst gstg-rt-mst gprod-mst gprod-rt-mst; do
  for e in gbuild gstg gstg-rt gprod gbuild-mst gstg-mst gstg-rt-mst gprod-mst; do
    env=$(aws-keycloak -q -p admin-$e env)
    for v in $env; do
      echo "TF_${e}_${v}" | tr '-' '_'
    done
  done
}

function awskeycloak2config () {
   env=$1
   export $(aws-keycloak -p admin-$env env)
   echo "aws_access_key_id = $AWS_ACCESS_KEY_ID"
   echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY"
   echo "aws_security_token = $AWS_SESSION_TOKEN"
}

function clear_ssh_sockets () {
  rm -f ~/.ssh/sockets/*
}

FZF_PATH=/usr/local/opt/fzf/bin
[ -f $FZF_PATH ] && source $FZF_PATH

PATH=~/usr/bin:$PATH
PATH=$PATH:~/go/bin
PATH=$PATH:~/Library/Python/3.7/bin

# direnv hook
eval "$(direnv hook zsh)"
