#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

PATH=~/usr/bin:$PATH
PATH=$PATH:~/go/bin
export PCS_DEV_TOOLS_DIRECTORY=/Users/shiv.pande/git_repos/git.soma.salesforce.com/public-cloud-start/pcs-dev-tools/

export PATH

if [ $ITERM_SESSION_ID ]; then
precmd() {
  echo -ne "\033]0;${PWD##*/}\007"
}
fi

export GO111MODULE=on
export GOPRIVATE="github.com/sfdc-pcg,git.soma.salesforce.com"
