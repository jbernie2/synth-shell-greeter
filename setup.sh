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
##	QUICK INSTALLER
##




##==============================================================================
##	FUNCTIONS
##==============================================================================


##------------------------------------------------------------------------------
##
setup()
{
	include() { source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/$1" ; }
	include 'bash-tools/bash-tools/user_io.sh'
	include 'bash-tools/bash-tools/hook_script.sh'
	include() { source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/$1" ; }
	include 'bash-tools/bash-tools/assemble_script.sh'


	## SWITCH BETWEEN AUTOMATIC AND USER INSTALLATION
	if [ "$#" -eq 0 ]; then
		local output_script="$HOME/.config/synth-shell/synth-shell-greeter.sh"
		local output_config_dir="$HOME/.config/synth-shell/"
		printInfo "Installing script as $output_script"
		local action=$(promptUser "Add hook your .bashrc file or equivalent?\n\tRequired for autostart on new terminals" "[Y]/[n]?" "yYnN" "y")
		case "$action" in
			""|y|Y )	hookScript $output_script ;;
			n|N )		;;
			*)		printError "Invalid option"; exit 1
		esac
		
	else
		local output_script="$1"
		local output_config_dir="$2"
	fi


	## DEFINE LOCAL VARIABLES
	local dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
	local input_script="$dir/synth-shell-greeter.sh"
	local input_config_dir="$dir/config/"

	local output_script_header=$(printf '%s'\
	"##!/bin/bash\n"\
	"\n"\
	"##  +-----------------------------------+-----------------------------------+\n"\
	"##  |                                                                       |\n"\
	"##  | Copyright (c) 2014-2020, Andres Gongora <mail@andresgongora.com>      |\n"\
	"##  | https://github.com/andresgongora/synth-shell-greeter                  |\n"\
	"##  | Visit the above URL for details of license and authorship.            |\n"\
	"##  |                                                                       |\n"\
	"##  | This program is free software: you can redistribute it and/or modify  |\n"\
	"##  | it under the terms of the GNU General Public License as published by  |\n"\
	"##  | the Free Software Foundation, either version 3 of the License, or     |\n"\
	"##  | (at your option) any later version.                                   |\n"\
	"##  |                                                                       |\n"\
	"##  | This program is distributed in the hope that it will be useful,       |\n"\
	"##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |\n"\
	"##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |\n"\
	"##  | GNU General Public License for more details.                          |\n"\
	"##  |                                                                       |\n"\
	"##  | You should have received a copy of the GNU General Public License     |\n"\
	"##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |\n"\
	"##  |                                                                       |\n"\
	"##  +-----------------------------------------------------------------------+\n"\
	"##\n"\
	"##\n"\
	"##  =======================\n"\
	"##  WARNING!!\n"\
	"##  DO NOT EDIT THIS FILE!!\n"\
	"##  =======================\n"\
	"##\n"\
	"##  This file was generated by an installation script.\n"\
	"##  If you edit this file, it might be overwritten without warning\n"\
	"##  and you might lose all your changes.\n"\
	"##\n"\
	"##  Visit for instructions and more information:\n"\
	"##  https://github.com/andresgongora/synth-shell/\n"\
	"##\n\n\n")


	## SETUP SCRIPT
	assembleScript "$input_script" "$output_script" "$output_script_header"


	## SETUP CONFIGURATION FILES
	[ -d "$output_config_dir" ] || mkdir -p "$output_config_dir"
	cp -ur "$input_config_dir/." "$output_config_dir/"


	## SETUP DEFAULT SYNTH-SHELL-GREETER CONFIG FILE
	local config_file="$output_config_dir/synth-shell-greeter.config"
	if [ ! -f  "$config_file" ]; then
		local distro=$(cat /etc/os-release | grep "ID=" | sed 's/ID=//g' | head -n 1)		
		case "$distro" in
			'arch' )		cp "$output_config_dir/os/synth-shell-greeter.archlinux.config" "$config_file" ;;
			'manjaro' )		cp "$output_config_dir/os/synth-shell-greeter.manjaro.config" "$config_file" ;;
			*)			cp "$output_config_dir/synth-shell-greeter.config.default" "$config_file" ;;
		esac
	fi
}






##==============================================================================
##	SCRIPT
##==============================================================================

setup $@

