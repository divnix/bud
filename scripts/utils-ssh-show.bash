#!/usr/bin/env bash

user="$(cut -d '@' -f 1 <<< "$1")"
if [[ "$user" == "root" ]]; then
  ssh $1 "cat /etc/ssh/ssh_host_ed25519_key.pub"
else
  ssh $1 "cat ~/.ssh/id_ed25519.pub"
fi
