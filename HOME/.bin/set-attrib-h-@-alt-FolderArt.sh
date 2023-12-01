#!/bin/bash
# -------------------------------------------
# Hide alternate-named FolderArt jpg files
# -------------------------------------------
# `attrib` cmd fails unless path is basename.ext only
find -type f \( \
  -iname 'Folder*.jpg' \
  ! -iname 'Folder.jpg' \
  ! -iname 'folder_background.jpg' \) \
  -exec bash -c 'pushd "${@%/*}"; attrib +h "${@##*/}"; popd' _ {} \;

exit 

	# create log to process per batch script @ Windows Command Line
	find -type f \( \
		-iname 'Folder*.jpg' \
		! -iname 'Folder.jpg' \
		! -iname 'folder_background.jpg' \) \
		-exec cygpath -aw {} \; >> find.log
		
	# @ Windows Command Line

		# directly
		
			# for /f "delims=" %x in ('type "D:\find.log"') do ( attrib +h "%~x" )

		# script 
		
			# @echo off 
			# for /f "delims=" %%x in ('type "D:\find.log"') do ( attrib +h "%%~x" )

