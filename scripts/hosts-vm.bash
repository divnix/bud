#!/usr/bin/env bash

HOST="${1:-$HOST}"

attr="$FLKROOT#nixosConfigurations.\"$HOST\".config.system.build.vm"

nix build "$attr" "${@:2}"

exec $FLKROOT/result/bin/run-$HOST-vm
