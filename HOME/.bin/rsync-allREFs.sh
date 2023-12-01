#!/bin/bash
_rs() {
	REQUIREs errMSG rsync
	[[ -d "${_REFs_STAGING}" ]] || { errMSG 'REFs folder NOT EXIST @ STAGING'; return 86; }
	[[ -d "$_WIN_IT_PATH" ]] || { errMSG '$_WIN_IT_PATH NOT EXIST'; return 86; }
		#find "$_WIN_IT_PATH" -type f \( -name 'REF.*' ! -iname '*.lnk' ! -iname '*~' ! -iname '*.swp' \)  -printf "%p\n"

		_allREFs=$( find "$_WIN_IT_PATH" \( -name 'REF.*' ! -iname '*.lnk' ! -iname '*~' ! -iname '*.swp' \) -type f -printf "%p\n" )
		
		# PUSH ...
		printf "\n %s\n\n"   'Push :: _WIN_IT_PATH  ==>  STAGING'
		printf "$_allREFs" | xargs -I {} bash -c 'rsync -itu "$@" "${_REFs_STAGING}/"' _ {} 
		# PULL ... [per checksum [-c], not mtime]
		printf "\n\n %s\n\n" 'Pull :: _WIN_IT_PATH  <==  STAGING'
		printf "$_allREFs" | xargs -I {} bash -c 'rsync -ituc "${_REFs_STAGING}/${@##*/}" "$@"' _ {}
		
	exit

	# PUSH ...
	printf "\n %s\n\n"   'Push :: _WIN_IT_PATH  ==>  STAGING'
	find "$_WIN_IT_PATH" -type f \
	  \( -name 'REF.*' ! -iname '*.lnk' ! -iname '*~' ! -iname '*.swp' \) \
	  -exec bash -c 'rsync -itu "$@" "${_REFs_STAGING}/"' sh {} \+

	# PULL ... [per checksum [-c], not mtime]
	printf "\n\n %s\n\n" 'Pull :: _WIN_IT_PATH  <==  STAGING'
	find "$_WIN_IT_PATH" -type f \
	  \( -name 'REF.*' ! -iname '*.lnk' ! -iname '*~' ! -iname '*.swp' \) \
	  -exec bash -c 'rsync -ituc "${_REFs_STAGING}/${@##*/}" "$@"' sh {} \;
}

_rs "$@"
