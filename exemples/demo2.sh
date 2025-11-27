#!/bin/bash
# Multilib support: bin or lib

eval "$(cat ../shxt.sh)"


set -eu

# if false; then
loader use bin is.sh https://raw.githubusercontent.com/qzb/is.sh/refs/heads/master/is.sh
set -x
is.sh number 42 ; echo "RET=$?"
is.sh number zaerty || true ; echo "RET=$?"
set +x

# else

# Required for is.sh in lib mode
set +u
loader use lib is.sh https://raw.githubusercontent.com/qzb/is.sh/refs/heads/master/is.sh
is number 42 ; echo "RET=$?"
is number zaerty || true ; echo "RET=$?"

# fi
echo OK
