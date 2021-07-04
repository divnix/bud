#!/usr/bin/env bash

if [[ -n "$1" ]]; then
  nix flake lock --update-input "$1" "$FLKROOT"
else
  nix flake update "$FLKROOT"
fi
