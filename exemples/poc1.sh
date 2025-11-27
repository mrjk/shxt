#!/bin/bashful


# Bin management
# ================================
loader download|install bin mybin URL
loader update bin mybin URL
loader use bin mybin [URL]


## LIbrary management
# ================================
loader download|install lib bashful-input URL
loader update lib bashful-input URL

# This read and load source code ONCE
loader use|source lib bashful-input [URL]
# loader source lib bashful-input [URL]


# File management
# ================================
loader download|install file myfile URL
loader update file myfile URL

loader path file myfile
loader cat file myfile


# Pkg management
# ================================
# Work with index
loader download pkg [INDEX_URL]
loader update pkg [INDEX_URL]

loader download pkg mypkg URL
loader update pkg mypkg URL

# Donload and execute pkg
loader use pkg mypkg

loader path pkg mypkg


# Init support
# =====================================

# Allo to configure loader
loader init|conf \
    --data-dir /tmp/toto... \
    --extra-bin-path MYPATH \
    --extra-lib-path MYPATH \
    --extra-file-path MYPATH \

    --download # Update missing files only
    --offline # Disable download
    --update # Redownload files files

    --download-only # Download missing deps and quit
    --dump # Download config and quit
    --help # Show help and quit


# Allow to support DOWNLOAD DEPS command and quit
# Cleanup temporary vars
loader app|start|clean
    --clean vars
    --clean func
    # --keep vars
    # --keep func
    --keep PATH

