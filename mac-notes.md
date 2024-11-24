Notes
=====



## Sanity

- [Touch ID as password replacement for sudo](https://apple.stackexchange.com/questions/259093/can-touch-id-on-mac-authenticate-sudo-in-terminal)
- [Home and End sane behavior](https://apple.stackexchange.com/a/16137/522215)
    - Check [Library/KeyBindings/DefaultKeyBinding.dict](Library/KeyBindings/DefaultKeyBinding.dict) for just home and end.
    - Check [Library/KeyBindings/DefaultKeyBinding.dict-compose](Library/KeyBindings/DefaultKeyBinding.dict-compose) if you want the X11 compose functionality (compose,o,o->°; compose,t,m->™, compose,o,r->®), rename of course, drop the -compose suffix.
- [Mac keyboard shortcuts](https://support.apple.com/en-us/HT201236)
- Turn on function keys (F1-F12) by default:
    - Choose Apple menu  > System Settings.
    - Click Keyboard in the sidebar.
    - Click the Keyboard Shortcuts button on the right.
    - Click Function Keys in the sidebar.
    - Turn on "Use F1, F2, etc. keys as standard function keys".
- Make the Insert key work in iterm2 - [source](https://adterrasperaspera.com/blog/2013/08/29/how-to-make-the-inserthelp-key-emit-insert-in-iterm2/).
    - Go into `iTerm2` preferences and go to the `keys` tab.
    - Hit the `+` button at the bottom to add a new key.
    - Press your Insert/Help key to set that as your shortcut key, then select Send Escape Sequence as your action, and set [2~ as your escape sequence.
    - To make Ctrl+Left and Ctrl+Right jump words - add with escape sequence + `[1;5D` for back and `[1;5C` for forward.
- [Fixing iterm2's LC_CTYPE](https://blog.remibergsma.com/2012/07/10/setting-locales-correctly-on-mac-osx-terminal-application/).
    - The setting is located in Preferences | Settings | Advanced -> `character encoding` = `en_US.UTF-8`.
    - If this is no longer exists (latest iTerm2) the value for `LC_CTYPE` in Advanced should be `en_US.UTF-8` instead.


## Install brew

Just follow the instructions on [brew.sh](https://brew.sh/). The original command works, but I'd recommend:

```shell
curl -fL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o brew_install.sh
less brew_install.sh # Inspect
chmod a+x ./brew_install.sh
./brew_install.sh
rm ./brew_install.sh
```


## Change "±§" and "`~" keys

Install https://karabiner-elements.pqrs.org/

    brew install karabiner-elements

For the **Apple Internal Keyboard** map `Control and symbols/grave_accent_and_tilde` to `Control and symbols/non_us_backslash` and vice versa.



## Bash setup

First install sane bash 5:

```shell
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install bash
grep "$HOMEBREW_PREFIX/bin/bash" /etc/shells || (echo "$BREW/bin/bash" | sudo tee -a /etc/shells)
sudo chsh -s "$HOMEBREW_PREFIX/bin/bash" "$USER"
```

Edit `~/.bash_profile` to be something like this:

```shell
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
```
and do the following to get the fancy prompt, aliases and stuff from the gwebu team:
```shell
mkdir -p "$HOME/github/gwebu-team"
cd "$HOME/github/gwebu-team"
git clone https://github.com/gwebu-team/profile.d.git
```
close your terminal and reopen it.



## WireGuard setup


### TUI (console) method:

This has the added benefit `host node001` works.

```shell
# Install the tools.
brew install wireguard-tools

# Configure.
sudo mkdir -p /usr/local/etc/wireguard/
sudo chmod -Rv o=- /usr/local/etc/wireguard
sudo nano /usr/local/etc/wireguard/wg0.conf
# paste your config here

# Start the VPN.
sudo wg-quick up wg0

# Verify it works.
sudo wg
```
TODO: Check [this wg server guide](https://barrowclift.me/post/wireguard-server-on-macos) and [this about automatically starting the intefaces](https://blog.scottlowe.org/2021/08/04/starting-wireguard-interfaces-automatically-launchd-macos/).


### GUI

This method has the downside of requiring FQDNs: `host node001.sf.gwebu.com` works, while `host node001` does not.
To fix this you can `sudo networksetup -setsearchdomains Wi-Fi sf.gwebu.com` for example..

Download the app from [vaardan/wireguard-macos-app](https://github.com/vaardan/wireguard-macos-app/releases). Add an empty tunnel, copy-paste the config, add name, save, activate.



## Git and GPG signing

```shell
brew install git gnupg tig gitgui git-gui gnupg pinentry-mac
echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
```
and configure git.



## Git and GPG signing

```shell
brew install git gnupg tig gitui git-gui gnupg pinentry-mac
echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
```
and configure git.



## Setting battery limit to 80%

NB: Currently [broken](https://github.com/zackelia/bclm/issues/49), for the time being use [AlDente Free
](https://apphousekitchen.com/pricing/)
```shell
brew tap zackelia/formulae
brew install bclm
bclm read
sudo bclm write 80
bclm read
sudo bclm persist
```


## Other useful software

```shell
brew install bash bash-completion coreutils htop hiddenbar keepassxc make midnight-commander mtr nfpm ncdu pipx pv rsync stats tmux wget xz
```

NB: Hidden bar requires a *hack* to work `sudo xattr -r -d com.apple.quarantine "/Applications/Hidden Bar.app"`



## Removing/disabling iTunes

```shell
brew install --cask notunes
```

And follow the instructions on https://github.com/tombonez/noTunes:

1. Navigate to System Settings
2. Select General
3. Select Login Items
4. Click the + under Open at Login and select noTunes.app



## Working with containers

### Dock settings

```shell
defaults write com.apple.Dock showhidden -bool YES  # https://apple.stackexchange.com/q/9048/522215
defaults write -g NSWindowShouldDragOnGesture true
```



### Install and use base apps


```shell
brew install podman podman-tui podman-compose podman-desktop                     # the better docker, including emulation and compose.
podman search alpine                                                             # find the image and figure out the whole classifier.
podman search --list-tags --limit 1024 docker.io/library/alpine | less           # Explore at will.
```
Extras

```shell
brew install pipx                                                                # Like python's pip but for GUI/TUI packages, per app environment.
pipx install visidata                                                            # very nice TUI data explorer.
podman search --list-tags --limit 16384 docker.io/library/alpine | vd -f fixed   # explore at will, press ->, #, [, ].
podman search --format "table {{.Name}} {{.Official}} {{.Stars}}" --limit 128 \
    alpine | vd -f fixed                                                         # Fancier.


for i in ingress ingress-dns registry volumesnapshots; do minikube addons enable $i; done


brew install in2csv
in2csv percent.xls | vd
```

See also: [Podman Machine Setup for x86_64 on Apple Silicon (run Docker amd64 containers on M1,M2,M3)](https://medium.com/@guillem.riera/podman-machine-setup-for-x86-64-on-apple-silicon-run-docker-amd64-containers-on-m1-m2-m3-bf02bea38598). This fix might not be needed for the latest versions of MacOSX. Install only if needed.

**Note**: In PodMan Desktop click on the "Docker Compatibility" in the bottom of the application window. This will enable PodMan to act as docker, and will prevent issues down the road.

## Google cloud SDK

```shell
brew install --cask google-cloud-sdk
brew install kind
```

### for bash users

```shell
source "$(brew --prefix)/share/google-cloud-sdk/path.bash.inc"
```

### for zsh users

```shell
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
```

### for fish users

```shell
source "$(brew --prefix)/share/google-cloud-sdk/path.fish.inc"
```

Then run:

```shell
gcloud components install gke-gcloud-auth-plugin kubectl pkg kustomize skaffold terraform-tools minikube
```



## Python

The upstream python and the one that PyCharm installs do not have uninstall option.
Installing with brew allows for easier upgrade and uninstall. We need 3.9 and 3.11
for the conductor project, 3.12 and later have problem with the setup.py. Sample install:

```shell
brew install python python@3.11 python@3.12 python@3.9
```

To switch the default version to 3.12:

```shell
brew unlink python && brew link python@3.12
```

To switch the default version to 3.9:

```shell
brew unlink python && brew link python@3.9
```

NB: Close the terminal and open a new one to "activate" the change. Maybe `hash -r` will work too.



## SSH Control Masters

In order to speed up SSH connectivity, we use SSH Control Masters, that will cache active SSH connections and will reuse them for later SSH tunnels.

Add to your `.bash_profile` the following useful aliases:

```shell
# ssh control masters
alias ssh_controlmasters_ls='(cd ~/.ssh/controlmasters/; ls -A 2>/dev/null || echo "-- No control masters --")'
alias ssh_controlmasters_check='(cd ~/.ssh/controlmasters/; [ "$(ls -A)" ] && for i in *; do echo -n "$i: "; ssh -O check "${i%:*}" -p "${i##*:}"; done)'
alias ssh_controlmasters_stop='(cd ~/.ssh/controlmasters/; [ "$(ls -A)" ] && for i in *; do echo -n "$i: "; ssh -O stop "${i%:*}" -p "${i##*:}"; done)'
```

Setup your config:
```shell
mkdir -p ~/.ssh/controlmasters
chmod -R go=- ~/.ssh/
nano ~/.ssh/config
```
and add the following section on the bottom:
```
# This must be the last section in your  ~/.ssh/config
Host *
    # Use the following line to just ssh node007.sf.gwebu.com with different user.
    User your_dc_user
    #  %h, %p, and %r (or alternatively %C)
    ControlPath ~/.ssh/controlmasters/%r@%h:%p
    ControlMaster auto
    # on = forever, 900 = 15 minutes
    ControlPersist 1800
    ForwardAgent yes
```

You can of course customize individual hosts adding a section above the `Host *` one like this:
```
Host git.sf.gwebu.com
    # you can skip this line if you have the `Host *` section below
    User your_dc_user
    # you can also skip/override DNS resolution
    HostName 172.31.231.11
    # this allows git clone "ssh://git.sf.gwebu.com/playground"
    # instead of git clone "ssh://your_dc_user@git.sf.gwebu.com:29418/playground"
    Port 29418
```



## Running virtmanager

```shell
brew install virt-manager
brew tap arthurk/homebrew-virt-manager
virt-manager -c "qemu:///session" --no-fork
```



## Various

- nice ls alternative: `brew install eza; eza -l`



## X11 forwarding

This is used by DevOps mostly to manage the Sofia DC. See [How to install X Window System XQuartz on macOS for ssh X11 forwarding](https://www.cyberciti.biz/faq/apple-osx-mountain-lion-mavericks-install-xquartz-server/).



## CA Certificates

Open `/opt/homebrew/etc/ca-certificates/cert.pem` and append the CA certificate there.

For more info:
```shell
brew info openssl
```
Certificate (ca-ipa001.sf.gwebu.pem):
```
-----BEGIN CERTIFICATE-----
MIIEjjCCAvagAwIBAgIBATANBgkqhkiG9w0BAQsFADA3MRUwEwYDVQQKDAxTRi5H
V0VCVS5DT00xHjAcBgNVBAMMFUNlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0yMzEx
MTUxMTUzMTdaFw00MzExMTUxMTUzMTdaMDcxFTATBgNVBAoMDFNGLkdXRUJVLkNP
TTEeMBwGA1UEAwwVQ2VydGlmaWNhdGUgQXV0aG9yaXR5MIIBojANBgkqhkiG9w0B
AQEFAAOCAY8AMIIBigKCAYEAsn4unfW9rGV3FkVhIhWfZLDDdq8wAHQVpxxm9BnO
k4rtpIZJ0eWFdhSmI3jq0raMbmgwNJtoS1ZP6yhDqOvn5UeF//u3uLD8220OwPEd
K0U3P1cMkpBirDxVq2W3+WWLaejQqKqYSaE3wkhiJ0HoqKLtBW5zGSoGhmMLAoYs
jQ2yNvcdBQbs5mNtainp4uAQQAqSMYxfoV+QCKe5iHQzdRAWhWtEXbUELVQ9zMr5
5SUl5NcT7JiGDuJP6HJoYY7yLu4bTP5vHylSPhAvQkt7Yk9Xiby6KDhgUewUoabO
8WhE+wjI+KKw5aY562Jw57JQeiv68+BKnvLK9vxs2B5c3axV/FfJ53vTkOLAzHM0
PW7UfEtElm1SoMkbmzjR3rHi/4x3Rkz1VRNd89UPytCNTdSRgDMtPLEq7KXF3+rf
W40pLKcePC0nW3d9/74UeGlX3iw9SBB9BjRXuUlWaeJgeHIUwnezSI3FqlUthjNX
X9rKNiLOUBTWStKjBKEDUZZ/AgMBAAGjgaQwgaEwHwYDVR0jBBgwFoAUAA2nTcgz
puGK99EfIwb5ieWVUm4wDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAcYw
HQYDVR0OBBYEFAANp03IM6bhivfRHyMG+YnllVJuMD4GCCsGAQUFBwEBBDIwMDAu
BggrBgEFBQcwAYYiaHR0cDovL2lwYS1jYS5zZi5nd2VidS5jb20vY2Evb2NzcDAN
BgkqhkiG9w0BAQsFAAOCAYEAagHg9wqNFZ+WPOAyPnZPDl8KE65BAhjMA06cohcx
nmnNPKR7J4Yo7cGnFKWLzMqLXqUVoKBwFhv3Yme81zoAGPl1QY9rgIvkWOl8ugbv
lDdijS9kL7WbOofL2WDxzlN4tyimcG7Wcmu/ZAx4C9mWzvBUydbozLjMNRumpAQg
ZcPb28+APQYeeg1v9jC0l040/eG4QAhe3HvZzNGPwI2DwXE8A8z3h3YJ7dgu37my
8HihlZP8IERNsIHNtmtE9itnE2igq058jcgFeFTthXz8jfRrNCzLlKCX20YcSWnN
Ca0Qe2nejoPxI85yFePFD+mJV5n4D0ohH9/q5QMWOjm8ACje5wF28ytos1eIzhs5
0a31cwXC4XpDhNCBxwCFbDhoXg8jMNmqkWr79gh5gXkGOJjv8r5ObWVX2WU55J+d
codyOTNEwp1qATI7wTdL3fpgL8TI5LEWMW587Km+DB0Ge1YHtJoO5PhXQuYNhpDD
6us9nVQx38ZtbeowOvKjx8Lk
-----END CERTIFICATE-----
```
See also [Adding the IPA CA for SOF DC](https://flyrlabs.atlassian.net/wiki/spaces/Traditiona/pages/4151083365/Sofia+DC#Adding-the-IPA-CA-for-SOF-DC)


## Update packages regularly

### Upgrade brew installed packages

```shell
brew update; brew upgrade -g; brew cleanup
# brew doctor # Optional
```

### Upgrading pipx installed pacakges

```shell
pipx upgrade-all
```

### Automated update using a script

And here is a script (~/bin/MAC_UP for example) that updates packages installed with brew, pipx and all gcloud components:
```shell
#!/usr/bin/env bash

set -xe

brew update
brew upgrade -g
brew cleanup
if ! brew doctor; then
    echo "The doctor said take a look... $?"
fi

if command -v pipx &>/dev/null; then
    pipx upgrade-all
fi

if command -v gcloud &>/dev/null; then
    gcloud components update
fi
```

To create the script:
```shell
mkdir ~/bin/
cat > ~/bin/MAC_UP # Copy-paste the above and press Ctrl+D.
chmod +x ~/bin/MAC_UP
```

You can add `~/bin` to your `PATH` or just run it as `~/bin/MAC_UP`.



## Adding chromium site apps

In google chrome you can create "an app" for the google calendar, Gmail, Jura…
To do so select the three dots on top right ⋮ -> Cast, Save, and Share -> Install Page as App…
