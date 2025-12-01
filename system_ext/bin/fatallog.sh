#!bin/sh

logdir=/mnt/blackbox/fatal_log

rm -rf $logdir/*

getprop > $logdir/getprop.log
logcat -b all -f $logdir/android.log &
dmesg -w > $logdir/kernel.log &
df > $logdir/df-info.log
mount > $logdir/mount-info.log

sleep 180s

cd $logdir
tar -zcvPf log.tar.gz *
rm -rf $logdir/getprop.log
rm -rf $logdir/android.log
rm -rf $logdir/kernel.log
rm -rf $logdir/df-info.log
rm -rf $logdir/mount-info.log

echo "fatallog end"
