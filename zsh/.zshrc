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
alias gfor="git fetch origin && git rebase origin/master"
alias gfur="git fetch upstream && git rebase upstream/master"
alias ghpc="gh pr create -a @me -r '@public-cloud-start/gia2h'"
alias zsrc="source ~/.zshrc"

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
function set_iterm_name() {
  mode=$1; shift
  echo -ne "\033]$mode;$@\007"
}
iterm_both () { set_iterm_name 0 $@; }
iterm_tab () { set_iterm_name 1 $@; }
iterm_window () { set_iterm_name 2 $@; }

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

function delete_squashmerged_tracking_branches() {
  git for-each-ref refs/heads/ "--format=%(refname:short)" | \
    while read branch; do
      mergeBase=$(git merge-base master $branch) && \
      [[ $(git cherry master $(git commit-tree $(git rev-parse $branch\^{tree}) -p $mergeBase -m _)) == "-"* ]] && \
      git branch -D $branch
    done
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
  vault kv get $QUANTUMK_VAULT_PATH
  export VAULT_TOKEN=$(vault login -token-only -address=$VAULT_ADDR -method=aws header_value=$AWS_LOGIN_HEADER role=$VAULT_ROLE)
}

function vault_auth2() {
  # Export the AWS credentials for one of the roles with the appropriate read/write privilege before running the commands.
  # Or, if you are using vaultconf-basic* pipelines, use *PCSKDeveloperRole*
  export VAULT_ROLE="${VAULT_ROLE:-kv_pcs-203892273912_pcsserviceinfra-rw}"
  export VAULT_CACERT="${HOME}/dev_cacerts.pem"
  export FI=${FI:-dev1-uswest2}
  AWS_LOGIN_HEADER=api.vault.secrets.$FI.aws.sfdc.cl
  export VAULT_ADDR=https://$AWS_LOGIN_HEADER
  export AWS_REGION=us-east-1 # STS service is always in us-east-1
  export VAULT_TOKEN=$(vault login --token-only --method=aws header_value=$AWS_LOGIN_HEADER role=$VAULT_ROLE)
  vault token lookup
}

function vault_qk_auth() {
  set -x
  export FI=${FI:-dev1-uswest2}

  serviceProvider="${serviceProvider:-pcs}"
  clientId="${clientId:-pcs-hogs-oauth2-proxy}"
  TEMPLATE="kv/quantumksharedsecrets/${FI}/realms/${serviceProvider}/${clientId}"
  export QUANTUMK_VAULT_ROLE=$(echo ${TEMPLATE}-ro | tr '/' '_')
  export QUANTUMK_VAULT_PATH="${TEMPLATE}/secrets"

  export VAULT_ADDR=https://api.vault.secrets.${FI}.aws.sfdc.cl:443
  AWS_LOGIN_HEADER=api.vault.secrets.$FI.aws.sfdc.cl
#  export VAULT_ROLE="${VAULT_ROLE:-kv_pcs-203892273912_pcsserviceinfra-rw}"
  export VAULT_CACERT="${HOME}/dev_cacerts.pem"
  export VAULT_TOKEN=$(vault login --token-only --address=$VAULT_ADDR --method=aws header_value=${AWS_LOGIN_HEADER} role="${QUANTUMK_VAULT_ROLE}")
  vault kv get $QUANTUMK_VAULT_PATH
}

function _decode_base64_url() {
  local len=$((${#1} % 4))
  local result="$1"
  if [ $len -eq 2 ]; then result="$1"'=='
  elif [ $len -eq 3 ]; then result="$1"'='
  fi
  echo "$result" | tr '_-' '/+' | base64 -D
}

# $1 => JWT to decode
# $2 => either 1 for header or 2 for body (default is 2)
function decode_jwt() { _decode_base64_url $(echo -n $1 | cut -d "." -f ${2:-2}) | jq .; }

function rename_bom() {
  BOM_PATH=$1
  NEW_NAME=$2
  jq --arg BOM_NAME $NEW_NAME '.falcon_instance.name = $BOM_NAME' $BOM_PATH
}

function ocr_latest_screenshot() {
  screenshotDir=~/Pictures/Screenshots
  filename=$(ls -tr ${screenshotDir} | tail -1)
  filepath=${screenshotDir}/${filename}
  tesseract ${filepath} -
}

############# Filter service instances belonging to service teams out of
############# falcon-instance-definintion
function st() {
  ST=$(SERVICE_NAME=$1 jq -r '.service_definition[] | select(.name==env.SERVICE_NAME).service_team' falcon-service-definition/1.0/*)
  SERVICE_TEAM=$ST jq '.team_definition[] | select(.name==env.SERVICE_TEAM) | {shortened_team_name:.shortened_name,team_name:.name,service_owners:[.gus_users+.admins]}' falcon-team-definition/1.0/*
}

function si() {
  export SERVICE_NAME=$1
  ST=$(jq -r '.service_definition[] | select(.name==env.SERVICE_NAME).service_team' falcon-service-definition/1.0/*)
  SERVICE_TEAM=$ST jq -c '.team_definition[] | select(.name==env.SERVICE_TEAM) | {team_name:.name,shortened_name:.shortened_name,service:env.SERVICE_NAME}' falcon-team-definition/1.0/*
}

service_types() {
  FID_FILE=$1
  jq -r '.functional_domain[].service_instances[].service_type' "${FID_FILE}" | sort -n | uniq > service_types
}

service_type_to_team() {
  SERVICE_TYPE_FILE=service_types
  while read sType; do
    export sType; pushd .. >/dev/null; st $sType | jq -r '[env.sType, .shortened_team_name, .team_name]|join(" ")'; popd>/dev/null;
  done< $SERVICE_TYPE_FILE > service_type_map
}

augment_service_instances() {
  SERVICE_MAP_FILE=service_type_map
  FID_FILE=${1}
  FID_FILE_AUGMENTED=${FID_FILE}.augmented
  cp ${FID_FILE} ${FID_FILE_AUGMENTED}
  while read sType shortenedTeamName teamName; do
    export sType; export shortenedTeamName; export teamName;
    jq '.functional_domain[].service_instances[] |= (select(.service_type==env.sType) |= .+ {service_team:env.teamName,shortened_name:env.shortenedTeamName})' $FID_FILE_AUGMENTED > f1.json
    mv f1.json $FID_FILE_AUGMENTED
  done < $SERVICE_MAP_FILE
}

filter_service_teams() {
  FID_FILE=${1}
  FID_FILE_AUGMENTED=${1}.augmented
  jq '(.functional_domain[].service_instances | arrays) |=
    map(select(.service_team | IN(
      "sam","mesh","fweinfrastructure","publicproxy","ddi","fit","soter","tableau-hyper-sync","sfmaps-services","industries-co","q4mobile","bastion"
    )))' ${FID_FILE_AUGMENTED} | \
    jq '.functional_domain[].service_instances[]|= del(.shortened_name,.service_team)' > ${FID_FILE}
}
#############

function gh-clone-org() {
  ORG=${1:-public-cloud-start}
  mkdir -p "${ORG}"
  # download a maximum of 1000 org repos and organize them under $ORG
   gh repo list -L 1000 "${ORG}" --no-archived --source --json languages,name,url --jq '.[] | select(.languages[].node.name=="Go") | .name' | while read -r repo _; do
   gh repo clone --sparse "${ORG}"/"$repo" "${ORG}"/"${repo}"
  done
}

function gh-clone-org-sparse() {
  ORG=${1:-public-cloud-start}
  mkdir -p "${ORG}"
  # download a maximum of 1000 org repos and organize them under $ORG
   gh repo list -L 1000 "${ORG}" --no-archived --source --json languages,name,url --jq '.[] | select(.languages[].node.name=="Go") | .url' | while read -r repo _; do
   git -C "${ORG}" clone --filter=blob:none --sparse $repo
  done
}

function update-go-version() {
  setopt +o nomatch
  for dir in ./*/; do
    pushd $dir
    go mod edit -go=1.19
    gsed -i -r -e 's/go=1.17/go=1.19/g' env.mk Makefile make/*
    vim Makefile make/standard-go.mk
    make deps
    popd
  done
}

function create-update-go-pr() {
  for dir in ./*/; do
    pushd $dir
    git switch -c shiv-update-go1.19

    make deps && git add go.* vendor
    git commit -m "Update to go1.19"

    gsed -i -r -e 's/(pcs-golang-ci-tooling:)(.*)/\157/g' .strata.yml
    git commit .strata.yml -m "Update golang-ci-tooling"
    go fmt $(go list ./... | grep -v vendor) && git commit -am "gofmt"

    git push -u origin shiv-update-go1.19
    gh label create -c '#2ECFD3' go1.19
    reviewers=$(repeat 3 {random_reviewer} | tr '\n' ',' | sed 's/,$/\n/')
    echo gh pr create -a @me -b "@W-12038443" -t "Update to go1.19" -l go1.19 -r ${reviewers}
    popd
    sleep 3
  done
}

function random_reviewer() {
  typeset -a reviewers
  RAND=$(od -A n -t d -N 1 /dev/urandom |tr -d ' ')
  reviewers=(
    alan-vaghti
    bgoines
    cindy-oneill
    cnadolny
    cyrus-mahdavi
    dmelanchenko
    ecoll
    grajpal
    jain-anirekh
    jonathan-mason
    lmisiuda
    msylla
    pchristopher
    mmittelstadt
    purvi-patel
    robert-nix
    rvasilev
    sahir
    sarahjane-olivas
    sarthur
    shiv-pande
    smith-nathan
    sofia-viotto
    v-bhat
    vdrozd
    weiteng-huang
    wmortl
    xiangjieli
  )
  print -r -- ${reviewers[$(( $RAND % ${#reviewers[@]} + 1 ))]}
}

st_diff() {
  BOMDIR=lib/fire/1.0.0/boms/
  FI=dev1-uswest2
  BOMFILE=${BOMDIR}/hydrated_${FI}.json
  export FD=scratchpad2
  LOOKBACK=$1
  comm -2 -3 \
    <(git show ${LOOKBACK}:./$BOMFILE | jq -c -r '.falcon_instance.functional_domains[] | select(.name==env.FD).service_teams[] | {service_team:.name,shortened_name:.shortened_name,accountID:.account_id}'|sort -n|uniq) \
    <(< $BOMFILE | jq -c -r '.falcon_instance.functional_domains[] | select(.name==env.FD).service_teams[] | {service_team:.name,shortened_name:.shortened_name,accountID:.account_id}'|sort -n|uniq)
}

bom_release_label() {
  REV_FILE=.git/BISECT_HEAD
  FI_FILE=./lib/fire/1.0.0/boms/hydrated_dev1-uswest2.json
  FIND_LABEL="20221111-190413"
  git bisect start --no-checkout
  git bisect bad upstream/master
  git bisect good upstream/master~10000

  while true; do
    CUR_LABEL=$(git show $(cat .git/BISECT_HEAD):lib/fire/1.0.0/boms/hydrated_dev1-uswest2.json | jq -r '.falcon_instance.release_label')
    echo $CUR_LABEL
    if [[ $CUR_LABEL == $FIND_LABEL ]]; then
      cat $REV_FILE
      git bisect reset
      break
    elif [[ $CUR_LABEL < $FIND_LABEL ]]; then
      git bisect good
    elif [[ $CUR_LABEL > $FIND_LABEL ]]; then
      git bisect bad
    fi
  set +x
  done
}
