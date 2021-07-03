#!/usr/bin/env bash

sudo $(which nixos-rebuild) --flake "$FLKROOT#\"$1\"" "${@:2}"
