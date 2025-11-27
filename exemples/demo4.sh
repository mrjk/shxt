#!/bin/bash
# Multilib support: bin or lib



eval "$(cat ../shxt.sh)"

# Failed test on strict mode ...
# set -eu
# export BASHFUL_MESSAGES_LOADED=
# export BASHFUL_MODES_LOADED=
# export BASHFUL_EXECUTE_LOADED=
# export BASHFUL_UTILS_LOADED=
# export BASHFUL_TERMINFO_LOADED=
# export BASHFUL_INPUT_LOADED=

# Test 

# Load a complete lib: https://github.com/jmcantrell/bashful
loader download lib bashful-utils https://raw.githubusercontent.com/jmcantrell/bashful/refs/heads/master/bin/bashful-utils
loader download lib bashful-doc https://raw.githubusercontent.com/jmcantrell/bashful/refs/heads/master/bin/bashful-doc
loader download lib bashful-terminfo https://raw.githubusercontent.com/jmcantrell/bashful/refs/heads/master/bin/bashful-terminfo
loader download lib bashful-execute https://raw.githubusercontent.com/jmcantrell/bashful/refs/heads/master/bin/bashful-execute
loader download lib bashful-modes https://raw.githubusercontent.com/jmcantrell/bashful/refs/heads/master/bin/bashful-modes

# set -x
loader download lib bashful-messages https://raw.githubusercontent.com/jmcantrell/bashful/refs/heads/master/bin/bashful-messages
loader download lib bashful-files https://raw.githubusercontent.com/jmcantrell/bashful/refs/heads/master/bin/bashful-files
loader download lib bashful-input https://raw.githubusercontent.com/jmcantrell/bashful/refs/heads/master/bin/bashful-input


# set -x
loader use lib bashful-messages
loader use lib bashful-input
# loader_source_lib lib bashful-input
set +x

echo BASHFULL LOADED

# set -x
# info "MESSAGE INFO"

warn "MESSAGE INFO"


# bashful-input help

echo OK

