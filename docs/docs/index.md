# SHell eXTender

Easily reuse code chunks across shell scripts.

## Install

If you arrived by chance on this page, this is because an app requires shxt.sh to be installed. To fix this problem, simply run:

```bash
# Install as system level
curl -v https://mrjk.github.io/shxt/shxt.sh | sudo bash -s install

# Install for current user
curl -v https://mrjk.github.io/shxt/shxt.sh | bash -s install
```

Then run again you're app, it should work.

However, if you're here to use shxt.sh in your script or as shell manager, you're at the good place, please read on!


## Using shxt in your scripts

shxt.sh virtually let you use and reuse common piece of code, usually available on internet. Shxt.sh takes advantage of this to provide a very minimalist but yet powerful tool to act as a simple dependency resolver for bash.

Thus a very basic and common way to use shxt.sh is to always start your scripts like this:

```bash
#!/bin/bash

# Auto install shxt
. shxt.sh || eval "$(curl -v https://mrjk.github.io/shxt/shxt.sh)"
```

## Using shxt with your daily shell

You may want to live try shxt in your shell, thus try this:
```bash
. shxt.sh || eval "SHXT_NOINSTALL=true; $(curl -v https://mrjk.github.io/shxt/shxt.sh)"
```

## Using shxt with in your bashrc

Store your public configs online, and access them if not available.
```bash
# .bashrc
# File bashrc managed by shxt.sh

# Run or auto-install shxt.sh
. shxt.sh || eval "$(curl -v https://mrjk.github.io/shxt/shxt.sh)"

# My shell config as lib
loader use lib bash_config https://raw.githubusercontent.com/USER/dotfiles/ref/head/master/.config/bash_config.sh
```




