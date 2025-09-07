@echo off
:: -------------------------------------------------------------
::  ImageX.exe :: Windows 7 AIK Tool for WIM management
:: -------------------------------------------------------------
call _edit.bat "%~f0" 
if %ERRORLEVEL% GTR 0 ( notepad "%~f0" )
GOTO :EOF
*********
set _CONFIG_INI_PATH=r:\ImageX_config_GOPATH.ini

:: CAPTURE 

imagex /capture /config "%_CONFIG_INI_PATH%" "%_SOURCE_PATH%" "%_WIM_PATH%\%_WIM_NAME%.wim" "%_IMAGE_NAME%"

:: per WIM.bat (config, *.ini,  can NOT be @ GOPATH)
wim ini "%_CONFIG_INI_PATH%"
wim time 1
wim "%_SOURCE_PATH%" 

:: APPEND 

call today
imagex /append /config "%_CONFIG_INI_PATH%" "%_SOURCE_PATH%" "%_WIM_PATH%\%_WIM_NAME%.wim" "%_IMAGE_NAME%"

:: per WIM.bat (config, *.ini,  MUST NOT be @ %_SOURCE_PATH%)
wim ini "%_CONFIG_INI_PATH%"
wim time 1
wim "%_SOURCE_PATH%" "%_WIM_PATH%\%_WIM_NAME%.wim"