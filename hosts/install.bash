#!/usr/bin/env bash

# ---------------------------------------------------
synopsis="install HOST [ARGS]"
help="Shortcut for nixos-install"
description="""
"""
# ---------------------------------------------------

cmd () {
  sudo nixos-install --flake "$FLKROOT#\"$1\"" "${@:2}"
}
