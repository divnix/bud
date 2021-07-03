#!/usr/bin/env bash

nix build "$FLKROOT#nixosConfigurations.\"$1\".config.system.build.$2" "${@:3}"
