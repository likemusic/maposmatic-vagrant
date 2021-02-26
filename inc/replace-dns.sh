#! /bin/bash

echo "*** Replace DNS ***"

sed -i.bak -e "s/^DNS=.*$/DNS=${DNS:-'8.8.8.8 8.8.4.4'}/g" /etc/systemd/resolved.conf
systemctl restart systemd-resolved.service
