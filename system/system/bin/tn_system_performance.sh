#! /system/bin/sh

config="$1"

function tinno_heapandlmk_setup()
{
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    let RamSizeGB="( $MemTotal / 1048576 ) + 1"
    
    Heapmaxfree=8m
    Heapminfree=512k
    Heapstartsize=16m
    Heapsize=512m
    Heapgrowthlimit=256m
	
    Extrafreekbytes=40960

    Lmkpsicompletestallms=70
    Lmkswapfreelowpercentage=20
    Lmkthrashinglimit=20
    Lmkthrashinglimitdecay=100
    Lmkswaputilmax=90
    Lmktimeout=100
    Vdexfilesize=0
    Odexfilesize=0
    Artfilesize=0

    echo "zram_boost config"
    AmsCacheProcessForRamBoost="0G|24,2G|26,4G|28,6G|30,8G|32,16G|32"
    ZramSizeForRamBoost="0G|55%,2G|60%,4G|70%,6G|80%,8G|90%,16G|90%"
    #carrier=$(getprop ro.carrier)
    #if [ "$carrier" == "retbr" ]; then
    #  ZramBoostSizeDefault="8G"
    #else
    #  ZramBoostSizeDefault="4G"
    #fi


    if [ $MemTotal -lt 4194430 ]; then
       AmsCacheProcessForRamBoost="0G|12,1G|12,2G|14,4G|14,8G|22"
       ZramSizeForRamBoost="0G|55%,1G|55%,2G|60%,4G|90%,8G|90%"
       #ZramBoostSizeDefault="4G"
    fi

    let ZramBoostSizeDefault="2G"
    let ZramBoostAISizeDefault="2G"

    if [ $RamSizeGB -le 2 ]; then
        ZramBoostSizeDefault="2G"
        ZramBoostAISizeDefault="2G"
    elif [ $RamSizeGB -le 4 ]; then
        ZramBoostSizeDefault="4G"
        ZramBoostAISizeDefault="4G"
    elif [ $RamSizeGB -le 6 ]; then
        ZramBoostSizeDefault="4G"
        ZramBoostAISizeDefault="4G"
    else
        ZramBoostSizeDefault="4G"
        ZramBoostAISizeDefault="4G"
    fi

    setprop sys.tinno.cached_processes $AmsCacheProcessForRamBoost
    setprop sys.tinno.zram_size_overlay $ZramSizeForRamBoost
    setprop persist.sys.default_zram_wb_size $ZramBoostSizeDefault
    setprop persist.sys.default_ai_zram_wb_size $ZramBoostAISizeDefault
	
    #heap parameter set
    setprop persist.sys.tinno.dalvik.vm.heapminfree $Heapminfree
    setprop persist.sys.tinno.dalvik.vm.heapmaxfree $Heapmaxfree
    setprop persist.sys.tinno.dalvik.vm.heapstartsize $Heapstartsize
    setprop persist.sys.tinno.dalvik.vm.heapsize $Heapsize
    setprop persist.sys.tinno.dalvik.vm.heapgrowthlimit $Heapgrowthlimit
    #extra_free_kbytes/cache parameter set
    setprop persist.sys.tinno.extra_free_kbytes $Extrafreekbytes
    #lmk parameter set
    setprop persist.sys.tinno.lmk.psi_complete_stall_ms $Lmkpsicompletestallms
    setprop persist.sys.tinno.lmk.swap_free_low_percentage $Lmkswapfreelowpercentage
    setprop persist.sys.tinno.lmk.thrashing_limit $Lmkthrashinglimit
    setprop persist.sys.tinno.lmk.thrashing_limit_decay $Lmkthrashinglimitdecay
    setprop persist.sys.tinno.lmk.swap_util_max $Lmkswaputilmax
    setprop persist.sys.tinno.lmk.kill_timeout_ms $Lmktimeout
    setprop persist.sys.tinno.vdex $Vdexfilesize
    setprop persist.sys.tinno.odex $Odexfilesize
    setprop persist.sys.tinno.art $Artfilesize

}

case "$config" in
    "tinno_heapandlmk_setup")
        tinno_heapandlmk_setup
    ;;
       *)

      ;;
esac


