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

include 'info_print_info.sh'
include 'info_about_os.sh'
include 'info_about_hardware.sh'
include 'info_about_network.sh'






##==============================================================================
##	ONE LINERS
##==============================================================================

printInfoOS()           { printInfoLine "OS" "$(getNameOS)" ; }
printInfoKernel()       { printInfoLine "Kernel" "$(getNameKernel)" ; }
printInfoShell()        { printInfoLine "Shell" "$(getNameShell)" ; }
printInfoDate()         { printInfoLine "Date" "$(getDate)" ; }
printInfoUptime()       { printInfoLine "Uptime" "$(getUptime)" ; }
printInfoUser()         { printInfoLine "User" "$(getUserHost)" ; }
printInfoNumLoggedIn()  { printInfoLine "Logged in" "$(getNumberLoggedInUsers)" ; }
printInfoNameLoggedIn() { printInfoLine "Logged in" "$(getNameLoggedInUsers)" ; }

printInfoCPU()          { printInfoLine "CPU" "$(getNameCPU)" ; }
printInfoCPULoad()      { printInfoLine "Sys load" "$(getCPULoad)" ; }

printInfoLocalIPv4()    { printInfoLine "Local IPv4" "$(getLocalIPv4)" ; }
printInfoExternalIPv4() { printInfoLine "External IPv4" "$(getExternalIPv4)" ; }

printInfoSpacer()       { printInfoLine "" "" ; }







##==============================================================================
##
##==============================================================================

printInfoGPU()
{
  local gpu=$(system_profiler SPDisplaysDataType |\
              head -n 3 |\
              tail -n 1 |\
              sed 's/^ *//g;
                   s/://;'
             )
  printInfoLine "GPU" "$gpu"
}






##==============================================================================
##
##==============================================================================

##------------------------------------------------------------------------------
##
printInfoSystemctl()
{
  local number_of_services=$(launchctl list | tail -n+2 | wc -l)
  local successful_services=$(launchctl list | tail -n+2 | grep '^.*\s0\s' | wc -l)
  local systcl_num_failed=$((number_of_services - successful_services))
  if   [ "$systcl_num_failed" -eq "0" ]; then
    local sysctl="All services OK"
    local state="nominal"
  elif [ "$systcl_num_failed" -eq "1" ]; then
    local sysctl="1 service failed!"
    local state="error"
  else
    local sysctl="$systcl_num_failed services failed!"
    local state="error"
  fi
	printInfoLine "Services" "$sysctl" "$state"
}



##------------------------------------------------------------------------------
##
printInfoColorpaletteSmall()
{
	local char="▀▀"

	local palette=$(printf '%s'\
	"$(formatText "$char" -c black -b dark-gray)"\
	"$(formatText "$char" -c red -b light-red)"\
	"$(formatText "$char" -c green -b light-green)"\
	"$(formatText "$char" -c yellow -b light-yellow)"\
	"$(formatText "$char" -c blue -b light-blue)"\
	"$(formatText "$char" -c magenta -b light-magenta)"\
	"$(formatText "$char" -c cyan -b light-cyan)"\
	"$(formatText "$char" -c light-gray -b white)")

	printInfoLine "Color palette" "$palette"
}



##------------------------------------------------------------------------------
##
printInfoColorpaletteFancy()
{
	## Line 1:	▄▄█ ▄▄█ ▄▄█ ▄▄█ ▄▄█ ▄▄█ ▄▄█ ▄▄█
	## Line 2:	██▀ ██▀ ██▀ ██▀ ██▀ ██▀ ██▀ ██▀

	local palette_top=$(printf '%s'\
		"$(formatText "▄" -c dark-gray)$(formatText "▄" -c dark-gray -b black)$(formatText "█" -c black) "\
		"$(formatText "▄" -c light-red)$(formatText "▄" -c light-red -b red)$(formatText "█" -c red) "\
		"$(formatText "▄" -c light-green)$(formatText "▄" -c light-green -b green)$(formatText "█" -c green) "\
		"$(formatText "▄" -c light-yellow)$(formatText "▄" -c light-yellow -b yellow)$(formatText "█" -c yellow) "\
		"$(formatText "▄" -c light-blue)$(formatText "▄" -c light-blue -b blue)$(formatText "█" -c blue) "\
		"$(formatText "▄" -c light-magenta)$(formatText "▄" -c light-magenta -b magenta)$(formatText "█" -c magenta) "\
		"$(formatText "▄" -c light-cyan)$(formatText "▄" -c light-cyan -b cyan)$(formatText "█" -c cyan) "\
		"$(formatText "▄" -c white)$(formatText "▄" -c white -b light-gray)$(formatText "█" -c light-gray) ")

	local palette_bot=$(printf '%s'\
		"$(formatText "██" -c dark-gray)$(formatText "▀" -c black) "\
		"$(formatText "██" -c light-red)$(formatText "▀" -c red) "\
		"$(formatText "██" -c light-green)$(formatText "▀" -c green) "\
		"$(formatText "██" -c light-yellow)$(formatText "▀" -c yellow) "\
		"$(formatText "██" -c light-blue)$(formatText "▀" -c blue) "\
		"$(formatText "██" -c light-magenta)$(formatText "▀" -c magenta) "\
		"$(formatText "██" -c light-cyan)$(formatText "▀" -c cyan) "\
		"$(formatText "██" -c white)$(formatText "▀" -c light-gray) ")

	printInfoLine "" "$palette_top"
	printInfoLine "Color palette" "$palette_bot"
}



##------------------------------------------------------------------------------
##
printInfoCPUTemp()
{
	if ( which sensors > /dev/null 2>&1 && sensors > /dev/null 2>&1); then

		## GET VALUES
		local temp_line=$(sensors 2>/dev/null |\
		                  grep Core |\
		                  head -n 1 |\
		                  sed 's/^.*:[ \t]*//g;s/[\(\),]//g')
		local units=$(echo $temp_line |\
		              sed -n 's/.*\( [[CF]]*\).*/\1/p' |\
		              sed 's/\ /°/g')
		local current=$(echo $temp_line |\
		                sed -n 's/^.*+\(.*\) [[CF]]*[ \t]*h.*/\1/p')
		local high=$(echo $temp_line |\
		             sed -n 's/^.*high = +\(.*\) [[CF]]*[ \t]*c.*/\1/p')
		local max=$(echo $temp_line |\
		            sed -n 's/^.*crit = +\(.*\) [[CF]]*[ \t]*.*/\1/p')


		## DETERMINE STATE
		## Use bc because we might be dealing with decimals
		if   (( $(echo "$current < $high" | bc -l) )); then
			local state="nominal"
		elif (( $(echo "$current < $max" | bc -l) )); then
			local state="critical";
		else
			local state="error";
		fi


		## PRINT MESSAGE
		local temp="$current$units"
		printInfoLine "CPU temp" "$temp" "$state"
	else
		printInfoLine "CPU temp" "lm-sensors not installed"
	fi


}



printResourceMonitor()
{
	local label=$1
	local value=$2
	local max=$3
	local units=$4
	local format=$5
	local crit_percent=$6
	local error_percent=${7:-99}


	## CHECK STATE
	local percent=$('bc' <<< "$value*100/$max")
	local percent=${percent/.*}
	local state="nominal"
	if   [ $percent -gt $error_percent ]; then
		local state="error"
	elif [ $percent -gt $crit_percent ]; then
		local state="critical"
	fi


	printInfoMonitor "$label" "$current_value" "$max" "$units" "$format" "$state"
}




##------------------------------------------------------------------------------
##
printMonitorCPU()
{
	assert_is_set $bar_cpu_crit_percent
	local format=$1
	local label="Sys load avg"
	local units=""
  # get idle cpu %
  # subtract from 100 to find usage
  local current_value=$(
    top -l 1 -s 0 | \
     grep -E "^CPU" | \
     grep -Eo '\d\d\.\d\d%\sidle' | \
     grep -Eo '\d\d\.\d\d' | \
     awk '{s+=$1} END {print ((100-s)/100)}'
  )
	local max=1
	local crit_percent=$bar_cpu_crit_percent
	printResourceMonitor "$label" "$current_value" "$max" "$units" "$format" "$crit_percent"
}



##------------------------------------------------------------------------------
##
printMonitorRAM()
{
	assert_is_set $bar_ram_units
	assert_is_set $bar_ram_crit_percent
	local format=$1
	local label="Memory"
	case "$bar_ram_units" in
		"MB")		local units="MB"; local units_divisor=1048576 ;;
		"TB")		local units="TB"; local units_divisor=1000000164000;;
		"PB")		local units="PB"; local units_divisor=1000000164000000 ;;
		*)		local units="GB"; local units_divisor=1073742000 ;;
	esac
  local max_mem=$(sysctl hw.memsize | awk '{printf $2}')

  # Activity Monitor metrics mapped to vm_stat categories
  # Memory used = app memory + wired memory + compressed
  # app memory = Anonymous
  # wired memory = wired
  # compressed = occupied by compressor
  # cached = File-backed
  local used_mem=$(vm_stat | \
    grep -E "(wired|Anonymous|occupied by compressor)" | \
    sed 's/.*://g;s/\.//g' | \
    awk -v p=$(pagesize) '{pages += $1} END {print (pages*p)}'
  )
  local max=$((max_mem / units_divisor))
  local current_value=$((used_mem / units_divisor))
	local crit_percent=$bar_ram_crit_percent
  printResourceMonitor "$label" "$current_value" "$max" "$units" "$format" "$crit_percent"
}


##------------------------------------------------------------------------------
##
printMonitorSwap()
{
	assert_is_set $bar_swap_units
	assert_is_set $bar_swap_crit_percent

	local format=$1
	local label="Swap"

	case "$bar_swap_units" in
		"MB")		local units="MB"; local option="--mega" ;;
		"TB")		local units="TB"; local option="--tera" ;;
		"PB")		local units="PB"; local option="--peta" ;;
		*)		local units="GB"; local option="--giga" ;;
	esac

	## CHECK IF SYSTEM HAS SWAP
	## Count number of lines in /proc/swaps, excluding the header (-1)
	## This is not fool-proof, but if num_swap_devs>=1, there should be swap
	local num_swap_devs=$(($(wc -l /proc/swaps | awk '{print $1;}') -1))

	if [ "$num_swap_devs" -lt 1 ]; then
		printInfoLine "$label" "N/A"

	else
		local swap_info=$('free' "$option" | tail -n 1)
		local current_value=$(echo "$swap_info" | awk '{SWAP=($3)} END {printf SWAP}')
		local max=$(echo "$swap_info" | awk '{SWAP=($2)} END {printf SWAP}')
		local crit_percent=$bar_swap_crit_percent

		printResourceMonitor "$label" "$current_value" "$max" "$units" "$format" "$crit_percent"
	fi
}


##------------------------------------------------------------------------------
##
printStorageMonitor()
{
	local label=$1
	local device=$2
	local units=$3
	local format=$4
	local crit_percent=$5
	local error_percent=${6:-99}
	case "$units" in
		"MB")		local units="MB"; local option="m" ;;
		*)		local units="GB"; local option="g" ;;
	esac
  local max=$(df "-${option}" "${device}"  | awk '{max=($2)} END {printf max}')
  local current_value=$(df "-${option}" "${device}"  | awk '{current=($4)} END {printf current}')
	printResourceMonitor "$label" "$current_value" "$max" "$units" "$format" "$crit_percent" "$error_percent"
}

##------------------------------------------------------------------------------
##
printMonitorHDD()
{
	assert_is_set $bar_hdd_units
	assert_is_set $bar_hdd_crit_percent
	local format=$1
	local label="Storage /"
	local device="/"
	local units=$bar_hdd_units
	local crit_percent=$bar_hdd_crit_percent
	printStorageMonitor "$label" "$device" "$units" "$format" "$crit_percent"
}



##------------------------------------------------------------------------------
##
printMonitorHome()
{
	assert_is_set $bar_home_units
	assert_is_set $bar_home_crit_percent

	local format=$1
	local label="Storage /home"
	local device=$HOME
	local units=$bar_home_units
	local crit_percent=$bar_home_crit_percent

	printStorageMonitor "$label" "$device" "$units" "$format" "$crit_percent"
}



##------------------------------------------------------------------------------
##
printMonitorCPUTemp()
{
	if ( which sensors > /dev/null 2>&1 ); then

		## GET VALUES
		local temp_line=$(sensors |\
		                  grep Core |\
		                  head -n 1 |\
		                  sed 's/^.*:[ \t]*//g;s/[\(\),]//g')
		local units=$(echo $temp_line |\
		              sed -n 's/.*\(°[[CF]]*\).*/\1/p' )
		local current=$(echo $temp_line |\
		                sed -n 's/^.*+\(.*\)°[[CF]]*[ \t]*h.*/\1/p' )
		local high=$(echo $temp_line |\
		            sed -n 's/^.*high = +\(.*\)°[[CF]]*[ \t]*c.*/\1/p' )
		local max=$(echo $temp_line |\
		              sed -n 's/^.*crit = +\(.*\)°[[CF]]*[ \t]*.*/\1/p' )
		local crit_percent=$(bc <<< "$high*100/$max")


		## PRINT MONITOR
		printResourceMonitor $current $max $crit_percent \
	        	     false $units "CPU temp"
	else
		printInfoLine "CPU temp" "lm-sensors not installed"
	fi
}
