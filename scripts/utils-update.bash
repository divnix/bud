#!/usr/bin/env bash

if [[ -n "$1" ]]; then
    nix flake lock --update-input "$1" "$FLAKEROOT"
else
    nix flake update "$FLAKEROOT"
fi
