#!/usr/bin/env bash

# ---------------------------------------------------
synopsis="get (core|community) [DEST]"
help="Copy the desired template to DEST"
description="""
"""
# ---------------------------------------------------

cmd () {
  if [[ "$1" == "core" || "$1" == "community" ]]; then
    nix flake new -t "github:divnix/devos/$1" "${2:-flk}"
  else
    echo "flk get (core|community) [DEST]"
    exit 1
  fi
}
