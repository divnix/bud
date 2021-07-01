#!/usr/bin/env bash

# ---------------------------------------------------
synopsis="up"
help="Generate $FLAKEROOT/hosts/up-$HOST.nix"
description="""
"""
# ---------------------------------------------------

cmd () {
  mkdir -p "$FLKROOT/up"

  # `sudo` is necessary for `btrfs subvolume show`
  sudo nixos-generate-config --dir "$FLKROOT/up/$HOST"

  printf "%s\n" \
    "{ suites, ... }:" \
    "{" \
    "  imports = [" \
    "    ../up/$HOST/configuration.nix" \
    "  ] ++ suites.core;" \
    "}" > "$FLKROOT/hosts/up-$HOST.nix"

  git add -f \
    "$FLKROOT/up/$HOST" \
    "$FLKROOT/hosts/up-$HOST.nix"
}
