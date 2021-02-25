#! /bin/bash

echo "*** Replace DNS ***"

sed -i.bak -e "s/^DNS=.*$/DNS=${DNS}/g" /etc/systemd/resolved.conf
systemctl restart systemd-resolved.service
