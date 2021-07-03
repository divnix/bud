#!/usr/bin/env bash

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
