#!/usr/bin/env bash

# ---------------------------------------------------
synopsis="vm HOST"
help="Generate a vm for HOST"
description="""
"""
# ---------------------------------------------------

cmd () {
  nix build \
    "$FLKROOT#nixosConfigurations.\"$1\".config.system.build.vm" \
    -o "$FLKROOT/vm/$1" \
    "${@:2}" \
  && echo "export NIX_DISK_IMAGE=\"$FLKROOT/vm/$2.qcow2\"" > "$FLKROOT/vm/run-$1" \
  && echo "$FLKROOT/vm/$2/bin/run-$1-vm" >> "$FLKROOT/vm/run-$1" \
  && chmod +x "$FLKROOT/vm/run-$1"
}
