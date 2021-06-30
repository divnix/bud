#!/usr/bin/env bash

# ---------------------------------------------------
synopsis="up"
help="Generate $FLAKEROOT/hosts/up-$HOSTNAME.nix"
description="""
"""
# ---------------------------------------------------

cmd () {
  mkdir -p "$FLKROOT/up"

  # `sudo` is necessary for `btrfs subvolume show`
  sudo nixos-generate-config --dir "$FLKROOT/up/$HOSTNAME"

  printf "%s\n" \
    "{ suites, ... }:" \
    "{" \
    "  imports = [" \
    "    ../up/$HOSTNAME/configuration.nix" \
    "  ] ++ suites.core;" \
    "}" > "$FLKROOT/hosts/up-$HOSTNAME.nix"

  git add -f \
    "$FLKROOT/up/$HOSTNAME" \
    "$FLKROOT/hosts/up-$HOSTNAME.nix"
}
