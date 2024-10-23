#!/usr/bin/env bash

export BASH_SILENCE_DEPRECATION_WARNING=1

# Changes the ulimit limits.
ulimit -Sn 4096      # Increase open files.
ulimit -Sl unlimited # Increase max locked memory.

eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$PATH:$HOME/.local/bin"

[[ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]] \
    && . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"

# Midnight Commander integration
MC_RC=$(echo "$HOMEBREW_PREFIX/Cellar/midnight-commander/"*"/libexec/mc/mc.sh")
if [ -r "$MC_RC" ]; then
    # Fix for the failure to cd to the directory where MC exited.
    sed -i.dist 's#$MC_USER/mc.pwd.#${MC_USER}_mc.pwd.#g' "$MC_RC"
    . "$MC_RC"
fi
unset MC_RC

# Do 'mkdir -p "$HOME/github/gwebu-team"; cd "$HOME/github/gwebu-team"; git clone https://github.com/gwebu-team/profile.d.git' to get these.
if [ -d "$HOME/github/gwebu-team/profile.d/etc/profile.d/" ]; then
    for i in "$HOME/github/gwebu-team/profile.d/etc/profile.d/"*.sh; do
        source "$i"
    done
fi

# JetBrains toolbox
if [[ -r "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ]]; then
    export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# nfpm
if command -V nfpm &> /dev/null; then
    . <(nfpm completion bash)
fi

# Google gcloud.
if test -r "$(brew --prefix)/share/google-cloud-sdk/path.bash.inc"; then
    . "$(brew --prefix)/share/google-cloud-sdk/path.bash.inc"
fi

# kubectl
if command -V kubectl &> /dev/null; then
    . <(kubectl --kubeconfig /dev/null completion bash)
fi

# Terraform
if [[ -x "$HOMEBREW_PREFIX/bin/terraform" ]]; then
    complete -C "$HOMEBREW_PREFIX/bin/terraform" terraform
fi

# ncdu
alias ncdu='ncdu --exclude ~/Library/CloudStorage/ --exclude ~/Library/Containers/'

# ssh control masters
alias ssh_controlmasters_ls='(cd ~/.ssh/controlmasters/; ls -A 2>/dev/null || echo "-- No control masters --")'
alias ssh_controlmasters_check='(cd ~/.ssh/controlmasters/; [ "$(ls -A)" ] && for i in *; do echo -n "$i: "; ssh -O check "${i%:*}" -p "${i##*:}"; done)'
alias ssh_controlmasters_stop='(cd ~/.ssh/controlmasters/; [ "$(ls -A)" ] && for i in *; do echo -n "$i: "; ssh -O stop "${i%:*}" -p "${i##*:}"; done)'

# python virtual env
# export VIRTUAL_ENV_DISABLE_PROMPT=yes

# misc
export TIME_STYLE=long-iso
export HISTSIZE=20480
export FZF_DEFAULT_OPTS="--history-size=$HISTSIZE"

# curl
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
. "$HOME/.cargo/env"
