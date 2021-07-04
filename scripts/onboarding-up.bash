#!/usr/bin/env bash

targetdir="$FLKROOT/hosts/${HOST//\./\/}"
mkdir -p "$targetdir"

# `sudo` is necessary for `btrfs subvolume show`
nixos-generate-config --dir "$targetdir"

printf "%s\n" \
  "{ suites, ... }:" \
  "{" \
  "  imports = [" \
  "    ./configuration.nix" \
  "  ] ++ suites.core;" \
  "" \
  "  flk.enable = true;" \
  "  flk.localFlakeClone = \"$FLKROOT\";" \
  "}" > "$targetdir/default.nix"

chown $USER:$(id -gn $USER) -R "$targetdir"

git add -f "$targetdir"
