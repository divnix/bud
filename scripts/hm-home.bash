#!/usr/bin/env bash
if [[ "$1" == "switch" ]]; then
  shift 1;
  switch=y
fi

HOST="${1:-$HOST}"
USER="${2:-$USER}"

attr="$FLKROOT#homeConfigurations.\"$USER@$HOST\".activationPackage"

if [[ "$switch" == "y" ]]; then
  nix build "$attr" "${@:3}" && result/activate && unlink result
else
  nix build "$attr" "${@:3}"
fi
