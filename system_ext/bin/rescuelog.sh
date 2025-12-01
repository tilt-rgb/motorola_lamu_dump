#!bin/sh

logdir=/mnt/blackbox/rescue_log

rm -rf $logdir/*

getprop > $logdir/getprop.log
logcat -b all -d -f $logdir/android.log
dmesg > $logdir/kernel.log

cd $logdir
tar -zcvPf log.tar.gz *
rm -rf $logdir/getprop.log
rm -rf $logdir/android.log
rm -rf $logdir/kernel.log

echo "resucelog end"
