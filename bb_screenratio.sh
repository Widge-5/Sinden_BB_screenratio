#!/bin/bash

######################################################################################################
##
##  BB9 aspect ratio conversion - by Widge
##  Version 1.03
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

title="BareBones Screen Aspect Adaptation Utility (v1.02)"
WT_HEIGHT=20
WT_WIDTH=70
WT_MENU_HEIGHT=5

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


function downloader() {
  rm -rf $2
  mkdir $2
  cd $2
  echo "Downloading "$1"..."
  wget --timeout 15 --no-http-keep-alive --no-cache --no-cookies $3
  wait
  echo "Extracting "$1"..."
  unzip -q main.zip
}

function tidyup(){
  echo "Cleaning up...."
  cd /home/pi
  rm -rf $1
  echo "Done."
}


function dloverlays() {
  downloader "new overlays" "/home/pi/srfoverlays" "https://github.com/Widge-5/Sinden_BB_screenratio/archive/refs/heads/main.zip"
  echo "Moving new overlays to location..."
  cd "/home/pi/srfoverlays/Sinden_BB_screenratio-main/overlay"
  cp *.* /opt/retropie/configs/all/retroarch/overlay
  cd /home/pi
}


function displaymodes () {
  restorechoice="1"
  echo "Your current display is: "
  /opt/vc/bin/tvservice -s
  choice=$(whiptail --title "$title" --menu "What display ratio do you want to convert to?" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT \
    "1" "| 16:9 . BB9 default, most common" \
    "2" "|  4:3 . Classic" \
    "3" "|  5:4 . Typical for some Arcade1UP cabinets" \
    3>&1 1>&2 2>&3)

  case $choice in
    1 ) #16:9
      displaygroupname="CEA"
      displaygroup="1"
      displaymode="4"
      newoverlay=$overlay169
      viewportX="173"; viewportY="10"; viewportW="933"; viewportH="700"
      newcfgfolder="/home/pi/srfoverlays/Sinden_BB_screenratio-main/16x9"
      restorechoice=$(whiptail --title "$title" --menu \
        "\nYou have chosen the default Barebones aspect ratio of 16:9.\nWould you like to strip out all of the bezels and apply global viewport settings or restore the default BareBones config files that may have previously been stripped out?" \
        $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT \
        "1" "| Strip the bezels from the config files" \
        "2" "| Restore the default BareBones config files" \
        3>&1 1>&2 2>&3)
    ;;
    2 ) #4:3"
      displaygroupname="DMT"
      displaygroup="2"
      displaymode="16"
      newoverlay=$overlay43
      viewportX="9"; viewportY="9"; viewportW="1006"; viewportH="750"
      newcfgfolder="/home/pi/srfoverlays/Sinden_BB_screenratio-main/4x3"
    ;;
    3 ) #5:4"
      displaygroupname="DMT"
      displaygroup="2"
      displaymode="35"
      newoverlay=$overlay54
      viewportX="12"; viewportY="41"; viewportW="1256"; viewportH="942"
                       stretchY="12";                    stretchH="1000"
      newcfgfolder="/home/pi/srfoverlays/Sinden_BB_screenratio-main/5x4"

      stretchchoice=$(whiptail --title "$title" --menu \
        "\nAlmost all of the games available are made with the 4:3 aspect ratio in mind. The display you have selected has a slightly narrower (taller) aspect ratio.\n\nWould you like to:" \
        $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT \
        "1" "| Display the games in their true 4:3 aspect ratio" \
        "2" "| Distort the games so they stretch to fill the whole screen?" \
        3>&1 1>&2 2>&3)

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
      TERM=ansi whiptail --title "$title" --infobox "Your display doesn't support the required display mode... Cancelling\nMake sure your Pi is connected to a display and that it is turned on before trying again" $WT_HEIGHT $WT_WIDTH
      exit
    fi    
}



function restoreOG(){
  downloader "config repository..." "/home/pi/cfgrestore" "https://github.com/Widge-5/sinden-barebones-configs/archive/refs/heads/main.zip"
  echo "Replacing configs..."
  cd "/home/pi/cfgrestore/sinden-barebones-configs-main/opt/retropie/configs"
  find . -name "*.cfg" | cpio -updm $location
  tidyup "/home/pi/cfgrestore"
}



function ratioquestion(){
  ratiochoice=$(whiptail --title "$title" --nocancel --menu \
    "$1" \
    $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT \
    "1" "| Correct ratio" \
    "2" "| Stretch to fill" \
    3>&1 1>&2 2>&3)
}


function trueratio(){
  ratioquestion "\nWould you like games that are natively 3:4 to be displayed in their correct ratio or distorted to 4:3?"
  case $ratiochoice in
    1 )
      echo " : Correct ratio"
      cp -v $newcfgfolder"/3x4.cfg" "/opt/retropie/configs/all/retroarch/config/MAME/bombbee.cfg"
      cp -v $newcfgfolder"/3x4.cfg" "/opt/retropie/configs/all/retroarch/config/MAME/cutieq.cfg"
      cp -v $newcfgfolder"/3x4.cfg" "/opt/retropie/configs/all/retroarch/config/MAME/geebee.cfg"
      cp -v $newcfgfolder"/3x4.cfg" "/opt/retropie/configs/all/retroarch/config/MAME/mmagic.cfg"
      cp -v $newcfgfolder"/3x4.cfg" "/opt/retropie/configs/all/retroarch/config/MAME/bronx.cfg"
      break
    ;;
    2 )
      echo " : Stretch to fill"
      break
    ;;
    * )
      echo " : Invalid choice"
    ;;
    esac
  ratioquestion "\nWould you like Cybertank, which is natively 8:3, to be displayed in its correct ratio or distorted 4:3?"
    case $ratiochoice in
      1 )
	echo " : Correct ratio"
        cp -v $newcfgfolder"/8x3.cfg" "/opt/retropie/configs/all/retroarch/config/FinalBurn Neo/cybertnk.cfg"
        break
      ;;
      2 )
	echo " : Stretch to fill"
        break
      ;;
      * )
        echo " : Invalid choice"
      ;;
    esac
  ratioquestion "\nWould you like Razzmatazz, which is natively 7:8 to be displayed in its correct ratio or distorted to 4:3?"
    case $ratiochoice in
      1 )
	echo " : Correct ratio"
        cp -v $newcfgfolder"/7x8.cfg" "/opt/retropie/configs/all/retroarch/config/MAME 2016/razmataz.cfg"
        break
      ;;
      2 )
	echo " : Stretch to fill"
        break
      ;;
      * )
        echo " : Invalid choice"
      ;;
    esac
  ratioquestion "\nWould you like the Tic-80 system, which is natively 16:9 to be displayed in its correct ratio or distorted to 4:3?"
    case $ratiochoice in
      1 )
	echo " : Correct ratio"
        cp -v $newcfgfolder"/tic80.cfg" "/opt/retropie/configs/tic80/retroarch.cfg"
        break
      ;;
      2 )
	echo " : Stretch to fill"
        break
      ;;
      * )
        echo " : Invalid choice"
      ;;
    esac
}


function gollyghost43() {
  cd "/home/pi/srfoverlays/Sinden_BB_screenratio-main/GGBT"
  if (whiptail  --title "$title" --yesno \
    "Would you like to remove the 16:9 scoreboard from Golly Ghost and Bubble Trouble, and apply calibrations for these games suited to a 4:3 display?" \
    $WT_HEIGHT $WT_WIDTH \
    3>&1 1>&2 2>&3)
    then
      echo " : Remove scoreboard"
      cp -v gollygho.cfg.43 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/cfg/gollygho.cfg
      cp -v nvram.gg43 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/nvram/gollygho/nvram
      cp -v bubbletr.cfg.43 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/cfg/bubbletr.cfg
      cp -v nvram.bt43 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/nvram/bubbletr/nvram
    else
      echo " : Keep Scoreboard"
      cp -v $newcfgfolder"/16x9.cfg" "/opt/retropie/configs/all/retroarch/config/MAME/gollygho.cfg"
      cp -v $newcfgfolder"/16x9.cfg" "/opt/retropie/configs/all/retroarch/config/MAME/bubbletr.cfg"
    fi
  cd /home/pi
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

  echo -e "Updating the overlay reference in every game and folder cfg in RetroArch with a reference to the overlay at: \033[0;33m"$newoverlay"\033[0m..."
  find $location -type f -name $filepattern -print0 | xargs -0 sed -i "/$oldoverlayref/c\\$newoverlayref"
  echo "Updating viewport settings..."
  find $location"all/" -type f -name $filepattern -print0 | xargs -0 sed -i "/$oldVPXref/c\\$newVPXref"
  find $location"all/" -type f -name $filepattern -print0 | xargs -0 sed -i "/$oldVPYref/c\\$newVPYref"
  find $location"all/" -type f -name $filepattern -print0 | xargs -0 sed -i "/$oldVPWref/c\\$newVPWref"
  find $location"all/" -type f -name $filepattern -print0 | xargs -0 sed -i "/$oldVPHref/c\\$newVPHref"
  echo -e "Updating the overlay_enable reference in RetroArch's system and global cfgs to \"false\" (for non-lg games)"
  find $location -maxdepth 2 -type f -name $filepattern -print0 | xargs -0 sed -i "/input_overlay_enable = /c\\input_overlay_enable = \"false\""
  echo "Done"
}




function gollyghost169() {
  echo "Repairing Bubble Trouble and Golly Ghost.."
  cd "/home/pi/srfoverlays/Sinden_BB_screenratio-main/GGBT"
  cp -v gollygho.cfg.169 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/cfg/gollygho.cfg
  cp -v nvram.gg169 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/nvram/gollygho/nvram
  cp -v bubbletr.cfg.169 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/cfg/bubbletr.cfg
  cp -v nvram.bt169 /home/pi/RetroPie/roms/arcade/Lightgun_Games/mame/nvram/bubbletr/nvram
  cd /home/pi
}


function main() {
  if [[ $EUID > 0 ]]; then
    echo "ERROR: script must be run with sudo"
    exit 0
  else

  if (whiptail --fb --title "$title" --yesno \
    "This script requires an internet connection.\n\nThis script will make significant changes to your system. Please ensure you have made a backup of your system before continuing.\n\nAre you sure you wish to proceed?" \
    $WT_HEIGHT $WT_WIDTH )
    then
      echo " : OK..."
      displaymodes
       case $restorechoice in
	1 )
          echo " : Replace"
          displaymodes2
          dloverlays
          replacerefs
          gollyghost43
          trueratio 
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
    else
      echo " : Cancelled"
      exit
    fi

    tidyup "/home/pi/srfoverlays"
    chown -R pi:pi /opt/retropie/configs/
    chown -R pi:pi /home/pi/

  if (whiptail --fb --title "$title" --yesno \
    "Process completed.  You should now reboot your Pi for the the changes to take effect.\n\nDo you want to reboot now?" \
    $WT_HEIGHT $WT_WIDTH )
    then
      colourecho "cLRED" " : REBOOTING"
      reboot
    else
        colourecho "cLRED" " : Don't forget to reboot!"
    fi
  fi
}

main
