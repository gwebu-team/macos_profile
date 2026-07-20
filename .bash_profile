#!/usr/bin/env bash

export BASH_SILENCE_DEPRECATION_WARNING=1

# Changes the ulimit limits.
ulimit -Sn 4096      # Increase open files.
ulimit -Sl unlimited # Increase max locked memory.

eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin:$PATH:$HOME/.local/bin:$HOME/bin"
# All commands have been installed with the prefix "g".
# If you need to use these commands with their normal names, you
# can add a "gnubin" directory to your PATH from your bashrc like:
export PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"

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

# python virtual env
# export VIRTUAL_ENV_DISABLE_PROMPT=yes

# misc
export TIME_STYLE=long-iso
export HISTSIZE=20480
export FZF_DEFAULT_OPTS="--history-size=$HISTSIZE"

# curl
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# nnn
n() {
    # Save the last working directory from nnn
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Launch nnn with any arguments passed
    nnn -d "$@"

    # If the temp file exists, cd to the saved directory
    if [ -f "$NNN_TMPFILE" ]; then
        . "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE"
    fi
}

# Drop ._foo files from tar - https://superuser.com/a/66874/153604
export COPYFILE_DISABLE=true
if tar --help | grep xattr > /dev/null 2>&1; then
    export TAR_WRITER_OPTIONS=--no-xattrs
fi

# cargo
. "$HOME/.cargo/env"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.bash.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.bash.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.bash.inc'; fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/doncho.gunchev/.lmstudio/bin"
# End of LM Studio CLI section

# LLVM
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
