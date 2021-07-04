#!/usr/bin/env bash

nixos-install --flake "$FLKROOT#\"$1\"" "${@:2}"
