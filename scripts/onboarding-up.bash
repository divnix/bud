#!/usr/bin/env bash

targetdir="$FLKROOT/hosts/${HOST//\./\/}"
mkdir -p "$targetdir"

# `sudo` is necessary for `btrfs subvolume show`
sudo $(which nixos-generate-config) --dir "$targetdir"

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

sudo chown $(id -u):$(id -g) -R "$targetdir"

git add -f "$targetdir"
