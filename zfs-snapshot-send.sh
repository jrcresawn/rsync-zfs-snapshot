#!/bin/bash

# usage: zfs-snapshot-send.sh [ZFS filesystem]
# example: zfs-snapshot-send.sh
# example crontab entry
# 00 17 * * 5 /opt/sbin/zfs-snapshot-send.sh

# This expression returns 0 if the week of the year is divisible by 4.
scrubweek=$(expr `date +%U` % 4)
scrubinprogress=$(zpool status | grep -q 'scan: scrub in progress')$?
sendinprogress=$(test -d /var/run/zfs-snapshot-send.lock)$?

if [ $scrubinprogress != 0 ] && [ $sendinprogress != 0 ]; then
    if [ $scrubweek == 0 ]; then  # initiate scrub
	zpool scrub rpool1 cals
    else  # initiate send
	if mkdir /var/run/zfs-snapshot-send.lock; then
	    echo "Lock succeeded" > /var/log/zfs-snapshot-send.log
	    
            # manage backup snapshots
	    /opt/sbin/zfs-snapshot.sh rpool1 backup 2
	    /opt/sbin/zfs-snapshot.sh cals backup 2

            # identify ZFS filesystem snapshots and send them to the destination
	    for i in `zfs list -H -t filesystem -o name $@` ; do
		dest=`echo $i | sed 's/\//_/g'`
		nice -n 19 zfs send $i@backup.0 > /backup/$dest
	    done
	
	    rmdir /var/run/zfs-snapshot-send.lock
	else
	    echo "Lock failed - exit"
	    exit 1
	fi
    fi
else
    echo 'The zpools are busy with other I/O operations this week.'
fi
