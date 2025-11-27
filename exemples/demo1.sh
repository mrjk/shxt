#!/bin/bash


# set -- -d

# set -x
eval "$(cat ../shxt.sh )"


# set -x
# loader use bin has https://raw.githubusercontent.com/kdabir/has/refs/heads/master/has

# exit
set -eu


# set -x
loader use bin hr https://raw.githubusercontent.com/LuRsT/hr/refs/heads/master/hr


loader use bin esh https://raw.githubusercontent.com/jirutka/esh/refs/heads/master/esh
loader use bin has https://raw.githubusercontent.com/kdabir/has/refs/heads/master/has
loader use bin mise https://github.com/jdx/mise/releases/download/v2024.1.0/mise-v2024.1.0-linux-x64

loader download bin direnv https://github.com/direnv/direnv/releases/download/v2.37.1/direnv.linux-amd64
loader download bin spark https://raw.githubusercontent.com/holman/spark/refs/heads/master/spark

loader use bin yadm https://raw.githubusercontent.com/yadm-dev/yadm/refs/heads/master/yadm


log WARN 'App LOADED'
echo $PATH

set +e

export HAS_ALLOW_UNSAFE=y

# Display where binaries have been installed
command -v has
command -v hr
command -v direnv
command -v esh

# Actually run the commands
has -v
hr
has vim
hr
has ansible || true
hr


has yadm
echo direnv status

direnv status

hr
echo 'Template <%= $var1 %>' | esh - var1=valuueee

hr
spark 0 30 55 80 33 150

echo OK