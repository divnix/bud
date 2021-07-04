#!/usr/bin/env bash

HOST="${1:-$HOST}"

attr="$FLKROOT#\"$HOST\""
nixos-install --flake "$attr" "${@:2}"
