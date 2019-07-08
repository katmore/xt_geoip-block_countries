#!/usr/bin/env bash
# install.sh
# Installs the 'xt_geoip-block_countries' lib and systemd unit files.
#
# usage:
#   install.sh [--force] [--uninstall] [--skip-systemd]
#
# options:
#   --force : remove or overwrite unrecognized files or directories in destination paths
#   --uninstall : uninstall and exit
#   --skip-systemd : do not create or enable systemd unit files
#
# (c) 2019 Doug Bird. All Rights Reserved.
# Distributed under the terms of the MIT license or the GPLv3 license.
# See: https://github.com/katmore/xt_geoip-block_countries
#

set -o pipefail

LIB_ROOT=/usr/local/lib/xt_geoip-block_countries

ME_SOURCE=$(realpath "${BASH_SOURCE[0]}")
ME_DIR="$( cd -P "$( dirname "$ME_SOURCE" )" && pwd )"

# FUNCTION: help
#   outputs reflective "help" message using comments from top of this script file
help() {
  local l=
  while read -r l; do
    [ "${l:0:1}" = "#" ] || break
    l=${l:1}
    [ -n "${l//[[:blank:]]/}" ] || l=""
    [ "${l:0:1}" != " " ] || l=${l:1}
    echo "$l"
  done < <(tail -n +2 "$ME_SOURCE")
}

# $FORCE: -f,--force option
FORCE=
# $UNINSTALL: --uninstall option
UNINSTALL=

# parse options
while getopts hf-: o; do
  case "$o" in
    f) FORCE=1;;
    h|u|a|v) help; exit;;
    -)
    case "$OPTARG" in
      force) FORCE=1;;
      uninstall) UNINSTALL=1;;
      help|usage|about|version) help; exit;;
      '') break;;
    esac
    ;;
  esac
done
shift $((OPTIND-1))

# $PATH_RMRF : array of paths to recursively remove
PATH_RMRF=()
# $PATH_RM : array of paths to remove
PATH_RM=()
# $DIR_CP : assoc array of directories to copy
declare -A DIR_CP
# $FILE_CP : assoc array of files to copy
declare -A FILE_CP
# $SYSD_SVC : assoc array of systemd services to create
declare -A SYSD_SVC

# FUNCTION: copy_dir
#   prepare a directory to be copied for later
#
# usage:
#   copy_dir SOURCE DEST
copy_dir() {
  local s="$1"
  local d="$2"
  [ -n "$s" ] || return 2
  [ -n "$d" ] || return 2
  [ ! -e "$d" ] || {
    [ -d "$d" ] || {
      [ "$FORCE" = "1" ] || {
        >&2 echo "unrecognized non-directory resource exists for install symlink destination: $d"
        >&2 echo "use '--force' option to remove / overwrite anyway"
        exit 1
      }
      PATH_RMRF+=( "$d" )
    }
  }
  DIR_CP[$s]=$d
}

# FUNCTION: copy_file
#   prepare a file to be symlinked for later
#
# usage:
#   copy_file SOURCE DEST
copy_file() {
  local s=$1
  local d=$2
  [ -n "$s" ] || return 2
  [ -n "$d" ] || return 2
  [ ! -e "$d" ] || {
    [ -f "$d" ] || {
      [ "$FORCE" = "1" ] || {
        >&2 echo "unrecognized non-file resource exists for install symlink destination: $d"
        >&2 echo "use '--force' option to remove / overwrite anyway"
        exit 1
      }
      PATH_RMRF+=( "$d" )
    }
  }
  FILE_CP[$s]=$d
}

# FUNCTION: soft_copy_file
#   prepare a file to be copied for later
#
# usage:
#   soft_copy_file SOURCE DEST
soft_copy_file() {
  local s="$1"
  local d="$2"
  [ -n "$s" ] || return 2
  [ -n "$d" ] || return 2
  [ ! -e "$d" ] || {
    echo "path already exists: $d"
    [ -f "$d" ] && {
      [ "$FORCE" = "1" ] && {
        FILE_CP[$d]=$d.$(date +%Y-%m-%d-%H%M%S).backup
	PATH_RM+=( "$d" )
      } || {
        [ "$UNINSTALL" != "1" ] && FILE_CP[$s]=$d.dist
        return 0
      }
    } || {
      [ "$FORCE" = "1" ] || {
         >&2 echo "unrecognized non-file resource exists for install copy destination: $d"
         >&2 echo "use '--force' option to remove / overwrite anyway"
         exit 1
      }
      PATH_RMRF+=( "$d" )
    }
  }
  [ "$UNINSTALL" != "1" ] || return 0
  FILE_CP[$s]=$d
  
}

# FUNCTION: sysd_svc
#   prepare a systemd service to be enabled and started for later
#
# usage:
#   sysd_svc SOURCE-PREFIX DEST-PREFIX
sysd_svc() {
	local s=$1
	local d=$2
	[ -n "$s" ] || return 2
	[ -n "$d" ] || return 2
	( [ -z "$SKIP_SYSTEMD" ] || [ "$SKIP_SYSTEMD" = 0 ] ) || return 0
	copy_file "$s.service" "$d.service"
	SYSD_SVC[$s.service]=$d.service
	[ ! -f "$s.timer" ] || {
		copy_file "$s.timer" "$d.timer"
		SYSD_SVC[$s.timer]=$d.timer
	}
}

# prepare to create $LIB_ROOT as symlink to src/xt_geoip-block_countries/lib
copy_dir $ME_DIR/lib $LIB_ROOT

# prepare to create /etc/xt_geoip-block_countries from src/xt_geoip-block_countries/etc/xt_geoip-block_countries
soft_copy_file $ME_DIR/etc/xt_geoip-block_countries /etc/xt_geoip-block_countries

# prepare to create systemd service xt_geoip-block_countries from src/xt_geoip-block_countries/systemd/system/xt_geoip-block_countries(.service|.timer)
sysd_svc $ME_DIR/systemd/system/xt_geoip-block_countries /lib/systemd/system/xt_geoip-block_countries

#
# recursively remove paths in $PATH_RMRF array
for d in "${PATH_RMRF[@]}"; do
  rm -rf "$d" || {
    >&2 echo "unable to recursively remove existing path, 'rm -rf' failed with status $? for install destination: $d"
    exit 1
  }
  echo "recursively removed: $d"
done

#
# remove files in $PATH_RM array
for d in "${PATH_RM[@]}"; do
  rm "$d" || {
    >&2 echo "unable to remove existing path, 'rm' failed with status $? for install destination: $d"
    exit 1
  }
  echo "removed: $d"
done

#
# exit if '--uninstall' flag
[ "$UNINSTALL" != "1" ] || {
  echo "uninstall complete"
  exit 0
}

#
# recursively copy paths in $DIR_CP array
for s in "${!DIR_CP[@]}"; do
  d=${DIR_CP[$s]}
  cp -r "$s" "$d" || {
    >&2 echo "unable to copy dir, 'cp -r' failed with status $? for install destination: $d"
    exit 1
  }
  echo "copied to directory: $d"
done

#
# copy files in $FILE_CP array
for s in "${!FILE_CP[@]}"; do
  d=${FILE_CP[$s]}
  cp $s $d || {
    >&2 echo "unable to copy file, 'cp' failed with status $? for install destination: $d"
    exit 1
  }
  echo "copied to file: $d"
done

#
# create, enable, and start systemd services in $SYSD_SVC array
for s in "${!SYSD_SVC[@]}"; do
  d=${SYSD_SVC[$s]}
  svc=$(basename $d)
  systemctl daemon-reload || {
	>&2 echo "warning, failed to reload daemons"
  }
  ! systemctl is-active $svc > /dev/null 2>&1 || {
	systemctl stop $svc || {
		>&2 echo "warning, failed to stop running service: $svc"
	}
	echo "systemd service stopped: $svc"
  }
  systemctl is-enabled $svc > /dev/null 2>&1 && {
	echo "systemd service already enabled: $svc"
  } || {
	systemctl enable $svc || {
		>&2 echo "unable to enable systemd service: $svc"
  		exit 1
	}
	echo "systemd service enabled: $svc"

  }
  echo "starting systemd service: $svc"
  systemctl start $svc || {
	>&2 echo "unable to start systemd service: $svc"
  	exit 1
  }
  echo "systemd service started: $svc" 
done





