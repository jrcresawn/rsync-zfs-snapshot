#!/bin/bash

# usage: zfs-snapshot-send.sh [ZFS filesystem]
# example: zfs-snapshot-send.sh
# example crontab entry
# 30 0 * * 6 /opt/sbin/zfs-snapshot-send.sh

if mkdir /var/run/zfs-snapshot-send.lock; then
    echo "Lock succeeded" > /var/log/zfs-snapshot-send.log

    # identify ZFS filesystem snapshots and send them to the
    # destination
    for i in `zfs list -H -t filesystem -o name $@` ; do
	dest=`echo $i | sed 's/\//_/g'`
	nice -n 19 zfs send $i@weekly.0 > /backup/$dest
    done

    rmdir /var/run/zfs-snapshot-send.lock
else
    echo "Lock failed - exit"
    exit 1
fi
