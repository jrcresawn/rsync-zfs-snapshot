#!/bin/bash

# usage: zfs-snapshot-send.sh [ZFS filesystem]
# example: rsync-zfs-snapshot.sh
# example crontab entry
# 00 0 * * 6 /opt/sbin/zfs-snapshot-send.sh

if mkdir /var/run/rsync-zfs-snapshot.lock; then
    echo "Lock succeeded" > /var/log/rsync-zfs-snapshot.log

    # identify ZFS filesystem snapshots and send them to the
    # destination
    for i in `zfs list -H -t filesystem -o name $@` ; do
	dest=`echo $i | sed 's/\//_/g'`
	nice -n 19 zfs send $i@weekly.0 > /backup/$dest
    done

    rmdir /var/run/rsync-zfs-snapshot.lock
else
    echo "Lock failed - exit"
    exit 1
fi
