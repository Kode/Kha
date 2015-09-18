@echo off
::Go up a folder, so khamake is called from the right directory
cd ..\

echo ___________________________________
echo khamake builder
echo type q to quit.
echo ___________________________________
::Target input.
:platform_input
set /p target="Specify target:" 


if %target%==q (
   echo Quitting...
   goto end_of_file
)
::Options input.
set /p options="Specify options:" 

set "TRUE="
::Checks if the input matches any of the valid targets
IF %target%==windows 	set TRUE=1
IF %target%==linux 		set TRUE=1
IF %target%==android 	set TRUE=1
IF %target%==android-native 	set TRUE=1
IF %target%==windowsrt 	set TRUE=1
IF %target%==osx 		set TRUE=1
IF %target%==ios 		set TRUE=1
IF %target%==html5 		set TRUE=1	
IF %target%==flash 		set TRUE=1
IF %target%==wpf 		set TRUE=1
IF %target%==xna 		set TRUE=1
IF %target%==java 		set TRUE=1
IF %target%==psm 		set TRUE=1
IF %target%==dalvik		set TRUE=1
IF %target%==tizen		set TRUE=1

::If the input is valid call Hake
::If True is not defined ( no valid target ) jump back to the start
IF defined TRUE (
   start /b /wait %opt% node Kha\make %target% %options%
) else (
   echo Unsupported platform...
   goto platform_input
)

:end_of_file

echo ___________________________________
pause
