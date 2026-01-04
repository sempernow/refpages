@echo off 
goto :eof

:: TrueCrypt (7.x) Compatibility Mode Option
/tc
 
:: Mount volume @ T:\
start VeraCrypt-x64.exe /l T /k "%_KEYFILE_PATH%" /p %_PASS% /q background /s /v "%_SOURCE_PATH%" /h n /c n

:: Dismount all [forcibly], wipe pw cache, & quit
start VeraCrypt-x64.exe /d /q /s /f /w 

:: Dismount one volume [forcibly]
start VeraCrypt-x64.exe /d %_DRIVE_LETTER% /s /f 
