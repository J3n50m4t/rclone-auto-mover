#!/bin/bash
if pidof -o %PPID -x "$0"; then
    exit 1
fi
touch /var/rclonemove/logs/move.log
truncate -s 0 /var/rclonemove/logs/move.log
echo "" >>/var/rclonemove/logs/move.log
echo "" >>/var/rclonemove/logs/move.log
echo "---Starting Move: $(date "+%Y-%m-%d %H:%M:%S")---" >>/var/rclonemove/logs/move.log

while true; do
    let "cyclecount++"
    if [[ $cyclecount -gt 4294967295 ]]; then
        cyclecount=0
    fi
    echo "" >>/var/rclonemove/logs/move.log
    echo "---Begin cycle $cyclecount: $(date "+%Y-%m-%d %H:%M:%S")---" >>/var/rclonemove/logs/move.log
    echo "Checking for files to upload..." >>/var/rclonemove/logs/move.log
    if [[ $(find "$hdpath/move" -type f | wc -l) -gt 0 ]]; then
        rclone move "$hdpath/move/" "$rclonemount:/" \
            --config=/config/rclone.conf \
            --log-file=/var/rclonemove/logs/move.log \
            --log-level=INFO --stats=5s --stats-file-name-length=0 \
            --max-size=300G \
            --tpslimit=20 \
            --checkers=16 \
            --no-traverse \
            --fast-list \
            --modify-window=10s \
            --max-transfer="$maxtransfer" \
            --bwlimit="$bwlimit" \
            --drive-chunk-size="$vfs_dcs" \
            --user-agent="$useragent" \
            --exclude="**_HIDDEN~"
            --exclude="**partial~"

        echo "Upload has finished." >>/var/rclonemove/logs/move.log
    else
        echo "No files in $hdpath/move to upload." >>/var/rclonemove/logs/move.log
    fi
    echo "---Completed cycle $cyclecount: $(date "+%Y-%m-%d %H:%M:%S")---" >>/var/rclonemove/logs/move.log
    echo "$(tail -n 200 /var/rclonemove/logs/move.log)" >/var/rclonemove/logs/move.log
    sleep 60
done
