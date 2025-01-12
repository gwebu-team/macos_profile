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
- To make `Ctrl+Left` and `Ctrl+Right` jump words - add with escape sequence + `[1;5D` for back and `[1;5C` for forward.
- To make `Shift+Ctrl+C` and `Shift+Ctrl+V` work as in Linux - add `Ctrl+Shift+C/V` to `Copy Selection or Send ^C` and `Paste or send ^V`
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
grep "$HOMEBREW_PREFIX/bin/bash" /etc/shells || (echo "$HOMEBREW_PREFIX/bin/bash" | sudo tee -a /etc/shells)
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



## Fish setup

**Note**: You need to do all steps for the bash setup above

```shell
brew install fish
grep "$HOMEBREW_PREFIX/bin/fish" /etc/shells || (echo "$BREW/bin/fish" | sudo tee -a /etc/shells)
sudo chsh -s "$HOMEBREW_PREFIX/bin/fish" "$USER"
```

Restart your terminal application and it should login with Fish


### Fanciness

For the fancy prompt you shout install [Oh My Fish](https://github.com/oh-my-fish/oh-my-fish)
```shell
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
```

Then install one of the packages, say BobTheFish
```shell
omf install bobthefish
```

Exit your terminal and start it again. You should see BobTheFish prompt style.

**NOTE**: For your terminal application (iTerm2), download and select one of the [PowerLine fonts](https://github.com/powerline/fonts). This looks good [Roboto Mono](https://github.com/powerline/fonts/blob/master/RobotoMono/Roboto%20Mono%20Medium%20for%20Powerline.ttf). 


### Path setup

In order to have installed applications from Brew and GCloud, add the following to `.config/fish/config.fish`.

```
set -gx PATH /opt/homebrew/bin $PATH

# Google gcloud.
set gcloud_path (brew --prefix)/share/google-cloud-sdk/path.fish.inc
if test -r $gcloud_path
    source $gcloud_path
end
```



## WireGuard setup

WireGuard will be used to access remotely testing/development Linux system.


### TUI (console) method:

**NOTE**: use GUI mode if possible.

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

**NOTE**: You will receive additional VPN configuration file from your manager.

**NOTE**: WireGuard App might not show in the Tray, so system restart may be needed.

Once you see System Tray icon, click on it and select `Manage Tunnels`. Select the tunnel you have just added.
On the lower right corner of the window, click on the `Edit` button. Once the Tunnel configuration window opens, check `On-Demand` for all ethernet interfaces you have.
This will automatically start the VPN when you try to access the remote network.



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

**NOTE**: You may need to restart the computer before Hidden bar works.



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
gcloud components install gke-gcloud-auth-plugin kubectl pkg kustomize skaffold terraform-tools minikube
brew install kind
```


### for bash/fish users

```shell
source "$(brew --prefix)/share/google-cloud-sdk/path.bash.inc"
```


### for zsh users

```shell
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
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



## Install go

```shell
brew install go
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



## Misc scripts

There are some scripts you may find useful in the [bin](bin) directory here.
