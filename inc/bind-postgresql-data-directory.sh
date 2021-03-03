if test -f "/disk/lvm0.img";
then
  rm /disk/lvm0.img
fi

truncate -s ${POSTGRESQL_DATA_DISK_SIZE:-6T} /disk/lvm0.img
losetup /dev/loop0 /disk/lvm0.img
pvcreate /dev/loop0
vgcreate vg0 /dev/loop0
lvcreate -n lv0 -l 100%FREE vg0
mkfs.ext4 /dev/vg0/lv0

mkdir -p /var/lib/postgresql/12
mount /dev/vg0/lv0 /var/lib/postgresql/12
