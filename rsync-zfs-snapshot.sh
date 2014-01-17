#!/bin/bash

# usage: rsync-zfs-snapshot.sh [ZFS filesystem mountpoint]
# example: rsync-zfs-snapshot.sh /
# example crontab entry
# 30 0 * * * /opt/sbin/rsync-zfs-snapshot.sh

if mkdir /var/run/rsync-zfs-snapshot.lock; then
    echo "Lock succeeded" > /var/log/rsync-zfs-snapshot.log

    # zfs-snapshot ZFS filesystems
    SOURCE=`zfs list -H -t filesystem -o mountpoint $@ | grep ^/ | sed 's/$/\/.zfs\/snapshot\/daily.0 /' | sort`
    CMD="rsync -av --delete $SOURCE /backup"
    echo $CMD >> /var/log/rsync-zfs-snapshot.log
    $CMD >> /var/log/rsync-zfs-snapshot.log

    rmdir /var/run/rsync-zfs-snapshot.lock
else
    echo "Lock failed - exit"
    exit 1
fi
