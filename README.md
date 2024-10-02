# Enhanced shell

## Motivation

If you have a better shell, you might have thought how to easily move it to another machine. I am going to show you how to enhance your `zsh shell` in a way that is easily movable.

A very good idea is to use `devbox` to enhance your shell. Afterwards you want to somehow get this configuration to a `git` repository and sync it whenever you need. This way you get everything in code, and an easy way to update from a single source of truth.

Take a look at the [devbox tutorial](https://github.com/Frunza/devbox) if you are not familiar with it.

## Prerequisites

A Linux or MacOS machine for local development. If you are running Windows, you first need to set up the *Windows Subsystem for Linux (WSL)* environment. This tutorial is made for MacOS and assumes you are enhancing your `zsh shell`.

You must have [devbox](https://www.jetify.com/devbox/docs/) installed.

You *should* also have `git` installed.

## Setting things up

Checkout the `git` repository *https://github.com/Frunza/enhanced-shell.git* in your home directory:
```sh
cd ~
git clone https://github.com/Frunza/enhanced-shell.git
```
It is important to clone the repository in your home directory because the `devbox` shell must be started from inside the repository and it is assumed that the repository location is there.

Move your `.zshrc` and `.config/starship.toml` files to some backup location. If `.config/starship.toml` does not exist, ignore it. If you are not setting things up for a new machine, check any custom configuration of `.zshrc` and `.config/starship.toml` and add it to `enhanced-shell/dotfiles/.zshrc` and `enhanced-shell/dotfiles/.config/starship.toml`.

Start a `devbox` shell from the repository:
```sh
cd enhanced-shell
devbox shell
```
This will start a `devbox` shell with preconfigured tools and call some init hook scripts.

## What just happened?

From now on, every time you start a new shell, you will get an enhanced shell with the default location of `~`.

Let's go step by step to see how everything was set up.

The first meaningful command called was `devbox shell`. This started a `devbox` shell with the configuration of `devbox.json`. If you take a look at it, you will notice 2 main parts: packages and init hooks.

Your new shell will have all packages configured preinstalled with the versions you specified. It is a good idea to version everything so that you do not unexpectedly end up with tools that do not work as expected any more.

The first init hook is a script that updates the environment: some tools are initialized, some keybindings are set, some plugins are configured.

The second init hook uses the [stow](https://www.gnu.org/software/stow/) tool to create a shortcut of `.zshrc` and `.config/starship.toml` from the repository location to where they should be.

## What we got

First of all, we new have a default shell with desired tools preconfigured. Since `.zshrc` and `.config/starship.toml` are only shortcuts now, every time you pull from the repository, you will get new changes automatically, and in this case easily sync your enhanced shell between more machines.

Even if a new tool is added in the `.config` file via the repository, the first shell will automatically make a shortcut for it, and therefore make it available right away by calling the `sync.sh` script from its init hooks.

### Let's go through what is configured in the first init hook `init.sh`

```sh
eval "$(starship init zsh)" || handle_error
```
this initializes [starship](https://starship.rs/), a handy tool with various features. Some relevant ones are moving the current path and adding some extra information above your command prompt, leaving it only with the command prompt character; this way the place where you type has a lot more space. It also adds some coloring for failed and succeeded commands. Feel free to use more of its features and change its configuration `.config/starship.toml`.

```sh
eval "$(zoxide init --cmd cd zsh)" || handle_error
```
this initializes [zoxide](https://github.com/ajeetdsouza/zoxide), a tool that enhances your `cd` command by smartly figuring out where you want to navigate in a more complex structure by indexing your most used paths.
Example usage in the repository:
```sh
cd dotfiles/.config
cd ..
cd ..
cd .config
```
Normally `cd .config` would not work, but `zoxide` knows what you mean based on your history, and navigate to `dotfiles/.config`.

```sh
source $(find /nix/store -name zsh-syntax-highlighting.zsh | grep 'share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh')
```
this installs the [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) plugin. You will get some nice colors in your shell.

```sh
source $(find /nix/store -name zsh-history-substring-search.zsh | grep 'share/zsh-history-substring-search/zsh-history-substring-search.zsh')
```
this installs the [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) plugin.
It gets more powerful with the following keybindings:
```sh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
```
This will alloy you to type part of a command and press the up and down arrow keys to navigate through the history based on what you typed.
For example, if your history is:
```sh
ssh root@123.123.123.123
ls
docker ps
ssh root@myVM
ls
```
if you type `ssh` and press the up arrow key, you will get `ssh root@123.123.123.123` as autocompletion; pressing the up arrow key again will give you `ssh root@myVM`.

```sh
alias clear="tput reset && printf '\033[3J'"
```
this alias overwrites your `clear` command to clear and reset your shell output; this is useful for viewing larger logs for example, because the beginning is the first line you see when scrolling to the top.

```sh
alias ls='eza --long --all --no-permissions --no-filesize --no-user --no-time --git'
```
this alias uses [eza](https://github.com/eza-community/eza?tab=readme-ov-file) to enhance your `ls` command. You get some nice coloring for different filetypes with the possibility to add extra metadata.

```sh
alias lst='eza --long --all --no-permissions --no-filesize --no-user --git --sort modified'
```
this should mean `ls time` and it adds timestamp and sorting to `ls`.

```sh
alias lsp='find . -maxdepth 1 -type f | fzf --preview "bat --style numbers --color always {}"'
```
this should mean `ls preview` and it uses [fzf](https://github.com/junegunn/fzf) to allow you to move and preview the files normally obtained by running `ls`.

```sh
alias cat='bat --paging never'
```
this alias uses [bat](https://github.com/sharkdp/bat) to enhance your `cat` command. You get some nice coloring for the output and you can use other parameters as well, in this case disabling paging.

### Let's go through what is configured in `dotfiles/.zshrc`

```sh
setopt HIST_IGNORE_ALL_DUPS
```
removes duplicate entries from the shell history. For example, running:
```sh
clear
ls
docker ps
docker ps
ls
```
will give you the following items when you press the up arrow multiple times: `ls`, `docker ps` and `clear`; so all duplicates are removed, not just the neighbouring ones.


```sh
DEVBOX_NO_PROMPT=true
```
runs `devbox` in a non-interactively mode.

```sh
LANG=en_US.UTF-8
```
sets the system locale.

```sh
source <(docker completion zsh)
```
enables command-line completion for `Docker` commands in the shell. For example, if you type `docker ru` and press the `tab` key, you will get an autocompletion for `docker ru`. Also, pressing the `tab` key twice will give you an option for available options to choose from.

```sh
source <(kubectl completion zsh)
```
enables command-line completion for `kubernetes` commands in the shell. For example, if you type `kubectl get po` and press the `tab` key, you will get an autocompletion for `kubectl get pods`. Also, pressing the `tab` key twice will give you an option for available options to choose from.

```sh
(cd ~/enhanced-shell && devbox shell)
cd ~
clear
```
navigates to the location of your enhanced shell repository and starts a `devbox` shell. This is the place where the path of the repository is important. Afterwards your shell navigates to your home directory, and clears the boilerplate at the end.

### Let's go through some of the devbox tools

Most tools presented were present in the `devbox.json` file. You can add more or change versions, depending on your needs.

One uncovered tools is [yq](https://github.com/mikefarah/yq), a lightweight and portable command-line YAML, JSON and XML processor. For example:
```sh
kubectl get namespace kube-system --output yaml | yq .
```
will get yaml output and print it as json.
```sh
kubectl get namespace kube-system --output json | yq -y . | pygmentize -l yaml
```
will get json output and print it as yaml.
You can also use `yq` to get a specific field from your structure:
```sh
kubectl get namespace kube-system --output yaml | yq ".status.phase"
```

## Downsides

Currently there is one issue I encountered with `devbox`, which might be good to know about: environment variables that are set up in more lines, loose their line endings. For example, the environment variable
```sh
export TEST_ENV_VAR="line 1
line 2
line 3"
```
is printed out as
```sh
line 1line 2line 3
```
in the `devbox` shell. This might happen if you have private keys or `k8s` cluster configurations as environment variables.
