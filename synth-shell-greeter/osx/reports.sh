#!/bin/bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2019-2020, Andres Gongora <mail@andresgongora.com>.     |
##  |                                                                       |
##  | This program is free software: you can redistribute it and/or modify  |
##  | it under the terms of the GNU General Public License as published by  |
##  | the Free Software Foundation, either version 3 of the License, or     |
##  | (at your option) any later version.                                   |
##  |                                                                       |
##  | This program is distributed in the hope that it will be useful,       |
##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##  | GNU General Public License for more details.                          |
##  |                                                                       |
##  | You should have received a copy of the GNU General Public License     |
##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##  |                                                                       |
##  +-----------------------------------------------------------------------+


##
##	DESCRIPTION:
##
##
##



##==============================================================================
##	EXTERNAL DEPENDENCIES
##==============================================================================
[ "$(type -t include)" != 'function' ]&&{ include(){ { [ -z "$_IR" ]&&_IR="$PWD"&&cd "$(dirname "${BASH_SOURCE[0]}")"&&include "$1"&&cd "$_IR"&&unset _IR;}||{ local d="$PWD"&&cd "$(dirname "$PWD/$1")"&&. "$(basename "$1")"&&cd "$d";}||{ echo "Include failed $PWD->$1"&&exit 1;};};}

include '../../bash-tools/bash-tools/color.sh'
include '../../bash-tools/bash-tools/print_utils.sh'
include '../../bash-tools/bash-tools/assert.sh'






##==============================================================================
##	
##==============================================================================

##------------------------------------------------------------------------------
##
reportLastLogins()
{
	assert_is_set ${fc_highlight}
	assert_is_set ${fc_info}

	## DO NOTHING FOR NOW -> This is disabled intentionally for now.
	## Printing logins should only be done under special circumstances:
	## 1. User configurable set to always on
	## 2. If the IP/terminal is very different from usual
	## 3. Other anomalies...
	if false; then
		printf "${fc_highlight}\nLAST LOGINS:\n${fc_info}"
		last -iwa | head -n 4 | grep -v "reboot"
	fi
}



##------------------------------------------------------------------------------
##
reportSystemctl()
{
	assert_is_set ${fc_highlight}
	assert_is_set ${fc_info}
	assert_is_set ${fc_crit}
	assert_is_set ${fc_none}
    ## 1. Get number of failed daemons
    ## 2. Report those that failed

    launchctl_num_failed=$(
      launchctl list |\
      tail -n+2 |\
      awk '{ if($2 != "0") { print $3 } }' |\
      wc -l
    )
    if [ "$launchctl_num_failed" -ne "0" ]; then
      #local failed=$(systemctl --failed | awk '/UNIT/,/^$/')
      local failed=$(
        launchctl list |\
        tail -n+2 |\
        awk '{ if($2 != "0") { print $3 } }'
      )
      printf "\n${fc_crit}SYSTEMCTL FAILED SERVICES:\n"
      printf "${fc_info}${failed}${fc_none}\n"
    fi
}



##------------------------------------------------------------------------------
##
reportHogsCPU()
{
	assert_is_set ${cpu_crit_print}
	assert_is_set ${bar_cpu_crit_percent}
	assert_is_set ${fc_highlight}
	assert_is_set ${fc_info}
	assert_is_set ${fc_crit}
	assert_is_set ${fc_none}
	export LC_NUMERIC="C"
	## EXIT IF NOT ENABLED
	if [ "$cpu_crit_print" == true ]; then
		## CHECK CPU LOAD
		#local current=$(awk '{avg_1m=($1)} END {printf "%3.2f", avg_1m}' /proc/loadavg)
    local current=$(
      top -l 1 -s 0 | \
       grep -E "^CPU" | \
       grep -Eo '\d\d\.\d\d%\sidle' | \
       grep -Eo '\d\d\.\d\d' | \
       awk '{s+=$1} END {print ((100-s)/100)}'
    )
		local max=$(nproc --all)
		local percent=$(bc <<< "$current*100/$max")
		if [ "$percent" -gt "$bar_cpu_crit_percent" ]; then
			## Escape all '%' characters
      local top=$(nice -n 1 'top' -l 1 -s 0)
			local top=$(echo "$top" | sed 's/\%/\%\%/g' )
			## EXTRACT ELEMENTS FROM TOP
			## - load:    summary of cpu time spent for user/system/nice...
			## - header:  the line just above the processes
			## - procs:   the N most demanding procs in terms of CPU time
      local cpus=$(echo "$top" | grep "^CPU" )
      local load=$(echo "${cpus:11:50}")
      local procs=$(ps aux -r |\
        awk '{print $11, $3}' |\
        head -n 4 |\
        sed "s/.*\///g" |\
        awk '{printf "%-20s %s\n", $1, $2}' |\
        sed 's/\%/\%\%/g'
      )
			## PRINT WITH FORMAT
			printf "\n${fc_crit}SYSTEM LOAD:${fc_info}  ${load}\n"
			printf "${fc_text}${procs}${fc_none}\n"
		fi
	fi
}


##------------------------------------------------------------------------------
##
reportHogsMemory()
{
	assert_is_set ${ram_crit_print}
	assert_is_set ${bar_ram_crit_percent}
	assert_is_set ${fc_highlight}
	assert_is_set ${fc_info}
	assert_is_set ${fc_crit}
	assert_is_set ${fc_none}
	## EXIT IF NOT ENABLED
	if [ "$ram_crit_print" == true ]; then
		## CHECK RAM
    local ram_is_crit=false
    local max=$(sysctl hw.memsize | awk '{printf $2}')

    # Activity Monitor metrics mapped to vm_stat categories
    # Memory used = app memory + wired memory + compressed
    # app memory = Anonymous
    # wired memory (used by os) = wired
    # compressed = occupied by compressor
    # cached = File-backed
    local current=$(vm_stat | \
      grep -E "(wired|Anonymous|occupied by compressor)" | \
      sed 's/.*://g;s/\.//g' | \
      awk -v p=$(pagesize) '{pages += $1} END {print (pages*p)}'
    )
    # 1048576 = Bytes in a MB
    local available=$(((max - current)/1048576))

		local percent=$(bc <<< "$current*100/$max")
		if [ $percent -gt $bar_ram_crit_percent ]; then
			local ram_is_crit=true
		fi

		## CHECK SWAP
    
    local swap_is_crit=false
    local max=$(sysctl vm.swapusage | sed 's/M//g' | awk '{print $4}')
    local current=$(sysctl vm.swapusage | sed 's/M//g' | awk '{print $7}')
		local percent=$(bc <<< "$current*100/$max")
		if [ $percent -gt $bar_swap_crit_percent ]; then
			local swap_is_crit=true
		fi


		## PRINT IF RAM OR SWAP ARE ABOVE THRESHOLD
    
    if $ram_is_crit || $swap_is_crit ; then
      local procs=$(ps aux -m |\
        awk '{print $2, $4, $11}' |\
        head -n 4 |\
        tail -n+2 |\
        sed 's/[[:graph:]]*\///g' |\
        sed 's/\%/\%\%/g' |\
        awk '{printf "%-10s %-5s %s\n", $1, $2, $3}'
      )
      printf "\n${fc_crit}MEMORY:\t "
      printf "${fc_info}Only ${available} MB of RAM available!!\n"
      printf "${fc_crit}PID\t   %%\t COMMAND\n"
      printf "${fc_info}${procs}${fc_none}\n"
    fi
	fi
}

