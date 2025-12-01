#!bin/sh

function logcmd()
{
    echo -e "\n"
}

function exe_cmd()
{
    logcmd "$@";
    eval $@;
}

sleep 5s

dstdir="/mnt/blackbox/poweron_log/"
index=0
max=0
tarfile=0
for dir in $(ls $dstdir)
do
    [ -d $dir ] && echo $dir
    if (($dir < 999)) && (($dir >= 0))
    then
        let "index++"
        if [ $dir -ge $max ];then
            max=$dir
        fi
    else
        echo "dir is bigger 1000"
    fi
done

if [ $index -eq 4 ];then
    let "max++"
    exe_cmd "mkdir $dstdir$max"
    exe_cmd "rm -rf $dstdir$((max-4))"
    exe_cmd "getprop > $dstdir$max/getprop.log"&
    exe_cmd "dmesg -w > $dstdir$max/kernel.log"&
    exe_cmd "logcat -b all -f $dstdir$max/android.log"&
else
    exe_cmd "mkdir $dstdir$index"
    exe_cmd "getprop > $dstdir$index/getprop.log"&
    exe_cmd "dmesg -w > $dstdir$index/kernel.log"&
    exe_cmd "logcat -b all -f $dstdir$index/android.log"&
fi

sleep 2m

if [ $index -eq 4 ];then
    tarfile=$max
else
    tarfile=$index
fi
cd $dstdir$tarfile
tar -zcvPf log_$tarfile.tar.gz *
exe_cmd "rm -rf $dstdir$tarfile/getprop.log"
exe_cmd "rm -rf $dstdir$tarfile/kernel.log"
exe_cmd "rm -rf $dstdir$tarfile/android.log"

echo "poweronlog end"
