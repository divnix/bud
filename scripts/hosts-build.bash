#!/usr/bin/env bash

HOST="${1:-$HOST}"

attr="$FLKROOT#nixosConfigurations.\"$HOST\".config.system.build.$2"

nix build "$attr" "${@:3}"
