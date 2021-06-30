#!/usr/bin/env bash

# ---------------------------------------------------
synopsis="home HOST USER [switch]"
help="Home-manager config of USER from HOST"
description="""
"""
# ---------------------------------------------------

cmd () {
  ref="$FLKROOT#homeConfigurations.$2@$1.activationPackage"
  if [[ "$3" == "switch" ]]; then
    nix build "$ref" && result/activate &&
      unlink result
  else
    nix build "$ref" "${@:3}"
  fi
}
