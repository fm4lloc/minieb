#!/bin/bash

# Automate a minimalist configuration for Debian Streach/Buster
#
# Written by: Fernando Magalhães (fm4lloc) <fm4lloc(at)gmail(ot)com>
#
# This program is free software; you can REDistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

declare -r red=$(tput setaf 1)
declare -r normal=$(tput sgr0)

declare -r prog_name="MiniDeb"
declare -r prog_vesion="2.09.30" #AAAAMMDD

declare -r debian_version="10.4"

# install libexo-1-0 to fix error "open terminal here" on thunar

# Base package
declare -a pkg_base=(xorg slim openbox obconf thunar libexo-1-0
thunar-archive-plugin obmenu lxmenu-data openbox-menu tint2
trayer wicd-gtk nitrogen lxappearance breeze-icon-theme gtk2-engines
obsession conky sakura mirage gmrun maim
galculator transmission-gtk audacious inkscape gimp
chromium chromium-l10n mpv evince engrampa lxappearance
geany volumeicon-alsa alsa-utils pulseaudio pavucontrol-qt
gtk2-engines-murrine gnome-themes-standard hardinfo gparted bash-completion build-essential 
linux-headers-$(uname -r) module-assistant dkms
libreoffice libreoffice-gtk3
thunderbird)

function help()
{
	version
	printf "\n%s\n"\
	"-i | --install - install packpages e copy config files."\
	"-r | --reconfigure - copy only the configuration files."\
	"-d | --description - show description of installed packages."\
	"Example for install:"\
	"Try $0 -i or $0 --install"
}

function show_description()
{
	printf "${red}%s\n${normal}" "You can press Ctrl+C at any time to end."
	for pkg_name in ${pkg_base[*]}
	do
		apt-cache search "^$pkg_name$" | egrep "^$pkg_name -"
	done
}

function install_packpages()
{
	printf "${red}%s\n${normal}" "Installing packages..."
	sudo apt update
	sudo apt install ${pkg_base[*]}
	
	# FIX: saída invalida do menu de processamento /etc/xdg/menus/xfce-applications.menu
	#sudo apt-get -y --purge remove libgarcon-common
	#sudo apt-get -y --purge autoremove
	
	setup_system
	exit 0
}

function setup_system()
{
	printf "${red}\n%s\n${normal}" "Copying configuration files:"
	cp -avr ./tint2 ~/.config
	cp -avr ./openbox ~/.config
	cp -avr ./geany ~/.config/
	cp -avr ./Wallpapers ~/
	cp -avr ./.themes ~/
	
	mkdir -v ~/screenshot/
	cp -avr .screenshot-maim.sh ~/
	chmod +x ~/.screenshot-maim.sh -v
	
	sed -i s/YOURNAME/$(whoami)/g ./nitrogen/bg-saved.cfg
	sed -i s/YOURNAME/$(whoami)/g ./nitrogen/nitrogen.cfg
	cp -avr ./nitrogen ~/.config
	
	sudo mv /usr/share/slim/themes/debian-softwaves/background.png{,.bkp}
	sudo cp -avr background.png /usr/share/slim/themes/debian-softwaves/
	
	sed -i s/YOURNAME/$(whoami)/g ./.gtkrc-2.0
	cp -avr ./.gtkrc-2.0 ~/
	
	cp -avr ./.conkyrc ~/
	cp -avrb ./.bashrc ~/
	
	printf "${red}\n%s\n${normal}" "Applying resolution improvement on LED / LCD screens:"
	cp -avr ./.fonts.conf ~/
	
	chmod +x ~/.config/openbox/autostart.sh -v
	
	printf "${red}\n%s\n${normal}" "Finished! Now you reboot the system."
}

function check_install()
{
	if [[ !$debian_version =~ ^`cat /etc/debian_version`$ ]]; then
		printf "${red}\n%s\n${normal}" "[WARNING] This script was only tested on version $debian_version of debian."
	fi
		printf "${red}\n%s\n${normal}" "Proceed with the installation? [N/y]"
        read -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
		install_packpages
        else
		printf "\nBye!"
		exit -1
        fi
}

function version()
{
	printf "${red}${prog_name} ${prog_vesion}${normal}"
}

# Main
case $1 in
	-i | --install)
		check_install
		exit 0
		;;
	-r | --reinstall)
		setup_system
		exit 0
		;;
	-d | --description)
		show_description
		exit 0
		;;
	*)
		help
		exit 0
esac
