#!/bin/bash


# =============================================================
# Documentation
# =============================================================

# Usage API:
# source import.sh ../lib
# import https://raw.githubusercontent.com/qzb/is.sh/master/is.sh
# import myapp_lib1.sh
# import myapp_lib2.sh

# package.sh file is.sh@v1.1.2 

# See: https://github.com/dylanaraps/pure-bash-bible/blob/master/README.md#get-the-terminal-size-in-lines-and-columns-from-a-script

# a vars from untouched shell: 
# bash: ( env -i bash --norc -o posix -c set ) | less
# sh: ( env -i sh --norc -c -- set )


# =============================================================
# Libraries
# =============================================================

# Portable realpath implementation in shell script
# Usage:
#  realpath [<PATH>]
# Example:
#  realpath "${BASH_SOURCE[0]}"
#  realpath ../bin/file
#  realpath
# Source: https://stackoverflow.com/a/45828988
realpath()
( 
  # TOFIX: Verify this function still work in strict mode
  # set -o errexit -o nounset
  declare link="${1:-$PWD}"
  
  # Try with real realpath first
  if command realpath "$link" 2>/dev/null; then return; fi

  # If it's a directory, just skip all this.
  if cd "$link" 2>/dev/null; then
    pwd -P "$link"; return 0
  fi

  # Resolve until we are out of links (or recurse too deep).
  declare n=0 limit=1024
  while [[ -L $link ]] && [[ $n -lt $limit ]]; do 
    n=$((n + 1))
    cd "$(dirname -- ${link})" \
      && link="$(readlink -- "${link##*/}")"
  done; cd "${link%/*}"

  # Check limit recursion
  [[ $n -lt $limit ]] || {
    >&2 printf "ERROR: Recursion limit ($limit) exceeded.\n"
    return 2; }

  printf '%s/%s\n' "$(pwd -P)" "${link##*/}"
)


# Add a <PATH> to <PATHS_VAR>
# Usage:
#  varpath_prepend <PATHS_VAR> <PATH>
# Example:
#  varpath_prepend PATH $PWD/app/bin
varpath_append_force() {
  local var=$1
  local path=$2

  log TRACE "Prepend to $var: $path"
  if [[ ":${!var}:" != *":$path:"* ]]; then
  # if [ -d "$path" ] && [[ ":${!var}:" != *":$path:"* ]]; then
  #   log TRACE "Add prepend to '$var': $path"
    export "${var}=${!var:+"${!var}:"}$path"

  fi
}
varpath_append() {
  local var=$1
  local path=$2
  
  if [ -d "$path" ]; then
    varpath_append_force "$var" "$path"
  else
    log TRACE "Skip directory for $var: $path"
  fi

}


# Add a <PATH> to <PATHS_VAR>
# Usage:
#  varpath_append <PATHS_VAR> <PATH>
# Example:
#  varpath_append PATH $PWD/app/bin
varpath_prepend_force() {
  local var=$1
  local path=$2

  if [[ ":${!var}:" != *":$path:"* ]]; then
    log TRACE "Append to $var: $path"
    export "${var}=$path${!var:+":${!var}"}"
  else
    log TRACE "Already in path $var: $path"
    return 1
  fi
}
varpath_prepend() {
  local var=$1
  local path=$2
  
  if [ -d "$path" ]; then
    varpath_prepend_force "$var" "$path"
  else
    log TRACE "Skip directory for $var: $path"
  fi

}


# Find first matching file called <NAME> in list of <PATHS_VAR>
# Usage:
#  varpath_find <PATHS_VAR> <NAME>
varpath_find ()
{
  local var_name=$1
  local target=$2
  local path=
  log TRACE "File lookup: '$target' from \$${var_name}"

  local paths=$(/usr/bin/tr ':' '\n' <<< "${!var_name}")
  while read path ; do
    file="$path/$target"
    if [[ -f "$file" ]]; then
      log TRACE "File lookup successed: $file"
      printf "%s\n" "$file"
      return 0
    else
      log TRACE "File lookup failed: $file"
    fi
  done <<<"$paths"
  log TRACE "Could not find file '$target' in '\$${var_name}'"
  # >&2 printf "%s\n" "WARN: Could not find file '$target' in "${var_name}""
  return 1
}

varpath_find2 ()
{
  local var_name=$1
  local target=$2
  local path=
  log TRACE "File lookup: '$target' from \$${var_name}"

  local paths=$(/usr/bin/tr ':' '\n' <<< "${!var_name}")
  while read path ; do
    file="$path/$target"
    if [[ -f "$file" ]]; then
      log TRACE "File lookup successed: $file"
      printf "%s\n" "$file"
      return 0
    else
      log TRACE "File lookup failed: $file"
    fi
  done <<<"$paths"
  log TRACE "Could not find file '$target' in '\$${var_name}'"
  # >&2 printf "%s\n" "WARN: Could not find file '$target' in "${var_name}""
  return 1
}


# Find all writable or parents dirs and return a colon separated string result
# Usage:
#  varpath_find_rw_dir [<PATHS>...]
varpath_find_rw_dir ()
{
  local target=($@)
  if [[ "$@" == '-' ]] ; then
    # Read from stdin
    local target=() line=
    # exec < <(printf '%s\n' "$@")
    while IFS= read -r line; do
      [ -z "$line" ] || target+=($line)
    done <<<"$(cat /dev/stdin)"
  fi
  local i=0
  local result=''
  while (( i < ${#target[@]} )); do
      local path="${target[i]}"
      local parent=${path%/*}
      if [ -d "$path" ]; then
        if [ -w "$path" ]; then
          result="${result:+$result:}$path"
        fi
      elif [ -d "$parent" ]; then
        if [ -w "$parent" ]; then
          result="${result:+$result:}$path"
        fi
      fi
      ((i++))
  done
  printf "%s" "$result"
}

# Test if shell is executed or sourced
# # if [[ "${BASH_SOURCE[0]}" =~ .*"$0"$ ]]; then
# if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
#     echo EXECUTED
# else
#     echo SOURCED
# fi

# Return true if context is executed
shell_is_executed () {
  [[ "${BASH_SOURCE[0]}" == "$0" ]]
}

# Return false if context is sourced
shell_is_sourced () {
  ! shell_is_executed
}

# Return false if context is sourced
shell_is_known () {
  local name=$1
  case "$name" in
    */sh) echo "$name" ;; 
    */ash) echo "$name" ;; 
    */bash) echo "$name" ;; 
    */zsh) echo "$name" ;; 
    *) return 1;; 
  esac
}

# Sources:
# https://serverfault.com/questions/146745/how-can-i-check-in-bash-if-a-shell-is-running-in-interactive-mode

# Return true if terminal stdin is interactive terminal
shell_is_interactive () {
  [ -t 0 ]
}

# Return true if terminal stdin is not interactive
shell_is_not_interactive () {
  ! [ -t 0 ]
}



# Source a shell file
shell_source ()
{
  local path=$1
  shift 1 || true
  local rc=0

  PWD="${path%/*}" . "$path" $@ || \
    {
      rc=$?
      >&2 printf "Failed to load lib returned $rc: %s\n" "$p"
    }
  return $rc
}


# Download an <URL> into <PATH> or stdout
# Usage:
#  download_file <URL>
#  download_file <URL> <PATH>
download_file() {
  local url=$1
  local filename=${2:--}

  if [ -z "$url" ]; then
      echo "Usage: download_file <URL> [<FILENAME>]"
      return 1
  fi

  # Create destination dir
  if [ "$filename" != '-' ]; then
    local parent="${filename%/*}"
    [[ -d "${parent}" ]] || mkdir -p "${parent}"
  fi

  # Find download tool
  local rc=0
  if command -v curl > /dev/null; then
      curl -L -s -o "$filename" "$url" || rc=$?
      if [[ $rc -ne 0 ]]; then
        log WARN "Failure after curl: $rc"
        return 1
      fi
  elif command -v wget > /dev/null; then
      wget -O "$filename" "$url"
  else
      printf "%s\n" "Neither curl nor wget is installed. Please install one of them to use this function."
      return 1
  fi

  # Report
  if [ $? -ne 0 ]; then
    >&2 printf "ERROR: Failed to download the file: %s\n" "$url"
    return 1
  else
    log TRACE "File downloaded successfully as: $filename"
  fi
}







# SHXT_LOG_LEVEL=${SHXT_LOG_LEVEL:-INFO}  # DRY, DEBUG, TRACE
# SHXT_LOG_SCALE="TRACE:DEBUG:RUN:INFO:DRY:HINT:NOTICE:CMD:USER:WARN:ERR:ERROR:CRIT:TODO:DIE:QUIT:PROMPT"


# CLI libraries
# =================
# Validate log level pass aginst limit
_log_validate_level ()
{
  local SHXT_LOG_SCALE="${SHXT_LOG_SCALE:-TRACE:DEBUG:INFO:NOTICE:WARN:ERR:ERROR:CRIT:TODO:DIE:QUIT:PROMPT}"

  local level=$1
  local limit_level=${2:-${SHXT_LOG_SCALE%%:*}}
  
  if [[ ! ":${SHXT_LOG_SCALE#*$limit_level:}:$limit_level:" =~ :"$level": ]]; then
    if [[ ! ":${SHXT_LOG_SCALE}" =~ :"$level": ]]; then
      >&2 printf "%s\n" "  BUG: Unknown log level: $level"
    fi
    return 1
  fi
}

# Logging support, with levels
log () 
{
  local SHXT_LOG_LEVEL=${SHXT_LOG_LEVEL:-INFO}

  local old_setting=${-//[^x]/}; set +x
  local level="${1:-DEBUG}"
  shift 1 || true

  # Check log level filter
  if _log_validate_level "$level" "$SHXT_LOG_LEVEL"; then

    local msg=${*}
    if [[ "$msg" == '-' ]]; then
      msg="$(cat -)"
    fi
    while read -r -u 3 line; do
      >&2 printf "%6s: %s\\n" "$level" "${line:- }"
    done 3<<<"$msg"
  fi
  
  # Restore trace mode if was enabled
  if [[ -n "${old_setting-}" ]]; then set -x; else set +x; fi
}

# Terminate all with error message and rc code
log_die ()
{
    local rc=${1:-1}
    shift 1 || true
    local msg="${*:-}"
    local prefix=DIE
    [[ "$rc" -eq 0 ]] || prefix=DIE
    if [[ -z "$msg" ]]; then
      [ "$rc" -ne 0 ] || exit 0
      log "$prefix" "Program terminated with error: $rc"
    else
      log "$prefix" "$msg"
    fi

    # Remove EXIT trap and exit nicely
    trap '' EXIT
    exit "$rc"
}







# =============================================================
# Internal libraries: Registries
# =============================================================


# Register library
# Usage: loader_register STORE PATH [NAME]
loader_register()
{
  local store_name=$1
  local store=${!store_name}
  local path=$2
  local file=${3:-${path##*/}}
  local dir=${path%/*}
  
  # # Do initial load
  # if [[ -z "${SHLIB-}" ]]; then
  #   SHSRC=$path
  #   SHSRC_FILE=$file
  #   SHSRC_DIR=$dir
  # fi
  
  # Check if lib is not already registered
  # [[ ":${store-}:" != *:$file:* ]] || {
  [[ ":${store-}:" != *:$file=*:* ]] || {
    >&2 printf "Item already registered: %s\n" "$file"
    return 1
  }
  
  # Add module into SHLIB
  declare -g "$store_name"="${store:+$store:}$file=$path"
 
  # Importing vars
  _IMPORT_PATH=$path
  _IMPORT_FILE=$file
  _IMPORT_DIR=$dir
}






# =============================================================
# Init Loader
# =============================================================


# Prepare import.sh environment
shxt_init()
{

  local auto_install=true
  local auto_update=true
  local debug=false
  local trace=false
  local OPTIND=0
  while getopts 'dxuUlL' opt; do
    case ${opt} in
      d)
        debug=true
        ;;
      x)
        trace=true
        ;;
      u)
        auto_update=true
        ;;
      U)
        auto_update=false
        ;;
      l)
        auto_install=true
        ;;
      L)
        auto_install=false
        ;;
      ?)
        log ERROR "Invalid option: -${OPTARG}."
        return 1
        ;;
    esac
    OPTIND=$((OPTIND + 1))
  done
  OPTIND=$((OPTIND - 1))
  shift "$OPTIND"


  # Enable flags
  if [[ "$debug" == true ]]; then
    SHXT_LOG_LEVEL=TRACE
    log INFO "shxt.sh debug mode enabled"
  fi
  if [[ "$trace" == true ]]; then
    set -x
  fi

  # Init core
  local d=${1-} # ${1:-$(ps -o args= $$)}
  
  local path=$(realpath "$0")
  local root="${path%/*}${d:+/$d}"


  # Autodetect current installation
  
  local install_path=$(command -v "shxt.sh" 2>/dev/null)
  local need_update=false
  if [[ "$auto_install" == true ]] && [[ ! -x "$install_path" ]] ; then
    # Auto install in PATH if not installed
    log INFO "Auto-installing shxt.sh"
    if _loader2__install; then
      need_update=true
    fi

  elif [[ "$auto_update" == true ]] && [[ -x "$install_path" ]] ; then
    # Run auto update ...
    local max_days=7
    local max_age_ts=$(date -d "now - $max_days days" +%s)
    local last_update_ts=$(date -r "$install_path" +%s)
    if (( last_update_ts <= max_age_ts )); then
      # echo "$filename is older than 100 days"
      log INFO "Auto-updating shxt.sh because older than $max_days days"
      if _loader2__install; then
        need_update=true
      fi
    else
      log TRACE "No need to update, newer than $max_days days"
    fi
  fi

  # Reload code
  if [[ "$need_update" == true ]]; then
    log TRACE "Reloading shxt source code"
    install_path=$(command -v "shxt.sh" 2>/dev/null)
    . "$install_path"
  fi
  export SHXT_INSTALL_PATH=$install_path



  # set +x

  # Auto-register into SHLIB or quit
  export SHXT_LIBS=''
  loader_register SHXT_LIBS "$path" shxt.sh || return 0
  export SHXT_VERSION=0.0.1
  export USER=${USER:-$(id -u)}
  export SHXT_NEEDLE=${SHXT_NEEDLE:-${USER}-$(cksum <<< "$path" | cut -f 1 -d ' ')}

  # Find most suitable RW path
  export SHXT_DATA_DIRS=$(varpath_find_rw_dir \
    "$HOME/.local/share/shxt" \
    "$HOME/.tmp/shxt" \
    "/tmp/" \
    "/dev/shm/" \
    "$root/cache/" \
    "$root/tmp/"
    )

  # Keep only first writable dir and append program needle
  export SHXT_RW_PATH="${SHXT_DATA_DIRS%%:*}${SHXT_DATA_DIRS:+/$SHXT_NEEDLE}"

  # Etra dirs
  export SHXT_DIR_BIN=${SHXT_RW_PATH:+$SHXT_RW_PATH/bin}
  export SHXT_DIR_LIB=${SHXT_RW_PATH:+$SHXT_RW_PATH/lib}
  export SHXT_DIR_FILES=${SHXT_RW_PATH:+$SHXT_RW_PATH/files}

  [ -d "${SHXT_DIR_BIN:-}" ] || mkdir -p "${SHXT_DIR_BIN}"
  [ -d "${SHXT_DIR_LIB:-}" ] || mkdir -p "${SHXT_DIR_LIB}"
  [ -d "${SHXT_DIR_FILES:-}" ] || mkdir -p "${SHXT_DIR_FILES}"


  # return 1

  # # Prepare lookup paths

  export SHXT_LIB_PATHS=
  # varpath_append SHXT_LIB_PATHS "$root/lib"
  # varpath_append SHXT_LIB_PATHS "$root/libexec"
  # varpath_append SHXT_LIB_PATHS "$root"
  # varpath_append SHXT_LIB_PATHS "$SHXT_DIR_SHARED/lib"
  # varpath_append SHXT_LIB_PATHS "$SHXT_DIR_DOWNLOADS/$SHXT_NEEDLE/lib"

  # export SHXT_FILE_PATHS=
  # varpath_append SHXT_FILE_PATHS "$root/share"
  # varpath_append SHXT_FILE_PATHS "$root"
  # varpath_append SHXT_FILE_PATHS "$SHXT_DIR_SHARED/share"
  # varpath_append SHXT_FILE_PATHS "$SHXT_DIR_DOWNLOADS/$SHXT_NEEDLE/files"

  export SHXT_BIN_PATHS=$PATH
  # varpath_prepend SHXT_BIN_PATHS "/usr/local/sbin/"
  # varpath_prepend SHXT_BIN_PATHS "/usr/local/bin/"
  # varpath_prepend SHXT_BIN_PATHS "$HOME/bin"
  # varpath_prepend_force SHXT_BIN_PATHS "$HOME/.local/bin"
  # varpath_prepend_force SHXT_BIN_PATHS "$HOME/.local/scripts"

  varpath_prepend SHXT_BIN_PATHS "$root/bin"
  varpath_prepend SHXT_BIN_PATHS "$root"
  varpath_prepend SHXT_BIN_PATHS "$SHXT_DIR_BIN"
  varpath_prepend SHXT_BIN_PATHS "$SHXT_DIR_SHARED/bin"
  # varpath_prepend SHXT_BIN_PATHS "$SHXT_DIR_DOWNLOADS/$SHXT_NEEDLE/bin"

  varpath_prepend SHXT_BIN_PATHS "$SHXT_RW_PATH"

  # log WARN "PATH DIRS: $SHXT_BIN_PATHS"

  # Self register and init
  # export SHXT_BIN_PATHS_OLD=${SHXT_BIN_PATHS_OLD:-$PATH}
  # export SHXT_FILE_MAP=
  # export SHLIB=
  # export SHXT_LIBS='toto:titi'

  # echo "RET=$(shell_is_known $path)"
  # return 1
  # loader_register SHXT_LIBS "$path" 

  # export PATH=$SHXT_BIN_PATHS


  log TRACE "shxt.sh inited: $SHXT_RW_PATH"

}


# Ensure shxt.sh is installed gloabally
_loader2__install ()
{

  local dest=${1:-}
  # local url="https://mrjk.github.io/shxt/shxt.sh"
  # local url="https://mrjk.github.io/shxt/v.1/shxt.sh"
  local url="https://raw.githubusercontent.com/mrjk/shxt/refs/heads/main/shxt.sh"

  local force=false
  while getopts ':f' opt; do
    case ${opt} in
      f)
        force=true
        ;;
      ?)
        log ERROR "Invalid option: -${OPTARG}."
        return 1
        ;;
    esac
  done

  # Quit if already installed
  local existing=$(command -v "shxt.sh" 2>/dev/null)
  if [[ -x "$existing" ]] ; then
    if [[ "$force" != true ]]; then
      log TRACE "shxt.sh already installed in $existing"
      return 0
    fi
  fi

  # Detect install path
  local result=
  if [ -n "$dest" ]; then
    dest=$(varpath_find_rw_dir "$dest")
  else

    dest=$(tr ':' '\n' <<< "$PATH" | tac | varpath_find_rw_dir -)
    dest=${dest%%:*}
  fi

  # Ensure destination dir exists
  [ -d "$dest" ] || mkdir -p "$dest"
  if [ ! -w "$dest" ] ; then
    log ERROR "Impossible to install or write in path: $dest"
    return 1
  fi

  # Ensure a file has been updated
  local _shxt_ctx_target_download_path="$dest/shxt.sh"
  log INFO "Downloading $_shxt_ctx_target_download_path from $url ..."
  if download_file "$url" "$_shxt_ctx_target_download_path"; then
    chmod +x "$_shxt_ctx_target_download_path"

    log INFO "shxt.sh installed in $dest"
  else
    log ERROR "Failed to install shxt.sh"
    return 1
  fi
}



_loader2__init ()
{
  echo "Init or reconfigure shxt $@"
}

_loader2__clean ()
{
  echo "Clean shxt $@"
}



# =============================================================
# NEW API V2 helpers
# =============================================================

_loader2__ctx_clean () {
  unset ${!_shxt_ctx_*}
}

_loader2__ctx_init () {

  export _shxt_ctx_kind=$1
  export _shxt_ctx_target=$2
  export _shxt_ctx_target_installed=false
  export _shxt_ctx_target_downloaded=false

  export _shxt_ctx_store_name=
  export _shxt_ctx_store_paths=

  export _shxt_ctx_target_download_dir=
  export _shxt_ctx_target_download_path=
  export _shxt_ctx_target_dir=
  export _shxt_ctx_target_path=

  # source_url=${3:-}

  case "$_shxt_ctx_kind" in
    bin)
      _shxt_ctx_store_name=SHXT_BIN_PATHS
      _shxt_ctx_target_download_dir=${SHXT_RW_PATH:+$SHXT_RW_PATH/bin}
      # path_suffix="$SHXT_DIR_BIN"
      ;;
    lib)
      _shxt_ctx_store_name=SHXT_LIB_PATHS
      _shxt_ctx_target_download_dir=${SHXT_RW_PATH:+$SHXT_RW_PATH/lib}
      # path_suffix="$SHXT_DIR_LIB"
      ;;
    file)
      _shxt_ctx_store_name=SHXT_FILE_PATHS
      _shxt_ctx_target_download_dir=${SHXT_RW_PATH:+$SHXT_RW_PATH/files}
      # path_suffix="$SHXT_DIR_FILES" 
      ;;  
    *) 
      >&2 printf "_loader2__ctx_init does not support kind '%s', please use one of: %s\n" "$_shxt_ctx_kind" "bin, lib or file"
      return 8
    ;;
  esac

  # Ensure path is always up to date
  export PATH=$SHXT_BIN_PATHS

  # Set custom paths
  _shxt_ctx_store_paths=${!_shxt_ctx_store_name}
  _shxt_ctx_target_download_path=${_shxt_ctx_target_download_dir:+$_shxt_ctx_target_download_dir/$_shxt_ctx_target}

  # Lookup if not downloaded
  if [ -f "$_shxt_ctx_target_download_path" ]; then
    _shxt_ctx_target_path="$_shxt_ctx_target_download_path"
    _shxt_ctx_target_downloaded=true
  else
    _shxt_ctx_target_path=$(varpath_find2 "$_shxt_ctx_store_name" "$_shxt_ctx_target" || true)
  fi

  # Report if installed
  _shxt_ctx_target_dir=${_shxt_ctx_target_path%/*}
  if [ -f "$_shxt_ctx_target_path" ]; then
    _shxt_ctx_target_installed=true
  fi

}

# ======================
# NEW API V2 LOADER
# ======================


_loader2__download ()
{
  _loader2__ctx_init "$@"
  shift 2
  local url=${1:-}
  
  # Ensure URL is available
  if [ -z "$url" ]; then
    log CRIT "Missing URL for $_shxt_ctx_target !"
    return 1
  fi

  if [ "$_shxt_ctx_target_downloaded" != true ]; then
    # log INFO "Downloading $_shxt_ctx_target ..."
    _loader2__update "$_shxt_ctx_kind" "$_shxt_ctx_target" "$url"
  # else
  #   log INFO "Using downloaded $_shxt_ctx_target ..."
  fi

}

_loader2__update ()
{
  _loader2__ctx_init "$@"
  shift 2
  local url=${1:-}
  
  # Ensure URL is available
  if [ -z "$url" ]; then
    log CRIT "Missing URL for $_shxt_ctx_target !"
    return 1
  fi

  # Ensure a file has been updated
  log INFO "Downloading $_shxt_ctx_target from $url ..."
  download_file "$url" "$_shxt_ctx_target_download_path"
  if [ "$_shxt_ctx_kind" == bin ]; then
    chmod +x "$_shxt_ctx_target_download_path"
  fi
}

_loader2__use ()
{
  _loader2__ctx_init "$@"
  shift 2
  local url=${1:-}

  if [ "$_shxt_ctx_target_installed" != true ]; then
    _loader2__update "$_shxt_ctx_kind" "$_shxt_ctx_target" "$url"
  fi

  # Enable the thing ...
  case "$_shxt_ctx_kind" in
    lib)
      local old_cd=$PWD
      log INFO "Sourcing lib $_shxt_ctx_target_path"
      cd "${_shxt_ctx_target_dir}"
      . "${_shxt_ctx_target_path}"
      cd "${old_cd}"
      ;;
    file) ;;  
  esac

}

_loader2__path ()
{
  _loader2__ctx_init "$@"
  printf '\s' "$_shxt_ctx_target_path"
}

_loader2__cat ()
{
  _loader2__ctx_init "$@"
  if [ -f "$_shxt_ctx_target_path" ]; then
    cat "$_shxt_ctx_target_path"
  fi
  return 1
}


_loader2__help_cli ()
{
  cat <<EOF
Mode: Executed
Usage: $0 --help
  $0 version
  $0 help
  $0 install [PATH]         Install/update automatically in PATH


Infos:
  SHXT_INSTALL_PATH=$SHXT_INSTALL_PATH
EOF

}

_loader2__help_api ()
{
  cat <<EOF
Mode: Sourced
Usage: . $0
  $0 version
  $0 help
  $0 install [PATH]         Install/update automatically in PATH

  $0 use [bin|lib|file] [NAME] [PATH]         Use an item, locally or remotely
  $0 download [bin|lib|file] [NAME] [PATH]    Download an item
  $0 update [bin|lib|file] [NAME] [PATH]      Always update an item

Infos:
  SHXT_INSTALL_PATH=$SHXT_INSTALL_PATH

EOF

}


loader_cli ()
{
  local action=${1:-help}
  case "$action" in
    help|--help|-h)
      _loader2__help_cli
      return $?
    ;;
  esac

  loader "$@"

}


# Main API
loader ()
{
  local action=$1
  shift 1

  case "$action" in
    version)
      printf '%s\n' "1.0.0"
      return $?
    ;;
    install)
      _loader2__install "$@"
      return $?
    ;;
    init|conf)
      _loader2__init "$@"
      return $?
    ;;
    app|start|clean)
      _loader2__clean "$@"
      return $?
    ;;
  esac


  case "$action" in
    # Behavioral settings
    download|install)
      _loader2__download "$@"
    ;;
    update)
      _loader2__update "$@"
    ;;
    use|source|enable)
      _loader2__use "$@"
    ;;

    # Informative API
    path)
      _loader2__path "$@"
    ;;
    cat)
      _loader2__cat "$@"
    ;;

    *) 
      >&2 printf "loader_use does not support action '%s', please use one of: %s\n" "$action" "bin, lib or file"
      return 8
    ;;
  esac

  _loader2__ctx_clean

}


# =============================================================
# Internal libraries
# =============================================================


# # =============================================================
# # Script loader
# # =============================================================

# # if [[ "${BASH_SOURCE[0]}" =~ .*"$0"$ ]]; then
# if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then

#   >&2 printf "$0 is not meant to be called, but sourced in shell scripts. See help usage below:\n\n"
#   import__help
#   exit 1

# else
#   shxt_init "$@"
# fi


# Use cases:
#  eval "$(cat ../shxt.sh)"

# log WARN "'${BASH_SOURCE[0]}' == $0"

# if [[ "${BASH_SOURCE[0]}" =~ .*"$0"$ ]]; then
# if [[ "${BASH_SOURCE[0]}" == "shxt.sh" ]]; then
if [[ "shxt.sh" == .*"$0"$ ]]; then
  # started as CLI
  shxt_init
  loader_cli "$@"

elif [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  # Loaded as library for any programs
  shxt_init

else
  shxt_init "$@"

fi

