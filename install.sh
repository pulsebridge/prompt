#!/usr/bin/env bash

CLR_SUCCESS="\033[1;32m"    # BRIGHT GREEN
CLR_CLEAR="\033[0m"         # DEFAULT COLOR

PULSEBRIDGE_PROMPT="$HOME/.pulsebridge/prompt"

function success() {
    echo -e "${CLR_SUCCESS}$1${CLR_CLEAR}"
}

now=$(date +"%Y%m%d_%H%M%S")
backup_path="backup/$now"

success "Creating backup path : $pwd/backup/$now..."
mkdir -p "backup/$now" 1>/dev/null

if test -d $PULSEBRIDGE_PROMPT; then
    success "Backing up $PULSEBRIDGE_PROMPT..."
    cp -R $PULSEBRIDGE_PROMPT/* "backup/$now" 1>/dev/null

    success "Removing $PULSEBRIDGE_PROMPT..."
    rm -rf $PULSEBRIDGE_PROMPT 1>/dev/null
fi

success "Creating $PULSEBRIDGE_PROMPT..."
mkdir -p $PULSEBRIDGE_PROMPT/bin 1>/dev/null

success "Installing PulseBridge Prompt to $PULSEBRIDGE_PROMPT..."
cp -Rf src/* $PULSEBRIDGE_PROMPT 1>/dev/null

if test -f $backup_path/scripts/bookmarks.sh; then
    success "Restoring bookmarks..."
    cp -R $backup_path/scripts/bookmarks.sh $PULSEBRIDGE_PROMPT/scripts 1>/dev/null
fi

for template in template/*; do
    name=$(basename "$template")
    path=$HOME/.${name}

    if test -f $path; then
        success "Backing up ${name}..."
        cp $path $backup_path/$name
    fi

    cat $template > $path
done

LOCAL_PREFIX=/usr/local
BASH_COMPLETION=$LOCAL_PREFIX/etc/bash_completion.d
UNAME=$(uname)
UNAME_INSTALL="./uname/install-$UNAME.sh"

if test -f $UNAME_INSTALL; then
    source $UNAME_INSTALL
fi

DOCKER_GC_NAME=docker-gc
DOCKER_GC_URI=https://raw.githubusercontent.com/spotify/docker-gc/master/docker-gc

GIT_PROMPT_NAME=git-prompt.sh
GIT_COMPLETE_NAME=git-flow-completion.bash
GIT_PROMPT_URI=https://raw.githubusercontent.com/lyze/posh-git-sh/master/$GIT_PROMPT_NAME
GIT_COMPLETE_URI=https://raw.githubusercontent.com/petervanderdoes/git-flow-completion/develop/$GIT_COMPLETE_NAME
PROMPT_COMPLETION=$PULSEBRIDGE_PROMPT/completions

if test -f "$BASH_COMPLETION/$GIT_COMPLETE_NAME"; then
    success "Removing git flow bash completion..."
    sudo rm -rf "$BASH_COMPLETION/$GIT_COMPLETE_NAME" 1>/dev/null
fi

if test -f "$BASH_COMPLETION/$GIT_PROMPT_NAME"; then
    success "Removing crappy git-prompt..."
    sudo rm -rf "$BASH_COMPLETION/$GIT_PROMPT_NAME" 1>/dev/null
fi

if ! test -d "$PROMPT_COMPLETION"; then
    mkdir -p "$PROMPT_COMPLETION" 1>/dev/null
fi

if type docker 1>/dev/null 2>&1; then
    success "Discovered docker; downloading $DOCKER_GC_NAME..."
    docker pull spotify/docker-gc
fi

success "Downloading better git-prompt..."
result=$(curl -s -L -D - "$GIT_PROMPT_URI" -o "$PROMPT_COMPLETION/$GIT_PROMPT_NAME" -# | grep "^HTTP/1.1" | head -n 1 | sed "s/HTTP.1.1 \([0-9]*\).*/\1/")

if test "$result" = "200"; then
    success "Successfully installed git-prompt..."
    chmod +x "PROMPT_COMPLETION/$GIT_PROMPT_NAME" 1>/dev/null 2>&1
fi

success "Downloading git-flow completion..."
result=$(curl -s -L -D - "$GIT_COMPLETE_URI" -o "$PROMPT_COMPLETION/$GIT_COMPLETE_NAME" -# | grep "^HTTP/1.1" | head -n 1 | sed "s/HTTP.1.1 \([0-9]*\).*/\1/")

if test "$result" = "200"; then
    success "Successfully installed git-flow completion..."
    chmod +x "$PROMPT_COMPLETION/$GIT_COMPLETE_NAME" 1>/dev/null 2>&1
fi

echo -e "${CLR_SUCCESS}"
echo "#######################################"
echo "#######################################"
echo "   PLEASE OPEN A NEW TERMINAL WINDOW"
echo "#######################################"
echo "#######################################"
echo -e "${CLR_CLEAR}"