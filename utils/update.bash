#!/usr/bin/env bash

# ---------------------------------------------------
synopsis="update [INPUT]"
help="Update and commit the lock file, or specific input"
description="""
"""
# ---------------------------------------------------

cmd () {
  if [[ -n "$1" ]]; then
    if [[ -n "$2" ]]; then
      (cd $1; nix flake lock --update-input "$2")
    else
      (cd $1; nix flake update)
    fi
    nix flake lock --update-input "$1" "$FLKROOT"
  else
    nix flake update "$FLKROOT"
  fi
}
