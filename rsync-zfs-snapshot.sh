#!/bin/bash

# usage: rsync-zfs-snapshot.sh [ZFS filesystem]
# example: rsync-zfs-snapshot.sh
# example crontab entry
# 30 0 * * * /opt/sbin/rsync-zfs-snapshot.sh

if mkdir /var/run/rsync-zfs-snapshot.lock; then
    echo "Lock succeeded" > /var/log/rsync-zfs-snapshot.log

    # zfs-snapshot ZFS filesystems
    for i in `zfs list -H -t filesystem -o name $@` ; do
	dest=`echo $i | sed 's/\//_/g'`
	CMD="zfs send $i@daily.0 > /backup/$dest"
    done

    echo $CMD >> /var/log/rsync-zfs-snapshot.log
    $CMD >> /var/log/rsync-zfs-snapshot.log

    rmdir /var/run/rsync-zfs-snapshot.lock
else
    echo "Lock failed - exit"
    exit 1
fi
