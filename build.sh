#!/bin/bash
# Go up a folder (ONLY IF NEEDED), so khamake is called from the right directory
FILETOCHECK="make.js"
if [ -s "$FILETOCHECK" ]
then
	cd ..
fi

echo "___________________________________"
echo "khamake builder"
echo "type q to quit."
echo "___________________________________"
# Target input.
#platform_input
echo "Specify target:" 
echo "" 
echo "The possible options are:"
echo " * windows"
echo " * linux"
echo " * android"
echo " * windowsrt"
echo " * osx"
echo " * ios"
echo " * html5"
echo " * flash"
echo " * wpf"
echo " * xna"
echo " * java"
echo " * psm"
echo " * dalvik"
echo " * tizen"
echo "___________________________________"
read target

if [ "$target" == "q" ]; then
   echo "Quitting..."
   echo "___________________________________"
   exit
fi

# Options input.
echo "Specify options:" 
read options

# Setting true to 0
TRUE=0

# Checks if the input matches any of the valid targets
if  [ "$target" == "windows" ] ||
	[ "$target" == "linux" ] ||
	[ "$target" == "android" ] ||
	[ "$target" == "windowsrt" ]
	[ "$target" == "osx" ] ||
	[ "$target" == "ios" ] ||
	[ "$target" == "html5" ] ||
	[ "$target" == "flash" ] ||
	[ "$target" == "wpf" ] ||
	[ "$target" == "xna" ] ||
	[ "$target" == "java" ] ||
	[ "$target" == "psm" ] ||
	[ "$target" == "dalvik" ] ||
	[ "$target" == "tizen" ] ||
	[ "$target" == "tizen" ]; then
	TRUE=1
fi

#If the input is valid call Hake
#If True is not defined ( no valid target ) jump back to the start
if [ "$TRUE" == "1" ]; then
   node Kha/make "$target" "$options"
else
   echo "Unsupported platform..."
fi

#end_of_file
echo "___________________________________"
exit