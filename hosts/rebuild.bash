#!/usr/bin/env bash

# ---------------------------------------------------
synopsis="HOST (switch|boot|test)"
help="Shortcut for nixos-rebuild"
description="""
"""
# ---------------------------------------------------

cmd () {
  sudo nixos-rebuild --flake "$FLKROOT#\"$1\"" "${@:2}"
}
