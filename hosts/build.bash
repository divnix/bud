#!/usr/bin/env bash

# ---------------------------------------------------
synopsis="build HOST BUILD"
help="Build a variant of your configuration from system.build"
description="""
"""
# ---------------------------------------------------

cmd () {
  nix build "$FLKROOT#nixosConfigurations.\"$1\".config.system.build.$2" "${@:3}"
}
