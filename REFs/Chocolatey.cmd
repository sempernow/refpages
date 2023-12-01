@echo off
:: =========================================================
::  Chocolatey :: Command Reference  
:: 
::  https://chocolatey.org/
::  https://chocolatey.org/docs/commands-reference
:: =========================================================
echo. & echo   Chocolatey :: Command Reference
type "%~f0"
echo. & pause 
goto :eof
*********
:: ===  COMMANDs  ===
choco -?  
choco search %_PKG_NAMEs%
choco list --lo
choco install %_PKG_NAMEs% -y 
choco upgrade %_PKG_NAMEs% -y 