@echo off
IF "%~1" == "" ( CALL _edit %~f0 & GOTO :EOF )
cls & echo. & title %~n0
SETLOCAL

SET _quality=-quality 100


:END
ENDLOCAL
GOTO :EOF
*********

ImageMagick.bat

mogrify -grayscale Rec709Luma %_quality% %*
mogrify -channel gray -despeckle %_quality% %*
mogrify -white-threshold 65%% %_quality% %*
mogrify -gamma 1.6 %_quality% %*
mogrify -contrast -contrast -contrast %_quality% %*
mogrify -contrast-stretch 0 %_quality% %*
mogrify -brightness-contrast -10x50 %_quality% %*


mogrify -mattecolor gray -frame 25x25+0+25 bkgnd.jpg
mogrify -mattecolor gray -frame 25x25+25+0 bkgnd.jpg

convert "target.jpg" -fuzz 40% -transparent white "target.png"

mogrify -bordercolor white -border 80 

rem -- add border --
mogrify -bordercolor #eeeeee -border  5 -quality 100 *.jpg
mogrify -bordercolor white   -border 80 -quality 85  *.jpg

convert -size 1043x716 canvas:white 

convert -size 1043x716 xc:#ff0066 
convert -size 1043x716 xc:rgba(250,250,255,1) 

mogrify +noise gaussian -attenuate 0.1 -quality 100 


mogrify -contrast-stretch 30x30 %_quality% %*
mogrify -contrast-stretch 1x1 %_quality% %*


mogrify -grayscale Rec709Luma %_quality% %*
mogrify -channel gray -despeckle %_quality% %*
mogrify -white-threshold 65%% %_quality% %*
mogrify -gamma 1.6 %_quality% %*
mogrify -contrast -contrast -contrast %_quality% %*

mogrify -channel gray -auto-gamma %_quality% %*
mogrify -level 2%%,98%%,1.5 %_quality% %*

convert %*-grayscale Rec709Luma %_quality% %*
convert %*-despeckle %_quality% %*
convert %*-white-threshold 65%% %_quality% %*
convert %*-gamma %_quality% 1.6 %*
convert %*-contrast -contrast -contrast %_quality% %*
		