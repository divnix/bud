#!/usr/bin/env bash

# ---------------------------------------------------
synopsis="ssh-show USER@HOSTNAME"
help="Show target host's SSH ed25519 key"
description="""
Use this script to quickly determine the target host
key for which to encrypt an agenix secret.
"""
# ---------------------------------------------------

cmd () {
  user="$(cut -d '@' -f 1 <<< "$1")"
  if [[ "$user" == "root" ]]; then
    ssh $1 "cat /etc/ssh/ssh_host_ed25519_key.pub"
  else
    ssh $1 "cat ~/.ssh/id_ed25519.pub"
  fi
}
