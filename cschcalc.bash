#!/bin/bash

#set -x
############################################################
#
# Author:       Àngel Ollé Blázquez
# Description: sar (sysstat) wrapper that shows theorical 
# percentage of clock cycles wasted on context switching.
#
# History:
#    01/01/2017 - v1.0.0 - initial version
#
############################################################
# Usage:
# ./cschcalc.bash <sar file>
# Example:
# ./cschcalc.bash /var/log/sa/sa30
############################################################
# TODO: 
# cpu fq. units => MHz
# different cpu's (cpuinfo)
# best error handling
# performance and general improvements
############################################################
# Notes:
# - Use of CPU model name to avoid possible mistakes with cpu MHz 
# reported by cpuinfo caused by SpeedStep/PowerNow!/Cooln'Quiet or similar.
# - requires sysstat
# - tested on RHEL 6/7, CentOS 7
############################################################


# global
ERRSTD=1
ERRFILE=2

die(){
    echo -e "${1}" >&2 
    exit "${2}"
}

usage(){
    die "${1}Usage: ./$(basename "${0}") <sar file>" ${ERRSTD}
}

calc(){
    COST=80000
    NPROC="$(nproc)"
    FREQ="$(grep -m 1 'model name' /proc/cpuinfo | sed 's/.*@\ \([0-9\.]\+\)GHz$/\1/;s/\.//;s/$/0000000/')"
    CSW="${1##*\ }"
    echo "$(awk -v f="${FREQ}" -v n="${NPROC}" -v c="${COST}" -v s="${CSW}" 'BEGIN {print (((s/n)*c)/f)*100}')%"    
}

[[ "${#}" -eq 1 ]] || usage "Error: provided ${#} arguments, only 1 argument required\n"
[[ -f "${1}" ]] || die "File ${1} not found." ${ERRFILE}
[[ ! $(sar -f "${1}" &> /dev/null) ]] || die "Invalid sar file" ${ERRFILE}

{
    while read line; do
        if [[ "${line}" =~ (^[0-9:]+\ (AM|PM)[\ ]+[0-9.\ ]+$) ]]; then
            echo "${line}   $(calc "${line}")"
        elif [[ "$line" =~ "cswch/s" ]]; then
            echo "${line}   %wastedcswch"
        else
            echo "${line}"
        fi
    done  
} < <(sar -w -f ${1})


