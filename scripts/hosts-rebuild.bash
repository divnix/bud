#!/usr/bin/env bash

HOST="${1:-$HOST}"

set -- "${@:2}"

if [ -x /run/wrappers/bin/sudo ]; then
  export PATH=/run/wrappers/bin:$PATH
  set -- --use-remote-sudo "$@"
fi

nixos-rebuild --flake "$FLAKEROOT#$HOST" "$@"
