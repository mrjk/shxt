# Usage

Once shxt installed, you can use it.

## Examples

Here are dropped some examples.

### Load other pieces of shell

Here is a somewhat configuration:

```bash
# .bashrc
# File bashrc managed by shxt.sh

# Run or auto-install shxt.sh
. shxt.sh || eval "$(curl -v https://mrjk.github.io/shxt/shxt.sh); shxt_init"

# My shell config as lib
loader use lib bash_config https://raw.githubusercontent.com/USER/dotfiles/ref/head/master/.config/bash_config.sh
loader use lib bash_ps1 https://raw.githubusercontent.com/USER/dotfiles/ref/head/master/.config/bash_ps1.sh
loader use lib vim https://raw.githubusercontent.com/USER/dotfiles/ref/head/master/.config/vim.sh

# Load bash config from lib
load_bash_config
load_ps1
load_vim
```

### Use other programs

But it works for binary files as well:

```bash

# My shell tools
loader use bin yadm https://raw.githubusercontent.com/yadm-dev/yadm/refs/heads/master/yadm
loader use bin has https://raw.githubusercontent.com/kdabir/has/refs/heads/master/has
loader download bin spark https://raw.githubusercontent.com/holman/spark/refs/heads/master/spark

# Configure my shell hooks
loader use lib direnv https://raw.githubusercontent.com/USER/dotfiles/ref/head/master/.config/bash_direnv.sh
loader use lib mise https://raw.githubusercontent.com/USER/dotfiles/ref/head/master/.config/bash_mise.sh

# Always run a notice message
log INFO 'Shxt.sh managed'
```

### Make it even more minimal

You can even compact the whole in one single file, executing other imports:

```bash
# .bashrc
# Minimal bashrc managed by shxt.sh

# Run or auto-install shxt.sh
. shxt.sh || eval "$(curl -v https://mrjk.github.io/shxt/shxt.sh); shxt_init"

# My shell config as lib
loader use lib my_super_bash_cfg https://raw.githubusercontent.com/USER/dotfiles/ref/head/master/.my_super_bash_cfg.sh

# Then load a single function
config_shell
```

### Configuring rc.files

To implement.


### Disabling temporarly

To implement

### Reload

To implement

## Issues

### Long loading time

This can happen the first time when shxt is not installed or when shxt need to download other dependencies. Thus it maybe a good idea to keep your shxt.sh config minimalist, especially when starting for the first time a shell. This can be annoying in a shell context, or when the machine is slow to responds.

Check also other comlplimentary tools such as direnv, mise, asdf, pkgx ...

## Rationale

The most problematic point is to modify .bashrc file to make things easily, and for two reasons:

* Sometimes the user does not have a writable path in $PATH, like `/home/USER/bin` or `/home/USER/.local/bin`. So you have to modify $PATH
* Sometimes you need to source shell snippets to make some apps to work. They basically inject code in your shell, like direnv, mise and many other shell tools.

So .bashrc can quickly become messy and hard to maintain. What if now shxt.sh provides a way to quickly bootstrap various shell scripts in different ways ? Thus it become possible to use shxt.sh as bootstrap tool, to bootstrap more complex tools and so on.


