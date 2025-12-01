#!/vendor/bin/sh
#
# Copyright (c) 2013-2016, Motorola LLC  All rights reserved.
#
# The purpose of this script is to compile information about the hardware
# versions of various devices on each unit.  This is useful when searching
# through reported issues for correlations with certain hardware revisions.
# The information is collected from various locations in proc and sysfs (some
# of which are product-specific) and compiled into small, single-line text
# files in the userdata partition, one for each type of device.  The format of
# these lines are as follows:
#
# MOTHREV-vX
# hw_name=XXXXX
# vendor_id=XXXXX
# hw_rev=XXXXX
# date=XXXXX
# lot_code=XXXXX
# fw_rev=XXXXX
# size=XXXXMB
# (components may also add additional fields to the ones above)
#
# The extact format of each field will be device-specific, but should be
# consistent across a particular hardware platform. Note that each revision
# data file is rewritten every time this script is called. This ensures that
# any future format changes to the revision files are picked up.
#
# While the method used to read the information should be consistent on a given
# platform, the specific path to a device's information may vary between
# products.  The hardware_revisions.conf file provides a way to adjust those
# paths from the default.
#

export PATH=/vendor/bin:$PATH

scriptname=${0##*/}
notice()
{
    echo "$*"
    echo "$scriptname: $*" > /dev/kmsg
}

# Output destination and permissions
OUT_PATH=/data/vendor/hardware_revisions
OUT_USR=system
OUT_GRP=system
OUT_PERM=0644
OUT_PATH_PERM=0755

# Default paths to hardware information
PATH_RAM=/sys/ram
PATH_NVM=/sys/block/mmcblk0/device

# Product-specific overrides
#[ -e /vendor/etc/hardware_revisions.conf ] && . /vendor/etc/hardware_revisions.conf

#
# Clear out all revision data in this directory. If in the future we decide
# to remove a component, we want to make sure any old files are not present.
#rm /data/vendor/hardware_revisions/*

#
# Append one piece of revision data to a given file. If a value is blank,
# then nothing will be written.
#
# $1 - tag
# $2 - value
# $3 - file to write
write_one_revision_data()
{
    if [ -n "${2}" ]; then
        VALUE="${2}"
        echo "${1}=${VALUE}" >> ${3}
    fi
}

#
# Generate the common data contained for
# all hardware peripherals
#
# $1 - file to write to
# $2 - name
# $3 - vendor ID
# $4 - hardware revision
# $5 - date
# $6 - lot code
# $7 - firmware revision
create_common_revision_data()
{
    FILE="${1}"
    echo "MOTHREV-v2" > ${FILE}

    write_one_revision_data "hw_name" "${2}" ${FILE}
    write_one_revision_data "vendor_id" "${3}" ${FILE}
    write_one_revision_data "hw_rev" "${4}" ${FILE}
    write_one_revision_data "date" "${5}" ${FILE}
    write_one_revision_data "lot_code" "${6}" ${FILE}
    write_one_revision_data "fw_rev" "${7}" ${FILE}
}

create_secondary_revision_data()
{
    FILE="${1}"

    write_one_revision_data "hw_name_s" "${2}" ${FILE}
    write_one_revision_data "vendor_id_s" "${3}" ${FILE}
    write_one_revision_data "hw_rev_s" "${4}" ${FILE}
    write_one_revision_data "date_s" "${5}" ${FILE}
    write_one_revision_data "lot_code_s" "${6}" ${FILE}
    write_one_revision_data "fw_rev_s" "${7}" ${FILE}
}

create_multiple_revision_data()
{
    local primary=0
    if [ $1 -eq $primary ]
    then
        create_common_revision_data "${FILE}" "${HNAME}" "${VEND}" "${HREV}" "${DATE}" "${LOT_CODE}" "${FREV}"
    else
        create_secondary_revision_data "${FILE}" "${HNAME}" "${VEND}" "${HREV}" "${DATE}" "${LOT_CODE}" "${FREV}"
    fi
}

#
# Applies the appropriate file permissions to the
# hardware revision data file.
#
# $1 - file to write to
apply_revision_data_perms()
{
    chown ${OUT_USR}.${OUT_GRP} "${1}"
    chmod ${OUT_PERM} "${1}"
}

#mkdir -p ${OUT_PATH}
#chown ${OUT_USR}.${OUT_GRP} ${OUT_PATH}
#chmod ${OUT_PATH_PERM} ${OUT_PATH}


#
# Compile ram
#
FILE="${OUT_PATH}/ram"
HNAME=
VEND=
HREV=
DATE=
FREV=
LOT_CODE=
INFO=
SIZE=
MR5=$(getprop | awk -F'[][]' '/\[ro\.boot\.ddr5\]/ {print $4}')
MR7=$(getprop | awk -F'[][]' '/\[ro\.boot\.ddr7\]/ {print $4}')

HNAME=$(getprop ro.boot.mem | sed 's/^[^_]*_\([^_]*\)_.*$/\1/')
SIZE=$((1024 * $(getprop ro.boot.mem | sed 's/^[^_]*_[^_]*_\([^_]*\)_.*$/\1/')))
if [ ${SIZE} = "8192" ]
then
        VEND=$(getprop ro.boot.mem | sed 's/_.*$//')
else
	if [ $(getprop ro.boot.mem | sed 's/_.*$//') = "SAMSUNG" ]
	then
		VEND=$(getprop ro.boot.mem | sed 's/_.*$//')
	elif [ $(getprop ro.boot.mem | sed 's/_.*$//') = "FORESEE" ]
	then
		VEND=$(getprop ro.boot.mem | sed 's/_.*$//')
	elif [ ${MR7} = "2" ]
	then
		VEND="CXMT"
	elif [ ${MR7} = "0" ]
	then
		VEND="MICRON"
	elif [ ${MR7} = "5" ]
	then
		VEND="BIWIN"
	fi
fi
INFO="0x${MR5},0x${MR7}"
create_common_revision_data "${FILE}" "${HNAME}" "${VEND}" "" "" "" ""
write_one_revision_data "config_info" "${INFO}" "${FILE}"
write_one_revision_data "size" "${SIZE}" "${FILE}"
apply_revision_data_perms "${FILE}"


#
# Compile nvm
#
FILE="${OUT_PATH}/nvm"
HNAME=
VEND=
HREV=
DATE=
FREV=
LOT_CODE=
SIZE=
if [ -d "${PATH_NVM}" ] ; then
    HNAME=`cat ${PATH_NVM}/type`
    if [ -d "${PATH_STORAGE}" ] ; then
        VEND=$(cat ${PATH_STORAGE}/vendor | awk '{print substr($0,length($0)-1,2)}')
	SIZE=$(1024 * `cat ${PATH_STORAGE}/size | sed 's/[^0-9]//g'`)
    else
	VEND=$(cat ${PATH_NVM}/manfid | awk '{print substr($0,length($0)-1,2)}')
	if [ ${VEND} = "f4" ]
	then
		VEND="BIWIN"
    	elif [ ${VEND} = "11" ]
    	then
		VEND="TOSHIBA"
    	elif [ ${VEND} = "45" ]
    	then
        	VEND="SANDISK"
    	elif [ ${VEND} = "15" ]
    	then
        	VEND="SAMSUNG"
    	elif [ ${VEND} = "70" ]
    	then
        	VEND="KINGSTON"
    	elif [ ${VEND} = "90" ]
    	then
        	VEND="HYNIX"
    	elif [ ${VEND} = "13" ]
    	then
        	VEND="MICRON"
    	elif [ ${VEND} = "d6" ]
    	then
        	VEND="FORESEE"
    	elif [ ${VEND} = "AB" ]
    	then
        	VEND="BIWIN"
    	elif [ ${VEND} = "9b" ]
    	then
       		VEND="YMTC"
    	elif [ ${VEND} = "c4" ]
    	then
       		VEND="TWSC"
    	elif [ ${VEND} = "F4" ]
    	then
       		VEND="BIWIN"
    	elif [ ${VEND} = "D6" ]
    	then
       		VEND="FORESEE"
    	elif [ ${VEND} = "ab" ]
    	then
       		VEND="BIWIN"
    	elif [ ${VEND} = "Ab" ]
    	then
       		VEND="BIWIN"
    	elif [ ${VEND} = "aB" ]
    	then
       		VEND="BIWIN"
    	elif [ ${VEND} = "9B" ]
    	then
       		VEND="YMTC"
    	elif [ ${VEND} = "C4" ]
    	then
		VEND="TWSC"
    	else
        	VEND="NA"
    	fi

	SIZE=$((1024 * $( getprop ro.boot.mem | sed 's/.*_//')))
    fi
    HREV=`cat ${PATH_NVM}/name`
    DATE=`cat ${PATH_NVM}/date`
    if [ -e ${PATH_NVM}/device_version -a -e ${PATH_NVM}/firmware_version ] ; then
        FREV="$(cat ${PATH_NVM}/device_version),$(cat ${PATH_NVM}/firmware_version)"
    else
        FREV="$(cat ${PATH_NVM}/hwrev),$(cat ${PATH_NVM}/fwrev)"
    fi
fi
create_common_revision_data "${FILE}" "${HNAME}" "${VEND}" "${HREV}" "${DATE}" "${LOT_CODE}" "${FREV}"
write_one_revision_data "size" "${SIZE}" "${FILE}"
apply_revision_data_perms "${FILE}"


