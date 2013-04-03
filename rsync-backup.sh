#!/bin/bash

# usage: rsync-backup.sh [ZFS file systems]
# example: rsync-backup.sh cals
# example crontab entry
# 30 0 * * * /opt/sbin/rsync-backup.sh

if mkdir /var/run/rsync-backup-lock; then
    echo "Lock succeeded" > /var/log/rsync-backup.log
    for i in `zfs list -H -r -o name $@`
    do
	CMD="rsync -a /$i/.zfs/snapshot/daily.0/ /backup/$i"
	echo $CMD >> /var/log/rsync-backup.log
	$CMD >> /var/log/rsync-backup.log
    done
    rmdir /var/run/rsync-backup-lock
else
    echo "Lock failed - exit"
    exit 1
fi
