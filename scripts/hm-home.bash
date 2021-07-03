#!/usr/bin/env bash

ref="$FLKROOT#homeConfigurations.$2@$1.activationPackage"
if [[ "$3" == "switch" ]]; then
  nix build "$ref" && result/activate &&
    unlink result
else
  nix build "$ref" "${@:3}"
fi
