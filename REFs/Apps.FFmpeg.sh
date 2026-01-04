#!/usr/bin/env bash
exit
# FFmpeg  
# ======
    # "FFmpeg libav" is the set of FFmpeg libraries 
    # DOCUMENTATION  http://ffmpeg.org/documentation.html  
    # Advanced Options  https://ffmpeg.org/ffmpeg.html#Advanced-options
    # Wiki  https://trac.ffmpeg.org/wiki [GOOD]
    # INSTALLation @ Windows
    # - select/download "Release Build" > 64-bit > "Static",
    #   https://ffmpeg.zeranoe.com/builds/  [ffmpeg-3.3.3-win64-static.zip
    # - extract/copy all therein to any destination folder, 
    # - add its 'bin' folder path to PATH Env.Var. ["%ProgramFiles%\FFmpeg\bin"]
    # Tested @ [Win7]cmd + [Cygwin/MinGW64/Git]bash

# FFplay; media player that accepts ffmpeg params
    # Use to quickly assess effects of ffmpeg params, e.g., 
    ffplay -ss 00:01:00 -i TEST.mp4 -vf 'eq=contrast=1.2:gamma=1.4'

# MAP
    # Used to select certain audio and/or video stream[s]
    # from a source having many; map(s) to output.
    # https://trac.ffmpeg.org/wiki/Map
        ffmpeg ... -i ... -map 0:0 -map 0:2 -map 0:2 ...
    # ID the streams first from file meta-data 
        ffmpeg  -i IN.ANY

    # re-encode FIRST VIDEO STREAM [0], 
    # but merely copy all others [a/v/subs/...]
        ffmpeg -i IN.mkv -map 0 -c copy -c:v $CODEC OUT.mkv
        
    # MUTLIPLE OUT
        ffmpeg -i IN.mkv -map 0:1 -map 0:2 AUDIO.m4a -map 0:0 VIDEO.mkv
        # DEFAULT, sans `-map`, attempts 'highest quality' audio/video stream[s]

    # Exctract the attached POSTER IMAGE of its video file 
        ffmpeg -i IN.mkv -map 0:v -map -0:V -c copy cover.jpg
        # ... maps all (0:v) video streams (regular + attached pictures) and then use a negative mapping (-0:V) to disable all regular video streams, leaving only the attached pictures mapped. Output fname can be anything. MP4/MKV can attach pictures of codec JPEG, PNG or BMP, so find which is attached to get the correct extension.
        ffmpeg -i IN.mkv  # Prints file meta-data.

# CONVERT graphics FILETYPEs :: ANY => ANY 
    ffmpeg -i %04d.png -s hd720 -q:v 2 %04d.jpg  # indexed SEQUENCEs [dddd.xyz]
    
        -q:v $N   # aka `-qscale:v`; QUALITY; 70+ @ PNG to WebP; JPEG; 2-31; LOWER is BETTER
        -s hd720  # aka `-video_size`; reSIZE per NAME or WIDTHxHEIGHT
        -vf "$FILTERGRAPH"  # SCALE/PAD/... A/V processing; see FILTER section. 
        -pix_fmt:v rgb8     # 8 bpp ??? does nothing

    # E.g., PNG to WEBP 
    ffmpeg -i IN.png -q:v 70 OUT.webp

# CONVERT video FILETYPEs [TRANSCODE] :: ANY => ANY 
    ffmpeg -i IN.ANY -c:a copy -c:v libx264 -b:v 1200k OUT.mp4  # constant bitrate
    ffmpeg -i IN.mp4 -c:a copy -c:v libx265 -s hd720 OUT.mp4    # resize
    ffmpeg -i IN.mp4 -c:a libvorbis -c:v libvpx -crf 25 -b:v 1M OUT.webm  # HTML5

    # CONVERT Wrapper ONLY : .ts => .mp4
    ffmpeg -i IN.ts  -c:a copy -c:v copy OUT.mp4

    # E.g., from unknown to high quality H.264 (copy audio) 
        ffmpeg -i /r/IN.mp4 -c:v h264_qsv -global_quality 21 -c:a copy /s/OUT.mp4  # QSV
        ffmpeg -i /r/IN.mp4 -c:v h264 -c:a copy -crf 21 /s/OUT.mp4                 # software only 

    # E.g., cleanup, enhance, and compress MPEG-2 (mpg) animated video; mpg => HEVC (mp4)
        # @ QSV ...
        # neither maxrate nor bufsize are shown as hevc_qsv params @ `ffmpeg -? encoder=hevc_qsv`
        # neither is global_quality, BUT explicitly @ https://ffmpeg.org/ffmpeg-codecs.html#QSV-encoders
        #_QSV_opts='-load_plugin hevc_hw -preset:v slow -profile:v main -global_quality 21 -maxrate 960k -bufsize 960k' 
        _QSV_opts='-load_plugin hevc_hw -preset:v slow -global_quality 21'
        _codec="h264_qsv $_QSV_opts"
        _codec="hevc_qsv $_QSV_opts"  # https://ffmpeg.org/ffmpeg-codecs.html#QSV-encoders
        _eq='eq=contrast=1.25:gamma=1.5:saturation=1.4' # enhance
        _filter="hqdn3d, $_eq" # denoise and enhance
        _streamable='-movflags faststart' # web-optimize; make streamable; play whilst downloading
        ffmpeg -i IN.mpg $_streamable -c:v $_codec -vf "$_filter" -c:a copy OUT.mp4

    # OPTIONs
        # FRAMERATE [fps]
            -r 30  # aka `-framerate`
        # BITRATE 
            -b:v 2M -b:a 192k
            -b:v 2600k

        # CHANGE framerate & maintain quality, e.g., from 50 to 30 fps; 
            bitrate=$(( $bitrate_in * 3/5 )) # working in kbps
            ffmpeg -i IN.ANY -r 30 -c:v h264_qsv -b:v ${bitrate}k -c:a copy OUT.ANY 

        # [re]SIZE/SCALE
            -s 1280x720  # aka `-video_size`; per NAME or WIDTHxHEIGHT
                # NAMEs @ http://ffmpeg.org/ffmpeg-utils.html#Video-size
                hd720:1280x720, hd1080:1920x1080, 2k:2048x1080, 4k:4096x2160,
                ntsc:720x480, pal:720x576, spal:768x576, film:352x240, 
                vga:640x480, svga:800x600, xga:1024x768, ...  

        # [re]SIZE/SCALE per Scaling Filter
            -vf scale=WIDTH:HEIGHT  # ??? equivalent to `-s` ??? 

        # ENCODING  https://trac.ffmpeg.org/wiki/Encode/H.264

            # CODECs (video|audio)  http://ffmpeg.org/ffmpeg-codecs.html
                -c:v NAME [PARAMs]  # EQUIVs: `-codec:v ...`, `-vcodec ...`
                -c:a NAME [PARAMs]  # aac, ac3, copy (audio-passthru), ...

                # list ALL NAMEs; libx265, libx264, h264_qsv, libvpx-vp9, ... 
                    ffmpeg -codecs -hide_banner
                    ffmpeg -codecs | grep -i 'qsv'  # filtered list
                # list ALL PARAMs available PER ENCODER (and their value-ranges)  
                    ffmpeg -? encoder=NAME  # If param is not shown, then do NOT USE it.

                # ENCODER NAMEs (VIDEO)
                    libx264     # H.264 [MPEG-4 AVC]  https://trac.ffmpeg.org/wiki/Encode/H.264
                    libx265     # H.265 [HEVC]  https://trac.ffmpeg.org/wiki/Encode/H.265
                    libvpx      # VP8   [WebM]   
                    libvpx-vp9  # VP9   [WebM]  https://trac.ffmpeg.org/wiki/Encode/VP9
                    # AUDIO
                    libvorbis

                    # QSV (Intel) HW Accel.  https://ffmpeg.org/ffmpeg-codecs.html#QSV-encoders
                    mpeg2_qsv   # H.262 [MPEG-2] 
                    h264_qsv    # H.264 [MPEG-4 AVC]
                    hevc_qsv    # H.265 [HEVC]
                    mjpeg_qsv

                # DEVICE; can explicitly specify for HW ACCELeration
                    -init_hw_device qsv:hw  # hw2, hw3, hw4, auto  
                    -init_hw_device list    # list all per ffmpeg (compiled/installed version)
                    -hwaccel qsv -i ...     # use HW accel for decoding; prepend to target input stream
                    -hwaccels               # list all 
                    # https://www.ffmpeg.org/ffmpeg.html#Advanced-Video-options 

                # PROFILEs 
                    -profile:v baseline -level 3.0 # HIGHEST COMPATIBILITY
                    -tune animation                # NOT available @ QSV

            # EXAMPLE: MP4
                    -c:v libx264 -pix_fmt yuv420p -profile:v baseline -level 3.0 -crf 22 -preset veryslow -vf -movflags +faststart -threads 0  # faststart allows play before download completes; threads max-utilizes cpu
                    -c:v libx265 -x265-params crf=21

                # QSV
                    -c:v h264_qsv -preset:v slow -global_quality 21
                    -c:v hevc_qsv -load_plugin hevc_hw -b 5M -maxrate 5M out.mp4
                    -c:v hevc_qsv -load_plugin hevc_hw -preset:v slow -profile:v main -global_quality 21 

                # GitHub https://github.com/Intel-FFmpeg-Plugin/Intel_FFmpeg_plugins/wiki

                    # E.g., w/ video filters pp + eq
                    _eq='eq=contrast=1.2:gamma=1.4:saturation=1.3'
                    _codec='hevc_qsv -load_plugin hevc_hw -preset:v 7 -profile:v 1 -global_quality 21'
                    ffmpeg -i IN.mpg -c:v $_codec -vf "pp, $_eq" -c:a copy OUT.mp4

            # CODEC COPY; [SANS transcoding]; FASTEST
                -c copy    # no NOT use w/ seek/clip
                -c:a copy  # @ AUDIO stream only; audio-passthru [unaltered]      

            # QUALITY :: per BITRATE or CRF [per codec!]
        
                # per BITRATE; one-pass, constant BITRATE
                    -b:v 1200K  # +sets FILESIZE

                # per CRF; Constant Rate Factor
                    -crf 25  # 28 is DEFAULT; LOWER is BETTER quality
                    # CRF maintains OUT quality per frame; 
                    # max compression efficiency @ single pass; 
                    # sacrifices control of filesize and bitrate. 

                    -crf 0  # LOSSLESS 

                    # CRF, `-crf`; NOT AVAILABLE @ QSV; instead use ...
                        -global_quality 20  # 1-51; appox. equiv. to -crf numbers

                    # H.265 @ CRF 28 ~ H.264 @ CRF 23, but HALF filesize 

                # x264 and x265 both use this SAME scheme,
                # but for CRF method @ H.265, use
                    -x265-params crf=23 

                # QUALITY vs. SPEED; presets [NAMEs]
                # faster is smaller, but lower quality
                    -preset NAME  # NAMEs ...
                        ultrafast, superfast, veryfast, faster, fast,  
                        medium, slow, slower, veryslow and placebo  # [don't use 'placebo']

                # H.265 Two-Pass Encoding; 
                    # targets file size, NOT frame-to-frame quality.
                    # https://trac.ffmpeg.org/wiki/Encode/H.265
                        -x265-params pass=1
                        -x265-params pass=2
                        
                    # TOTAL Bitrate    = FILE SIZE / DURATION 
                    #          kbps    = MiB * [Kibit/MiB] / min * [sec/min] 
                    # E.g., 
                        200 MiB / 10 min = (200 * (1024 * 8)) / 600 
                                                         = ~2730 kbps
                             @ AUDIO Bitrate:  128 kbps, leaves (2730 - 128) kbps, 
                            so VIDEO Bitrate: 2602 kbps

                        ffmpeg -y -i IN.ANY -c:v libx265 -preset medium -b:v 2600k \
                            -x265-params pass=1 -c:a aac -b:a 128k -f mp4 /dev/null && \

                        ffmpeg -i IN.ANY -c:v libx265 -preset medium -b:v 2600k \
                            -x265-params pass=2 -c:a aac -b:a 128k OUT.mp4

                    # VP8/VP9 [WebM] QUALITY options
                    # https://trac.ffmpeg.org/wiki/Encode/VP9
                    
                    # CRF mode [MUST INCLUDE `-b:v 0`] 
                        ffmpeg -i IN.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 OUT.WebM 
                    
                    # Constant Bitrate [ALL must be EQUAL]
                        ffmpeg -i IN.mp4 -c:v libvpx-vp9 -minrate 1M -maxrate 1M -b:v 1M OUT.WebM
                
    # E.g., LOSSLESS H.264

        # @ fastest encoding
            ffmpeg -i IN.ANY -c:v libx264 -preset ultrafast -crf 0 OUT.mkv

        # @ best compression
            ffmpeg -i IN.ANY -c:v libx264 -preset veryslow -crf 0 OUT.mkv

    # E.g., AVI => MP4
    
        # CONVERT all in folder; AVI => MP4 
        # per HEVC; default quality; passthru audio
            find -maxdepth 1 -iname '*.avi' -exec sh -c \
            'ffmpeg -i "$@" -vcodec libx265 -c:a copy "${@%.*}.mp4" &' _ {} \; 
            # ... CONCURRENTLY, per bkgnd processes
            # then clone timestamps
            find -maxdepth 1 -iname '*.avi' -exec sh -c 'touch -r "$@" "${@%.*}.mp4"' _ {} \; 

    # E.g., animated GIF extract/convert 
    
        # CONVERT :: GIF => MP4  [H.265/HEVC]
                ffmpeg -i IN.gif -c:v libx265 RESULT.mp4  # 11.6 MB => 0.23 MB  !!! 
        # CONVERT :: GIF => MP4  [H.264] 
                ffmpeg -i IN.gif -movflags faststart -pix_fmt yuv420p \
                        -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" OUT.mp4  # @ Maximum compatibility 
                        # @ StackExchange.com  https://unix.stackexchange.com/questions/40638/how-to-do-i-convert-an-animated-gif-to-an-mp4-or-mv4-on-the-command-line

        # EXTRACT :: GIF => PNGs [0001.png to NNNN.png]
            ffmpeg -i IN.gif %04d.png
 
    # SLIDESHOW/ANIMATE :: PNGs => GIF  [100x BIGGER than an MP4]
        ffmpeg -r 23 -i %04d.png -s hd720 -vf format=yuv420p RESULT.gif
        # ... setting framerate, size, pixel-format of the result

    # >>>  NEVER use JPGs as source for GIF  <<<

    # PIXEL FORMAT [COLOR/CHROMA SUB-SAMPLING]
        -pix_fmts           # LIST all
        -pix_fmt yuv420p    # MAX COMPATIBILITY
        -pix_fmt yuv440p    # DEFAULT
        -vf format=NAME     # equivalent 
        -pixel_format NAME  # equivalent
        
        # FFmpeg attempts to AVOID color subsampling, which is technically preferable. Unfortunately most video players and online video services ONLY SUPPORT the 'YUV' color space with '4:2:0 chroma' SUBSAMPLING. So, for MAX COMPATIBILITY, use the 'yuv420p' pixel format. [DATED???]

    # SLIDESHOW/ANIMATE :: PNGs/JPGs [+M4A/MP3] => MP4 
    
    # https://en.wikibooks.org/wiki/FFMPEG_An_Intermediate_Guide/image_sequence
    
        # SLIDESHOW  

            # play @ 2 seconds per image:
                ffmpeg -r 1/2 -i %03d.png OUT.webm

            # force an output [video] framerate
                ffmpeg -r 1/2 -i %03d.png -r 10 OUT.webm

        # ANIMATIONS
        
        #  https://trac.ffmpeg.org/wiki/Slideshow
        #  100 PNGs [28 MB] => 1 MP4 [507 KB]
        #  Use JPG [100% quality] or PNG [4bpp] as input
            ffmpeg -r 18 -i %04d.png RESULT.mp4
            
                -r  # default is 25

            # PIPE per `-f image2pipe -i -`
                cat *.png | ffmpeg -f image2pipe -i - RESULT.mkv

            # SPECIFY FRAMEs [FIRST/TOTAL numbers] 
                -start_number $FIRST  # first frame number 
                -vframes      $TOTAL  # total number of frames

                # per NUMBER; -start_number/-vframes [first/total]
     
                    ffmpeg -start_number 100 -i %03d.png -vframes 600 OUT.mp4
                
            # LOOP one image; -loop/[-t] 
                -loop 1 [-t $SECONDS]  # for optionally limited duration

                # Loop a single image for 30 seconds
                
                    ffmpeg -loop 1 -i SOURCE.jpg -t 30 OUT.mp4
                
                # Loop a single image [mix] for DURATION of source AUDIO [-shortest]
                
                    ffmpeg -loop 1 -i IMAGE.jpg -i AUDIO.wav -c:v libx264 -c:a aac -b:a 192k -shortest OUT.mp4
                    # I.e, add an album cover or such poster image to an audio file.
                    
                    # PRESERVE AUDIO; if source audio codec is okay, then copy it [sans transcoder].
                    ffmpeg -loop 1 -i IMAGE.jpg -i AUDIO.m4a -c:v libx264 -c:a copy -shortest OUT.mp4 
        
        # H.265 [HEVC]
        # https://trac.ffmpeg.org/wiki/Encode/H.265
            ffmpeg -i %03d.jpg -c:v libx265 RESULT.mp4 
                    
            # COMPARISONS :: H.264 vs. H.265 [rendered MP4]
            
            # from JPG100: 1.6/0.47 MB  [70% smaller]
            # from PNG24:  1.2/0.67 MB  [44% smaller]
            # from PNG4:   1.5/0.33 MB  [78% smaller]

    # EXTRACT VIDEO [FRAMES] :: MKV/MP4/AVI/...  =>  JPG/PNG/... 

        # EXTRACT all frames
            ffmpeg -i IN.mp4 -s hd720 -q:v 3 %04d.jpg  
            # => 0001.jpg to dddd.jpg

                -s hd720   # resize to 1280x720
                -q:v $N    # $N:2-31 @ JPG [best to worst QUALITY]
                -qscale:v  # equivalent [set qual NOT needed @ PNG]

        # EXTRACT per framerate; `-vf fps=...`  
            ffmpeg -i IN.avi -vf fps=1/10 -q:v 3 %05d.jpg  # 6 per minute 

        # EXTRACT per I-frame; `-vf select=...`  
        # https://en.wikipedia.org/wiki/Video_compression_picture_types  
            ffmpeg -i IN.mkv -vf "select='eq(pict_type,PICT_TYPE_I)'" -vsync vfr -q:v3 %04d.jpg

        # EXTRACT ONE IMAGE @ specific TIME; `-vframes`
            ffmpeg -ss 00:02:03 -i IN.mp4 -vframes 1 OUT.jpg

        # EXTRACT ALL per LOSSLESS method, if MJPEG frames [uncommon]

            # if IN is MJPEG: EXTRACT frames LOSSLESSly per `mjpeg2jpeg` STREAMer
            # http://ffmpeg.org/ffmpeg-bitstream-filters.html#mjpeg2jpeg
                ffmpeg -i IN.avi -c:v copy -bsf:v mjpeg2jpeg %05d.jpg

                # SHOW CODEC :: TEST for MJPEG frames
                # can use `ffmpeg` or `ffprobe` here ...
                    ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1 IN.avi 
                    # => 'codec_name=mjpeg'  [if MJPEG]

    # FIX AVI/DivX :: Unpack DivX-style packed B-frames [invalid MPEG-4]
    # http://ffmpeg.org/ffmpeg-bitstream-filters.html#mpeg4_005funpack_005fbframes
        ffmpeg -i IN.avi -codec copy -bsf:v mpeg4_unpack_bframes OUT.avi

# TRIM/CUT/CLIP [sans transcoding] [INSTANTLY]    

    # SEEKING [TRIM/CUT/CLIP] :: SELECTing SPECIFIC FRAMEs
        # The process alters frame timestamps, so
        # take care when mixing or using a/v codecs 
        # https://trac.ffmpeg.org/wiki/Seeking 

    # per TIMESTAMP [HH:MM:SS]

        _START=00:01:40
        #_STOP=01:14:30
        _DURATION=01:13:00

        # IN-SEEKing is FASTest, but timestamps reset to zero.

        # -ss/-to [START/STOP]
        ffmpeg -ss $_START -i $_INFILE -to $_STOP -c copy -map 0 $_OUTFILE
            # if sans `-to ...`, then to end.

        # -ss/-t [START/DURATION]

        ffmpeg -ss $_START -i IN.mp4 -t $_DURATION -c copy -map 0 OUT.mp4
        # +Convert wrapper type : .ANY => .ANY

        ffmpeg -i OUT.mp4 -af 'afade=t=in:ss=0:d=2,afade=t=out:st=4360:d=10' -c:a aac -map 0 OUT.m4a

        # Sans in-seeking; slower, but TIMESTAMPS PRESERVED.

            ffmpeg -i $_INFILE -ss $_START -t $_DURATION -c copy -map 0 $_OUTFILE

        # per SECONDS  [SS.nnn] 

        # -ss/-to [START/STOP]
            ffmpeg -i $_INFILE -ss 4110 -to 1542 -c copy -map 0 $_OUTFILE

        # -ss/-t  [START/DURATION]
            ffmpeg -i $_INFILE -ss 4110 -t 1542 -c copy -map 0 $_OUTFILE

    # per START/FRAMES 

        # -ss/-frames [START/FRAMES]
        # e.g., to EXTRACT ONE FRAME @ 10 sec in
            ffmpeg -ss 10 -i IN.mkv -frames:v 1 -q:v 2 OUT.jpg

        # IN SEEKing; very FAST, but timestamps reset to zero, so
        # must also adjust any mix source[s]; do NOT use `-start_frame` this way 
            ffmpeg -ss 00:23:00 -i IN.mkv -frames:v 1 OUT.jpg
                -ss .. -i ... -t ... -copyts  # keep original timestamps; do NOT reset

        # OUT SEEKing; very SLOW, but timestamps aren't reset; useful for mixing
            ffmpeg -i IN.mkv -ss 00:23:00 -frames:v 1 OUT.jpg

    # per FRAME NUMBERs; -start_number/-vframes [FIRST/TOTAL]
        ffmpeg -i IN.mp4 -start_number 75 -vframes 175 OUT.mp4 
        -start_number # used here, it merely calibrates numbering
        # don't use this method for extracting
        # use it for SLIDESHOW; IMGs => VIDEO
        -start_number 75   # start frame number; not good @ extracting
        -vframes 175       # number of frames [fps * time]      

# CONCAT
    # If files' format/codec etc are IDENTICAL  
    # https://trac.ffmpeg.org/wiki/Concatenate#samecodec  
    ffmpeg -f concat -safe 0 -i $_PATHS_LIST_FILE -c copy $_OUTFILE
    # where $_PATHS_LIST_FILE (path) contains lines: 
        file 'in1.mp4'
        file 'in2.mp4'
    # (if paths of files in list are rel-paths, then `-safe 0` may be omitted.) 

    # @ VOB (series) MPEG-2 => MPEG-4, per pipeline.
    # (DVD-ripped VOB files are typically MPEG-2; H.262)
    cat VTS_01_{1..8}.VOB > VTS_01_ALL.VOB  # per brace-expansion (globbing)

            # TRANSCODE + CONCAT
            cat VTS_01_{1..8}.VOB | ffmpeg -hwaccel qsv -i - \
                -c:v h264_qsv -preset:v slow -global_quality 21 -c:a copy 'VTS_01_ALL.mp4'

    # CONCAT VIDEO (mp4) FILEs then CONVERT/EXTRACT to AUDIO (mp3) 

        # Create a paths-list file 
        find -execdir printf "file %s\n" {} \+ > $_PATHS_LIST_FILE
        # Concat mp4 files 
        ffmpeg -f concat -safe 0 -i $_PATHS_LIST_FILE -c:a copy -c:v copy out.mp4

        # Concat mp4 files, extract/convert audio to mp3  
        ffmpeg -f concat -safe 0 -i $_PATHS_LIST_FILE \
            -vn -c:a libmp3lame -ac 2 -ar 44100 -b:a 256k out.mp3

        # Concat mp4 files, extract audio (m4a), extract 1 image file
        ffmpeg -f concat -safe 0 -i $_PATHS_LIST_FILE -q:v 2 -vframes 1 POSTER.jpg -vn -c:a copy out.m4a
        
        # Add poster image to m4a file
        ffmpeg -loop 1 -r 1 -i 'POSTER.jpg' -i 'out.m4a' -c:a copy -shortest 'out2.m4a'

# CROP FRAMEs  
    # E.g., remove upper+lower 85px horizontals [bars] from a 1280x720 IN  
    ffmpeg -i IN.mp4 -filter:v "crop=1280:550:0:85" OUT.mp4
    # NOTE: not transcoding here; codec copy

        -filter:v "crop=w:h:x:y"  # [px]
            w    # width of OUT rectangle
            h    # height of OUT rectangle
            x:y  # LEFT:TOP corner of OUT rectangle

# CONVERT audio FILETYPEs [TRANSCODE] :: MP3/FLAC/AAC
    # https://trac.ffmpeg.org/wiki/Encode/MP3
    # https://trac.ffmpeg.org/wiki/AudioChannelManipulation#a5.1stereo  

    # FLAC => MP3 [PRESERVE METADATA]
    ffmpeg -i IN.flac -b:a 320k -map_metadata 0 -id3v2_version 3 OUT.mp3

    # EXTRACT AUDIO : CONVERT XYZ => MP3/FLAC/AAC
    ffmpeg -i IN.XYZ -vn -c:a libmp3lame -ac 2 -ar 44100 -b:a 256k OUT.mp3

    # ... + FADE IN/OUT : absolute time fade-in (ss) and fade-out (st), in seconds
    ffmpeg -i IN.mp4 -vn -af 'afade=t=in:ss=0:d=2,afade=t=out:st=4360:d=10' -c:a aac OUT.m4a

        # Example: Convert ALL .mp4 FILEs @ PWD
        find . -iname '*.mp4' -execdir /bin/bash -c '
            ffmpeg -i "${@}" -vn -c:a libmp3lame -ac 2 -ar 44100 -b:a 256k "${@%.*}.mp3"
        ' _ {} \+

        -c:a  # aac, libmp3lame, ...; list @ `ffmpeg -codecs`
        -q:a  # VBR QUALITY; 0-9; 0 is highest; aka `-qscale:a 2`
        -b:a  # CBR [kbps]; 8, 16, ..., 128 [DEFAULT], 160, 192, 224, 256, or 320
        -ar   # audio sampling rate, e.g., 44100, 48000; DEFAULTs to that of IN.
        -ac   # number of OUT audio channels; e.g., 5.1 => stereo
        -vn   # remove video; use, e.g., @ MP4 => M4A [ACC-audio file]
        -an   # remove audio

     # e.g., convert poorly mixed source to 2 equal [mono] channels  
         -ac 1

    # ... many options; needn't include DEFAULT options, but helps crappy players;
    # e.g., need `-ar` for WMP.exe to properly handle time-progress display 

    ffmpeg -i IN.XYZ -ac 2 -ar 44100 -b:a 256k OUT.mp3  # MUST append 'k' @ `-b:a ...`

    # CROP
    ffmpeg -i IN.XYZ -vn -ss 00:00:00 -t 00:02:50 -ac 2 -ar 44100 -b:a 256k OUT.mp3

    # FADE IN/OUT [audio filter]
        # IN:  start @ 0 sec, duration: 4 sec
        -af 'afade=t=in:ss=0:d=4'
        # OUT: start @ 160 sec, duration: 10 sec
        -af 'afade=t=out:st=160:d=10' 
        # IN,OUT :: `-af IN,OUT`
        -af 'afade=t=in:ss=0:d=3,afade=t=out:st=4620:d=10' -c:a aac
        # NOTE: audio filters are placed BEFORE codec 

    # AAC 
    # .m4a; audio component of MP4 [MPEG-4 part 3]; successor
    # https://trac.ffmpeg.org/wiki/Encode/AAC  [successor to MP3]  
    
        # clone it ...
        ffmpeg -i IN.XYZ -vn -c:a copy OUT.m4a
    
        ffmpeg -i IN.XYZ -vn -c:a aac -ac 2 -b:a 256k OUT.m4a
        
            # VBR option 
            -vbr 3  # 1-5; 1 ~ 20-32 kbps/ch; 5 ~ 96-112 kbps/ch

# EXTRACT an ATTACHED cover/poster IMAGE from its video file
        ffmpeg -i IN.mkv -map 0:v -map -0:V -c copy cover.jpg  
        # ... searches and extracts; output file can be any name.
        # ... maps all video streams (regular + attached pictures) and then use a negative mapping to disable all regular video streams (-0:V), leaving only the attached pictures mapped. MP4s can have attached pictures with codec JPEG, PNG or BMP. Check which one your file has, and correct the extension.

# EXTRACT AUDIO (m4a) from VIDEO (mp4) FILEs
    find -iname '*.mp4' -execdir /bin/bash -c \
        'ffmpeg -i "${@}" -vn -c:a copy "${@%.*}.m4a"' _ {} \;

# EXTRACT AUDIO + poster-image from VIDEO :: MP4 => M4A + 1 JPG [poster]
    # Extract a POSTER IMAGE 
    ffmpeg -ss 74.5 IN.mp4 -q:v 2 -vframes 1 POSTER.jpg

    # Extract AUDIO clip [unprocessed]; stripped of video
    ffmpeg -i 'IN.mp4' -ss 12 -to 162 -vn -c:a copy 'AUDIO_CLIP.m4a'
    #... also see above "CONCAT VIDEO (mp4) FILEs then CONVERT/EXTRACT to AUDIO (mp3)"

    # Add poster image
    ffmpeg -loop 1 -r 1 -i 'POSTER.jpg' -i 'AUDIO_CLIP.m4a' -c:a copy -shortest 'AV0.m4a'
    
    # Add audio fade in/out
    ffmpeg -i 'AV0.m4a' -af 'afade=t=in:ss=0:d=6,afade=t=out:st=146:d=4' -c:v copy -c:a aac -b:a 152k  'AV.m4a'

    # Add meta-tags
    # https://wiki.multimedia.cx/index.php/FFmpeg_Metadata#MPEG_Transport_Streams
    ffmpeg -i 'AV.m4a' -c copy -metadata author="Alice Fredenham" -metadata title="My Funny Valentine" -metadata genre="Jazz" -metadata year="2013" -metadata album_artist="Alice Fredenham" -metadata show="BGT Audition" 'OUT.m4a'
    
    # FLAC
        ffmpeg -i IN.XYZ -vn -ac 2  OUT.flac

# MIX (MUX) VIDEO + AUDIO files => MP4
    # Mux A/V
    ffmpeg -i Video.mp4 -i Audio.m4a -c copy Muxed.mp4
    # Mux A/V; mute V
    ffmpeg -i Video.mp4 -i Audio.wav \
    -c:v copy -c:a aac -strict experimental \
    -map 0:v:0 -map 1:a:0 Muxed.mp4

    # if LENGTHs DIFFER ...
        -shortest

    # Mux a STRETCHed VIDEO source to MATCH an AUDIO source. 
    # A/V sources may differ in length, FPS, and play speed.
    # Presentation TimeStamp (PTS) filter; changes that of each video frame.
    # http://trac.ffmpeg.org/wiki/How%20to%20speed%20up%20/%20slow%20down%20a%20video
        # Finding the stretch-factor: 
        # 22:29/21:31 => 22.483/21.517 = 0.9570342036205133  1/1.044894734396059
            ffmpeg -i video.mp4 -filter:v "setpts=1.045*PTS" -an video.stretched.mp4
            # mux the stretched video with the audio:
            ffmpeg -i video.stretched.mp4 -i audio.mp4 -c copy -strict experimental \
            -map 0:v:0 -map 1:a:0 -shortest muxed.mp4 

        # ALT solution is to mod video FPS to that of audio source, 
        # `-r 29.97`, but requires re-encoding video.
            ffmpeg -i video.mp4 -i audio.mp4 \
            -r 29.97 -strict experimental \
            -map 0:v:0 -map 1:a:0 -shortest muxed.mp4 

    # MIX + CUT/CLIP of source JPGs + AUDIO => MP4
    
        # E.g., remove first 96 frames, and its 3.82 sec [@ 25 fps] 
        # of audio from the mix [OUT]
            -start_number 0097  # start @ indexed-frame number 0097
            -vframes 300        # stop [OUT] after 300 frames
            -crf 25             # quality per CRF; changes did NOTHING
            -b:v 1600k          # quality per bitrate; this worked
            -ss 3.82            # start @ time [used here for audio; to match frames]
        
        # TEST 300 frames; start @ 0097
        ffmpeg -start_number 0097 -i %04d.jpg -ss 3.82 -i AUDIO.m4a -vframes 300 -c:v h264_qsv TEST.mp4

        # render full @ H.265 codec [rendered @ 1x]
        ffmpeg -start_number 0097 -i %04d.jpg -ss 3.82 -i AUDIO.m4a -c:v h265 OUT.mp4
        
        # render full @ H.264 w/ QSV codec [rendered @ 5x]
        ffmpeg -start_number 0097 -i %04d.jpg -ss 3.82 -i AUDIO.m4a -c:v h264_qsv -b:v 1600k OUT.mp4

# STREAMING 

    # HLS 
    ffmpeg -i INPUT.mp3 -c:a libmp3lame -b:a 128k -map 0:0 -f segment -segment_time 10 -segment_list outputlist.m3u8 -segment_format mpegts output%03d.ts

    # Make a H.264 video streamable; playable whilst downloading ; superfast process
        _streamable='-movflags faststart'  # "... the moov atom ..."
        ffmpeg -i TARGET.mp4 $_streamable -c:v copy -c:a copy TARGET-streamable.mp4

    # Encoding for Streaming Sites  
    #   https://trac.ffmpeg.org/wiki/EncodingForStreamingSites
    # Streaming Guide  
    #   https://trac.ffmpeg.org/wiki/StreamingGuide
    # Streaming your Desktop  
    #   https://trac.ffmpeg.org/wiki/EncodingForStreamingSites#Streamingyourdesktop
    # DEVICEs (Drivers)
        # Desktop
        `-f x11grab -i :0.0`     # Linux
        `-f gdigrab -i desktop`  # Windows
        # Webcam @ Windows
        `-f dshow -i video="USB Camera":audio="Microphone (Realtek USB2.0 MIC)"`        
            # List/Find devices 
                ffmpeg -list_devices true -f dshow -i dummy
            # Get DESTINATION IP Address 
                curl ifconfig.me # @ Destination machine

    # Win7 :: Stream/Capture @ 1 fps
    # Win32 GDI-based screen capture device [gdigrab]
    #   https://ffmpeg.org/ffmpeg-devices.html#gdigrab
    
        # Webcam  http://4youngpadawans.com/stream-camera-video-and-audio-with-ffmpeg/  (2018)
            ffmpeg -f dshow \
                -i video="USB Camera":audio="Microphone (Realtek USB2.0 MIC)" \
                -profile:v high -pix_fmt yuvj420p -level:v 4.1 -preset ultrafast -tune zerolatency \
                -vcodec libx264 -r 10 -b:v 512k -s 640x360 \
                -acodec aac -ac 2 -ab 32k -ar 44100 \
                -f mpegts -flush_packets 0 udp://${_DESTINATION_IPv4_ADDR}:5000?pkt_size=1316

                # Legend:
                -f dshow         # Windows drivers for capturing video and audio
                -vcodec libx264  # Raw video from camera will be encoded using H264 video codec
                -r 10            # video FPS (frames per second)
                -b:v 512k        # video bitrate Kbps (kilo bits per second)
                -s 640x360       # video width and height
                -acodec aac      # raw audio from microphone will be encoded using AAC audio codec
                -ac 2            # 2 audio channels (stereo)
                -ab 32k          # audio bitrate in Kbps
                -ar 44100        # audio sampling rate 44.1 KHz
                # MPEG transport stream is sent via UDP protocol to computer @ `${_DESTINATION_IPv4_ADDR}:5000` (IP:PORT).

            # Watch @ DESTINATION MACHINE browser, URL: udp://@0.0.0.0:5000, and press Play

        # Entire DESKTOP [@ default quality]
            ffmpeg -f gdigrab -r 1 -i desktop %04d.jpg  # FRAMEs @ 1 fps
            ffmpeg -f gdigrab -i desktop CAPTURE.mp4    # VIDEO  @ 25 fps [default]

        # Window per TITLE
            ffmpeg -f gdigrab -r 1 -i title="Library" %04d.png  # FRAMEs @ 1 fps 
        
        # LOSSLESS H.265 [quickly]
            ffmpeg -f gdigrab -i desktop -c:v libx265 -qp 0 -preset ultrafast CAPTURE.mkv
        
            # then shrink it [LOSSLESSly]
                ffmpeg -i CAPTURE.mkv -c:v libx265 -qp 0 -preset veryslow CAPTURE.shrunk.mkv


    # RHEL @ Nux Desktop  
    # https://linuxadmin.io/install-ffmpeg-on-centos-7/
    # http://li.nux.ro/repos.html
        yum -y install epel-release
        rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
        yum install ffmpeg ffmpeg-devel -y
        
    # Intel Media Server Studio 2017  [meh; proprietary, but SDK +QSV]
        # https://software.intel.com/intel-media-server-studio

    # FFmpeg Source Snapshots
        git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
    
# META 
    ffmpeg -version 
                 -hide_banner  # hide config etal blather
                 -v error      # hide all std-err
                 *s  # append 's' to any arg LISTs ALL available, e.g., `-devices`
 
    # Encoder PARAMS INFO  https://ffmpeg.org/ffmpeg-codecs.html#QSV-encoders
        ffmpeg -? encoder=h264_qsv  -hide_banner 

    # SHOW media INFO [ignore err msgs; `-hide_banner`]
        ffmpeg -i IN.mkv  # prints to STDERR (fd 2)
            
    # BENCHMARK per Null muxer; e.g., Direct-X HW decoder
        # https://ffmpeg.org/ffmpeg-formats.html#null
        ffmpeg [-hwaccel $DEVICE] -threads 1 -i IN.mp4 -c:v $NAME -f null - -benchmark  
        
        # Speed comparison @ h264_qsv/h264: 
        #   ~ 9x faster w/ QSV; Kaby Lake [i5-7400T/H270/Win7x64]

    # SHOW ALL codecs/formats/muxers/encoders/pix_fmts/bsfs/devices/...
        # https://ffmpeg.org/ffmpeg.html#Description
        ffmpeg -codecs  # decoders + encoders; h264_qsv, hevc, aac, ac3, ...

    # METADATA :: Add/Edit [fields per filetype]
        # https://wiki.multimedia.cx/index.php/FFmpeg_Metadata#MPEG_Transport_Streams
        ffmpeg  -i IN.ANY -c copy -metadata title="Foo bar" -metadata year="1986" ...    

    # SYNTHETIC INPUT;  per 'Libavfilter' [virtual input device]
    # various input/pattern  https://trac.ffmpeg.org/wiki/FancyFilteringExamples#mandelbrot
        # TEST pattern  [`testsrc`]
        ffmpeg -f lavfi -i testsrc=duration=10:size=hd720:rate=25 OUT.mkv
        ffplay -f lavfi -i testsrc:size=hd720  # play it directly
        # SMPTE pattern [`smptebars`]
        -f lavfi -i smptebars=duration=10:size=hd720:rate=25
        # RGB pattern   [`rgbtestsrc`]
        -f lavfi -i rgbtestsrc=duration=10:size=hd720:rate=25 -pixel_format yuv440p
        # filtergraph; looks like microscope view of bugs
        -f lavfi -i life,edgedetect,negate,fade=in:0:100 -frames:v 200 life.mp4
        # a 10 second, 200x200px, #ff0066 colored square
        -f lavfi -i color=c=ff0066:size=200x200 -t 10
        # add video NOISE to input per bitstream filter and `huffyuv` codec
        -i INPUT.mkv -codec:v huffyuv -bsf:v noise -codec:a copy
        # CELLAUTO 
        -f lavfi -i cellauto=size=hd720:rule=110  # 9, 18, 22, 26, 30, ..., 218, 225
        # MANDELBROT 
        -f lavfi -i mandelbrot -vf "format=gbrp,split=4[a][b][c][d],[d]histogram=display_mode=0:level_height=244[dd],[a]waveform=m=1:d=0:r=0:c=7[aa],[b]waveform=m=0:d=0:r=0:c=7[bb],[c][aa]vstack[V],[bb][dd]vstack[V2],[V][V2]hstack"

# VIDEO FILTERs; `-vf "$FILTERGRAPH"`
    # https://ffmpeg.org/ffmpeg-filters.html#Filtering-Introduction
    # https://ffmpeg.org/ffmpeg-filters.html#Video-Filters
    # https://trac.ffmpeg.org/wiki/FilteringGuide
    # https://trac.ffmpeg.org/wiki/Scaling%20(resizing)%20with%20ffmpeg
    "$FILTERGRAPH"  # may contain many CHAINs, which may contain many FILTERs
    # COMMA-SEPARATE filters; SEMICOLON separates chains
    #  https://ffmpeg.org/ffmpeg-filters.html#Filtergraph-description
    ffmpeg ... -i IN.ANY ... -vf "$FILTERGRAPH" ... OUT.ANY

    # DE-INTERLACE 
        -vf yadif              # de-interlace
        -vf bwdif              # bob weaver de-interlace https://ffmpeg.org/ffmpeg-filters.html#bwdif 

    # SCALE to half size 
        -vf 'scale=iw*.5:ih*.5'  # reSIZE per filter method
        -vf 'scale=iw/2:-1'      # equiv. per `-1`; preserve aspect-ratio

    # SCALE to fit 650x933 [wxh]
        -vf "scale='if(gt(a,.7),650,-1)':'if(gt(a,.7),-1,922)'"

    # SCALE + preserve aspect-ratio; if ALL images SAME SIZE
        -vf 'scale=w=650:h=922:force_original_aspect_ratio=decrease'

    # PAD top/bottom + left/right, with images centered therein
        -vf "pad=w=800:h=950:x='(ow-iw)/2':y='(oh-ih)/2':color=white"

    # SCALE + PAD
        -vf "scale='if(gt(a,.7),650,-1)':'if(gt(a,.7),-1,922)',pad=w=800:h=960:x='(ow-iw)/2':y='(oh-ih)/2':color=white"  
        # NOTE scale WxH smaller than pad WxH; 
        # FAILs if any image has either dimension larger than pad WxH

    # >>>  methods above will FAIL on certain scale/pad vs. image size[s]  <<<
    # >>>  So, prefer the below scale/pad method; less finicky; more robust
        
    # SCALE + PAD + preserve ASPECT-RATIO; @ VARYing/UNKnown SIZE images
            
        # 3x4 [1024x768] [xga]
        -vf "scale=iw*min(768/iw\,1024/ih):ih*min(768/iw\,1024/ih),pad=768:1024:(768-iw*min(768/iw\,1024/ih))/2:(1024-ih*min(768/iw\,1024/ih))/2:color=white" 

        # 9x16 [720x1280] [vertical-hd720] [smartphone]
        -vf "scale=iw*min(720/iw\,1280/ih):ih*min(720/iw\,1280/ih),pad=720:1280:(720-iw*min(720/iw\,1280/ih))/2:(1280-ih*min(720/iw\,1280/ih))/2:color=white" 

        # 16x9 [1920x1080] [hd1080]
        -vf "scale=iw*min(1920/iw\,1080/ih):ih*min(1920/iw\,1080/ih),pad=1920:1080:(1920-iw*min(1920/iw\,1080/ih))/2:(1080-ih*min(1920/iw\,1080/ih))/2:color=white"
        
    # VARY frame DURATIONs per image using ZOOMPAN filter
    # E.g., 1 sec/image (25 frm), except 3rd image is shown 3 sec (25+50 frm); 5th image is shown 5 sec (25+100 frm):       
        -vf "zoompan=d=25+'50*eq(in,3)'+'100*eq(in,5)'"
    
    # CROSSFADING between images
        -vf "framerate=fps=30:interp_start=64:interp_end=192:scene=100"

    # ADD TEXT
        # Add 'Foo bar', Exo2-Bold.ttf, size 24 pt, at x=100 and y=50 from top-left, yellow bordered by red box, 20% opacity on both.
        -vf "drawtext=fontfile=/usr/share/fonts/truetype/Exo2/Exo2-Bold.ttf: text='Foo bar':x=100: y=50: fontsize=24: fontcolor=yellow@0.2: box=1: boxcolor=red@0.2"

        # Add '09:57:00:00', white on black, at bottom center of video
        -vf "drawtext=fontfile=Gentium-R.ttf: timecode='09\:57\:00\:00': r=25: \x=(w-tw)/2: y=h-(2*lh): fontcolor=white: box=1: boxcolor=0x00000000@1"
        # ... all files, incl. font file, located @ current working dir
                
    # FLIP 
        -vf "geq=p(W-X\,Y)"    # HORIZONTALLY
        -vf "hflip"            # equivalent [horizontal]
        -vf "geq=p(X\,H-Y)"    # VERTICALLY

    # CONTRAST/BRIGHTNESS/SATURATION/GAMMA  
    # eq  https://ffmpeg.org/ffmpeg-filters.html#eq
        -vf 'eq=contrast=1.2:gamma=1.4:saturation=1.3' # used on animation video

    # POST PROCESSIONG  https://ffmpeg.org/ffmpeg-filters.html#pp
        -vf pp              # default: hb|a,vb|a,dr|a
        -vf pp=hb/vb/dr/al  # h+vert deblocking, deringing, auto-levels
        pp=de/-al           # default sans auto-levels (brightness/contrast)

    # HALD-CLUT image; to create/apply color-adjustment presets
    # https://ffmpeg.org/ffmpeg-filters.html#haldclut-1

    # DENOISE 
        # per hqdn3d; high quality 3d denoise filter (nice!)
            -vf hqdn3d # https://ffmpeg.org/ffmpeg-filters.html#hqdn3d-1
                [luma_spacial:chroma_spacial:luma_tmp:chroma_tmp] # 0-100, each
                hqdn3d=4:3:6:4.5 # default

            # Denoise AND Sharpen
                # hqdn3d + smartblur; neg blur sharpens
                # https://ffmpeg.org/ffmpeg-filters.html#smartblur-1
                -vf "hqdn3d=4:4:4:4,smartblur=lr=2.00:ls=-0.90:lt=-5.0:cr=0.5:cs=1.0:ct=1.5"

                # hqdn3d + unsharp; neg blur sharpens
                -vf "hqdn3d=4:4:4:4,unsharp=3:3:1:3:3:1"

        # per nlmeans (SLOW)
            -vf nlmeans # https://ffmpeg.org/ffmpeg-filters.html#nlmeans

        # per 2D freq-domain (DCT) filter; (SLOW)
        # https://ffmpeg.org/ffmpeg-filters.html#dctdnoiz
            -vf "dctdnoiz=e='gte(c, 4.5*3)'"  # denoise with a sigma of 4.5
            -vf "dctdnoiz=15:n=4"             # "violent denoise"; block size 16x16 

        # per pp (post-processing); results vary; added noise in some cases
            -vf pp  # https://ffmpeg.org/ffmpeg-filters.html#pp

    # ADD NOISE 
        -vf "noise=alls=20:allf=t+u"  # add temporal and uniform noise

    # FFT Filter [`fftfilt`], E.g., 
    # https://ffmpeg.org/ffmpeg-filters.html#fftfilt
        # High-pass:
            -vf "fftfilt=dc_Y=128:weight_Y='squish(1-(Y+X)/100)'"
        # Low-pass:
            -vf "fftfilt=dc_Y=0:weight_Y='squish((Y+X)/100-1)'"
        # Sharpen:
            -vf "fftfilt=dc_Y=0:weight_Y='1+squish(1-(Y+X)/100)'"
        # Blur:
            -vf "fftfilt=dc_Y=0:weight_Y='exp(-4 * ((Y+X)/(W+H)))'"

        # Fade in the 1st 25 frames; fade out last 25 frames of 1000-frame video:
            -vf "fade=in:0:25,fade=out:975:25"

        # DRAW BOX or GRID [drawbox/drawgrid]
            -vf "drawbox=10:20:200:60:blue@0.5"  # draw a box

        # OVERLAYs; takes two inputs and has one output. 
        # https://ffmpeg.org/ffmpeg-filters.html#overlay-1
        # Insert a transparent PNG logo 10px in from bottom-left corner
            ffmpeg -i MAIN.jpg -i LOGO.png -filter_complex 'overlay=10:main_h-overlay_h-10' OUT.jpg

