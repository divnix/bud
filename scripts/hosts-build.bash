#!/usr/bin/env bash

output="${2:-$1}"

if [[ ! "$output" == "$1" ]]; then
    HOST="${1}"
fi

attr="$FLAKEROOT#nixosConfigurations.\"$HOST\".config.system.build.$output"

nix build "$attr" "${@:3}"
