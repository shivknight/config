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
plugins=(
  git
  docker
  ssh-agent
  terraform
  golang
  wd
  kubectl
  fzf
)


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
alias dc="docker-compose"

set -o vi
bindkey "^R" history-incremental-search-backward
bindkey "^?" backward-delete-char
[[ -n ${key[Backspace]} ]] && bindkey "${key[Backspace]}" backward-delete-char

SAVEHIST=100000

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

function clear_ssh_sockets () {
  rm -f ~/.ssh/sockets/*
}

function jdiff () {
  vimdiff <(jq -S '.' $1) <(jq -S '.' $2)
}

FZF_PATH=/usr/local/opt/fzf/bin
[ -f $FZF_PATH ] && source $FZF_PATH

PATH=~/usr/bin:$PATH
PATH=$PATH:~/go/bin
PATH=$PATH:~/Library/Python/3.7/bin
PATH=$PATH:/Users/shiv.pande/git_repos/git.soma.salesforce.com/public-cloud-start/pcs-dev-tools/bin
PATH=$PATH:/Users/shiv.pande/.gem/ruby/2.3.0/bin

### iTerm2 window title
if [ $ITERM_SESSION_ID ]; then
  export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"; ':"$PROMPT_COMMAND";
fi

# direnv hook
eval "$(direnv hook zsh)"

function amereast1_dnsresolvers () {
  sudo sh -c 'echo "nameserver 10.2.33.2\nnameserver 10.2.33.3" >> /etc/resolv.conf'
}

function delete_squashmerged_tracking_branches() {
  git for-each-ref refs/heads/ "--format=%(refname:short)" | \
    while read branch; do
      mergeBase=$(git merge-base master $branch) && \
      [[ $(git cherry master $(git commit-tree $(git rev-parse $branch\^{tree}) -p $mergeBase -m _)) == "-"* ]] && \
      git branch -D $branch
    done
}

function kubectl_ns_cleanup() {
  for NS in $(kubectl get ns 2>/dev/null | grep Terminating | cut -f1 -d ' '); do
    kubectl get ns $NS -o json > /tmp/$NS.json
    sed -i '' "s/\"kubernetes\"//g" /tmp/$NS.json
    kubectl replace --raw "/api/v1/namespaces/$NS/finalize" -f /tmp/$NS.json
  done
}

function kpcs() {
  # set -x
  kargs=${@[1,-2]}
  service=${*[-1]}
  kubectl $kargs $(kubectl get pod -l app.kubernetes.io/name=$service -o name)
}

# eval "$(starship init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(zoxide init zsh)"
source <(stern --completion=zsh)

function vault_auth() {
  set -x
  export FI=${FI:-dev1-uswest2}

  serviceProvider="${serviceProvider:-pcs}"
  clientId="${clientId:-pcs-hogs-oauth2-proxy}"
  TEMPLATE="kv/quantumksharedsecrets/${FI}/realms/${serviceProvider}/${clientId}"
  export QUANTUMK_VAULT_ROLE=$(echo ${TEMPLATE}-ro | tr '/' '_')
  export QUANTUMK_VAULT_PATH="${TEMPLATE}/secrets"

  export VAULT_ADDR=https://api.vault.secrets.${FI}.aws.sfdc.cl:443
  AWS_LOGIN_HEADER=api.vault.secrets.$FI.aws.sfdc.cl
  export VAULT_ROLE="${VAULT_ROLE:-kv_pcs-203892273912_pcsserviceinfra-rw}"
  export VAULT_CACERT="${HOME}/dev_cacerts.pem"
  export VAULT_TOKEN=$(vault login -token-only -address=$VAULT_ADDR -method=aws header_value=$AWS_LOGIN_HEADER role=$VAULT_ROLE)
}

function vault_auth2() {
  # Export the AWS credentials for one of the roles with the appropriate read/write privilege before running the commands.
  # Or, if you are using vaultconf-basic* pipelines, use *PCSKDeveloperRole*
  export VAULT_ROLE="${VAULT_ROLE:-kv_pcs-203892273912_pcsserviceinfra-rw}"
  export VAULT_CACERT="~/dev_cacerts.pem"
  export FI=${FI:-dev1-uswest2}
  AWS_LOGIN_HEADER=api.vault.secrets.$FI.aws.sfdc.cl
  export VAULT_ADDR=https://$AWS_LOGIN_HEADER
  export AWS_REGION=us-east-1 # STS service is always in us-east-1
  export VAULT_TOKEN=$(vault login --token-only --method=aws header_value=$AWS_LOGIN_HEADER role=$VAULT_ROLE)
  vault token lookup
}

_decode_base64_url() {
  local len=$((${#1} % 4))
  local result="$1"
  if [ $len -eq 2 ]; then result="$1"'=='
  elif [ $len -eq 3 ]; then result="$1"'='
  fi
  echo "$result" | tr '_-' '/+' | base64 -D
}

# $1 => JWT to decode
# $2 => either 1 for header or 2 for body (default is 2)
decode_jwt() { _decode_base64_url $(echo -n $1 | cut -d "." -f ${2:-2}) | jq .; }
