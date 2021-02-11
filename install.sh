#!/bin/bash

set -e

cp rpi-router.service /etc/systemd/system/rpi-router.service
cp rpi-router.sh /usr/local/sbin/rpi-router.sh
mkdir -p /usr/lib/rpi-router 
cp -a ./. /usr/lib/rpi-router
