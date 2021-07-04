#!/usr/bin/env bash

HOST="${1:-$HOST}"

attr="$FLKROOT#\"$HOST\""
nixos-rebuild --flake "$attr" "${@:2}"
