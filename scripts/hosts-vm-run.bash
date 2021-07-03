#!/usr/bin/env bash

rm -rf "$FLKROOT/vm/tmp/$1"* \
&& nix build \
  "$FLKROOT#nixosConfigurations.\"$1\".config.system.build.vm" \
  -o "$FLKROOT/vm/tmp/$1" \
  "${@:2}" \
&& \
( \
  export NIX_DISK_IMAGE="$FLKROOT/vm/tmp/$1.qcow2" \
  && "$FLKROOT/vm/tmp/$2/bin/run-$1-vm" \
) \
&& rm -rf "$FLKROOT/vm/tmp/$1"* \
&& rmdir --ignore-fail-on-non-empty "$FLKROOT/vm/tmp"
