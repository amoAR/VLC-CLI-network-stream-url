@echo off
:start
setlocal enableExtensions
setlocal enableDelayedExpansion

::title
title amoAR VLC CLI - Stream HTTP source

::set generall global variables
set "tab=   "
set "Commands=Commands\"
set "Database=Database\"
set "Design=Design\"
set "style=%Design%style.exe"
set "Help=Help\"

::set foreground oreground colors code
set "fDefaultColor=39m"
set "fBlack=30m"
set "fRed=31m"
set "fGreen=32m"
set "fYellow=33m"
set "fCyan=36m"

pushd %~dp0

:: validate necessary folders and files except .exe files
:: check Commands
:diag
if not exist "%Commands%" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 1 \033[0m | %style% 
    echo:
    echo | set /p="Please wait while we fix the issue... "
    set "change=Commands"
    goto fix
)

set "counter=findstr /r /n "^^" %Commands%commands.txt | find /c ":""
for /f %%a in ('!counter!') do set number=%%a
if not "%number%"=="40" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 1.1 \033[0m | %style% 
    echo: 
    echo | set /p="Please wait while we fix the issue... "
    set "change=commands.txt"
    goto fix
)

set "counter=findstr /r /n "^^" %Commands%Pcommands.txt | find /c ":""
for /f %%a in ('!counter!') do set number=%%a
if not "%number%"=="39" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 1.2 \033[0m | %style% 
    echo: 
    echo | set /p="Please wait while we fix the issue... "
    set "change=Pcommands.txt"
    goto fix
)

:: check Database
if not exist "%Database%" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 2 \033[0m | %style% 
    echo:
    echo | set /p="Please wait while we fix the issue... "
    set "change=Database"
    goto fix
)

if not exist "%Database%vlcLocation.txt" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 2.1 \033[0m | %style% 
    echo:
    echo | set /p="Please wait while we fix the issue... "
    set "change=vlcLocation.txt"
    goto fix
)

if not exist "%Database%subLocation.txt" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 2.2 \033[0m | %style% 
    echo:
    echo | set /p="Please wait while we fix the issue... "
    set "change=subLocation.txt"
    goto fix
)

if not exist "%Database%playlist.xspf" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 2.3 \033[0m | %style% 
    echo:
    echo | set /p="Please wait while we fix the issue... "
    set "change=playlist.xspf"
    goto fix
)

:: check Design
if not exist "%Design%" (
    echo Oh^^! it looks like we detected a problem in directory - ERROR 3
    echo:
    pause
    exit /b 0
) else (
    if not exist "%Design%style.exe" (
        echo Oh^^! it looks like we detected a problem in directory - ERROR 3.1
        echo:
        pause
        exit /b 0
    )
)

:: check Help
if not exist "%Help%" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 4 \033[0m | %style% 
    echo:
) else goto helpFiles

:helpFiles
if not exist "%Help%help.txt" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 4.1 \033[0m | %style% 
    echo:
    echo | set /p="Please wait while we fix the issue... "
    set "change=help.txt"
    goto fix
)

if not exist "%Help%vlc.txt" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 4.2 \033[0m | %style%
    echo:
)

if not exist "%Help%subtitle.txt" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 4.3 \033[0m | %style% 
    echo:
)

if not exist "%Help%commands.txt" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 4.4 \033[0m | %style% 
    echo:
)

if not exist "%Help%url.txt" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 4.5 \033[0m | %style% 
    echo:
)

if not exist "%Help%playlist.txt" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 4.6 \033[0m | %style% 
    echo:
)

if not exist "%Help%error.txt" (
    echo \033[%fYellow% Oh^^! it looks like we detected a problem in directory - ERROR 4.7 \033[0m | %style% 
    echo:
)



::welcome
echo:
:::  /$$    /$$ /$$        /$$$$$$         /$$$$$$  /$$       /$$$$$$
::: | $$   | $$| $$       /$$__  $$       /$$__  $$| $$      |_  $$_/
::: | $$   | $$| $$      | $$  \__/      | $$  \__/| $$        | $$  
::: |  $$ / $$/| $$      | $$            | $$      | $$        | $$  
:::  \  $$ $$/ | $$      | $$            | $$      | $$        | $$  
:::   \  $$$/  | $$      | $$    $$      | $$    $$| $$        | $$  
:::    \  $/   | $$$$$$$$|  $$$$$$/      |  $$$$$$/| $$$$$$$$ /$$$$$$
:::     \_/    |________/ \______/        \______/ |________/|______/

for /f "delims=: tokens=*" %%a in ('findstr /b ::: "%~f0"') do @echo %%a
echo:
echo:


::-------Step 1-------
::validate VLC location --> 1-check the default path | 2-get it from user
:vlcLocation
set /p vlcPath=<%Database%vlcLocation.txt 

if exist "%vlcPath%\vlc.exe" (
    echo \033[%fGreen% vlc confirmed \033[0m | %style%
    goto subLocation
) else (
    echo \033[%fRed% Unfortunately, we could not find VLC location. please enter it manually \033[0m | %style%
    :getVlcLocationManuallyRetry
    echo \033[%fYellow% %tab%------------------------------------------ \033[0m | %style%
    set /p "vlcPath=>%tab%Location (e.g. C:\Program Files\VideoLAN): "
    echo \033[%fYellow% %tab%------------------------------------------ \033[0m | %style%
    goto checkVlcLocation
)

::validate user input location
:checkVlcLocation
if exist "%vlcPath%\vlc.exe" (
    echo %vlcPath%>%Database%vlcLocation.txt
    echo:
    echo \033[%fGreen% vlc confirmed \033[0m | %style%    
    goto subLocation
) else (
    echo \033[%fRed% Something wrong. please try again \033[0m | %style%
    echo:
    goto getVlcLocationManuallyRetry
)


::-------Step 2-------
::validate sub folder location --> 1-check the pre-determined path | 2-get path from user
:subLocation
set /p subPath=<%Database%subLocation.txt

if exist "%subPath%" (
    echo \033[%fGreen% sub folder confirmed \033[0m | %style%
    goto stream
) else (    
    if "%subPath%"=="no" goto stream else goto menu
)

::menu option for subtitle step if nothing is already determined --> 1-get path from user | 2-skip this step
:menu
echo:
echo:
echo  1 - Enter 1 to set subtitle folder location ^(like C:\Users\you\Desktop\Sub^)
echo  2 - Enter 2 if you don't have a subtitle folder
echo  3 - Soon...

::get input
:menuInput
echo:
set /p "M=Type 1 or 2 then press ENTER: "
for %%a in (1 2) do if "%M%"=="%%a" goto menuOptions else (
    echo \033[%fRed% Something wrong^! try again. \033[0m | %style%
    goto menuInput
)

::input analysis
:menuOptions
if "%M%"=="1" goto getSubLocationRetry

if "%M%"=="2" (
    echo no>%Database%subLocation.txt
    echo no sub folder
    goto stream
)


::get subtitle folder path from user
:getSubLocationRetry
echo \033[%fYellow% %tab%----------------------------------- \033[0m | %style%
set /p "subPath=>%tab%Enter the subtitle folder location: "
echo \033[%fYellow% %tab%----------------------------------- \033[0m | %style%

::check it
:checkSubLocation
if exist "%subPath%" (
    echo %subPath%>%Database%subLocation.txt
    echo \033[%fGreen% sub folder confirmed \033[0m | %style%
    goto stream
) else (
    echo \033[%fRed% Something wrong^! try again. \033[0m | %style%
    echo:
    goto getSubLocationRetry
)


::-------Step 3-------
::get stream URL
:stream
echo:
echo:
echo \033[%fYellow% %tab%-------------------------------------------------------- \033[0m | %style%
set /p "stream=>%tab%Please enter your command, network URL or playlist path: "
echo \033[%fYellow% %tab%-------------------------------------------------------- \033[0m | %style%

if "%stream%"=="5" goto exit
if "%stream%"=="exit" goto exit
if "%stream%"=="bye" goto exit

if "%stream%"=="reset" goto resetAll

if "%stream%"=="0" goto resetSub
if "%stream%"=="reset sub" goto resetSub

if "%stream%"=="1" goto playlist
if "%stream%"=="play playlist" goto playlist

if "%stream%"=="2" goto resetPlaylist
if "%stream%"=="reset playlist" goto resetPlaylist

if "%stream%"=="-h" goto help
if "%stream%"=="-help" goto help
if "%stream%"=="/?" goto help

if "%stream%"=="vlc /?" goto helpVlc
if "%stream%"=="vlc -h" goto helpVlc
if "%stream%"=="sub /?" goto helpSub
if "%stream%"=="sub -h" goto helpSub
if "%stream%"=="commands /?" goto helpCommands
if "%stream%"=="commands -h" goto helpCommands
if "%stream%"=="url /?" goto helpUrl
if "%stream%"=="url -h" goto helpUrl
if "%stream%"=="playlist /?" goto helpPlaylist
if "%stream%"=="playlist -h" goto helpPlaylist
if "%stream%"=="error /?" goto helpError
if "%stream%"=="error -h" goto helpError



if "%stream:~-4%"==".txt" goto list else (
    goto validateUrlHttps
)

:: list of URL ---> create a playlist
:list
:: check exist
if not exist "%stream%" (
    echo \033[%fRed% The entered path is not valid^^!. try again \033[0m | %style%
    goto stream
)

:: generate VLC playlist
if "%subPath%"=="no" (
    start /wait /b /min "amoAR VLC CLI - Playlist Generator" playlist.exe "%stream%" "%Database%playlist.xspf" "%Commands%Pcommands.txt" ""    
) else (
    start /wait /b /min "amoAR VLC CLI - Playlist Generator" playlist.exe "%stream%" "%Database%playlist.xspf" "%Commands%Pcommands.txt" "%subPath%"    
)
goto playlist

:: reset the subtitle location path by user
:resetSub
cls
echo \033[%fYellow% ----------------------------- \033[0m | %style%
echo | set /p="Reset subtitle location (Y/N)? "
for /f delims^= %%g in ('choice /c YN /n /t 20 /d Y') do if /i "%%g"=="N" (
    set "change=no"
    goto restart
)
set "change=yes"
echo Y
echo \033[%fYellow% ----------------------------- \033[0m | %style%

break>%Database%subLocation.txt
timeout 3 /nobreak >nul
goto restart


:: validate url inputed by user with https pattern
:validateUrlHttps
echo %stream% | findstr "^https://" >nul
if errorlevel 1 (
    goto validateUrlHttp
) else (
    goto sub
)

:: validate url inputed by user with http pattern
:validateUrlHttp
echo %stream% | findstr "^http://" >nul
if errorlevel 1 (
    echo \033[%fRed% your URL is not valid^^! try again \033[0m | %style%
    echo:
    goto stream
) else (
    goto sub
)


::-------Step 4-------
::find subtitle --> 1-get last part of URL | 2-remove part extension | 3-convert _ to . | 4-add .srt
:sub
::get last part of URL --> e.g fileName = The_Blacklist_S01E01_720p_BluRay_PaHe.mkv
for %%a in ("%stream%") do (
    set url= %%~pa
    set url=!url:~2!
    set fileName=%%~nxa
)

::remove extension part --> e.g movieName = The_Blacklist_S01E01_720p_BluRay_PaHe
set "movieName=%fileName:~0,-4%"

::get backup of commands file
copy /y "%Commands%commands.txt" "%Commands%commands.bak">nul 2>&1||exit /b

::remove last line of commands file (contains the previous --sub-file option)
(   set "line="
    for /f "usebackq delims=" %%a in ("%Commands%commands.bak") do (
        if defined line echo !line!
        set "line=%%a"))>"%Commands%commands.txt"

:: get user subtitle folder location --> if its value is "no" skip | else find related sub
set /p subPath=<%Database%subLocation.txt
if "%subPath%"=="no" goto importNoSub else (
    start /wait /b "amoAR VLC CLI - Subtitle Finder" subFinder.exe "%movieName%" "%subPath%"
    goto subFinder
)

:: check if subFinder give error in log --> S = success | F = failed
:subFinder
:: get last line log
for /f "usebackq delims==" %%a in ("%Database%subFinder.log") do set "subFinderLog=%%a"
:: get status of log
set "sunFinderStatus=%subFinderLog:~20,1%"

if "%sunFinderStatus%"=="S" goto commands else (
    cls
    goto restart
)

::skip import sub
:importNoSub
echo --qt-updates-notif>>%Commands%commands.txt


::-------Step 5-------
::get VLC option commands --> get VLC option commands from commands file line by line
:commands
for /f "tokens=*" %%x in (%Commands%commands.txt) do call set "options=%%options%% %%x"
cls
echo:
echo:
echo:
echo \033[%fGreen% options confirmed \033[0m | %style%
echo:
::show VLC output info
echo \033[%fCyan% movie name: %fileName% \033[0m | %style%
echo \033[%fCyan% import sub: done \033[0m | %style% 
echo:
echo \033[%fYellow% launching an instance of VLC ------- 100%% \033[0m | %style%
echo \033[%fYellow% set parameter arguments ------------ 100%% \033[0m | %style%

popd

::-------Step 6-------
::result --> open VLC by VLC.exe [options] [stream]
:play
echo:
echo ^*This console will close automatically after the movie ends, but you can close me now.

:: open VLC with paramters
pushd %vlcPath%
vlc%options% %stream%
popd
goto quit


:playlist
set /p playlist=<%Database%playlist.xspf
if not "%playlist%"=="<?xml version="1.0" encoding="UTF-8"?>" (
    echo \033[%fRed% You have no playlists^^!, make one first. \033[0m | %style%
    goto stream
)
cls
echo:
echo:
echo:
echo \033[%fGreen% playlist confirmed \033[0m | %style%
echo \033[%fGreen% options  confirmed \033[0m | %style%
echo:
::show VLC output info
echo \033[%fCyan% movie name: playlist \033[0m | %style%
echo \033[%fCyan% import sub: done \033[0m | %style%
echo:
echo \033[%fYellow% launching an instance of VLC ------- 100%% \033[0m | %style%
echo \033[%fYellow% set parameter arguments ------------ 100%% \033[0m | %style%
echo:
echo ^*This console will close automatically after the movie ends, but you can close me now.

:: open VLC with paramters
start /wait "" %Database%playlist.xspf

goto quit

:: reset current playlist by user
:resetPlaylist
cls
echo \033[%fYellow% --------------------- \033[0m | %style%
echo |set /p="Reset playlist (Y/N)? "
for /f delims^= %%g in ('choice /c YN /n /t 20 /d Y') do if /i "%%g"=="N" (
    set "change=no"
    goto restart
)
set "change=yes"
echo Y
echo \033[%fYellow% --------------------- \033[0m | %style%

break>%Database%playlist.xspf
timeout 3 /nobreak >nul
goto restart


::exit --> goodbye, endlocal, terminate
:quit
pushd %~dp0
echo:
echo:
echo | set /p=">"
echo \033[%fCyan% I hope you enjoyed watching^^! \033[0m | %style% 
timeout 2 /nobreak >nul
cls
goto restart

:: fix the detected problem
:fix
if "%change%"=="Commands" (
    mkdir %change%
    goto fixed
)

if "%change%"=="commands.txt" (
    type nul > %Commands%%change%
    (
       echo --play-and-exit
       echo --qt-continue=2
       echo --no-stats
       echo --clock-synchro=0
       echo --role=video
       echo --preferred-resolution=-1
       echo --fps=144
       echo --no-video-title-show
       echo --qt-name-in-title
       echo --swscale-mode=8
       echo --directx-3buffering
       echo --direct3d11-hw-blending
       echo --avcodec-hw=d3d11va
       echo --avcodec-skiploopfilter=4
       echo --postproc-q=6
       echo --sout-mp4-faststart
       echo --sout-deinterlace-phosphor-chroma=4
       echo --sout-x264-preset=ultrafast
       echo --sout-x264-tune=film
       echo --sout-x264-level=51
       echo --sout-x264-profile=high444
       echo --sout-x264-bluray-compat
       echo --antiflicker-softening-size=31
       echo --src-converter-type=0
       echo --network-caching=333
       echo --mtu=1492
       echo --aout=directsound
       echo --directx-volume=0.8
       echo --qt-max-volume=200
       echo --no-audio-time-stretch
       echo --force-dolby-surround=1
       echo --stereo-mode=5
       echo --sout-speex-mode=2
       echo --sout-speex-quality=10
       echo --speex-resampler-quality=10
       echo --captions=708
       echo --subsdec-encoding=UTF-8
       echo --subsdec-autodetect-utf8
       echo --no-sub-autodetect-file
       echo --sub-file=._\
    ) > %Commands%%change%
    goto fixed
)

if "%change%"=="Pcommands.txt" (
    type nul > %Commands%%change%
    (
       echo ^<vlc:option^>playlist-autostart^</vlc:option^>
       echo ^<vlc:option^>qt-continue=2^</vlc:option^>
       echo ^<vlc:option^>no-stats^</vlc:option^>
       echo ^<vlc:option^>clock-synchro=0^</vlc:option^>
       echo ^<vlc:option^>role=video^</vlc:option^>
       echo ^<vlc:option^>preferred-resolution=-1^</vlc:option^>
       echo ^<vlc:option^>fps=144^</vlc:option^>
       echo ^<vlc:option^>no-video-title-show^</vlc:option^>
       echo ^<vlc:option^>qt-name-in-title^</vlc:option^>
       echo ^<vlc:option^>swscale-mode=8^</vlc:option^>
       echo ^<vlc:option^>directx-3buffering^</vlc:option^>
       echo ^<vlc:option^>direct3d11-hw-blending^</vlc:option^>
       echo ^<vlc:option^>avcodec-hw=d3d11va^</vlc:option^>
       echo ^<vlc:option^>avcodec-skiploopfilter=4^</vlc:option^>
       echo ^<vlc:option^>postproc-q=6^</vlc:option^>
       echo ^<vlc:option^>sout-mp4-faststart^</vlc:option^>
       echo ^<vlc:option^>sout-deinterlace-phosphor-chroma=4^</vlc:option^>
       echo ^<vlc:option^>sout-x264-preset=ultrafast^</vlc:option^>
       echo ^<vlc:option^>sout-x264-tune=filmv^</vlc:option^>
       echo ^<vlc:option^>sout-x264-level=51^</vlc:option^>
       echo ^<vlc:option^>sout-x264-profile=high444^</vlc:option^>
       echo ^<vlc:option^>sout-x264-bluray-compat^</vlc:option^>
       echo ^<vlc:option^>antiflicker-softening-size=31^</vlc:option^>
       echo ^<vlc:option^>src-converter-type=0^</vlc:option^>
       echo ^<vlc:option^>network-caching=333^</vlc:option^>
       echo ^<vlc:option^>mtu=1492^</vlc:option^>
       echo ^<vlc:option^>aout=directsound^</vlc:option^>
       echo ^<vlc:option^>directx-volume=0.8^</vlc:option^>
       echo ^<vlc:option^>qt-max-volume=200^</vlc:optionv^>
       echo ^<vlc:option^>no-audio-time-stretch^</vlc:option^>
       echo ^<vlc:option^>force-dolby-surround=1^</vlc:option^>
       echo ^<vlc:option^>stereo-mode=5^</vlc:option^>
       echo ^<vlc:option^>sout-speex-mode=2^</vlc:option^>
       echo ^<vlc:option^>sout-speex-quality=10^</vlc:option^>
       echo ^<vlc:option^>speex-resampler-quality=10^</vlc:option^>
       echo ^<vlc:option^>captions=708^</vlc:option^>
       echo ^<vlc:option^>subsdec-encoding=UTF-8^</vlc:option^>
       echo ^<vlc:option^>subsdec-autodetect-utf8^</vlc:option^>
       echo ^<vlc:option^>no-sub-autodetect-file^</vlc:option^>
    ) > %Commands%%change%
    goto fixed
)

if "%change%"=="Database" (
    mkdir %change%
    goto fixed
)

if "%change%"=="vlcLocation.txt" (
    type nul > %Database%%change%
    (
        echo C:\Program Files\VideoLAN\VLC
    ) > %Database%%change%
    goto fixed
)

if "%change%"=="subLocation.txt" (
    type nul > %Database%%change%
    goto fixed
)

if "%change%"=="playlist.xspf" (
    type nul > %Database%%change%
    goto fixed
)

if "%change%"=="help.txt" (
    type nul > %Help%%change%
    (
       echo Commands:                   Action:
       echo:
       echo ver                         find current version
       echo -help, -h                   help for other help commands
       echo exit, bye, 5                exit
       echo reset                       reset app
       echo reset sub, 0                reset subtitle setting
       echo play playlist, 1            play last playlist
       echo reset playlist, 2           clear playlist
       echo:
       echo vlc -h                      help about set vlc location path to run
       echo sub -h                      help about subtitles
       echo commands -h                 help about set VLC option commands
       echo url -h                      help about valid URLs
       echo playlist -h                 help about playlists
       echo error -h                    help about errors
       echo:
       echo:
       echo *You can also use /? instead of -h
    ) > %Help%%change%
    goto fixed
)


:fixed
pushd %~dp0
echo | set /p="|"
echo \033[36m Fixed \033[0m | %style%
echo:
echo:

:restart
if "%change%"=="no" cls
if "%change%"=="yes" echo:
endlocal
goto start

:exit
echo:
echo:
echo | set /p=">"
echo \033[%fCyan% Bye, bye^^! \033[0m | %style%
timeout 2 /nobreak >nul
endlocal
exit /b 0


:: help
:help
cls
type %Help%help.txt
goto helpEnd


:: help about vlc
:helpVlc
cls
type %Help%vlc.txt
goto helpEnd


:: help about subtitle
:helpSub
cls
type %Help%subtitle.txt
goto helpEnd


:: help about VLC commands option
:helpCommands
cls
type %Help%commands.txt
goto helpEnd


:: help about valid URLs
:helpUrl
cls
type %Help%url.txt
goto helpEnd


:: help about playlists
:helpPlaylist
cls
type %Help%playlist.txt
goto helpEnd


:: help about errors
:helpError
cls
type %Help%error.txt
goto helpEnd


:: current version
:version
cls
echo amoAR VLC CLI - Stream HTTP source
echo Version 1.0.0
echo All rights reserved.
goto helpEnd


:: end of help
:helpEnd
echo:
echo:
echo \033[%fYellow% --------------- \033[0m | %style%
echo | set /p="Exit guide? (Y) "
choice /c Y /n
cls
goto restart


:: reset all
:resetAll
cls
echo \033[%fYellow% ----------------------------------------------- \033[0m | %style%
echo | set /p="Reset app (Y/N)? This will delete all your data"
for /f delims^= %%g in ('choice /c YN /n') do if /i "%%g"=="N" (
    set "change=no"
    goto restart
)
set "change=yes"
echo Y
echo \033[%fYellow% ----------------------------------------------- \033[0m | %style%

echo:
echo:
echo Do not close the program during the process^^!
echo ...
del /s /q %Commands%
del /s /q %Database%
del /q %Help%help.txt
echo Done.
echo Wait until the program restarts automatically and then files and folders are overwritten
timeout 7 /nobreak >nul
goto restart