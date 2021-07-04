#!/usr/bin/env bash

targetdir="$FLAKEROOT/hosts/${HOST//\./\/}"
mkdir -p "$targetdir"

# `sudo` is necessary for `btrfs subvolume show`
nixos-generate-config --dir "$targetdir"

printf "%s\n" \
  "{ suites, ... }:" \
  "{" \
  "  imports = [" \
  "    ./configuration.nix" \
  "  ] ++ suites.base;" \
  "" \
  "  bud.enable = true;" \
  "  bud.localFlakeClone = \"$FLAKEROOT\";" \
  "}" > "$targetdir/default.nix"

chown $USER:$(id -gn $USER) -R "$targetdir"

git add -f "$targetdir"
