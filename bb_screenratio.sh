#!/bin/bash

######################################################################################################
##
##  BB9 aspect ratio conversion - by Widge
##  Version 1.
##  January 2023
##
##  # TV modes #
##  16:9 = Group 1 (CEA) Mode 4 (1280*720)
##  4:3 = Group 2 (DMT) Mode 16 (1024*768)
##  5:4 = Group 2 (DMT) Mode 35 (1280*1024)
##
######################################################################################################


overlay43="/opt/retropie/configs/all/retroarch/overlay/SindenBorderWhite43.cfg"
overlay54="/opt/retropie/configs/all/retroarch/overlay/SindenBorderWhite54.cfg"
overlay169="/opt/retropie/configs/all/retroarch/overlay/SindenBorderWhite169.cfg"

location="/opt/retropie/configs/"
filepattern="*.cfg"
configtxt="/boot/config.txt"

_cQUERY="cCYAN"
_cOPTIONS="cLCYAN"

function colourecho(){
    _nc="\033[0m"
    case $1 in
      cBLACK )         _col="\033[0;30m";;
      cDGRAY|cDGREY )  _col="\033[1;30m";;
      cRED )           _col="\033[0;31m";;
      cLRED )          _col="\033[1;31m";;
      cGREEN )         _col="\033[0;32m";;
      cLGREEN )        _col="\033[1;32m";;
      cBROWN|cORANGE ) _col="\033[0;33m";;
      cYELLOW )        _col="\033[1;33m";;
      cBLUE )          _col="\033[0;34m";;
      cLBLUE )         _col="\033[1;34m";;
      cPURPLE )        _col="\033[0;35m";;
      cLPURPLE )       _col="\033[1;35m";;
      cCYAN )          _col="\033[0;36m";;
      cLCYAN )         _col="\033[1;36m";;
      cLGRAY|cLGREY )  _col="\033[0;37m";;
      cWHITE )         _col="\033[1;37m";;
      cNUL|* )         _col=$nc;;
    esac
  echo -e "${_col}${2}${_nc}"
}

function dloverlays() {
  rm -rf /home/pi/srfoverlays
  mkdir /home/pi/srfoverlays
  cd /home/pi/srfoverlays
  echo "Downloading new overlays..."
  wget --timeout 15 --no-http-keep-alive --no-cache --no-cookies "https://github.com/Widge-5/Sinden_BB_screenratio/archive/refs/heads/main.zip"
  wait
  echo "Extracting new overlays..."
  unzip -q main.zip

  echo "Moving new overlays to location..."
  cd "/home/pi/srfoverlays/Sinden_BB_screenratio-main/overlay"
  cp *.* /opt/retropie/configs/all/retroarch/overlay
}


function displaymodes () {
  restorechoice="1"
  echo "Your current display is: "
  /opt/vc/bin/tvservice -s
  colourecho $_cQUERY "What display ratio do you want to convert to?"
  colourecho $_cOPTIONS "[1] 16:9 (BB9 default, most common)"
  colourecho $_cOPTIONS "[2] 4:3"
  colourecho $_cOPTIONS "[3] 5:4 (typical for some Arcade1UP cabinets)"
  colourecho $_cOPTIONS "Make your selection. Any other key to cancel."
  read -N1 choice
    case $choice in
      1 )
        echo " : 16:9"
        displaygroupname="CEA"
	displaygroup="1"
        displaymode="4"
	newoverlay=$overlay169
	viewportX="173"; viewportY="10"; viewportW="933"; viewportH="700"
	colourecho $_cQUERY "You have chosen the default Barebones aspect ratio of 16:9. Would you like to..."
        colourecho $_cOPTIONS "[1] Just run the local script that strips the bezels and applies global viewport settings for a 16:9 display;"
	colourecho $_cOPTIONS "[2] Restore the default BareBones config files that were previously stripped out by this script;"
        colourecho $_cOPTIONS "Make your selection. Any other key to cancel."
        read -N1 restorechoice
      ;;
      2 )
        echo " : 4:3"
        displaygroupname="DMT"
	displaygroup="2"
        displaymode="16"
	newoverlay=$overlay43
	viewportX="9"; viewportY="9"; viewportW="1006"; viewportH="750"
      ;;
      3 )
        echo " : 5:4"
        displaygroupname="DMT"
	displaygroup="2"
        displaymode="35"
	newoverlay=$overlay54
	viewportX="12"; viewportY="41"; viewportW="1256"; viewportH="942"
	                stretchY="12";                    stretchH="1000"
        colourecho $_cQUERY "Almost all of the games available are made with the 4:3 aspect ratio in mind."
        colourecho $_cQUERY "The display you have selected has a slightly narrower (taller) aspect ratio."
        colourecho $_cQUERY "Would you like to:"
        colourecho $_cOPTIONS "[1] Display the games in their true 4:3 aspect ratio; or"
        colourecho $_cOPTIONS "[2] Distort the games so they stretch to fill the whole screen?"
        colourecho $_cOPTIONS "Make a selection, or press any other key to quit."
        read -N1 stretchchoice
        case $stretchchoice in
          1 )
            echo " : Excellent choice."
          ;;
          2 )
            echo " : Distort the image."
            viewportY=$stretchY
            viewportH=$stretchH
          ;;
          * )
            echo "  : Cancelled"
            exit 0
          ;;
        esac
      ;;
      * )
        echo "  : Cancelled"
        exit 0
      ;;
    esac
}

function displaymodes2(){
    if /opt/vc/bin/tvservice -m $displaygroupname | grep -q "mode "$displaymode ; then 
      echo "Display mode supported";
      sed -i "/hdmi_group=/c\hdmi_group=$displaygroup" $configtxt
      sed -i "/hdmi_mode=/c\hdmi_mode=$displaymode" $configtxt
      echo $configtxt " updated."
    else
      echo "Your display doesn't support the required display mode. Cancelling"
      exit
    fi    
}

function restoreOGbase(){
        rm -rf /home/pi/cfgrestore
        mkdir /home/pi/cfgrestore
	cd /home/pi/cfgrestore
	echo "Downloading cfg repository..."
        wget --timeout 15 --no-http-keep-alive --no-cache --no-cookies "https://github.com/Widge-5/sinden-barebones-configs/archive/refs/heads/main.zip"
	wait
	echo "Extracting config repository..."
        unzip -q main.zip
}


function restoreOG(){
        restoreOGbase
	echo "Replacing configs..."
	cd "/home/pi/cfgrestore/sinden-barebones-configs-main/opt/retropie/configs"
	find . -name "*.cfg" | cpio -updm $location
	echo "Cleaning up...."
	cd /home/pi
        rm -rf /home/pi/cfgrestore
	echo "Done."
}





function replacerefs() {
  oldoverlayref="input_overlay = "
  oldVPXref="custom_viewport_x = "
  oldVPYref="custom_viewport_y = "
  oldVPWref="custom_viewport_width = "
  oldVPHref="custom_viewport_height = "

  newoverlayref="$oldoverlayref\""$newoverlay"\""
  newVPXref="$oldVPXref\""$viewportX"\""
  newVPYref="$oldVPYref\""$viewportY"\""
  newVPWref="$oldVPWref\""$viewportW"\""
  newVPHref="$oldVPHref\""$viewportH"\""

  echo -e "Updating every overlay reference in retroarch with a reference to the overlay at: \033[0;33m"$newoverlay"\033[0m..."
  find $location -type f -name $filepattern -print0 | xargs -0 sed -i "/$oldoverlayref/c\\$newoverlayref"
  echo "Updating viewport settings..."
  find $location -type f -name $filepattern -print0 | xargs -0 sed -i "/$oldVPXref/c\\$newVPXref"
  find $location -type f -name $filepattern -print0 | xargs -0 sed -i "/$oldVPYref/c\\$newVPYref"
  find $location -type f -name $filepattern -print0 | xargs -0 sed -i "/$oldVPWref/c\\$newVPWref"
  find $location -type f -name $filepattern -print0 | xargs -0 sed -i "/$oldVPHref/c\\$newVPHref"
  echo "Done"
}

function gollyghost43() {
  cd "/home/pi/srfoverlays/Sinden_BB_screenratio-main/GGBT"
  colourecho $_cQUERY "Would you like to remove the 16:9 scoreboard from Golly Ghost and Bubble Trouble, and apply calibrations for these games suited to a 4:3 display? (y/n)"
  read -N1 yn
  case $yn in
    y|Y )
      echo " : Remove scoreboard"
      cp -v gollygho.cfg.43 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/cfg/gollygho.cfg
      cp -v nvram.gg43 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/nvram/gollygho/nvram
      cp -v bubbletr.cfg.43 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/cfg/bubbletr.cfg
      cp -v nvram.bt43 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/nvram/bubbletr/nvram
    ;;
    * )
      echo " : Skip"
    ;;
  esac
  echo "Cleaning up...."
  cd /home/pi
  rm -rf /home/pi/srfoverlays
}


function gollyghost169() {
  echo "Repairing Bubble Trouble and Golly Ghost.."
  cd "/home/pi/srfoverlays/Sinden_BB_screenratio-main/GGBT"
  cp -v gollygho.cfg.169 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/cfg/gollygho.cfg
  cp -v nvram.gg169 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/nvram/gollygho/nvram
  cp -v bubbletr.cfg.169 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/cfg/bubbletr.cfg
  cp -v nvram.bt169 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/nvram/bubbletr/nvram
  echo "Cleaning up...."
  cd /home/pi
  rm -rf /home/pi/srfoverlays
}


function main() {
  if [[ $EUID > 0 ]]; then
    echo "ERROR: script must be run with sudo"
    exit 0
  else
    colourecho $_cQUERY "This script requires an internet connection."
    colourecho $_cQUERY "This script will make significant changes to your system.  Please ensure you have made a backup of your system before continuing."
    colourecho $_cOPTIONS "-Are you sure you wish to proceed? (y/n)"
    read -N1 yn
    case $yn in
      y|Y )
        echo " : OK..."
        displaymodes
	case $restorechoice in
	  1 )
            echo " : Replace"
            displaymodes2
            dloverlays
            gollyghost43 
            replacerefs
          ;;
          2 )
            echo " : Restore"
            displaymodes2
            restoreOG
            dloverlays
            gollyghost169
          ;;
          * )
            echo " : Cancelled"
            exit
          ;;
        esac
      ;;
      * )
        echo " : Cancelled"
        exit
      ;;
    esac
  fi
  chown -R pi:pi /opt/retropie/configs/
  chown -R pi:pi /home/pi/
  colourecho $_cQUERY "Process completed.  You should now reboot your Pi for the the changes to take effect."
  colourecho $_cOPTIONS "Do you want to reboot now? (y/n)"
  read -N1 yn
  case $yn in
    y|Y )
      colourecho "cLRED" " : REBOOTING"
      reboot
    ;;
    * )
      colourecho "cLRED" " : Don't forget to reboot!"
    ;;
  esac
}

main

