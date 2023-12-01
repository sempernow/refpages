@echo off
CALL _edit "%~f0" & GOTO :EOF
rem ---------------------------------------------------------
rem  DO NOT EXECUTE this file
rem ---------------------------------------------------------
rem  Command syntax | examples
rem
rem 	http://itsvista.com/topic/commands/
rem 	http://ss64.com/nt/for_r.html
rem
rem  The special characters requiring ^ or quotes:
rem      	<space>
rem      	&(){}^=;!'+,`~
rem
rem  The ampersand (&), pipe (|), and paren ( ) are 
rem  special chars which must be preceded by the escape 
rem  character "^", or quot. marks when passed as arguments.
rem ---------------------------------------------------------
GOTO :EOF

:: -- REG.exe :: QUERY/ADD keys --
REG /? 
:: query add delete copy save restore load unload compare export import flags 

:: ROOTKEY  [ HKLM | HKCU | HKCR | HKU | HKCC ]
::   current user root-key
::     HKCU [HKEY_CURRENT_USER]
::   machine-wide root-key
::     HKLM [HKEY_LOCAL_MACHINE]
REG EXPORT KeyName FILEpath [/y]
REG SAVE KEYname FILEpath [/y]
REG LOAD KEYname FILEpath 

:: Load keyfile; suppress confirmation popup
REGEDIT /s FILEpath

REG query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont"
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont" /v 000 /t REG_SZ /d "Source Code Pro Light"

rem -- set default console font --
REG ADD HKCU\Console /v FaceName /t REG_SZ /d "Courier New" /f
rem -- set console font size --
REG ADD HKCU\Console /v FontSize /t REG_DWORD /d 20 /f

rem -- UTF-8 support [careful; broke commands last try]
REG ADD HKCU\Console /v CodePage /t REG_DWORD /d 65001 /f

rem -- RegEdit.exe :: EXPORT a key or entire registry --
RegEdit /e "%TEMP%\%_fname%" %_key%

	rem -- key-root :: expand [if needed] --
	FOR %%X IN ( "HKCR=HKEY_CLASSES_ROOT" "HKCU=HKEY_CURRENT_USER" "HKLM=HKEY_LOCAL_MACHINE" "HKU=HKEY_USERS" "HKCC=HKEY_CURRENT_CONFIG" ) DO ( CALL SET _key=%%_key:%%~X%%)
	
	rem -- fname :: set per key-param --
	SET _fname=%_key:\=_%

	rem -- fname :: shorten --
	FOR %%X IN ( "HKEY_CLASSES_ROOT=HKCR" "HKEY_CURRENT_USER=HKCU" "HKEY_LOCAL_MACHINE=HKLM" "HKEY_USERS=HKU" "HKEY_CURRENT_CONFIG=HKCC" ) DO ( CALL SET _fname=%%_fname:%%~X%%)

rem -- Command EXTENSIONS ENABLED/DISABLED 
HKEY_CURRENT_USER\Software\Microsoft\Command Processor
"CompletionChar"=dword:00000009
"DefaultColor"=dword:00000000
"EnableExtensions"=dword:00000001
"PathCompletionChar"=dword:00000009

PowerShell

get-help about_signing
set-executionpolicy remotesigned

rem -- run powershell script from batch file --
Powershell.exe -executionpolicy remotesigned -File  "Get_Acl.ps1"
rem -- version info --
Get-Host 
rem -- ACL info --
Get-Acl %1 | Format-List
rem -- ACL info ; handle paths containing square-brackets --
Get-Item -LiteralPath %1 | Get-Acl | Format-List


rem -- delete empty dirs
for /f "delims=" %%d in ('dir /s /b /ad ^| sort /r') do rd "%%~d"

rem -- root --
PUSHD \
rem -- parent dir of this script [unless] --
PUSHD "%~dp0..\"

rem -- mute echo status on unset var [no ouput if unset] --
echo.%* 
  rem -- ... replaces ... --
  IF NOT "%~1" == "" ( echo %* )

rem -- MM:SS --
echo %TIME:~3,5%

rem -- prevent run on double-click, while bypassing w/ param ---
IF "%~1" == "" ( CALL _edit "%~f0" & GOTO :EOF )

rem -- test if path is drive-root --
IF "%~f1" == "%~d1\" ( echo path is @ root )

rem -- MATH :: increment var --
SET /a _count+=1

rem -- set dynamic var inside a for-loop, or if-loop --
rem -- overcome delayed expansion problem            --
FOR /l %%i IN ( 1, 1, 3 ) DO ( CALL SET _this=%%_this%%%%i & echo %_this% )
rem -- or --
SETLOCAL EnableDelayedExpansion
set VAR=before
if "%VAR%" == "before" (
	set VAR=after
	if "!VAR!" == "after" @echo If you see this, it worked
)

rem -- read text; space is like new line --
FOR %%S IN (%_some_txt%) DO ( echo %%S)

rem -- iterate through list of strings --
FOR %%X IN ( str1 "str two" str3 str4 "and 5" ) DO ( echo %%~X)

rem -- str replacement [if substr] --
FOR %%a IN ( "adjust=ADJUST" "convert=CONVERT" "resize=RESIZE" ) DO ( 
	CALL SET _action=%%_action:%%~a%%
)
rem -- OR ... 
rem -- str replacement [if perfect match only] --
FOR %%a IN ( ADJUST CONVERT RESIZE ) DO ( 
	IF /I "%_action%" == "%%a" ( SET _action=%%a) 
)
	
rem -- show all files @ folder --
FOR %%F IN ("%_folder%\*.*") DO ( echo %%~nxF)

rem -- list all log files in current dir  --
FOR %%D IN (*.log) DO ( echo  %%~nD)

rem -- process all folders [e.g., set attrib]; full depth; per abs, fully-qual path --
for /r %D in (.) do ( attrib +r "%~fD" )
rem -- if in script ... --
for /r %%D in (.) do ( attrib +r "%%~fD" )

rem -- loop - simple iteration --
FOR /L %%I IN (start#, step#, stop#) DO ( CALL :this %%I )

rem -- E.g., countdown --
FOR /L %%A IN (%_secs%,-1,0) DO ( 
	echo %~n0 :: %%A
	TIMEOUT /T 1 > nul
)

rem -- loop through subfolders --
FOR /D %%F IN ("%_folder%\*") DO (  ...

rem -- loop through all files in all subfolders --
FOR /R %%X IN (*) DO ( ...

rem -- loop through all files in all subfolders under %_path% --
FOR /R "%_path%" %%X IN (*) DO ( ...

rem -- list dir tree [paths] of %CD%; all subfolders [recurse]  --
FOR /R %%D IN (.) DO ( echo  %%~fD)
rem NOTE on above: prepends ".\" to dirname, so use expansion [%%~fD]

rem -- delete all (sub)folders named %_str% --
FOR /R "%~f1" %%F IN (.) DO ( IF "%%~nxF"== "%_str%" ( RD /S /Q "%%~fF") )

rem -- process [read] a file; NEVER USE; has issues; see fix [below] --
FOR /F %%A IN (path)  DO ( SET _var=%%A)

rem -- process a command-output, e.g., set a variable to it --
FOR /F %%A IN ('command') DO ( SET _var=%%A)

rem -- process a string --
FOR /F %%A IN ("string")  DO ( SET _var=%%A)

rem -- read all text in file, line by line --
FOR /F "delims=" %%L IN (%_some_txt_file%) DO ( echo %%L)
rem -- PROBLEM: in above: quotes NOT allowed, so file-path can't have spaces --
rem -- FIX: how to read file @ ANY path, line by line --
FOR /F "delims=" %%L IN ('TYPE "%_path%"') DO ( echo %%L)

rem -- delims can be set to multiple delimiters --
"delims=, ;" rem -- treats comma, space, and semicolon all as delimiters --

rem -- PARSE string OR command-output --
rem    skip 1st line, pass tokens 2,5,6,7,8,9,10,... to a,b,c,d,e where e is 8,9,10,... --
FOR /F "skip=1 eol=; tokens=2,5-7* delims= " %%a IN ("%_str%") DO ( CALL :DO %%a %%b %%c %%d %%e )
rem -- default eol is ";", so don't need it in that case --
FOR /F "eol=; tokens=2,5-7* delims= " %%a IN ('command') DO ( CALL :DO %%a %%b %%c %%d %%e )

rem -- E.g., flag substring found in command output --
FOR /F "delims=" %%a IN ('NET VIEW 2^> nul ^| FIND /I "%substring%"') DO ( SET _flag=%%a)

rem -- parse SPACE-DELIMITED parameters ... --

rem -- E.g., parse %* :: lop off 1st positional param [%1]; NOTE param w/ quotes are preserved; also 'echo.%_var%' syntax silences echo status ["echo is ON/OFF"] on unset variable --
FOR /F "tokens=1* delims= " %%a IN ('echo.%*') DO ( SET _all_but_first=%%b)

rem -- handle MORE than nine [%1, %2,...,%9] positional PARAMeters --
FOR /F "tokens=1-15 delims= " %%a IN ('echo.%*') DO ( echo 11[%%k] 12[%%l] 13[%%m] 14[%%n] 15[%%o] )
rem -- assign all params above %9 to one variable --
FOR /F "tokens=1-9* delims= " %%a IN ('echo.%*') DO ( SET _options=%%j)

rem -- test/validate %_path% path exist in %PATH% Env. Var. --
FOR /F "delims=" %%a IN ("%_path%") DO ( SET _RESULT=%%~$PATH:a)

rem -- using backquotes allows double-quotes in command --
for /f "tokens=2 usebackq delims==" %a in (`command`) do echo %b

rem -- VARIABLE EXPANSION; EXPANDING VARIABLES ... [ @ command-line, use % instead of %% ]

	set _foo=bar
	%_foo:a=z%      bzr
	%_foo:a=%       br
	%_foo:~2%       r 
	%_foo:~1,2%     ar

	rem -- Expanding positional parameters (inherent variables) %0, %1, %2, ...
		
		%~f0		- current batch file fully qualified path/fname
		%~n0		- current batch file fname
		%~1			- removes any surrounding quotes from %1

	rem -- DIFFERING behavior per c: vs. c:\  @ drive root-case --
	@ %CD% = S:\SCRATCH
	 
	%*	s:
	******
	%~f1	S:\SCRATCH
	%~d1	S:
	%~p1	\
	%~dp1	S:\
	%~nx1 	SCRATCH

	%*	s:\
	*******
	%~f1	s:\
	%~d1	s:
	%~p1	\
	%~dp1	s:\
	%~nx1

	for /f "delims=" %%G in (...) do ( ...)

	    %%~G         - expands %%G removing any surrounding quotes (")
	    %%~fG        - expands %%G to a fully qualified path name 
	    %%~dG        - expands %%G to a drive letter only
	    %%~pG        - expands %%G to a path only
	    %%~nG        - expands %%G to a file name only
	    %%~xG        - expands %%G to a file extension only
		
	    %%~sG        - expanded path contains short names only 
					 - I.e., "8.3" names. E.g., "R:\123456~1.123"
					 
	    %%~aG        - expands %%G to file attributes of file
	    %%~tG        - expands %%G to date/time of file
	    %%~zG        - expands %%G to size of file
		
					COMBINE them ...
		%%~dpG  	- drive and path
		%%~nxG		- filename with extension

		%%~$PATH:G	- expands %%G to qual. path if exists in Env. Var., else null.
					  E.g., if %PATH% contains C:\Windows\System32\WindowsPowerShell\v1.0\,
							and %1 is WindowsPowerShell, or system32\WindowsPowerShell, 
							then %~$PATH:1 is C:\Windows\System32\WindowsPowerShell.
							If %PATH% does not contain the dir-name, or relative path, then it's nul.

					rem -- if %_path% path exist in %PATH% Env. Var., then result set to %_path%, else to nul --
					FOR /F "delims=" %%a IN ("%_path%") DO ( SET _RESULT=%%~$PATH:a)
						
rem -- ATTRIB; add read-only, NOT-content-indexed to folder, subs, & files --
ATTRIB +r +i this_folder /S /D

rem -- ROBOCOPY; all subs, files data/attrib/tstamp, folder tstamp --
ROBOCOPY "%_source%" "%_target%" /E  /COPY:DAT /DCOPY:T
rem -- copy only certain files; all subfolders --
ROBOCOPY "%_source_dir%" "%_target_dir%" %_files% /S

rem -- run 1 then 2 --
command1 & command2
rem -- run 2 if 1 is successful --
command1 && command2 

rem -- run 2 if 1 fails --
command1 || command2

rem -- params are delimited with ";" or "," or blank space --
command1 param1;param2

rem -- equivalent in a script --
GOTO :EOF
EXIT /B 

rem -- start exe from .bat file; script waits for program to end --
some-program.exe
rem -- start exe from .bat file in temporary child process in current window; vars/env not available to parent script; parent script waits for program to end --
cmd /c some-program.exe

rem -- start exe from...; program is @ %_folder%; script waits... --
"%_folder%\some-program.exe" %_params%
rem -- start exe from bat file in separate process; script does NOT wait; new window remains open after its script ends --
START some-program.exe
rem -- start exe in separate process, and wait for it to close.
START /WAIT some-program.exe
START "the title" foo.exe && call bar.bat

rem -- START new cmd window, launch script w/ params --
rem    script path :: script must exist in CD or path in PATH Env. Var.
START script.bat p1 "p 2" p3
START /MIN script.bat p1 "p 2" p3
START /WAIT /MIN script.bat p1 "p 2" p3
rem -- NOTE: script-path can NOT be in quotes --

rem -- START new cmd window, and launch script w/ params, close when done --
START cmd /c script-name.bat p1 "p 2" p3 
START cmd /c "%path%\script-name.bat" p1 p2 p3 
rem -- NOTE: limitations on params if script-path quoted --

rem -- same as above, but keep window open --
START cmd /k "%path%\script-name.bat" p1 p2 p3 

rem -- start EXEcutable w/out new window, & wait until completion --
rem    NOTE: "^" continues command on next line.
START /WAIT /B sendEmail.exe ^
-f %_FROM% ^
-t %_TO% ^
-a "%_folder%\%_file%"

rem -- Go to URL @ default browser --
START "need quoted str here" "http:\www.google.com"

rem -- run VBscript from bat file; no NOT wait --
Cscript [options...] [ScriptName.vbs] [script_arguments]
Cscript //NoLogo //B my.vbs /arg1 /arg2

rem -- E.g., ...

Cscript "%~dp0invisibleBAT.vbs" "_write_log.bat %~n0 [%1] %_action% %_delay%"

rem -- suppress logo/info/errors @ stdout [no-logo, batch-mode] --
Cscript //NoLogo //B "%_VBS_SCRIPT_PATH%" "{command} param1 param2 ..."

rem -- Windows Script Host [CSCRIPT.exe] runs both .vbs and .js scripts --

rem -- using escape character 
set varname=new^&name

rem -- syntax for redirect 
CALL hello there > LOG1.LOG
echo some text here >> LOG1.LOG

rem -- std out to log; err to nul --
set _ > "%TEMP%\%~n0.log" 2> nul
rem -- std out & err to log -- 
set _ > "%TEMP%\%~n0.log" 2>&1

rem -- same thing; easier to read for long lists of such ..
>  LOG1.LOG	 CALL hello there
>> LOG1.LOG  echo some text here

rem -- redirect stdout & error to nul
command > nul 2>&1

rem -- one command, multi-lines --
CALL :TEST 	^
		P1 ^
		P2 ^
		Pn

rem ------------------------------
rem -- %DATE% and %TIME% format to "04.30.2011 [15.44.40.21]" --
SET _date=%DATE:~4%
echo %_date:/=.% [%TIME::=.%]

rem -- WARNING: PATH cmd is like SET; end space will generate ERR.
( PATH %_add_this%;%PATH%)

rem  Forcefully terminate task & child tasks 
rem  of process_id or image_name
rem ----------------------------------------
taskkill /f /t [/pid %process_id% | /im %image_name%]

rem -- is titled cmd.exe running --
TASKLIST /FI "IMAGENAME eq cmd.exe" /FI "STATUS eq RUNNING" | FIND "%_title%"
rem -- verbose, format-output: CSV, no-header 
TASKLIST %_STATUS_FILTER_STR% /V /fo CSV /nh

rem defrag with verbose report
defrag %systemdrive% -v > Defrag_C_report.txt

rem defrag with free space consolidation
defrag %systemdrive% -x

rem command window size ...
mode con cols=80 lines=25

rem PROMPT :: >
prompt $G
rem PROMPT :: drive\path>
prompt $P$G

rem -- open %this_folder% with Windows Explorer --
CALL explorer /select,%this_folder%\this_file
rem -- OR --
CALL explorer /select,%this_folder%\%subfolder%
rem -- ... both open to SAME folder [%this_folder%] --

rem -- USE QUOTES to SAFELY test for nonexistent variable --
IF "%_var%" == "" ( ... )

rem -- STRIP var of QUOTES before using in IF command -- 
SET _path="%*"
SET _path=%_path:"=%
IF [NOT] EXIST "%_path%" ( ... )

rem -- do NOT use 'DEFINED' cmd --
rem -- wrong result :: shows 'NOT "DEFINED"', regardless! [Okay if '%_var%'] --
IF DEFINED "%~1" ( echo [%1] is DEFINED ) ELSE ( echo [%1] IS NOT "DEFINED" )

rem -- get user input :: default to no --
rem    [also prevents prior query val leak in, & prevents fail on nul]
SET _query=NO
SET /P _query=Proceed ^?  [Y]   
IF /I NOT "%_query:~0,1%" == "Y" ( GOTO :EOF )

rem -- get user input :: query handler subroutine --
CALL :QUERY Purge icon cache
GOTO :EOF
:QUERY
	cls
	CALL report %*
	SET _query=
	SET /P _query=Do [Y]  
	IF /I "%_query:~0,1%" == "Y" ( SET _query=Y) ELSE ( SET _query=)
	GOTO :EOF

rem blank line ...
echo.
rem -- or --
echo/

rem Ctrl+s
rem scroll stop/pause ...
dir | more
any-command | more

rem -- pipe a command-output to clipboard --
rem   <command>| clip.exe
@echo %_str%| CLIP.exe

rem --- write to log ---
echo %_str%> "%TEMP%\%~nx0.%TIME::=.%.txt"
	
rem READ/echo a text file
rem *********************
TYPE "%_path-to-some-file%"

rem REDIRECT output -- both standard and err
rem ----------------------------------------
TYPE "%_bogus-path%" > nul 2>&1

rem -- list all rel-paths of all files containing %~1 str --
FORFILES /s /m *%~1* /c "cmd /c echo   @relpath"

rem -- get foldersize & files/dir count [incl subdirs & hidden files] -- 
FOR /f %%z in ('FORFILES /s /c "cmd /c echo @fsize"') DO ( SET /a _size+=%%~z & SET /a _fcount+=1)

rem -- delete all folders older than ...
FORFILES /M * /D -%_MAX_AGE_RECORDS% /C "CMD /c RD /S /Q @file" > nul 2>&1

rem -- write list of all fnames of today's %_log% files --
FORFILES /M %_log% /D +0 /C "CMD /c echo @file>> %_wake_log_list%" 2> nul


rem -- string substitution; every occurance is replaced --
SET _str=%_str:_replace_this=_with_this%

rem -- lop off everything but first 3 characters --
echo.%_str:~0,3%

rem -- lop off everything but last 4 characters --
echo.%_str:~-4%

rem -- lop off the last 2 characters.
echo.%_str:~0,-2%
	
rem -- lop off "_substr" & everything to its left, in %_str%--
SET _str=%_str:*_substr=%
rem -- same as above, but when _substr is a variable --
CALL SET _str=%%_str:*%_substr%=%%

rem -- lop off everything to left of "_substr", in %_str%--
SET _str=%_str:*_substr=_substr%
rem -- same as above, but when "_substr" is a variable --
CALL SET _str=%%_str:*%_substr%=%_substr%%%

rem -- extract a substing "[...]" embedded in a string --

	rem --- remove everything to the left of "[" ---
	SET _str=%_str:*[=[%

	rem --- STORE everything to the right of "]" ---
	SET _bad_right=%_str:*]=%
	
	rem -- remove STOREd from str --
	CALL SET _str=%%_str:%_bad_right%=%%

rem -- random number between 0 and 4 --
SET /A _number=%RANDOM% %% 5

rem -- variable in value --
CALL SET _s=%%_RANDOM_ARRAY_%_n%%%

rem -- var/param in varname --
SET _%~n0_params=hex 2048 29 3
CALL _randomfast %%_%~n0_params%% 	

rem -- wildcards: "*" is any str, and "?" is one char --
del ??.??.??%_known_part%*.tmp

rem -- find all selected files containing a string --
FINDSTR /i /s "foo" *.bat

rem -- display power requests --
POWERCFG -REQUESTS

rem -- Network --

Nuclear Option :: Reset ALL ...

	ipconfig /flushdns
	netsh int reset all
	netsh int ipv4 reset
	netsh int ipv6 reset
	netsh winsock reset
		
rem -- show wireless networks --
netsh wlan show all

rem -- show all users ever connected --
netsh wlan show profiles

rem -- show user/pass key info [stored keys only] --
netsh wlan show profile "%USERNAME%" key=clear

rem -- Enable Microsoft Virtual WiFi Miniport Adapter --
netsh wlan set hostednetwork mode=allow ssid=%_hotspot% key=%_key% keyUsage=persistent
rem -- Disable/delete Microsoft Virtual WiFi Miniport Adapter --
netsh wlan delete profile name="%_hotspot%"

netsh wlan show hostednetwork

netsh wlan start hostednetwork
netsh wlan stop hostednetwork

rem -- See netsh.exe.txt [none of the changes helped; was SSD speed, not LAN issue] --
netsh int tcp show global

	Querying active state...

	TCP Global Parameters
	----------------------------------------------
	Receive-Side Scaling State          : enabled
	Chimney Offload State               : automatic
	NetDMA State                        : enabled
	Direct Cache Acess (DCA)            : disabled
	Receive Window Auto-Tuning Level    : normal
	Add-On Congestion Control Provider  : none
	ECN Capability                      : disabled
	RFC 1323 Timestamps                 : disabled

netsh int tcp show heuristics
netsh int ipv4 show route

netsh wlan show all

	shows all wireless networks and channels detected.

netsh wlan show profiles
netsh wlan show drivers

netsh int ip reset
netsh advfirewall reset

rem -- interface/adapter/NIC :: show --
netsh interface show interface
rem -- interface/adapter/NIC :: Enable|Disable --
netsh interface set interface name="GbE" admin=disabled

ipconfig /all				- all tcp/ip/mac config info of this machine
ping <ip>					- test connectivity
ping -a <ip>				... also resolve host name [get it from IP]
arp -a						- ARP Table; what this machine learned of its net

nslookup 70.123.15.20		- resolve IP (find its name), using default server
nslookup <host-IP> 8.8.8.8	- resolve host-IP using google DNS server 8.8.8.8 [google]
nslookup					- for interactive mode, use no options

	nslookup                ... interactive mode ...

	> type=ptr				- reverse lookup; Name => IP 

tracert	 <target-IP>		- show path; all routers; all hops; 

netstat           Displays active connections 
	-b            ... the executable that created each connection.
	-o            ... the PID associated with each connection.
	-f            ... Fully Qualified Domain Names (FQDN) of Foreign Address
	-a            ... all connections and listening ports.
	
	-es           ... Ethernet statistics [e], sorted per protocol [s].
	-esp TCP      ... of TCP protocol only [p]
	
	-r            ... the routing table
						  
route						- manipulate network route table.
route print					- show 

nbstat						- shows protocol stats and current TCP/IP connections 
							  using NBT (NetBIOS over TCP/IP).

rem -- synchronize time @ computers on a domain [Win OS service] --
w32tm

rem -- NFS; enabled/tested NFS protocol @ Win7.SP1.64; unable to mount --
 
rem -- NFS protocol --
showmount -e \\ROUTERUSB

rem -- NFS mount [FAILed] --
mount -o mtype=hard 198.168.1.1:/tmp/mnt/WinPE *
mount -o mtype=hard router.asus.com:/tmp/mnt/WinPE *

rem -- list all services running --
NET START 

rem -- create/map admin-share to last avail drv letter ---
NET USE * \\aPC\c$ [password /user:"%USERNAME%"]

rem -- map network share to z: --
NET USE z: "\\aPC\[share-name or share-path]"
rem -- disconnect --
NET USE z: /delete
rem -- join a password protected share --
NET USE z: "\\aPC\[share-name or share-path]" %_pw% /user:"%USERNAME%"
rem -- same as above, but prompt for password --
NET USE z: "\\aPC\[share-name or share-path]"  *    /user:"%USERNAME%"

rem -- NOTE above: user-name can be domain-name\user-name --

rem -- create network share --
NET SHARE M=M:\ /GRANT:"XPC Remote",FULL /USERS:3

rem -- create network share --
NET SHARE M=M:\ /GRANT:"XPC Remote",FULL /USERS:3

rem -- del admin share [until reboot] --
NET SHARE c$ /delete

rem -- list users --
NET USER 

rem -- info per user --
NET USER "%USERNAME%"

rem -- restrict logon-from locations [NICE :: this is effectively Two Factor Auth. !!!]-- 
NET USER "%USERNAME%" /WORKSTATIONS:TrustedComputerName1,TrustedComputerName2,...8

rem -- activate / disable user account --
NET USER "%USERNAME%" /active:[yes|no] 

rem -- Add/Del user to/from group --
NET LOCALGROUP group_name UserLoginName /add
rem -- e.g. ... --
NET LOCALGROUP Administrators "%USERNAME%" /add
NET LOCALGROUP Administrators "%USERNAME%" /delete

rem -- list groups --
NET LOCALGROUP

rem -- Add/Del group --
NET LOCALGROUP group_name /add
NET LOCALGROUP group_name /delete

rem -- LIST group members on domain --
NET LOCALGROUP administrators 
NET LOCALGROUP users 


rem -- mount volume -- MOUNTVOL [drive:]path VolumeName --
MOUNTVOL G:\ \\?\Volume{e846be4e-d4c5-11df-896d-0023547cb864}\ 

rem -- remove volume "g:" [unmount] -- 
MOUNTVOL G:\  /D

rem -- File System Utility --
FSUTIL volume diskfree %~d1
FSUTIL volume dismount %~d1
rem -- change FS memory cache [MS default is 1. Max is 2.]
FSUTIL behavior QUERY MemoryUsage
FSUTIL behavior SET MemoryUsage 2
FSUTIL behavior SET MemoryUsage 1
rem -- default @ Win7.Ult.SP1.64 ==> "MemoryUsage = 0" --
rem -- and yet disk/LAN speed is MAX ~ theoretical limit --

rem -- gpedit :: CREATE SYMLINK 
rem -- Computer configuration → Windows Settings → Security Settings → Local Policies → User Rights Assignment → Create symbolic links

rem -- SYMLINKs access via LAN 
rem -- "The symbolic link cannot be followed because its type is disabled"
rem -- FIX per ... 
fsutil behavior set SymlinkEvaluation R2R:1
fsutil behavior set SymlinkEvaluation R2L:1
rem -- query/test --
fsutil behavior query SymlinkEvaluation

rem -- windows default --
fsutil behavior set SymlinkEvaluation L2L:1 R2R:0 L2R:1 R2L:0
rem -- custom --
fsutil behavior set SymlinkEvaluation L2L:1 R2R:1 L2R:1 R2L:1

rem -- Env. Vars. :: SETX :: create/change --
SETx /?
rem -- global per current user --
SETX VAR "VALUE"
rem -- global per machine [/M]--
SETX VAR "VALUE" /M
rem -- example --
SETX NET_share_PATH "\\%COMPUTERNAME%\this folder" /M

SET _this_dir=%CD%
echo.%_this_dir%
----------------------
"Open command window here"

... SHIFT & RIGHT-CLICK mouse 
(whilst mouse focus is in the folder). 

prevents command window from closing on completion ...
cmd /K - from "run" .
-------------------------------------

pause - from within cmd.exe .

command-name | more ...
Display one screen/line at a time:
dir | more 
... thereafter, spacebar forwards it quickly

cd %systemroot%
SET this_location=%userprofile%\___TEMP
cd %this_location%

no output 
somecommand > nul 

no output, no error messages
somecommand 2> nul

output to file [overwrite] ...

dir c:\ > c:\folders.txt
echo.%_accum%> %_target%

output to file [append] ...
echo.%_accum%>> %_target%

example output-to-file commands

chkdsk > c:\chk_dsk.txt
chkntfs > c:\chk_ntfs.txt
driverquery > c:\driver_query.txt
systeminfo > c:\system_info.txt

systeminfo | find "BIOS Version" ... filter out stuff

tasklist [/svc] > c:\task_list.txt
tree /a /f "d:\1 data" > c:\dir_tree.txt


Attributes ..
Super Hide
attrib +s +h  (system and hide) path/filename [/S] current folder and all sub-folders

ATTRIB [+R | -R] [+A | -A ] [+S | -S] [+H | -H] [+I | -I]
       [drive:][path][filename] [/S [/D] [/L]]
		   
----------
Clone; copy all dirs, files, hidden, system, w/ attrib & timestamps prseverved.
ROBOCOPY "%_source%" "%_target%" /E /COPYALL /DCOPY:T
----------------------------   
Copy from V: to K: everything [/e], including hidden & system files [/h], 
copy attributes [/k], and display names while copying [/f] ...
---------------------------------------------------------------------
xcopy V:\*.* K:\  /e /h /k /f         

Does NOT copy hidden or system files, reSETs readonly attribute ...
-----------------------------
xcopy V:\*.* K:\  /e /f  

rem ... to NOT copy empty folders, use /s instead of /e.

rem -- Join multiple mp3 files
copy /b *.mp3 newfile.mp3

rem compare two directories ...
fc /a c:\this\*.* c:\that\*.* > compared.txt
rem ********************************************

rem -- disk --
format in NTFS

format e: /fs:ntfs /v:volume_label /q

rem -- Admin --

tasklist
taskkill

rem -- map drive to a folder --
subst Z: c:\subfolder

rem -- open files; maintain object list --
openfiles /local [on | off]
rem -- show open files; only works if object list is "on" --
openfiles /query
rem -- disconnect open files; wildcard "*" okay
openfiles /disconnect [/s <System> [/u [<Domain>\]<UserName> [/p [<Password>]]]] {[/id <OpenFileID>] | [/a <AccessedBy>] | [/o {read | write | read/write}]} [/op <OpenFile>]

rem -- get session id of current user --
query user

rem -- find user by sesson name/ID --
query session 

rem -- example ouput during a RDC session --
R:\>query session
 SESSIONNAME       USERNAME                 ID  STATE   TYPE        DEVICE
 services                                    0  Disc
>rdp-tcp#0         XPC Remote                2  Active  rdpwd
 console                                     4  Conn
 rdp-tcp                                 65536  Listen

rem -- Logoff --
Shutdown.exe /l

rem -- logoff by session name | ID --
LOGOFF [sessionname | sessionid] [/SERVER:servername] [/V] [/VM]

rem -- logoff console [the standard local] session --
LOGOFF console /v
rem -- logoff the active session --
LOGOFF %SESSIONNAME%
rem -- logoff; but what session(s) ? --
LOGOFF

rem -- logoff everyone but user_name [does not work if names contain spaces]
FOR /f "skip=2 tokens=2,3,4" %%i in ('query session') DO ( 
       IF NOT "%%i"==user_name ( logoff %%j )
)

rem -- logoff target session-name [%1], if it's the active session --
SETLOCAL
SET _flag_session=
SET _target_session_name=%1
FOR /f "skip=2 tokens=1,2" %%i in ('QUERY SESSION') DO ( 
	IF /I "%%i" == ">%_target_session_name%" ( SET _flag_session=1) 
)
IF NOT "%_flag_session%" == "" ( LOGOFF %_target_session_name% ) ELSE ( CALL black & echo   NULL method except @ %_target_session_name% & TIMEOUT /T 5 > nul )
ENDLOCAL	
GOTO :EOF


:: Credentials Manager
cmdkey.exe
	cmdkey /list
	cmdkey /list:targetname
	cmdkey /add:targetname /user:username /pass:password
	cmdkey /delete:targetname

:: GUI
control /name Microsoft.CredentialManager

rem -- RDC - Remote Desktop Connection --

rem -- RDC :: Connect session --
MSTSC [<connection file>] [/v:<server[:port]>] [/admin] [/f[ullscreen]] [/w:<width>] [/h:<height>] [/public] | [/span] [/edit "connection file"] [/migrate] [/?]

MSTSC "%USERPROFILE%\Documents\Default.rdp" /v:%_machine%

rem -- RDC :: Disconnect session [NOT same as logoff] --
rem -- NOTE: %SESSIONNAME% Env. Var. only exists @ console cmd window, not via TaskSch --
TSDISCON 

rem -- pnputil : Export/Save all installed DRIVERs (files) : Brilliant
MD C:\Exported_Drivers
pnputil /export-driver * C:\Exported_Drivers

rem -- WMIC - Windows Management Instrumentation -- 
rem    manage certain components of Windows from the command line; 
rem    can be used to get and set all sorts of information regarding 
rem    the operating system and hardware.
WMIC [Get/Set/Call]
rem -------------------------------------------------------------------------------
rem Do NOT use WMIC's SET or CALL commands unless absolutely sure of consequences.
rem -------------------------------------------------------------------------------
rem -- show physical drives --
wmic diskdrive list brief /format:list
wmic diskdrive get Partitions,DeviceID,InterfaceType,Model 

rem -- show drives available --
wmic logicaldisk get DeviceID,VolumeName,VolumeDirty,FileSystem,Size,FreeSpace
wmic logicaldisk list brief /format:list

wmic product where name="CCCC Help Russian" call uninstall

rem -- show drive letters only, e.g., "c:" --
FOR /F "delims=" %%d IN ('wmic logicaldisk get DeviceID ^| FIND /I ":"') DO ( echo.%%d )

rem   -- Take OWNership / ACLs [access] --> Administrator / Full --
rem      If target is a folder, then all its files will be affected.

rem Target folder/file - add rights for Admins; recurse through all subfolders
rem --------------------------------------------------------------------------
TAKEOWN /F "%_target%" /A /R /D Y
ICACLS "%_target%" /grant Administrators:F /T /C

rem -- Reset ACLs to parent inheritances; removes all EXPLICIT access
ICACLS D:\files /reset /T /C /L /Q

rem Target folder/file - NO recurse
rem -------------------------------
TAKEOWN /F "%_target%" /A
ICACLS "%_target%" /grant Administrators:F /C

rem -- show all ACLs [here and below] :: <path> <Sid:perms> -- 
ICACLS "%~1" /T

rem -- e.g. --
S:\test\folders test XPC\LAN:(I)(OI)(CI)(F)
                     BUILTIN\Administrators:(I)(OI)(CI)(F)
                     NT AUTHORITY\SYSTEM:(I)(OI)(CI)(F)
					 
rem -- show if any have 'Administrators' access [nul if none] --
ICACLS "%~1" /T | find "Administrators"

ICACLS %1 ...
rem 'Sid' is USER ID; may be numerical, 'S-0-...' or English
rem 'perm' is permission[s]

	rem -- recurse --
	/T
	rem -- continue on error --
	/C
	rem -- operate on Symbolic Links, themselves, NOT their targets --
	/L
	rem -- suppress messages if successful --
	/Q

	rem -- inheritance applied only to folders, but affects files too --
	rem -- enable|disable|remove; if used, use 'r' only [removes PREVIOUSly applied]--
	/inheritance:e|d|r
	rem -- explicitly grant; replace [:r] or add previous explicit grant BY THIS Sid only
	/grant[:r] Sid:perm
	rem -- explicitly deny [don't need] --
	/deny      Sid:perm
	rem -- remove EXPLICIT access by Sid; does NOT restore inheritances --
	/remove[:g|:d] Sid
	rem -- remove EXPLICIT access by ALL Sid; restores inheritance [per parent] --
	rem -- [do NOT use @ drive root]
	/reset [/T]
	rem -- set new owner; doesn't force, as does TAKEOWN, e.g., @ system files/folders --
	/setowner Sid  [/T]
	rem -- find [if] Sid @ path; 'SID Found:...' or  'No files with ...' --
	/findsid <user-or-group-name> [/T]	
	rem -- ??? --
	/verify [/T]
	
	rem -- save/restore per ACLs file [note the difference in path settings] --
	/save    "s:\target folder"  [/T]  /C /L /Q
	/restore "s:"  /C /L /Q
	
	rem -----------------------------------------------------------------------
	rem   NOTE PATH DIFFERENCE on save/restore --

	ICACLS "%~f1" /save    ACLs.SAVE.RESTORE.log /T /L /C /Q

	ICACLS "%~dp1" /restore /substitute "%_OLD_Sid%" "%_NEW_Sid%" ACLs.SAVE.RESTORE.log /L /C /Q
	
	rem   * if saved ...     @ "s:\target folder"
	rem 
	rem   * then restore ... @ "s:"
	rem 
	rem   ACLs.SAVE.RESTORE.log [example] ...
	rem 
	rem     target folder
	rem     D:PAI(D;;CC;;;WD)(A;;0x1200a9;;;WD)(A;;FA;;;SY)(A;;FA;;;BA)
	rem -----------------------------------------------------------------------

	rem -- EXAMPLE :: cloned ACLs of a system folder from XPC to HTPC --

	ICACLS "C:\Documents and Settings" /save ACLs.SAVE.RESTORE.log /L /C /Q
	ICACLS "\\HTPC\c$" /restore ACLs.SAVE.RESTORE.log /L /C /Q

rem -- Inheritance :: these do RECURSE, so if use with '/T', need '/T' on reset too --
rem --- AVOID '/T'; so, very fast; 1 file write per entire dir tree --
	(OI)(CI)      ALL sub-folders/files AND root files; explicitly here, by inheritance below. 
	(OI)(CI)(IO)  ALL sub-folders/files, by inheritance only. NO RIGHTS HERE.
		 (CI)(IO)  ALL sub-folders/files, by inheritance only. NO RIGHTS HERE.
	(OI)    (IO)  ALL sub-folders/files, by inheritance only. NO RIGHTS HERE.	
	(I) (CI)      this folder by inheritance
	    (CI)      this folder

rem -- ***  Neither '/remove' nor '/reset' remove INHERITED rights '(I)'; --
rem --      so, inherited rights can only be changed by either ...

	rem -- by EXCLUSIVE grant ...
		ICACLS <target> /inheritance:r grant:r Sid:(...
	 
	rem -- OR --
	
	rem -- by '/inheritance:r'; removes inheritances for ALL Sid; leaves only EXPLICITs, if any
		ICACLS <target> /inheritance:r /remove Sid

rem -- ***  Neither '/inheritanc:r' nor '/grant:r' affect EXPLICIT access by OTHER Sid[s] --

rem -- ***  So, avoid explicits below drive root, otherwise changes can become tedious/slow; whereas explicit+inhert, '(OI)(CI)(*)', affect target all child objects with ONE WRITE to the ACL.


rem -- Syntax for exclusive/replace [more than one Sid] ...
ICACLS %1 /inheritance:r /grant:r "%Sid_1%":(OI)(CI)(F) /grant:r "%Sid_2%":(OI)(CI)(F) ...

rem -- This is how Windows OS does it at drive-root, for each Sid,   --
rem    so each new file/folder inherits parent ACL                   --

rem -- explicit [here only] --
	/grant:r SYSTEM:(F) 
rem -- inherited [below only] --
	/grant:r SYSTEM:(OI)(CI)(IO)(F)


rem    How to set per virgin Windows OS format NTFS, per Sid ...
rem    Shown here for 'SYSTEM' Sid only; add any/all other(s) Sid(s) in THIS ONE COMMAND, since inheritance is set per remove 'r' & grant per replace 'r' ...
 ICACLS "Q:\New folder" /inheritance:r /grant:r SYSTEM:(F) /grant:r SYSTEM:(OI)(CI)(IO)(F)

rem  1. Windows grants both explicitly [here only], and thru inheritance [below only w/ '(IO)']
rem  2. '/inheritance:r' removes PREVIOUSLY applied; analagous to '/grant:r' which repalces.
		
rem -- So, to recursively replace inherited rights w/ read-only on all at and below target ...
ICACLS %1 /inheritance:r /grant:r Sid:(R) /grant:r Sid:(OI)(CI)(IO)(R) /C 
rem -- ... the 'Sid:(R)' is for root (here) files; the '(IO)' is for all below -- 

rem -- e.g., LIST-ONLY (no file reads) access; all files in all subfolders 
ICACLS "%1" /inheritance:r /grant:r Sid:(RX) /inheritance:r /grant:r Sid:(CI)(RX)

rem -- lock/unlock per ALCs scheme [toggle recurse; off @ unlock @&for top-level [future] access]--
SET _RECURSE=/T
:LOCK
rem -- explicit; @ here only --
ICACLS %1 /inheritance:r /grant:r Administrators:(R) /C
rem -- or --
ICACLS %1 /inheritance:r /grant:r "%USERNAME%":(R) /C

rem -- thru inheritance; @ here and below --
ICACLS %1 /inheritance:r /grant:r Administrators:(OI)(CI)(R) /C
rem -- or --
ICACLS %1 /inheritance:r /grant:r "%USERNAME%":(OI)(CI)(R) /C


:UNLOCK
ICACLS %1 /reset %_RECURSE% /C

rem -- SubInAcl.exe --
SET PATH=%ProgramFiles%\Windows Resource Kits\Tools;%PATH%
SubInAcl /file "%_target%" /setowner=%_GROUP%
rem -- set owner [TAKEOWN only sets to current-user or Administrators]
SubInAcl /subdirectories "%_target%\*" /setowner=%_GROUP%
rem -- display owner --
SubInAcl /subdirectories "%_target%\*" /display=owner

rem -- shutdown --
Shutdown.exe /s

rem -- Reboot --
Shutdown.exe /r

rem -- Logoff --
Shutdown.exe /l

rem -- Hybernation on/off [persists until reset] --
POWERCFG -h on
POWERCFG -h off

rem -- Standby/Hybernate per current settings (see POWERCFG.exe) --
RunDll32.exe powrprof.dll,SetSuspendState

rem -- Standby   [untested] --
RunDll32.exe powrprof.dll,SetSuspendState Standby
rem -- Hybernate [untested] --
RunDll32.exe powrprof.dll,SetSuspendState Hybernate


rem -- boot :: BCD store --
bcdedit.exe /? /export
bcdedit.exe /export "c:\exported_boot_datastore"

rem -- Bootsect.exe [XP legacy] --
bootsect /nt60 e:

Bootsect.exe updates the master boot code for hard disk partitions to switch between BOOTMGR (nt60, used by Windows7 & Vista) and NTLDR (nt52, used by XP). You can use this tool to restore the boot sector on your computer. This tool replaces FixFAT and FixNTFS.

Bootsect Commands

Bootsect uses the following conventions:

bootsect.exe {/help | /nt52 | /nt60} {SYS | ALL | <DriveLetter:>} [/force]

For example, to apply the master boot code that is compatible with NTLDR to the volume labeled E, use the following command:

bootsect.exe /nt52 E:

-----------------------------------------

---------




