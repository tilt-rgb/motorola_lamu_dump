#!/system/bin/sh

# Copyright (C) 2016 Motorola Mobility, Inc.
# All Rights Reserved

# Please provide implementation for all the functions below.
# Then, push this script to /mnt/sdcard/CQATest/

# Your code must provide return values in text form such as:
# RETURN=PASS
# RETURN=FAIL
# RETURN=<VALUE>

version=0.3

##### READ_TRACK_ID  #####

function READ_TRACK_ID
{
    # insert your code below
    READ_TRACK_ID="FAIL"
    for i in $(seq 5 -1 1)
    do
    if [ $(getprop ro.serialno) = "" ];then
    #echo "wait..."
    READ_TRACK_ID="FAIL"
    else
    SN=$(getprop ro.serialno)
    READ_TRACK_ID="OK"
	#asciiStr="ABCDEFG"
 
    for c in $(echo $SN|sed 's/./& /g')
    do
        hexArr=$hexArr$(printf "%X" "'$c")
    done

    echo "7E0046180400000000"$hexArr"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000AABB"

    break
    fi
    sleep 0.5
    done
    if [ $READ_TRACK_ID = "FAIL" ];then
    echo "7E0006180400000003AEA3"
    #  echo "feature $0 not implemented"
    fi
}



##### CHECK_POWER_UP  #####

function CHECK_POWER_UP
{
    # insert your code below
    if [ "$(getprop sys.boot_completed)" = "1" ];then
	echo "7E00081806000000003100AABB"
	else
	echo "7E00081806000000003000AABB"
	fi
}

##### Returns the HW ID to distinguish SKUs ####
function READ_HW_ID
{
    RET=$(getprop ro.boot.hwsku)
    if [ -z "$RET" ]; then
      echo "7E000918050000000000001AABB"
    else
      hex=$(printf "%x" $RET)
      echo "7E0009180500000000"$hex"0000AABB"
    fi
}

##### UTAG_SET_BATTERY_ID  #####

function UTAG_SET_BATTERY_ID
{
    # insert your code below
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ];then
    input keyevent 26
	sleep 0.5
    fi
	
	cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE TEST_FLAG_OP --es CQA_TEST_FUNCTION SETBATTERYSN --es CQA_TEST_PARAMS $1))
	
	sleep 1
    UTAG_SET_BATTERY_ID="FAIL"
    for i in $(seq 6 -1 1)
    do
    if [ $(getprop persist.sys.SETBATTERYSN) -eq 1 ];then
    echo "7E0006250200000000328ACRRC"
    UTAG_SET_BATTERY_ID="OK"
    break
    #else
    #echo "wait..."
    fi
    sleep 1
    done
    if [ $UTAG_SET_BATTERY_ID = "FAIL" ];then
    echo "7E00062502000000000001CRRC"
    #echo "feature $0 not implemented"
    fi
}

function UTAG_GET_BATTERY_ID
{
    # insert your code below
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ];then
    input keyevent 26
	sleep 0.5
    fi

	cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE TEST_FLAG_OP --es CQA_TEST_FUNCTION READBATTERYSN))

	sleep 1
    UTAG_GET_BATTERY_ID="FAIL"
    for i in $(seq 6 -1 1)
    do
	if [ $(getprop persist.sys.READBATTERYSN) = "" ];then
    #echo "wait..."
    UTAG_GET_BATTERY_ID="FAIL"
    else
    SN=$(getprop persist.sys.READBATTERYSN)
	#echo $SN
	#asciiStr="ABCDEFG"

    #for c in $(echo $SN|sed 's/./& /g')
    #do
    #    hexArr=$hexArr$(printf "%X" "'$c")
    #done
    #echo "7E0006250300000000"$SN"CRRC"
    echo $SN
    UTAG_GET_BATTERY_ID="OK"
    break
    #else
    #echo "wait..."
    fi
    sleep 1
    done
    if [ $UTAG_GET_BATTERY_ID = "FAIL" ];then
    echo "7E0006250300000001CRRC"
    #echo "feature $0 not implemented"
    fi
}

function UTAG_SET_WALLPAPER
{
    # insert your code below
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ];then
    input keyevent 26
	sleep 0.5
    fi

	cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE TEST_FLAG_OP --es CQA_TEST_FUNCTION SETWALLPAPER --es CQA_TEST_PARAMS $1))
	sleep 1
    UTAG_SET_WALLPAPER="FAIL"
    for i in $(seq 6 -1 1)
    do
    if [ $(getprop persist.sys.SETWALLPAPER) -eq 1 ];then
    echo "7E000618020000000000CRRC"
    UTAG_SET_WALLPAPER="OK"
    break
    #else
    #echo "wait..."
    fi
    sleep 1
    done
    if [ $UTAG_SET_WALLPAPER = "FAIL" ];then
    echo "7E000618020000000001CRRC"
    #echo "feature $0 not implemented"
    fi
}

function UTAG_GET_WALLPAPER
{
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ "$RET" -eq 0 ]; then
        input keyevent 26
        sleep 0.5
    fi

    am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE TEST_FLAG_OP --es CQA_TEST_FUNCTION READWALLPAPER > /dev/null 2>&1
    sleep 1

    UTAG_GET_WALLPAPER="FAIL"

    for i in $(seq 6 -1 1); do
        wallpaper=$(getprop persist.sys.READWALLPAPER)
        log_info "wallpaper.log" "wallpaper = $wallpaper"
        if [ -z "$wallpaper" ]; then
            sleep 1
        else
            for c in $(echo $wallpaper | sed 's/./& /g')
            do
              hexArr=$hexArr$(printf "%X" "'$c")
            done
            log_info "wallpaper.log" "hexArr = $hexArr"
            echo "7E0006180300000000$hexArr"
            UTAG_GET_WALLPAPER="OK"
            break
        fi
    done

    if [ "$UTAG_GET_WALLPAPER" = "FAIL" ]; then
        echo "7E0006180300000001CRRC"
    fi
}



##### GET_TYPE_C_STATE  #####

function GET_TYPE_C_STATE
{
  # insert your code below
	RET=$(cat /sys/devices/platform/extcon_usb/cc_orient)
	log_info "usb_type.log" "read node /sys/devices/platform/extcon_usb/cc_orient => $RET"
	if [ "$RET" == "CC1" ];then
	  echo "7E0009090E00000000434331AABB"
	elif [ "$RET" == "CC2" ]; then
	  echo "7E0009090E00000000434332AABB"
	elif [ "$RET" == "CCNone" ]; then
	  echo "7E0009090E0000000043434EAABB"
	fi
}

##### READ_BATTERY_THERMISTOR_VALUE  #####

function READ_BATTERY_THERMISTOR_VALUE
{
    # insert your code below
    log_path="thermal.log"

    RET=$(grep -w '^battery$' /sys/class/thermal/thermal_zone*/type -rnIs)
    log_info "$log_path" "battery_thermal content = $RET"

    zone_num=$(echo "$RET" | awk -F'thermal_zone' '{print $2}' | awk -F'/' '{print $1}')
    if [ -z "$zone_num" ]; then
      log_info "$log_path" "Failed to extract zone number from grep result."
      return
    fi

    temp_node="/sys/class/thermal/thermal_zone${zone_num}/temp"
    if [ -f "$temp_node" ]; then
      a=1000
      result=$(cat "$temp_node")
      log_info "$log_path" "battery_thermal node path= $temp_node, Temperature = $result"
      #echo $RET
      temp=$(echo $((result/a)))
      #echo $temp
      if [ $temp -gt 0 ]; then
        hex=$(printf "%04x" $temp)
      else
        hex=$(printf "%04x" $((temp & 0xFFFF)))
      fi
      echo "7E0007130500000000"$hex"AABB"
    else
      log_info "$log_path" "Temperature node file does not exist: $temp_node"
      return
    fi
}

function READ_AP_THERMISTOR_VALUE
{
    # insert your code below
    log_path="thermal.log"

    RET=$(grep -w '^mtktsAP$' sys/class/thermal/thermal_zone*/type -rnIs)
    log_info "$log_path" "ap_thermal content = $RET"

    zone_num=$(echo "$RET" | awk -F'thermal_zone' '{print $2}' | awk -F'/' '{print $1}')
    if [ -z "$zone_num" ]; then
      log_info "$log_path" "Failed to extract zone number from grep result."
      return
    fi

    temp_node="/sys/class/thermal/thermal_zone${zone_num}/temp"
    if [ -f "$temp_node" ]; then
        a=1000
        result=$(cat "$temp_node")
        log_info "$log_path" "ap_thermal node path= $temp_node, Temperature = $result"
        temp=$(echo $((result/a)))
        if [ $temp -gt 0 ]; then
          hex=$(printf "%04x" $temp)
        else
          hex=$(printf "%04x" $((temp & 0xFFFF)))
        fi

        echo "7E0007130100000000"$hex"AABB"
    else
      log_info "$log_path" "Temperature node file does not exist: $temp_node"
      return
    fi
}

# Read the PCB Thermistor value
function READ_PCB_THERMISTOR_VALUE
{
    # insert your code below
    log_path="thermal.log"

    RET=$(grep -w '^mtk_ts_board$' /sys/class/thermal/thermal_zone*/type -rnIs)
    log_info "$log_path" "pcb_thermal content = $RET"

    zone_num=$(echo "$RET" | awk -F'thermal_zone' '{print $2}' | awk -F'/' '{print $1}')
    if [ -z "$zone_num" ]; then
      log_info "$log_path" "Failed to extract zone number from grep result."
      return
    fi

    temp_node="/sys/class/thermal/thermal_zone${zone_num}/temp"
    if [ -f "$temp_node" ]; then
      a=1000
      result=$(cat "$temp_node")
      log_info "$log_path" "pcb_thermal node path= $temp_node, Temperature = $result"
      temp=$(echo $((result/a)))
      if [ $temp -gt 0 ]; then
        hex=$(printf "%04x" $temp)
      else
        hex=$(printf "%04x" $((temp & 0xFFFF)))
      fi

      echo "7E0007130200000000"$hex"AABB"
    else
      log_info "$log_path" "Temperature node file does not exist: $temp_node"
      return
    fi
}

function READ_CHARGE_THERMISTOR_VALUE
{
    # insert your code below
    log_path="thermal.log"

    RET=$(grep -w '^mtk_ts_charger$' /sys/class/thermal/thermal_zone*/type -rnIs)
    log_info "$log_path" "charger_thermal content = $RET"

    zone_num=$(echo "$RET" | awk -F'thermal_zone' '{print $2}' | awk -F'/' '{print $1}')
    if [ -z "$zone_num" ]; then
      log_info "$log_path" "Failed to extract zone number from grep result."
      return
    fi

    temp_node="/sys/class/thermal/thermal_zone${zone_num}/temp"
    if [ -f "$temp_node" ]; then
      a=1000
      result=$(cat "$temp_node")
      log_info "$log_path" "charger_thermal node path= $temp_node, Temperature = $result"
      temp=$(echo $((result/a)))
      if [ $temp -gt 0 ]; then
        hex=$(printf "%04x" $temp)
      else
        hex=$(printf "%04x" $((temp & 0xFFFF)))
      fi

      echo "7E0007130300000000"$hex"AABB"
    else
      log_info "$log_path" "Temperature node file does not exist: $temp_node"
      return
    fi
}


function READ_PA_THERMISTOR_VALUE
{
    # insert your code below
    log_path="thermal.log"

    RET=$(grep -w '^mtktsbtsmdpa$' /sys/class/thermal/thermal_zone*/type -rnIs)
    log_info "$log_path" "pa_thermal content = $RET"

    zone_num=$(echo "$RET" | awk -F'thermal_zone' '{print $2}' | awk -F'/' '{print $1}')
    if [ -z "$zone_num" ]; then
      log_info "$log_path" "Failed to extract zone number from grep result."
      return
    fi

    temp_node="/sys/class/thermal/thermal_zone${zone_num}/temp"
    if [ -f "$temp_node" ]; then
      a=1000
      result=$(cat "$temp_node")
      log_info "$log_path" "pa_thermal node path= $temp_node, Temperature = $result"
      temp=$(echo $((result/a)))
      if [ $temp -gt 0 ]; then
        hex=$(printf "%04x" $temp)
      else
        hex=$(printf "%04x" $((temp & 0xFFFF)))
      fi

      echo "7E0007130400000000"$hex"AABB"
    else
      log_info "$log_path" "Temperature node file does not exist: $temp_node"
      return
    fi
}

function READ_CPU_THERMISTOR_VALUE
{
    # insert your code below
    log_path="thermal.log"

    RET=$(grep -w '^mtktscpu$' /sys/class/thermal/thermal_zone*/type -rnIs)
    log_info "$log_path" "cpu_thermal content = $RET"

    zone_num=$(echo "$RET" | awk -F'thermal_zone' '{print $2}' | awk -F'/' '{print $1}')
    if [ -z "$zone_num" ]; then
      log_info "$log_path" "Failed to extract zone number from grep result."
      return
    fi

    temp_node="/sys/class/thermal/thermal_zone${zone_num}/temp"
    if [ -f "$temp_node" ]; then
      a=1000
      result=$(cat "$temp_node")
      log_info "$log_path" "cpu_thermal node path= $temp_node, Temperature = $result"
      temp=$(echo $((result/a)))
      if [ $temp -gt 0 ]; then
        hex=$(printf "%04x" $temp)
      else
        hex=$(printf "%04x" $((temp & 0xFFFF)))
      fi

      echo "7E0007130600000000"$hex"AABB"
    else
      log_info "$log_path" "Temperature node file does not exist: $temp_node"
      return
    fi
}

##### START_TOUCHSCREEN_TEST  #####
function START_TOUCHSCREEN_TEST
{
    # insert your code below
    #RESULT_FILE="/sdcard/testresult.txt"
    # PASS_WORD="MP TEST PASS"
    FAIL_WORD="FAIL"
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ];then
    input keyevent 26
    fi
    sleep 0.5
    RET=$(cat /proc/touch_info/tp_selftest_result)
    #echo $RET
    sleep 3

    #RET=$(grep "$PASS_WORD" $RESULT_FILE)
    #echo $RET

    result=$(echo $RET | grep "$FAIL_WORD")
    if [[ "$result" != "" ]]; then
    #if [ $RET  "$PASS_WORD" ];then
       echo "7E0006190100000001AABB"  #FAIL
    else
      echo "7E0006190100000000AABB"   #PASS
    fi
}

# The magnetometer self-test returns the original value of the XYZ triax
function MAGNETOMETER_TEST_MAG_SENSE_READINGS_ONLY_READ
{
    $(setprop persist.sys.SENSOR_MSENSOR_RAWDATA "")
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ]; then
        input keyevent 26
        sleep 0.5
    fi

    am start -n com.ape.factory/com.ape.factory.testActivities.sensor.MSensorFtm >> /dev/null 2>&1
    SENSOR_MSENSOR_RAWDATA="FAIL"
    for i in $(seq 10 -1 1); do
      rawdata=$(getprop persist.sys.SENSOR_MSENSOR_RAWDATA)
      #echo $rawdata
      if echo "$rawdata" | grep -q "," ;then
        result=$(echo $rawdata | grep -oE '[0-9.-]*')
        x=$(echo $result | awk '{print $1 }')
        y=$(echo $result | awk '{print $2 }')
        z=$(echo $result | awk '{print $3 }')
        #echo $x
        #echo $y
        #echo $z

        hexX=$(printf "%8x" $x)
        hexXX=$(echo $(printf "%08s\n" $hexX))
        #echo "hexX: "$hexX" , "$hexXX
        hexY=$(printf "%8x" $y)
        hexYY=$(echo $(printf "%08s\n" $hexY))
        #echo "hexY: "$hexY" , "$hexYY
        hexZ=$(printf "%8x" $z)
        hexZZ=$(echo $(printf "%08s\n" $hexZ))
        #echo "hexZ: "$hexZ" , "$hexZZ

        echo "7E0012030100000000""${hexXX: -8}""${hexYY: -8}""${hexZZ: -8}""CRRC"
        SENSOR_MSENSOR_RAWDAT="OK"
        break
      fi
      sleep 0.1
    done
    if [ SENSOR_MSENSOR_RAWDAT = "FAIL" ]; then
      echo "7E0006260600000001CRRC"
    fi
}

#### Read id the GYROSCOPE exists
function GYROSCOPE_SELF_TEST
{
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ]; then
        input keyevent 26
        sleep 0.5
    fi
    cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE SENSOR --es CQA_TEST_FUNCTION SENSOR_GYROSCOPE_SUPPORT))
    sleep 1
    GYROSCOPE_SUPPORT="FAIL"
    for i in $(seq 6 -1 1)
    do
      if [ "$(getprop persist.sys.gyroscope.support)" -eq 1 ]; then
        echo "7E0006010700000000CRRC"
        GYROSCOPE_SUPPORT="OK"
        break
      fi
      sleep 1
      done
      if [ "$GYROSCOPE_SUPPORT" = "FAIL" ]; then
          echo "7E0006010700000001CRRC"
      fi
}

#### Read if the acceleration exists
function ACCELEROMETER_SELF_TEST
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ]; then
      input keyevent 26
      sleep 0.5
  fi
  cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE SENSOR --es CQA_TEST_FUNCTION SENSOR_ACC_SUPPORT))
  sleep 1
  ACCELEROMETER_SUPPORT="FAIL"
  for i in $(seq 6 -1 1)
  do
    if [ "$(getprop persist.sys.acceleration.support)" -eq 1 ]; then
      echo "7E0006010100000000CRRC"
      ACCELEROMETER_SUPPORT="OK"
      break
    fi
    sleep 1
    done
    if [ "$ACCELEROMETER_SUPPORT" = "FAIL" ]; then
        echo "7E0006010100000001CRRC"
    fi
}

##### ACCLEROMETER_EXECUTE_OFFSET_CALIBRATION  #####
function ACCLEROMETER_EXECUTE_OFFSET_CALIBRATION
{
  log_info "acceleration_test.log" "acceleration calibrate start ..."
  # insert your code below
	RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ];then
    input keyevent 26
    sleep 0.5
  fi

  am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE SENSOR --es CQA_TEST_FUNCTION SENSOR_CAL_ACCEL >> /dev/null 2>&1
  sleep 3

  SENSOR_CAL_ACCEL="FAIL"
  for i in $(seq 6 -1 1)
  do
    cal_accel_prop=$(getprop persist.sys.SENSOR_CAL_ACCEL)
    log_info "acceleration_test.log" "getprop persist.sys.SENSOR_CAL_ACCEL = $cal_accel_prop"
    if [ "$cal_accel_prop" == "1" ];then
      echo "7E0006010200000000CRRC"
      SENSOR_CAL_ACCEL="OK"
      break
    fi

    sleep 1
  done

  if [ "$SENSOR_CAL_ACCEL" = "FAIL" ];then
    echo "7E0006010200000001CRRC"
  fi
}

##### ACCLEROMETER_READ_OFFSET  #####
function ACCLEROMETER_READ_OFFSET
{
   # insert your code below
   RET=$(cat /mnt/vendor/nvcfg/sensor/acc_cali.json)
   #echo $RET
   result=$(echo $RET | grep -oE '[0-9-]*')
   #echo  $result
   x=$(echo  $result | awk '{ print $1 }')
   #echo  $x
   y=$(echo  $result | awk '{ print $2 }')
   #echo  $y
   z=$(echo  $result | awk '{ print $3 }')
   #echo  $z
   
   hexX=$(printf "%8x" $x)
   hexXX=$(echo $(printf "%08s\n" $hexX))
   #echo ${hexXX:0-0:8}
   hexY=$(printf "%x" $y)
   hexYY=$(echo $(printf "%08s\n" $hexY))
   #echo ${hexYY:0-0:8}
   #echo $(printf "%08s\n" $hexY)
   hexZ=$(printf "%x" $z)
   #echo $(printf "%08s\n" $hexZ)
   hexZZ=$(echo $(printf "%08s\n" $hexZ))
   #echo ${hexZ: -8}
   echo "7E0012010300000000""${hexXX: -8}""${hexYY: -8}""${hexZZ: -8}""CRRC"
}


function GYROSCOPE_EXECUTE_OFFSET_CALIBRATION
{
  # insert your code below
  log_info "gyroscope_test.log" "gyroscope calibrate start ..."
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ];then
    input keyevent 26
    sleep 0.5
  fi

  am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE SENSOR --es CQA_TEST_FUNCTION SENSOR_CAL_GYRO >> /dev/null 2>&1
  sleep 3
  SENSOR_CAL_GRY="FAIL"
  for i in $(seq 6 -1 1)
  do
    gyroscope_calibrate_prop=$(getprop persist.sys.SENSOR_CAL_GRY)
    log_info "gyroscope_test.log" "getprop persist.sys.SENSOR_CAL_GRY = $gyroscope_calibrate_prop"
    if [ "$gyroscope_calibrate_prop" -eq 1 ];then
      echo "7E0006010500000000CRRC"
      SENSOR_CAL_GRY="OK"
      break
    fi
    sleep 1
  done
  if [ "$SENSOR_CAL_GRY" = "FAIL" ];then
    echo "7E0006010500000001CRRC"
  fi
}

function GYROSCOPE_READ_OFFSET
{
   # insert your code below
   RET=$(cat /mnt/vendor/nvcfg/sensor/gyro_cali.json)
   #echo $RET
   result=$(echo $RET | grep -oE '[0-9-]*')
   #echo  $result
   x=$(echo  $result | awk '{ print $1 }')
   #echo  $x
   y=$(echo  $result | awk '{ print $2 }')
  # echo  $y
   z=$(echo  $result | awk '{ print $3 }')
   #echo  $z
   
   hexX=$(printf "%8x" $x)
   hexXX=$(echo $(printf "%08s\n" $hexX))
   #echo ${hexXX:0-0:8}
   hexY=$(printf "%x" $y)
   hexYY=$(echo $(printf "%08s\n" $hexY))
   #echo ${hexYY:0-0:8}
   #echo $(printf "%08s\n" $hexY)
   hexZ=$(printf "%x" $z)
   #echo $(printf "%08s\n" $hexZ)
   hexZZ=$(echo $(printf "%08s\n" $hexZ))
   #echo ${hexZ: -8}
   echo "7E0012010600000000""${hexXX: -8}""${hexYY: -8}""${hexZZ: -8}""CRRC"
}


function ENABLE_PROXIMITY_SENSOR
{
  log_info "psensor_test.log" "enable_proximity_sensor start .."
  # insert your code below
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ];then
    input keyevent 26
    sleep 0.5
  fi

  am start -n com.mediatek.sensorhub.ui/com.mediatek.sensorhub.sensor.alspsex.ProxSensorFtm >> /dev/null 2>&1
  ENABLE_PROXIMITY_SENSOR="FAIL"
  for i in $(seq 9 -1 1)
  do
    enable_proximity_sensor=$(getprop persist.sys.PSENSOR_ON)
    log_info "psensor_test.log" "getprop persist.sys.PSENSOR_ON = $enable_proximity_sensor"
    if [ "$enable_proximity_sensor" -eq 1 ];then
      echo "7E0006260100000000CRRC" #PASS
      ENABLE_PROXIMITY_SENSOR="OK"
      break
    fi
    sleep 1
  done

  if [ "$ENABLE_PROXIMITY_SENSOR" = "FAIL" ];then
    echo "7E0006260100000001CRRC" #FAIL
  fi

}


function PROX_CROSSTALK_CALIBRATION
{
    # insert your code below
    log_info "psensor_test.log" "psensor_uncover_cali start ..."
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ];then
      input keyevent 26
      sleep 0.5
    fi

    am start -n com.mediatek.sensorhub.ui/com.mediatek.sensorhub.sensor.alspsex.ProxSensorFtm --es action docaliuncover >> /dev/null 2>&1
    sleep 3

    SENSOR_CAL_PROXIMITY="FAIL"
    for i in $(seq 9 -1 1)
    do
      proximity_cal_prop=$(getprop persist.sys.SENSOR_CAL_PROXIMITY)
      log_info "psensor_test.log" "getprop persist.sys.SENSOR_CAL_PROXIMITY = $proximity_cal_prop"
      if [ "$proximity_cal_prop" -eq 1 ];then
        echo "7E0006260300000000CRRC"
        SENSOR_CAL_PROXIMITY="OK"
        break
      fi
      sleep 1
    done

    if [ $SENSOR_CAL_PROXIMITY = "FAIL" ];then
      echo "7E0006260300000001CRRC"
    fi
}

function PROX_READ_COVER_RAWDATA
{
    # insert your code below
    log_info "psensor_test.log" "prox_read_rawdata start ..."
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ];then
      input keyevent 26
      sleep 0.5
    fi

    am start -n com.mediatek.sensorhub.ui/com.mediatek.sensorhub.sensor.alspsex.ProxSensorFtm --es action getrawdata >> /dev/null 2>&1
    sleep 1.5
    SENSOR_PROXIMITY_RAWDATA="FAIL"
    for i in $(seq 9 -1 1)
    do
      prox_read_rawdata=$(getprop persist.sys.SENSOR_PROXIMITY_RAWDATA)
      log_info "psensor_test.log" "getprop persist.sys.SENSOR_PROXIMITY_RAWDATA = $prox_read_rawdata"
      if [ "$prox_read_rawdata" -ne 0 ];then
	      rawdata=$prox_read_rawdata
	      hexX=$(printf "%8x" $rawdata)
        hexXX=$(echo $(printf "%08s\n" $hexX))
        echo "7E000A260400000000""${hexXX: -8}""CRRC"
        SENSOR_PROXIMITY_RAWDATA="OK"
        break
      fi
      sleep 1
    done

    if [ $SENSOR_PROXIMITY_RAWDATA = "FAIL" ];then
      echo "7E000A260400000001CRRC"
    fi
}



function WRITE_PROX_UNCOVER_RAWDATA
{
    # insert your code below
	echo "7E0006260500000000CRRC"
}

function PROX_WRITE_COVER_RAWDATA
{
    # insert your code below
	echo "7E0006260500000000CRRC"
}

function PROX_EXECUTE_THRESHOLD_CALIBRATION
{
  log_info "psensor_test.log" "psensor_cover cali start ..."
  # insert your code below
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ];then
    input keyevent 26
    sleep 0.5
  fi

  am start -n com.mediatek.sensorhub.ui/com.mediatek.sensorhub.sensor.alspsex.ProxSensorFtm --es action docalicover >> /dev/null 2>&1
  sleep 2
  SENSOR_CAL_PROXIMITY_2CM="FAIL"
  for i in $(seq 9 -1 1)
  do
    prox_cover_cali_prop=$(getprop persist.sys.SENSOR_CAL_PROXIMITY_2CM)
    log_info "psensor_test.log" "getprop persist.sys.SENSOR_CAL_PROXIMITY_2CM = $prox_cover_cali_prop"
    if [ "$prox_cover_cali_prop" -eq 1 ];then
      echo "7E0006260600000000CRRC" #PASS
      SENSOR_CAL_PROXIMITY_2CM="OK"
      break
    fi
    sleep 1
  done

  if [ $SENSOR_CAL_PROXIMITY_2CM = "FAIL" ];then
    echo "7E0006260600000001CRRC" #FAIL
  fi
}

function PROX_READ_THRESHOLD
{
   # insert your code below
   RET=$(cat /mnt/vendor/nvcfg/sensor/ps_cali.json)
   #echo $RET
   result=$(echo $RET | grep -oE '[0-9-]*')
   #echo  $result
   x=$(echo  $result | awk '{ print $1 }')
   #echo  $x
   y=$(echo  $result | awk '{ print $2 }')

   
   hexX=$(printf "%8x" $x)
   hexXX=$(echo $(printf "%08s\n" $hexX))
   #echo ${hexXX:0-0:8}
   hexY=$(printf "%x" $y)
   hexYY=$(echo $(printf "%08s\n" $hexY))
   #echo ${hexYY:0-0:8}
   #echo $(printf "%08s\n" $hexY)
   echo "7E000E260700000000""${hexXX: -8}""${hexYY: -8}""CRRC"
}

function DISABLE_PROXIMITY_SENSOR
{
    # insert your code below
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ];then
    input keyevent 26
	sleep 0.5
    fi
    am start -n com.mediatek.sensorhub.ui/com.mediatek.sensorhub.sensor.alspsex.ProxSensorFtm --es action finish >> /dev/null 2>&1

    DISABLE_PROXIMITY_SENSOR="FAIL"
    for i in $(seq 9 -1 1)
    do
    if [ $(getprop persist.sys.PSENSOR_ON) -eq 0 ];then
    echo "7E0006260200000000CRRC" #PASS
    DISABLE_PROXIMITY_SENSOR="OK"
    break
    #else
    #echo "wait..."
    fi
    sleep 1
    done
    if [ $DISABLE_PROXIMITY_SENSOR = "FAIL" ];then
    echo "7E0006260200000001CRRC" #FAIL
    #echo "feature $0 not implemented"
    fi
}

function ENABLE_ALS_SENSOR
{
  ENABLE_ALS_SENSOR="FAIL"

  if [ -f /sys/bus/platform/drivers/als_ps/test_alsenable ]; then

    echo 1 > /sys/bus/platform/drivers/als_ps/test_alsenable

    for i in $(seq 6 -1 1); do
      enable_als=$(cat /sys/bus/platform/drivers/als_ps/test_alsenable)
      log_info "LSensor.log" "enable_als= $enable_als"

      if [ -n "$enable_als" ] && [ "$enable_als" -eq 1 ]; then
        echo "7E0006020500000000CRRC" # PASS
        ENABLE_ALS_SENSOR="OK"
        break
      fi

      sleep 0.5
    done
  else
    log_info "LSensor.log" "Node /sys/bus/platform/drivers/als_ps/test_alsenable does not exist"
    echo "7E0006020500000001CRRC" # FAIL
    return
  fi

  if [ "$ENABLE_ALS_SENSOR" == "FAIL" ]; then
    echo "7E0006020500000001CRRC" # FAIL
  fi
}

function LIGHT_SENSOR_READ_FROM_PHONE_3CH
{

  SENSOR_LSENSOR_RAWDATA="FAIL"

  if [ -f /sys/bus/platform/drivers/als_ps/test_alsgetch ]; then
    for i in $(seq 6 -1 1); do
      als_lux_result=$(cat /sys/bus/platform/drivers/als_ps/test_alsgetch)
      log_info "LSensor.log" "read_lux= $als_lux_result"

      if [ -n "$als_lux_result" ]; then
        Lux=$(echo "$als_lux_result" | awk '{print $1}')
        Visible_light=$(echo "$als_lux_result" | awk '{print $2}')
        Infrared_light=$(echo "$als_lux_result" | awk '{print $3}')
        Full_spectrum_value=$(echo "$als_lux_result" | awk '{print $4}')
        final=$(echo "$als_lux_result" | awk '{print $5}')
        log_info "LSensor.log" "Lux= $Lux, Visible_light= $Visible_light, Infrared_light= $Infrared_light, Full_spectrum_value= $Full_spectrum_value"
        if [ "$Lux" -eq 0 ] && [ "$Visible_light" -eq 0 ] && [ "$Infrared_light" -eq 0 ] && [ "$Full_spectrum_value" -eq 0 ]; then
          log_info "LSensor.log" "All data is 0, the $i time"
          continue
        else
          hexX=$(printf "%08x" $Lux)
          hexY=$(printf "%08x" $Visible_light)
          hexZ=$(printf "%08x" $Infrared_light)
          echo "7E0012020100000000""${hexX: -8}""${hexY: -8}""${hexZ: -8}""CRRC"
          SENSOR_LSENSOR_RAWDATA="OK"
          break
        fi
      fi

      sleep 0.5

    done
  else
    log_info "LSensor.log" "Node /sys/bus/platform/drivers/als_ps/test_alsgetch does not exist"
    echo "7E0006260600000001CRRC"
    return
  fi

  if [ "$SENSOR_LSENSOR_RAWDATA" == "FAIL" ]; then
    echo "7E0006260600000001CRRC"
  fi

}

function LIGHT_SENSOR_CALIBRATION_WRITE_TARGET
{
    # insert your code below
    echo "7E0006020200000000CRRC"
}

function LIGHT_SENSOR_CALIBRATION_EXCUTE_CALI
{
    # insert your code below
	SENSOR_LSENSOR_CAL="FAIL"
	log_info "LSensor.log" "als_cali_start...."

  if [ -f /sys/bus/platform/drivers/als_ps/test_alscali ]; then
    echo 1 > /sys/bus/platform/drivers/als_ps/test_alscali
    sleep 2

    for i in $(seq 6 -1 1); do
      als_cali_status=$(cat /sys/bus/platform/drivers/als_ps/test_alscali)
      log_info "LSensor.log" "als_cali_status= $als_cali_status"

      if [ -n "$als_cali_status" ] && [ "$als_cali_status" -eq 1 ] ; then
        echo "7E0006020300000000CRRC";
        SENSOR_LSENSOR_CAL="OK"
        break
      fi

      sleep 0.5
    done
  else
    log_info "LSensor.log" "Node /sys/bus/platform/drivers/als_ps/test_alscali does not exist"
    echo "7E0006020300000001CRRC" # FAIL
    return
  fi

  if [ "$SENSOR_LSENSOR_CAL" == "FAIL" ]; then
     echo "7E0006020300000001CRRC"
  fi
}


function LIGHT_SENSOR_CALIBRATION_VERIFY_COEFFICIENTS
{
   # insert your code below
   RET=$(cat /mnt/vendor/nvcfg/sensor/als_cali.json)
   log_info "LSensor.log" "als_cali_result= $RET"
   #echo $RET
   result=$(echo $RET | grep -oE '[0-9-]*')
   #echo  $result
   x=$(echo  $result | awk '{ print $1 }')
   
   hexX=$(printf "%8x" $x)
   hexXX=$(echo $(printf "%08s\n" $hexX))
   #echo ${hexXX:0-0:8}
   echo "7E000E260700000000""${hexXX: -8}""CRRC"
}

function DISABLE_ALS_SENSOR
{

  if [ -f /sys/bus/platform/drivers/als_ps/test_alsenable ]; then
    disable_als=$(cat /sys/bus/platform/drivers/als_ps/test_alsenable)
    log_info "LSensor.log" "disable_als==> $disable_als"
    echo "7E0006020600000000CRRC" #PASS
  else
    log_info "LSensor.log" "Node /sys/bus/platform/drivers/als_ps/test_alsenable does not exist"
    echo "7E0006020600000001CRRC" # FAIL
    return
  fi
}

function FPS_ON_SENSOR
{
    # insert your code below
    setprop persist.sys.power_disable true
    am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE  FINGERPRINT --es CQA_TEST_FUNCTION FINGERPRINT_PRESENCE >> /dev/null 2>&1
    sleep 2
    FINGERPRINT_PRESENCE="FAIL"
    for i in $(seq 6 -1 1)
    do
    if [ $(getprop persist.sys.FINGERPRINT_PRESENCE) -eq 1 ];then
    echo "7E0006020600000011CRRC"
    FINGERPRINT_PRESENCE="OK"
    break
    #else
    #echo "wait..."
    fi
    sleep 1
    done
    if [ $FINGERPRINT_PRESENCE = "FAIL" ];then
    echo "7E0006020600000010CRRC"
    # echo "feature $0 not implemented"
    fi
    setprop persist.sys.power_disable false
}

function ENABLE_REAR_LIGHT_SENSOR
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ "$RET" -eq 0 ]; then
    input keyevent 26
    sleep 0.5
  fi

  am start -n com.mediatek.sensorhub.ui/com.mediatek.sensorhub.sensor.alspsex.FtmRearLight --activity-clear-top  >> /dev/null 2>&1
  log_info "rals_test.log" "enable_rals start ==> "

  ENABLE_RLS_SENSOR="FAIL"
  for i in $(seq 9 -1 1)
  do
    if [ "$(getprop persist.sys.RLSENSOR_ON)" -eq 1 ]; then
      echo "7E00192300000000AABB"
      ENABLE_RLS_SENSOR="OK"
      break
    fi
    sleep 1
    done
    if [ "$ENABLE_RLS_SENSOR" = "FAIL" ]; then
      echo "7E00192300000001AABB"
    fi
}

function REAR_LIGHT_SENSOR_READ_FORM_PHONE_LUX
{
  SENSOR_RLSENSOR_LUX_3CH="FAIL"
  Machine_Model=$(getprop ro.boot.hwsku)
  log_info "rals_lux.log" "Machine_Model = $Machine_Model"

  echo 1 > /sys/bus/platform/drivers/als_ps/test_rear_alsenable
  als_enable=$(cat /sys/bus/platform/drivers/als_ps/test_rear_alsenable)

  if [ "$als_enable" -eq 1 ]; then
    if [ -f /sys/bus/platform/drivers/als_ps/test_rear_alsgetch ]; then
      for i in $(seq 6 -1 1); do
        rals_lux_result=$(cat /sys/bus/platform/drivers/als_ps/test_rear_alsgetch)
        log_info "rals_lux.log" "rals_read_lux = $rals_lux_result"

        if [ -n "$rals_lux_result" ]; then
            lux=$(echo "$rals_lux_result" | awk '{print $1}')
            visible_light=$(echo "$rals_lux_result" | awk '{print $2}')
            infrared_light=$(echo "$rals_lux_result" | awk '{print $3}')
            full_spectrum_value=$(echo "$rals_lux_result" | awk '{print $4}')
            log_info "rals_lux.log" "lux = $lux, visible_light = $visible_light, infrared_light = $infrared_light, full_spectrum_value = $full_spectrum_value"

            if [ "$lux" -eq 0 ] && [ "$visible_light" -eq 0 ] && [ "infrared_light" -eq 0 ] && [ "$full_spectrum_value" -eq 0 ]; then
              log_info "rals_lux.log" "All data is 0, the $i time"
              continue

            else
              hexX=$(printf "%08x" $lux)
              hexY=$(printf "%08x" $visible_light)
              hexZ=$(printf "%08x" $infrared_light)
              hexW=$(printf "%08x" $full_spectrum_value)

              if [ "$Machine_Model" -gt 9 ]; then
                echo "7E00192400000000""${hexX: -8}""${hexY: -8}""${hexZ: -8}""AABB"  #The Lamu machine reports three two-channel values.
                SENSOR_RLSENSOR_LUX_3CH="OK"
                break
              else
                echo "7E00192400000000""${hexX: -8}""${hexY: -8}""${hexZ: -8}""${hexW: -8}""AABB"  #The LamuLite machine reports three two-channel values.
                SENSOR_RLSENSOR_LUX_3CH="OK"
                break
              fi
            fi
        fi

        sleep 0.5

        done
    else
      log_info "rals_lux.log" "Node /sys/bus/platform/drivers/als_ps/test_rear_alsgetch does not exist"
      echo "7E00192400000001AABB"
      return
    fi
  else
    echo "7E00192400000001AABB"
  fi

  if [ "$SENSOR_RLSENSOR_LUX_3CH" == "FAIL" ]; then
    echo "7E00192400000001AABB"
  fi
}

function REAR_LIGHT_SENSOR_CALIBRATION_WRITE_TARGET
{
  echo "7E00192700000000AABB"
}

function REAR_LIGHT_EXECUTE_OFFSET_CALIBRATION
{
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ]; then
      input keyevent 26
      sleep 0.5
    fi
    am start -n com.mediatek.sensorhub.ui/com.mediatek.sensorhub.sensor.alspsex.FtmRearLight --es action doCali >> /dev/null 2>&1
    log_info "rals_test.log" "rals_caliration start ==> "
    sleep 2
    SENSOR_CALI_REAR_LIGHT="FAIL"
    for i in $(seq 6 -1 1)
    do
      rals_caliration_prop=$(getprop persist.sys.SENSOR_CALI_REAR_LIGHT)
      log_info "rals_test.log" "getprop persist.sys.SENSOR_CALI_REAR_LIGHT = $rals_caliration_prop"
      if [ "$rals_caliration_prop" -eq 1 ]; then
        echo "7E00192500000001AABB"
        SENSOR_CALI_REAR_LIGHT="OK"
        break
      fi
      sleep 1
      done
      if [ $SENSOR_CALI_REAR_LIGHT = "FAIL" ]; then
        echo "7E00192500000000AABB"
      fi
}

function REAR_LIGHT_READ_OFFSET
{
  if [ -f /mnt/vendor/nvcfg/sensor/rearals_cali.json ]; then
    RET=$(cat /mnt/vendor/nvcfg/sensor/rearals_cali.json)
    result=$(echo $RET | grep -oE '[0-9]*')
    x=$(echo $result | awk '{ print $1 }')
    hexX=$(printf "%8x" $x)
    hexXX=$(echo $(printf "%08s\n" $hexX))
    echo "7E00192600000000""${hexXX: -8}""AABB"
  else
    echo "7E00192600000000AABB"
  fi
}

function DISABLE_REAR_LIGHT_SENSOR
{
    # insert your code below
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ];then
      input keyevent 26
      sleep 0.5
    fi
    am start -n com.mediatek.sensorhub.ui/com.mediatek.sensorhub.sensor.alspsex.FtmRearLight --es action finish >> /dev/null 2>&1
    log_info "rals_test.log" "disable_rls start ==> "

    DISABLE_RLS_SENSOR="FAIL"
    for i in $(seq 9 -1 1)
    do
      if [ "$(getprop persist.sys.RLSENSOR_ON)" -eq 0 ];then
      echo "7E00192800000000AABB" #PASS
      DISABLE_RLS_SENSOR="OK"
      break
      fi
    sleep 1
    done
    if [ "$DISABLE_RLS_SENSOR" = "FAIL" ];then
      echo "7E00192800000001AABB" #FAIL
    fi
}

function FLICKER_SENSOR_READ_OFFSET
{
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ]; then
      input keyevent 26
      sleep 0.5
    fi

    am start -n com.ape.factory/com.ape.factory.testActivities.sensor.FlickerSensor --es action getData >> /dev/null 2>&1
    sleep 3
    SENSOR_DATA_FLICKER="FAIL"
    result=$(getprop persist.sys.flicker.data)

    for i in $(seq 6 -1 1)
    do
        if [ -n "$result" ] && [ "$result" -ne 0 ] 2>/dev/null; then  # Check if result is not empty and not 0
            hex=$(printf "%04x" "$result")
            echo "7E00192900000000${hex}AABB"
            SENSOR_DATA_FLICKER="OK"
            break
        fi
        sleep 0.5
        result=$(getprop persist.sys.flicker.data)  # Reread property values
    done

    if [ "$SENSOR_DATA_FLICKER" = "FAIL" ]; then
        echo "7E00192900000000AABB"
    fi
}

function DISABLE_NFC
{
    echo "feature $0 not implemented"
    echo "1"
}

function RESET_NFC
{
    # insert your code below
    echo "feature $0 not implemented"
    echo "1"
}

function ENABLE_NFC_TEST_MODE
{
    # insert your code below
    cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE NFC --es CQA_TEST_FUNCTION NFCTN))
    NFCTN="FAIL"
    for i in $(seq 6 -1 1)
    do
    if [ $(getprop persist.sys.NFCTN) -eq 1 ];then
    echo "7E0006120300000001AABB"
    NFCTN="OK"
    break
    #else
    #echo "wait..."
    fi
    sleep 1
    done
    if [ $NFCTN = "FAIL" ];then
    echo "7E0006120300000000AABB"
    # echo "feature $0 not implemented"
    fi
}

function START_NFC_SWP_SELF_TEST_BOARD
{
    # insert your code below
    echo "feature $0 not implemented"
    echo "1"
}


function NFC_ANTENNA_SELFTEST
{
    # insert your code below
    echo "feature $0 not implemented"
    echo "1"
}

function READ_LCD_VENDOR_INFO
{
    # insert your code below
    RET=$(cat /sys/devices/platform/product-device-info/info_lcd)
    log_info "vendor_info.log" "$RET"
    if [ $RET == "TXD-ILI9883C-VDO" ]; then
      echo "7E00070D010000000001CRRC"
    elif [ $RET == "BOE-ICNL9922C-VDO" ]; then
      echo "7E00070D010000000002CRRC"
    elif [ $RET == "DIJIN-NT36672S-VDO" ]; then
      echo "7E00070D010000000003CRRC"
    elif [ $RET == "TIANMA-NT36528A-VDO" ]; then
      echo "7E00070D010000000004CRRC"
    elif [ $RET == "TIANMA-TD4376-VDO" ]; then
      echo "7E00070D010000000005CRRC"
    elif [ $RET == "DIJIN-TD4160-VDO" ]; then
      echo "7E00070D010000000006CRRC"
    fi
}

function READ_NVM_SIZE
{
    # insert your code below
    RET=$(cat /sys/block/mmcblk0/size)
    #echo $RET
    hex=$(printf "%x" $((RET/2)))
    #echo $hex
    echo "7E000A0A0200000000"$hex"CRRC"
}


function READ_SDCARD_SIZE
{
   # insert your code below
   strA="media_rw"

   RET=$(df | grep "media_rw")
   #echo $RET

   if [ "$RET" =  "" ];then
   echo "7E00062102000000000AABB"
   else
   size=$(echo $RET | awk '{ print $2 }')
   hex=$(printf "%08x" $size)
   echo "7E000621020"$hex"ABBA"
   fi
}



function GET_RAM_LPDDR_SIZE
{
    # insert your code below
    a=1024

    RET=$(getprop ro.boot.mem | cut -d'_' -f3)
    hex=$(printf "%x" $((RET*a)))

    echo "7E0006220100000000"$hex"AABB"
}


function READ_SW_VERSION
{
    # insert your code below
    # echo $(getprop ro.build.description)
    #  echo "feature $0 not implemented"
    RET=$(getprop ro.build.description)
    result=""
    for i in $(seq 0 $((${#RET}-1))); do
       char="${RET:$i:1}"
       ascii=$(printf "%d" "'$char")
       decimal=$(printf "%d" "$ascii")  # Concatenate the ASCII code of each character into the result string
       result+=$(printf "%x" $decimal)  # Convert decimal to hexadecimal
    done

    echo $result
}

function GET_MMC_ABSENT_STATUS
{
    # insert your code below
    #RET=$(cat /sys/devices/platform/11240000.mmc/mmc_host/mmc1/sd_state)
    if [ -f /sys/devices/platform/11240000.mmc/mmc_host/mmc1/sd_state ]; then
      RET=$(cat /sys/devices/platform/11240000.mmc/mmc_host/mmc1/sd_state)
      if [ $RET -eq 1 ]; then
        echo "7E000721010000000001AABB"
      else
        echo "7E000721010000000000AABB"
      fi
    else
      echo "7E000721010000000000AABB"
    fi
}

function SWITCH_POWER_SOURCE_TO_BATTERY
{
    # insert your code below
    echo 1 > /sys/devices/platform/charger/enable_hiz
    echo "7E0006090100000000AABB"
}

function SWITCH_POWER_SOURCE_TO_CHARGE
{
    # insert your code below
    echo 0 > /sys/devices/platform/charger/enable_hiz
    echo "7E0007090200000000AABB"
}

function SWITCH_CHARGER_ENABLE
{
  echo 1 > /sys/devices/platform/charger/factory_enable_switch_charger
  RET=$(cat /sys/devices/platform/charger/factory_enable_switch_charger)
  if [ "$RET" -eq 1 ]; then
    echo "7E0007090300000000AABB"
  else
    echo "7E0007090300000001AABB"
  fi
}

function SWITCH_CHARGER_DISABLE
{
  echo 0 > /sys/devices/platform/charger/factory_enable_switch_charger
  RET=$(cat /sys/devices/platform/charger/factory_enable_switch_charger)
  if [ "$RET" -eq 0 ]; then
    echo "7E0007090400000000AABB"
  else
    echo "7E0007090400000001AABB"
  fi
}

function CHARGER_PUMP_ENABLE
{
  echo 1 > /sys/devices/platform/charger/factory_enable_pump_charger
  RET=$(cat /sys/devices/platform/charger/factory_enable_pump_charger)
  if [ "$RET" -eq 1 ]; then
    echo "7E0007090500000000AABB"
  else
    echo "7E0007090500000001AABB"
  fi
}

function CHARGER_PUMP_DISABLE
{
  echo 0 > /sys/devices/platform/charger/factory_enable_pump_charger
  RET=$(cat /sys/devices/platform/charger/factory_enable_pump_charger)
  if [ "$RET" -eq 0 ]; then
    echo "7E0007090600000000AABB"
  else
    echo "7E0007090600000001AABB"
  fi
}

function QUICK_STANDBY
{
    # insert your code below
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -gt 0 ];then
    input keyevent 26
    fi

    echo "7E0006180300000000AABB"
}

#### Shutdown command
function POWER_OFF
{
    reboot -p
}

function READ_VBUS_VOLTAGE
{
    # insert your code below
    RET=$(cat /sys/devices/platform/charger/ADC_Charger_Voltage)
    hex=$(printf "%x" $RET)

    echo "7E000618030000"$hex"AABB"
}


function DISABLE_BATTERY_FET
{
    # insert your code below
    # echo "not support"
    echo 0 > /sys/devices/platform/charger/enable_charger
    RET=$(cat /sys/devices/platform/charger/enable_charger)
    if [ $RET -eq 0 ]; then
      echo "7E0006090900000000AABB"   # PASS
    else
      echo "7E0006090900000001AABB"   #FAIL
    fi
}

function ENABLE_PATH_FET_TO_BATTERY
{
    # insert your code below
    # echo "not support"
    echo 1 > /sys/devices/platform/charger/enable_charger
    RET=$(cat /sys/devices/platform/charger/enable_charger)
    if [ $RET -eq 1 ]; then
      echo "7E0007090B00000000AABB"   #PASS
    else
      echo "7E0007090B00000001AABB"   #FAIL
    fi
}

##### READ_VBAT_VOLTAGE  #####

function READ_VBAT_VOLTAGE
{
    # insert your code below
    RET=$(cat /sys/class/power_supply/battery/voltage_now)
    hex=$(printf "%x" $RET)

    echo "7E000A09070000000000"$hex"AABB"
}

function SET_INPUT_PATH_TO_3_AMPS
{
    # insert your code below
    echo 3000000 > /sys/devices/platform/charger/factory_input_charging_current

    echo "7E0007090A00000000AABB"
}

function SET_OUTPUT_PATH_TO_1_AMPS
{
    # insert your code below
    echo 1000000 > /sys/devices/platform/charger/factory_charging_current

    echo "7E0007090B00000000AABB"
}

function READ_DCP_STATUS
{
  RET=$(cat /sys/devices/platform/charger/chr_type)
  result=""
  if [ $RET -eq 4 ]; then
    result="SDP"
  elif [ $RET -eq 5 ]; then
    result="DCP"
  elif [ $RET -eq 6 ]; then
    result="CDP"
  else
    echo "7E0002090F00000000000001CRRC"  # unknow
    return
  fi

  charType=""
  for i in $(seq 0 $((${#result}-1))); do
    char="${result:$i:1}"
    ascii=$(printf "%d" "'$char")
    decimal=$(printf "%d" "$ascii")
    charType+=$(printf "%x" $decimal)
  done
  echo "7E0002090F00000000"$charType"AABB"
}

# Detect SIM1 status
function VERIFY_SIM1_REMOVE_STATUS
{
    RET=$(getprop gsm.sim.state)
    sleep 0.5
    SIM1=$(echo $RET | cut -d',' -f1)
    if [ "$SIM1" == "ABSENT" ]; then
    echo "7E000727010000000000CRRC"
    else
    echo "7E000727010000000001CRRC"
    fi
}

# Detect SIM2 status
function VERIFY_SIM2_REMOVE_STATUS
{
    RET=$(getprop gsm.sim.state)
    sleep 0.5
    SIM2=$(echo $RET | cut -d',' -f2)
    if [ "$SIM2" == "ABSENT" ]; then
    echo "7E000727010000000000CRRC"
    else
    echo "7E000727010000000001CRRC"
    fi
}

function GET_SIM_ABSENT_STATUS
{
    # insert your code below
    RET=$(cat /sys/devices/platform/product-device-info/info_cardslot)
    result=$(echo "$RET" | sed 's/ //g')
    if [ "$result" == "insert" ]; then
    echo "7E000727030000000001CRRC"
    else
    echo "7E000727030000000000CRRC"
    fi
}

function ENABLE_WLAN
{
    # insert your code below
    svc wifi enable
    echo "7E0006240100000000AABB"
}

function DISABLE_WLAN
{
    # insert your code below
    svc wifi disable
    echo "7E0006240200000000AABB"
}

function ENABLE_BT
{
    # insert your code below
    svc bluetooth enable
    echo "7E0002070100000000AABB"
}

function DISABLE_BT
{
    # insert your code below
    svc bluetooth disable
    echo "7E0002070200000000AABB"
}

function ENABLE_NFC
{
    # insert your code below
    svc nfc enable
    echo "7E0006120100000000AABB"
}

function DISABLE_NFC
{
    # insert your code below
    svc nfc disable
    echo "7E0006120200000000AABB"
}


function CAP_SENSOR_DETECT
{
    # insert your code below
    if [ -f /sys/class/sar/ic_check ];then
      RET=$(cat /sys/class/sar/ic_check)
      if [ "$RET" == "0x00" ]; then
        echo "7E0006080100000000CRRC"
      else
        echo "7E0006080100000011CRRC"
      fi
    else
      echo "7E0006080100000011CRRC"
    fi
}

function CAP_SENSOR_ENABLE
{
    # insert your code below
    if [ -f /sys/class/sar/enable ];then
      echo 1 > /sys/class/sar/enable
      RET=$(cat /sys/class/sar/enable)
      if [ "$RET" == "0x00" ]; then
        echo "7E0006080200000000CRRC"
      else
        echo "7E0006080200000011CRRC"
      fi
    else
    echo "7E0006080200000011CRRC"
    fi
}

function CAP_SENSOR_EXECUTE_SELF_CALIBRATION
{
    # insert your code below
    if [ -f /sys/class/sar/calibrate ];then
    echo 99 > /sys/class/sar/calibrate
    echo "7E0006080400000000CRRC"
    else
    echo "7E0006080400000011CRRC"
    fi
}

function CAP_SENSOR_READ_DIFF_VALUE
{
    # insert your code below
    if [ -f /sys/class/sar/diff ];then
    RET=$(cat /sys/class/sar/diff)
    size=$(echo "$RET" | awk -F'=' '{ print $2 }')
    log_info "sar_diff.log" "RET= $RET \n result= $size"

    result=(${size// /})
    diffret=""

    for v in ${result[@]};do
        #echo "list: $v"
        hexX=$(printf "%8x" $v)
        hexXX=$(echo $(printf "%08s\n" $hexX))
        v=$(echo ${hexXX: -8})
        diffret=$diffret$v
        #echo "diffret= $diffret"
        #echo $v
    done
    #echo "${result[@]}"
    #echo $diffret
    echo "7E001E080700000000"$diffret"00000000CRRC"
    else
    echo "7E0006080700000011CRRC"
    fi
}

function CAP_SENSOR_CHECK_CALI_VALUE_BOARD
{
  logfile="sar_offset.log"
  if [ -f /sys/class/sar/offset ]; then
    RET=$(cat /sys/class/sar/offset)
    log_info "$logfile" "sar_result= $RET"
    if [ -f /sys/bus/i2c/drivers/awinic_sar/3-0012/mode_operation ]; then
      size=$(echo "$RET" | awk -F': ' '{print $2}' | sed 's/[^0-9.]//g' | cut -c1-6)
      log_info "$logfile" "sar1= $size"
      result=(${size// /})
    elif [ -d /sys/bus/i2c/drivers/hx9031as/3-0028 ]; then
      size=$(echo "$RET" | awk -F'[=pF ]+' '{for(i=2; i<=NF; i+=2) print $i}')
      log_info "$logfile" "sar_2= $size"
      result=(${size// /})
    else
      log_info "$log_info" "sar_offset_test_fail"
      echo "7E0006080500000011CRRC"
      return
    fi

    diffret=""
    a=1000
    for v in "${result[@]}"; do
      v=$(echo "$v" | awk '{printf "%.3f", $0}')
      v=$(echo "$v $a" | awk '{printf("%.0f", $1 * $2)}')

      log_info "$logfile" "sar_list: $v"
      hexX=$(printf "%8x" "$v")
      hexXX=$(printf "%08s\n" "$hexX" | tr ' ' '0')
      v=$(echo "${hexXX: -8}")
      diffret="$diffret$v"
      #echo "$diffret"
    done

    echo "7E0006080500000000${diffret}00000000CRRC"
  else
    echo "7E0006080500000011CRRC"
  fi
}


function CAP_SENSOR_CHECK_CALI_VALUE_PHONE
{
    # insert your code below
    if [ -f /sys/bus/i2c/drivers/awinic_sar/3-0012/offset ];then
    size=$(cat /sys/bus/i2c/drivers/awinic_sar/3-0012/offset | awk '{ print $3 }')
    #echo $size

    result=(${size// /})
    diffret=""
    a=1000
    for v in ${result[@]};do
        result="$v"| awk '{printf "%.3f", $0}'
        v=$(echo $v $a | awk '{printf("%.0f",$1*$2)}')

        #echo $v
        hexX=$(printf "%8x" $v)
        hexXX=$(echo $(printf "%08s\n" $hexX))
        v=$(echo ${hexXX: -8})
        diffret=$diffret$v
        #echo $v
    done
    #echo "${result[@]}"
    #echo $diffret
    echo "7E0006080500000000"$diffret"CRRC"
    else
    echo "7E0006080500000011CRRC"
    fi
}

function CAP_SENSOR_DISABLE
{
    # insert your code below
    if [ -f /sys/class/sar/enable ];then
      echo 0 > /sys/class/sar/enable
      echo "7E0006080300000000CRRC"
    else
      echo "7E0006080300000011CRRC"
    fi
}

function RESET_TEST_FLAG
{
    # insert your code below
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ];then
    input keyevent 26
    sleep 0.5
    fi

    cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE  TEST_FLAG_OP --es CQA_TEST_FUNCTION RESETTAG))
    log_info "Test_flag.log" "clear test flag..."
    sleep 1
    RESETTAG="FAIL"
    for i in $(seq 6 -1 1)
    do
    if [ $(getprop persist.sys.RESETTAG) -eq 1 ];then
    echo "7E0046180100000001AABB"
    RESETTAG="OK"
    break
    #else
    #echo "wait..."
    fi
    sleep 1
    done
    if [ $RESETTAG = "FAIL" ];then
    echo "7E0006020600000010CRRC"
    # echo "feature $0 not implemented"
    fi
}

function WRITE_TEST_FLAG
{
    # insert your code below
    log_info "Test_flag.log" "write_test_flag start ..."
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ];then
    input keyevent 26
    sleep 0.5
    fi

    tag=$1
    #echo $tag
    bt="01000000000000000000000000000000"
    L2="01000000000000001000000000000000"
    ar="01000000000000001100000000000000"
   cam="01000000000000001110000000000000"

    log_info "Test_flag.log" "write_test_flag this = $tag"

    if [ $tag = $bt ];then
        cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE  TEST_FLAG_OP --es CQA_TEST_FUNCTION WRITETAGBT))
        sleep 1
        WRITETAGBT="FAIL"
        for i in $(seq 6 -1 1)
        do
        if [ $(getprop persist.sys.WRITETAGBT) -eq 1 ];then
        echo "7E0046180300000000AABB"
        WRITETAGBT="OK"
        break
        #else
        #echo "wait..."
        fi
        sleep 1
        done
        if [ $WRITETAGBT = "FAIL" ];then
        echo "7E0046180300000001AABB"
        # echo "feature $0 not implemented"
        fi
    fi

    if [ $tag = $L2 ];then
        cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE  TEST_FLAG_OP --es CQA_TEST_FUNCTION WRITETAGL2vision))
        sleep 1
        WRITETAGL2vision="FAIL"
        for i in $(seq 6 -1 1)
        do
        if [ $(getprop persist.sys.WRITETAGL2vision) -eq 1 ];then
        echo "7E0046180300000000AABB"
        WRITETAGL2vision="OK"
        break
        #else
        #echo "wait..."
        fi
        sleep 1
        done
        if [ $WRITETAGL2vision = "FAIL" ];then
        echo "7E0046180300000001AABB"
        # echo "feature $0 not implemented"
        fi
    fi

    if [ $tag = $ar ];then
    #echo testar
        cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE  TEST_FLAG_OP --es CQA_TEST_FUNCTION WRITETAGAR))
        sleep 1
        WRITETAGAR="FAIL"
        for i in $(seq 6 -1 1)
        do
        if [ $(getprop persist.sys.WRITETAGAR) -eq 1 ];then
        echo "7E0046180300000000AABB"
        WRITETAGAR="OK"
        break
        #else
        #echo "wait..."
        fi
        sleep 1
        done
        if [ $WRITETAGAR = "FAIL" ];then
        echo "7E0046180300000001AABB"
        # echo "feature $0 not implemented"
        fi
    fi

    if [ $tag = $cam ];then
        cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE  TEST_FLAG_OP --es CQA_TEST_FUNCTION WRITETAGCAM))
        sleep 1
        WRITETAGBT="FAIL"
        for i in $(seq 6 -1 1)
        do
        if [ $(getprop persist.sys.WRITETAGCAM) -eq 1 ];then
        echo "7E0046180300000000AABB"
        WRITETAGBT="OK"
        break
        #else
        #echo "wait..."
        fi
        sleep 1
        done
        if [ $WRITETAGBT = "FAIL" ];then
        echo "7E0046180300000001AABB"
        # echo "feature $0 not implemented"
        fi
    fi

}

function READ_TEST_FLAG
{
    log_info "Test_flag.log" "READ_TEST_FLAG..."
    # insert your code below
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ];then
    input keyevent 26
    sleep 0.5
    fi

    cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE  TEST_FLAG_OP --es CQA_TEST_FUNCTION READTAG))
    sleep 1

    bt=$(getprop persist.sys.READTAGBT)
    l2=$(getprop persist.sys.READTAGL2vision)
    ar=$(getprop persist.sys.READTAGAR)
    cam=$(getprop persist.sys.READTAGCAM)

    readtag=$(getprop persist.sys.READTAG)

    log_info "Test_flag.log" "READ_TEST_FLAG flag result: BT= $bt; L2= $l2; AR= $ar; Cam=$cam; ReadTag= $readtag"

    if [ $readtag -ne 2 ];then
        if [ $bt -eq 1 ];then
        bt="100000000000000"
        else
        bt="000000000000000"
        fi

        if [ $l2 -eq 1 ];then
        l2="1"
        else
        l2="0"
        fi

        if [ $ar -eq 1 ];then
        ar="1"
        else
        ar="0"
        fi

        if [ $cam -eq 1 ];then
        cam="10000000000000"
        else
        cam="00000000000000"
        fi

        log_info "Test_flag.log" "read_test_flag output: BT= $bt; L2=$l2; AR=$ar; Caam=$cam"
        echo "7E00461802000000000"$bt$l2$ar$cam"AABB"
    else
        echo "7E004618020000000100000000000000000000000000000000AABB"
    fi
}

function SET_HW_MANUFACTUREDATE
{
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ]; then
        input keyevent 26
        sleep 0.5
    fi

    tag=$1
    path="/mnt/persist/misc/HW_MANUFACTUREDATE"

    #  Check if the file or directory exists and create it if it does not exist
    if [ ! -f "$path" ] || [ ! -s "$path" ]; then
        touch "$path"
    fi

    # Write tag to the file
    echo "$tag" > "$path"
    sleep 0.5

    result=$(cat $path)
    if [ $result -eq $tag ]; then
        echo "7E0009171800000000AABB"  #PASS
    else
        echo "7E0009171800000001AABB"  #FAIL
    fi
}

function GET_HW_MANUFACTUREDATE
{
    RET=$(cat /sys/class/leds/lcd-backlight/brightness)
    if [ $RET -eq 0 ]; then
        input keyevent 26
        sleep 0.5
    fi

    file="/mnt/persist/misc/HW_MANUFACTUREDATE"
    if [ ! -f "$file" ]; then
        echo "7E0009171700000001000AABB"
    elif [ ! -s "$file" ]; then
        echo "7E0009171700000001000AABB"
    else
        result=$(cat $file)
        hex=$(printf "%x" $result)
        echo "7E0009171700000000"$hex"AABB"
    fi
}

###################################################################
# Function:    FM_ON                                              #
# Description: This function should enable the FM module          #
#              and sync default frequency of 97.5Mhz              #
# Note:        no splash screen or prompt box should be required  #
# Inputs:      N/A                                                #
# Output:      status:     OK/FAIL                               #
###################################################################
function FM_ON
{
    # insert your code below
    am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE FM --es CQA_TEST_FUNCTION FM_ON
    sleep 1
    FM_ON="FAIL"
    for i in $(seq 15 -1 1)
    do
    if [ $(getprop persist.sys.FM_STATE_ON) -eq 1 ];then
    FM_ON="OK"
    echo "RETURN=PASS"
    break
    #else
    #echo "wait..."
    fi
    sleep 1
    done
    if [ $FM_ON = "FAIL" ];then
    echo "RETURN=FAIL"
    echo "feature $0 not implemented"
    fi
}

###################################################################
# Function:    FM_TUNE                                            #
# Description: This function should sync a desired freq passed as #
#              input on this function call                        #
# Inputs:      Desired FM freq                                    #
# Output:      status:     OK/FAIL                               #
###################################################################
function FM_TUNE
{
    # takes argument
    # insert your code below
    am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE FM --es CQA_TEST_FUNCTION FM_TUNE --es CQA_TEST_PARAMS $1

    #am broadcast -a com.ape.factory.FM_GETRSSI --es FMtune $1
    sleep 1
    FM_TUNE="FAIL"
    for i in $(seq 3 -1 1)
    do
    if [ $(getprop persist.sys.FM_TuneState) -eq 1 ];then
    echo "parameter received: $1"
    echo "RETURN=PASS"
    FM_TUNE="OK"
    break
    #else
    #echo "wait..."
    fi
    sleep 1
    done
    if [ $FM_TUNE = "FAIL" ];then
    echo "parameter received: $1"
    echo "RETURN=FAIL"
    #echo "feature $0 not implemented"
    fi
}

###################################################################
# Function:    FM_GETRSSI                                         #
# Description: This function should return the FM RSSI            #
# Note:        The RSSI should be updated periodically or on      #
#              every call of function FM_GETRSSI                  #
# Inputs:      N/A                                                #
# Output:      OK,[FM rssi]/FAIL                                 #
###################################################################
function FM_GETRSSI
{
    # insert your code below
    am broadcast -a com.ape.factory.FM_GETRSSI
    sleep 1
    FM_GETRSSI="FAIL"
    for i in $(seq 15 -1 1)
    do
    if [ $(getprop persist.sys.RSSI_VALUE) -ne 0 ];then
    echo "RETURN=PASS,[$(getprop persist.sys.RSSI_VALUE)]"
    FM_GETRSSI="OK"
    break
    #else
    #echo "wait..."
    fi
    sleep 1
    done
    if [ $FM_GETRSSI = "FAIL" ];then
    echo "RETURN=FAIL"
    #echo "feature $0 not implemented"
    fi
}

###################################################################
# Function:    FM_OFF                                             #
# Description: This function should disable the FM module         #
# Note:        terminate any FM process                           #
# Inputs:      N/A                                                #
# Output:      status:     OK/FAIL                               #
###################################################################
function FM_OFF
{
    # insert your code below
    am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE FM --es CQA_TEST_FUNCTION FM_OFF
    sleep 1
    FM_OFF="FAIL"
    for i in $(seq 15 -1 1)
    do
    if [ $(getprop persist.sys.FM_STATE_OFF) -eq 1 ];then
    FM_OFF="OK"
    echo "RETURN=PASS"
    break
    #else
    #echo "wait..."
    fi
    sleep 1
    done
    if [ $FM_OFF = "FAIL" ];then
    echo "RETURN=FAIL"
    echo "feature $0 not implemented"
    fi
}

###################################################################
# Function:    FM_CHECK                                           #
# Description: This function should check FM (SOC or not.)        #
# Inputs:      N/A                                                #
# Output:      status:     OK/FAIL                               #
###################################################################
function FM_CHECK
{
    sleep 1
    FM_CHECK="FAIL"
    for i in $(seq 6 -1 1)
    do
    if [ $(getprop persist.sys.FTMFM_state) -eq 1 ];then
    echo "RETURN=PASS"
    FM_CHECK="OK"
    break
    #else
    #echo "wait..."
    fi
    sleep 1
    done
    if [ $FM_CHECK = "FAIL" ];then
    echo "RETURN=FAIL"
    fi
}

function AUDIO_BYPASS_AGLO
{
    AudioSetParam SET_BypassProcess=1
    sleep 0.2
    echo "7E000C0100000000CRRC"
}

function AUDIO_BYPASS_CLOSE
{
    AudioSetParam SET_BypassProcess=0
    sleep 0.2
    echo "7E000C0100000001CRRC"
}

####################################################################
# Function:    AIRPLANE_MODE_ON                                    #
# Description: This function is used to turn on the airplane mode  #
# Inputs:      N/A                                                 #
# Output:      status:     OK/FAIL                                 #
####################################################################
function AIRPLANE_MODE_ON
{
  settings put global airplane_mode_on 1
  sleep 0.2
  RET=$(settings get global airplane_mode_on)
  if [ $RET -eq 1 ]; then
    echo "7E00191700000001AABB"  #PASS
  else
    echo "7E00191700000000AABB"  #FAIL
  fi
}

####################################################################
# Function:    AIRPLANE_MODE_OFF                                   #
# Description: This function is used to turn off the airplane mode #
# Inputs:      N/A                                                 #
# Output:      status:     OK/FAIL                                 #
####################################################################
function AIRPLANE_MODE_OFF
{
  settings put global airplane_mode_on 0
  sleep 0.2
  RET=$(settings get global airplane_mode_on)
    if [ $RET -eq 0 ]; then
      echo "7E00191800000001AABB"  #PASS
    else
      echo "7E00191800000000AABB"  #FAIL
    fi
}

###########################################################################
# Function:    WRITE_MFG_DATE                                             #
# Description: This function is used to write the battery production date #
# Inputs:      N/A                                                        #
# Output:      status:     OK/FAIL                                        #
###########################################################################
function WRITE_MFG_DATE
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ]; then
      input keyevent 26
      sleep 0.5
  fi

  cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE TEST_FLAG_OP --es CQA_TEST_FUNCTION SETMFGDATA --es CQA_TEST_PARAMS $1))

  sleep 1
  UTAG_SET_MFG_DATE="FAIL"
  for i in $(seq 6 -1 1)
  do
  if [ $(getprop persist.sys.SETMFGDATA) -eq 1 ];then
  echo "7E0006300200000000329ACRRC"
  UTAG_SET_MFG_DATE="OK"
  break
  #else
  #echo "wait..."
  fi
  sleep 1
  done
  if [ $UTAG_SET_MFG_DATE = "FAIL" ];then
  echo "7E00063002000000000001CRRC"
  #echo "feature $0 not implemented"
  fi
}

###########################################################################
# Function:    READ_MFG_DATE                                              #
# Description: This function is used to read the battery production date  #
# Inputs:      N/A                                                        #
# Output:      status:     OK/FAIL                                        #
###########################################################################
function READ_MFG_DATE
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ]; then
      input keyevent 26
      sleep 0.5
  fi

  cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE TEST_FLAG_OP --es CQA_TEST_FUNCTION READMFGDATA))

  sleep 1
  UTAG_GET_MFG_DATE="FAIL"
  for i in $(seq 6 -1 1)
  do
  if [ $(getprop persist.sys.READMFGDATA) = "" ];then
  #echo "wait..."
  UTAG_GET_MFG_DATE="FAIL"
  else
  DATE=$(getprop persist.sys.READMFGDATA)
  #echo "7E0006300300000000"$DATE"CRRC"
  echo $DATE
  UTAG_GET_MFG_DATE="OK"
  break
  #else
  #echo "wait..."
  fi
  sleep 1
  done
  if [ $UTAG_GET_MFG_DATE = "FAIL" ];then
  echo "7E0006300300000001CRRC"
  #echo "feature $0 not implemented"
  fi
}

###########################################################################
# Function:    WRITE_FIRST_USAGE_DATE                                     #
# Description: This function is used to write the battery first usgae date#
# Inputs:      N/A                                                        #
# Output:      status:     OK/FAIL                                        #
###########################################################################
function WRITE_FIRST_USAGE_DATE
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ]; then
      input keyevent 26
      sleep 0.5
  fi

  cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE TEST_FLAG_OP --es CQA_TEST_FUNCTION SETFIRSTUSAGEDATA --es CQA_TEST_PARAMS $1))

  sleep 1
  UTAG_SET_FIRST_DATE_USGAE="FAIL"
  for i in $(seq 6 -1 1)
  do
  if [ $(getprop persist.sys.SETFIRSTUSAGEDATA) -eq 1 ];then
  echo "7E0006300200000000331ACRRC"
  UTAG_SET_FIRST_DATE_USGAE="OK"
  break
  #else
  #echo "wait..."
  fi
  sleep 1
  done
  if [ $UTAG_SET_FIRST_DATE_USGAE = "FAIL" ];then
  echo "7E00063002000000000001CRRC"
  #echo "feature $0 not implemented"
  fi
}

###########################################################################
# Function:    READ_FIRST_USAGE_DATE                                      #
# Description: This function is used to read the battery first usgae dat  #
# Inputs:      N/A                                                        #
# Output:      status:     OK/FAIL                                        #
###########################################################################
function READ_FIRST_USAGE_DATE
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ]; then
      input keyevent 26
      sleep 0.5
  fi

  cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE TEST_FLAG_OP --es CQA_TEST_FUNCTION READFIRSTUSAGEDATA))

  sleep 1
  UTAG_GET_MFG_DATE="FAIL"
  for i in $(seq 6 -1 1)
  do
  if [ $(getprop persist.sys.READFIRSTUSAGEDATA) = "" ];then
  #echo "wait..."
  UTAG_GET_FIRST_DATE_USAGE="FAIL"
  else
  DATE=$(getprop persist.sys.READFIRSTUSAGEDATA)
  #echo "7E0006300310000000"$DATE"CRRC"
  echo $DATE
  UTAG_GET_FIRST_DATE_USAGE="OK"
  break
  #else
  #echo "wait..."
  fi
  sleep 1
  done
  if [ $UTAG_GET_FIRST_DATE_USAGE = "FAIL" ];then
  echo "7E0006300310000001CRRC"
  #echo "feature $0 not implemented"
  fi
}

##############################################################################
# Function:    WRITE_FIRST_USAGE_DATE_FLAG                                   #
# Description: This function is used to write the user's first use date mark #
# Inputs:      N/A                                                           #
# Output:      status:     OK/FAIL                                           #
##############################################################################
function WRITE_FIRST_USAGE_DATE_FLAG
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ]; then
      input keyevent 26
      sleep 0.5
  fi

  cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE TEST_FLAG_OP --es CQA_TEST_FUNCTION SETFIRSTDATEFLAG --es CQA_TEST_PARAMS $1))

  sleep 1
  WRITE_FIRST_DATE_FLAG="FAIL"
  for i in $(seq 6 -1 1)
  do
    if [ $(getprop persist.sys.WRITE_FIRST_DATE_FLAG) -eq 1 ]; then
      echo "7E0006310200000000301ACRRC"
      WRITE_FIRST_DATE_FLAG="OK"
      break
    fi
    sleep 1
  done
  if [ $WRITE_FIRST_DATE_FLAG = "FAIL" ]; then
    echo "7E00063102000000000001CRRC"
  fi
}

##############################################################################
# Function:    READ_FIRST_USAGE_DATE_FLAG                                   #
# Description: This function is used to read the user's first use date mark  #
# Inputs:      N/A                                                           #
# Output:      status:     OK/FAIL                                           #
##############################################################################
function READ_FIRST_USAGE_DATE_FLAG
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ]; then
      input keyevent 26
      sleep 0.5
  fi

  cqatest=$(echo $(am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE TEST_FLAG_OP --es CQA_TEST_FUNCTION READFIRSTDATEFLAG))

  sleep 1
  UTAG_GET_FIRST_DATE_FLAG="FAIL"
  for i in $(seq 6 -1 1)
  do
  if [ $(getprop persist.sys.READ_FIRST_DATE_FLAG) = "" ];then
  #echo "wait..."
  UTAG_GET_FIRST_DATE_FLAG="FAIL"
  else
  FLAG=$(getprop persist.sys.READ_FIRST_DATE_FLAG)
  echo "7E000631030000320"$FLAG"AABB"
  UTAG_GET_FIRST_DATE_FLAG="OK"
  break
  #else
  #echo "wait..."
  fi
  sleep 1
  done
  if [ $UTAG_GET_FIRST_DATE_FLAG = "FAIL" ];then
  echo "7E0006310300000001CRRC"
  #echo "feature $0 not implemented"
  fi
}

function SMALL_PLATE_DETECTION
{

  log_path="small_plate_detection.log"
  log_info "$log_path" "SKU info = $(getprop ro.boot.hardware.sku)"
  RET=$(grep -w '^mtktsusb$' sys/class/thermal/thermal_zone*/type -rnIs)
  log_info "$log_path" "plate_detection content = $RET"
  # echo "grep result: $RET"

  # Extracting hot zone numbers using awk
  ZONE_NUMBER=$(echo "$RET" | awk -F'thermal_zone' '{print $2}' | awk -F'/' '{print $1}')

  if [ -z "$ZONE_NUMBER" ]; then
    log_info "$log_path" "Failed to extract zone number from grep result."
    echo "7E0006310312000001AABB"
  fi

  #echo "Extracted zone number: $ZONE_NUMBER"

  # Constructing the temperature node path
  TEMP_NODE="sys/class/thermal/thermal_zone${ZONE_NUMBER}/temp"

  if [ -f "$TEMP_NODE" ]; then
    path_result=$(cat "$TEMP_NODE")
    log_info "$log_path" "Temperature node path = $TEMP_NODE, Temperature = $path_result"
    #echo "Temperature at $TEMP_NODE: $path_result"
    if [ $path_result -gt 20000 ] && [ $path_result -lt 60000 ]; then
      echo "7E0006310312000000AABB"
    else
      echo "7E0006310312000001AABB"
    fi
  else
    log_info "$log_path" "Temperature node file does not exist: $TEMP_NODE"
    echo "7E0006310312000001AABB"
  fi
}

function GET_CAMERA_PN
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ "$RET" -eq 0 ]; then
      input keyevent 26
      sleep 0.5
  fi
  camera_path="data/vendor/camera_dump/MotoCamPN.bin"
  if [ -f $camera_path ]; then
    camera_pn_result=$(cat $camera_path)
    log_info "camera_pn.log" "camera_path = $camera_path, camera_pn_result= $camera_pn_result"
    echo $camera_pn_result
  else
    log_info "camera_pn.log" "camera_path the node path does not exist"
    echo "7E0006310401000001AABB"
  fi
}

function MOTO_CAMERA_8S_CODE
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ "$RET" -eq 0 ]; then
    input keyevent 26
    sleep 0.5
  fi

  moto8SCode_path="/data/vendor/camera_dump/Moto8SCode.bin"

  if [ -f "$moto8SCode_path" ]; then
    moto8SCode_result=$(cat "$moto8SCode_path")
    log_info "moto8SCode.log" "moto8SCode_path = $moto8SCode_path, moto8SCode_result = $moto8SCode_result"
    echo "$moto8SCode_result"
  else
    log_info "moto8SCode.log" "moto8SCode_path the node path does not exist"
    echo "7E0006310402000001AABB"
  fi
}

####################################################################
# Function:    READ_FTM_FLAG                                       #
# Description: Get some flags from Tinno production in FtmApp      #
# Inputs:      N/A                                                 #
# parameter:   FinalTest/CaliTest/CouplingT/AudioTest/CameraTes    #
# parameter:   GoogleKey/FtmAppTes/PATTest/PCBATest/SubPCBATe      #
# parameter:   RuninTest/MMITest/FPCTest                           #
# Output:      status:     PASS/FAIL/NA                            #
####################################################################
function READ_FTM_FLAG
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ "$RET" -eq 0 ]; then
      input keyevent 26
      sleep 0.5
  fi

  finaltest=$(getprop persist.sys.FinalTest)
  calitest=$(getprop persist.sys.CaliTest)
  copltest=$(getprop persist.sys.CouplingTest)
  audiotest=$(getprop persist.sys.AudioTest)
  cameratest=$(getprop persist.sys.CameraTest)
  googlekey=$(getprop persist.sys.GoogleKey)
  ftmapptest=$(getprop persist.sys.FtmAppTest)
  pattest=$(getprop persist.sys.PATTest)
  pcbatest=$(getprop persist.sys.PCBATest)
  subpcbatest=$(getprop persist.sys.SubPCBATest)
  runintest=$(getprop persist.sys.RuninTest)
  mmitest=$(getprop persist.sys.MMITest)
  fpctest=$(getprop persist.sys.FPCTest)

  pass="PASS"
  fail="FAIL"
  na="NA"

  am start -n com.ape.factory/.CQAtest.CQAActivity -S --es CQA_TEST_MODE TEST_FLAG_OP --es CQA_TEST_FUNCTION READFTMFLAG --es CQA_TEST_PARAMS $1 &>/dev/null
  sleep 0.5
  log_info "ftm_flag.log" "start read ftm flag = $1"

  # Retry logic
  attempt=0
  max_attempts=3
  while [ "$attempt" -lt "$max_attempts" ]; do
    if [ "$1" == "FinalTest" ]; then
      finaltest=$(getprop persist.sys.FinalTest)
      if [ "$finaltest" -eq 1 ]; then
        echo $pass
        return
      elif [ "$finaltest" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    if [ "$1" == "CaliTest" ]; then
      calitest=$(getprop persist.sys.CaliTest)
      if [ "$calitest" -eq 1 ]; then
        echo $pass
        return
      elif [ "$calitest" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    if [ "$1" == "CouplingTest" ]; then
      copltest=$(getprop persist.sys.CouplingTest)
      if [ "$copltest" -eq 1 ]; then
        echo $pass
        return
      elif [ "$copltest" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    if [ "$1" == "AudioTest" ]; then
      audiotest=$(getprop persist.sys.AudioTest)
      if [ "$audiotest" -eq 1 ]; then
        echo $pass
        return
      elif [ "$audiotest" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    if [ "$1" == "CameraTest" ]; then
      cameratest=$(getprop persist.sys.CameraTest)
      if [ "$cameratest" -eq 1 ]; then
        echo $pass
        return
      elif [ "$cameratest" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    if [ "$1" == "GoogleKey" ]; then
      googlekey=$(getprop persist.sys.GoogleKey)
      if [ "$googlekey" -eq 1 ]; then
        echo $pass
        return
      elif [ "$googlekey" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    if [ "$1" == "FtmAppTest" ]; then
      ftmapptest=$(getprop persist.sys.FtmAppTest)
      if [ "$ftmapptest" -eq 1 ]; then
        echo $pass
        return
      elif [ "$ftmapptest" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    if [ "$1" == "PATTest" ]; then
      pattest=$(getprop persist.sys.PATTest)
      log_info "ftm_flag.log" "PATTest flag result = $pattest"
      if [ "$pattest" -eq 1 ]; then
        echo $pass
        return
      elif [ "$pattest" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    if [ "$1" == "PCBATest" ]; then
      pcbatest=$(getprop persist.sys.PCBATest)
      if [ "$pcbatest" -eq 1 ]; then
        echo $pass
        return
      elif [ "$pcbatest" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    if [ "$1" == "SubPCBATest" ]; then
      subpcbatest=$(getprop persist.sys.SubPCBATest)
      if [ "$subpcbatest" -eq 1 ]; then
        echo $pass
        return
      elif [ "$subpcbatest" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    if [ "$1" == "RuninTest" ]; then
      runintest=$(getprop persist.sys.RuninTest)
      if [ "$runintest" -eq 1 ]; then
        echo $pass
        return
      elif [ "$runintest" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    if [ "$1" == "MMITest" ]; then
      mmitest=$(getprop persist.sys.MMITest)
      if [ "$mmitest" -eq 1 ]; then
        echo $pass
        return
      elif [ "$mmitest" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    if [ "$1" == "FPCTest" ]; then
      fpctest=$(getprop persist.sys.FPCTest)
      if [ "$fpctest" -eq 1 ]; then
        echo $pass
        return
      elif [ "$fpctest" -eq 2 ]; then
        echo $fail
        return
      fi
    fi

    # If the first attempt fails, try again
    attempt=$((attempt + 1))
    sleep 0.3
  done

  # If all retries fail, return NA
  echo $na
}

####################################################################
# Function:    GET_FAST_CHARGE_CUR                                 #
# Description: Get the current charging test current result        #
# Inputs:      N/A                                                 #
# parameter:   N/A                                                 #
# Output:      Current value/FAIL                                  #
####################################################################
function GET_FAST_CHARGE_CUR
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ]; then
    input keyevent 26
    sleep 0.5
  fi

  multiplier=1000

  file="/mnt/persist/misc/FTM_APP/BatI.log"
  if [ ! -f "$file" ]; then
    log_info "battery_walt.log" "$file does not exist"
    echo "7E0009201900000001AABB"
  elif [ ! -s "$file" ]; then
    log_info "battery_walt.log" "$file is empty"
    echo "7E0009201900000001AABB"
  else
    result=$(cat $file)
    log_info "battery_walt.log" "$file value is: $result"
    #Multiply the result by MULTIPLIER (1000) and convert to an integer
    multiplied_result=$(awk -v val="$result" -v mul="$multiplier" 'BEGIN { printf "%.0f", val * mul }')
    hex=$(printf "%08x" "$multiplied_result")
    log_info "battery_walt.log" "$file conversion value => $multiplied_result, The hexadecimal number is => $hex"
    echo "7E0009201900000000${hex}CRRC"
    #echo $result
  fi
}

####################################################################
# Function:    GET_FAST_CHARGE_VOL                                 #
# Description: Get the current charging test voltage result        #
# Inputs:      N/A                                                 #
# parameter:   N/A                                                 #
# Output:      Voltage value/FAIL                                  #
####################################################################
function GET_FAST_CHARGE_VOL
{
  RET=$(cat /sys/class/leds/lcd-backlight/brightness)
  if [ $RET -eq 0 ]; then
    input keyevent 26
    sleep 0.5
  fi

  multiplier=1000

  file="/mnt/persist/misc/FTM_APP/BatU.log"
  if [ ! -f "$file" ]; then
    log_info "battery_walt.log" "$file does not exist"
    echo "7E0009202100000001AABB"
  elif [ ! -s "$file" ]; then
    log_info "battery_walt.log" "$file is empty"
    echo "7E0009202100000001AABB"
  else
    result=$(cat $file)
    log_info "battery_walt.log" "$file value is: $result"
    #Multiply the result by MULTIPLIER (1000) and convert to an integer
    multiplied_result=$(awk -v val="$result" -v mul="$multiplier" 'BEGIN { printf "%.0f", val * mul }')
    hex=$(printf "%08x" "$multiplied_result")
    log_info "battery_walt.log" "$file conversion value => $multiplied_result, The hexadecimal number is => $hex"
    echo "7E0009202100000000${hex}CRRC"
    #echo $result
  fi
}

# Create a log information method to store logs in the specified directory
function log_info
{
    local pathfile="$1"
    local message="$2"
    path="/data/debuglogger/CQA_command/$pathfile"

    # Make sure the directory exists
    local dirpath=$(dirname "$path")
    if [ ! -d "$dirpath" ]; then
        mkdir -p "$dirpath"  # Create a directory and its parent directory
    fi

    # Make sure the log file exists
    if [ ! -f "$path" ]; then
        touch "$path"
    fi

    # Recording log information
    echo "[$(date +'%Y-%m-%d %H:%M:%S.%6N')] [INFO] $message" >> "$path"
}

##### Other - END #####

##### Main #####
#echo
#echo "CQA Commands - Version $version"
#echo
#echo "Command executed - \"$0 $@\""
#echo
eval $@
