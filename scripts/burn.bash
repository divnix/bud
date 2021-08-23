
set -e
set -o pipefail

iso="$FLAKEROOT/result/iso/"
iso="$iso$(ls "$iso" | fzf)"
dev=$(lsblk -d -n --output RM,NAME,FSTYPE,SIZE,LABEL,TYPE,VENDOR,UUID | awk '{ if ($1 == 1) { print } }' | fzf | awk '{print $2}')
dev="/dev/$dev"

pv -tpreb "$iso" | dd bs=4M of="$dev" iflag=fullblock conv=notrunc,noerror oflag=sync
