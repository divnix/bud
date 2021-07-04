#!/usr/bin/env bash

if [[ "$1" == *"@"* ]]; then
  HOST="$(cut -d '@' -f 2 <<< "$1")"
  USER="$(cut -d '@' -f 1 <<< "$1")"
else
  HOST="${1:-$HOST}"
  HOST="$(IFS='.'; parts=($(echo $HOST)); IFS=' '; host=$(for (( idx=\${#parts[@]}-1 ; idx>=0 ; idx-- )) ; do printf \"\${parts[idx]}.\"; done); echo \${host:: -1})"
  USER="${2:-$USER}"
fi

if [[ "$user" == "root" ]]; then
  cmd="cat /etc/ssh/ssh_host_ed25519_key.pub"
else
  cmd="cat ~/.ssh/id_ed25519.pub"
fi

ssh "$USER@$HOST" $cmd
