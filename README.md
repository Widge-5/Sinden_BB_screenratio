# Aspect Ratio Adaptation Utility for Sinden BareBones (v 1.04)
Script for users of the BareBones (9) image to quickly and easily adapt the system for use on 4:3 or 5:4 displays.

## Reason
The Barebones image was developed with the majority of home users in mind. As the vast majority of modern TV sets are of the 16:9 aspect ratio this is what we expect most users to be using their Sinden lightguns with.
However, there are still those who would like to use the BareBones image on either traditional TV sets or monitors bult into reproduction arcade cabinets that are in the 4:3 or even 5:4 ratio (Arcade1Up, what were you thinking!?).
It is for these users that this script has been written.  Converting BareBones from 16:9 is no small undertaking if done manually due to the fact that most games have unique bezel overlays that would need to be replaced.

## How to use
Always make a backup of your image before running a utiliy such as this one.  You do so at our own risk.  It is not possible to account for thy myriad changes and personalisations that users can make to their systems so please take precautions before you do so to ensure that you can revert back if the outcome is not to your satisfaction.

**If you already have an older version of the script, you should delete it first. It will not be overwritten by the wget command below**

If running from the Pi itself with a connected keyboard, press `F4` to exit EmulationStation and reach the command line.
Or you can connect to your Pi via SSH using a reliable utility such as PuTTY.
From the command line, type the following:
```
cd /home/pi/
wget https://github.com/Widge-5/Sinden_BB_screenratio/raw/main/bb_screenratio.sh
chmod +x bb_screenratio.sh
sudo ./bb_screenratio.sh
```
This will download the script to your `/home/pi` folder and make it executable. The last line executes the script.

When you run the script you will be presented with a few questions that will determine what conversion is needed.
It will only take a minute or two to complete the whole process, then you should reboot your Pi for the changes to take effect.

## What to expect
- Your Pi will be configured to display natively with the aspect ratio of your choice - this means that the terminal and EmulationStation itself will not appear distorted/stretched if you have selected the correct ratio.
- RetroArch will have been given blanket viewport settings assuming that all games are 4:3 ratio across the board, the vast majority are. The viewport settings have been defined so the game picture fits neatly within the border without obstruction.
- If you are using a 5:4 display, you will see a little empty space at the top and bottom of the screen, this is becasue 4:3 is wider than 5:4. But if that is a concern for you and you prefer to stretch and fill, you are given the option to do so in the script.
- For some games and systems that display natively in ratios other than 4:3, you will be given the option of displaying these in their correct ratios, or to distort them to fill your screen.
- Some games, such as Sky Raider, had bezels that provided extra dressing to improve the look of the game.  A consequence of removing the bezel is that the games basic graphics will be all you get.
- Golly Ghost and Bubble Trouble utilised the bezel area on 16:9 displays to show the dynamic scoreboard. An option has been included in the script to remove the scoreboard and calibrate the guns for the new ratio if you so wish.

## Restoring BareBones back to its original 16:9 state with bezels.
It's possible that you may want to migrate the pi to a new 16:9 display at some time in the future.
In most cases the script can be run again to restore the image back to its original state by choosing the option for 16:9 displays and then choosing to replace the configs with those from the BB9 github repo.
The script will then replace the files previously changed with those from the github repo.  Be mindful that if you have made some other changes or personalisations they may or may not be affected by the restoration.  The script will restore all of retroarch's game and folder `.cfg` files and the global and system-specific `retroarch.cfg` files (and only these) as these are the files that would have been changed by the first alteration process.

## Watch the YouTube video demo:
Click the image to play the video.
[![Watch the video](https://img.youtube.com/vi/nP4XE7SBvWA/maxresdefault.jpg)](https://youtu.be/nP4XE7SBvWA)
