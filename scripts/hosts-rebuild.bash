#!/usr/bin/env bash

nixos-rebuild --flake "$FLKROOT#\"$1\"" "${@:2}"
