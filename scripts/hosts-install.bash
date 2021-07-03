#!/usr/bin/env bash

sudo $(which nixos-install) --flake "$FLKROOT#\"$1\"" "${@:2}"
