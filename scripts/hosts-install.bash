#!/usr/bin/env bash

HOST="${1:-$HOST}"

attr="$FLAKEROOT#\"$HOST\""
nixos-install --flake "$attr" "${@:2}"
