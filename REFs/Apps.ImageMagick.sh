# ----------------------------------------------------------------------------
# ImageMagick / GraphicsMagick
#
#   Two main tools [almost identical]:
# 
#     * mogrify [overwrite input file] [batch mode] 
#     * convert [output to new file]
#
#   http://www.imagemagick.org/script/command-line-options.php
#   http://www.imagemagick.org/script/index.php
#   http://www.imagemagick.org/Usage/
#
#   http://www.graphicsmagick.org/utilities.html 
# 
#   Image Geometry  
#   http://www.imagemagick.org/script/command-line-processing.php#geometry
#
#   Multi-line Command; continue-on-next-lin character
#
#     Unix:    "\"
#     Windows: "^"
# ----------------------------------------------------------------------------
exit
# INSTALL
    choco install imagemagick

# USAGE ImageMagick vs. GraphicsMagick
    # @ IM:  
  `magick UTILITY ...`
    # @ GM:  
  `gm UTILITY ...`
    
    # [Use FFmpeg instead, wherever possible]

# INFO [identify]

    identify TARGET 
    
# WEB OPTIMIZE per width [OUTPUT_WIDTH]
# http://www.smashingmagazine.com/2015/06/efficient-image-resizing-with-imagemagick/

    mogrify -filter Triangle -define filter:support=2 -thumbnail OUTPUT_WIDTH -unsharp 0.25x0.08+8.3+0.045 -dither None -posterize 136 -quality 82 -define jpeg:fancy-upsampling=off -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=1 -define png:exclude-chunk=all -interlace none -colorspace sRGB INPUT_PATH
 
    # CAN USE mogrify like convert ...
    mogrify -path TARGET_DIR ... SOURCE_DIR\*.EXT  # doesn't overwrite source[s]

   # Reduced quality, blurr to reduce the size; stripped metadata and interlace to create progressive JPEG.
   convert -strip -interlace Plane -gaussian-blur 0.05 -quality 85% IN.jpg OUT.jpg

# QUALITY [jpg]  http://www.imagemagick.org/Usage/formats/#jpg

    -compress LossLess -quality 100  # flakey explanation; quesionable utility
    -quality 100                     # NOT lossless

    
# CREATE image file
    
    convert -size WIDTHxHEIGHT canvas:white FILE
    convert -size WIDTHxHEIGHT xc:rgb(253,253,255) FILE

    
# CREATE Animated GIF from PNGs

    # ALWAYS start w/ PNGs [4/8 bpp] as SOURCEs, NOT JPGs,
    # else jpg to gif conversion; SLOW and BIG

    # delay [hundredths-of-a-second], loop[s] [0=infinity]
    
    convert -delay 7 -loop 0 INDEXed_*.png RESULT.gif

# CREATE MPEG/MP4 from PNGs

    convert INDEXed_*.png RESULT.mp4 
    
    # - Use png 8bpp [24bpp okay; NOT less than 8bpp !!!]
    #   -- size of mp4 QUADRUPLED using 4bpp vs. 8bpp png source files 
    # - can use `-quality 100` with whatever %, 
    #   but unexpected results UNLESS 100%.
    # - `-delay...` use is a mystery; GIF => MP4 method sort of preserves it.
    # - FAILs @ Cygwin due to dependencies; `ffmpeg` etal

# CREATE MPEG/MP4 from GIFs
    
    convert SOURCE.gif RESULT.mp4 
    
    # MP4 is 3x larger than GIF => PNGs => MP4 method
    # GIF delay is dialated.


# APPEND horizontally (+) or vertically (-)   http://www.imagemagick.org/Usage/layers/

    convert  SOURCE_1 SOURCE_2 -append -resize 50% RESULT


# BORDER [ size in pixels or percent; NNN|NNN% ]

    mogrify -bordercolor white -border SIZE[%] FILE


# RESIZE [values are max; does NOT distort]

    mogrify -resize WIDTH[%]xHEIGHT[%] FILE
    mogrify -resize xHEIGHT[%] FILE
    mogrify -resize WIDTH[%] FILE

    # and set DPI
    
        mogrify -resize WIDTH -units PixelsPerInch -density DPI
    
    # per RESAMPLE; set DPI such that printed size [pixels|%] remains unchanged
    
        mogrify -units PixelsPerInch -resample DPIxDPI FILE
    
    # other RESIZE examples
    
        mogrify -gamma .45455 -resize NNN[%] -gamma 2.2 FILE
                       
        mogrify -adaptive-resize NNN% FILE

        # web-optimize per width [OUTPUT_WIDTH]
        # http://www.smashingmagazine.com/2015/06/efficient-image-resizing-with-imagemagick/
        mogrify -path OUTPUT_PATH -filter Triangle -define filter:support=2 -thumbnail OUTPUT_WIDTH -unsharp 0.25x0.25+8+0.065 -dither None -posterize 136 -quality 82 -define jpeg:fancy-upsampling=off -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=1 -define png:exclude-chunk=all -interlace none -colorspace sRGB -strip INPUT_PATH 

# BITS PER PIXEL [depth] ... flakey

    mogrify -depth 24 TARGET

# THUMBNAIL [resize/resample]	

    convert -thumbnail 25%x25% SOURCE TARGET

    
# ROTATE 

    mogrify -rotate DEGREES[<|>] FILE

# FLIP [vertical] 
    mogrify -flip FILE

# FLOP [horizontal]
    mogrify -flop FILE

# SHARPEN [try 20x1]

    mogrify -sharpen RADIUSxSIGMA FILE
    
    
# DPI 

    mogrify -units PixelsPerInch -density DPI FILE
    
    # Use -resample to preserve print size ...
    
    mogrify -units PixelsPerInch -resample DPIxDPI FILE
    
    
# CROP  WIDTHxHEIGHT+WIDTH_OFFSET+HEIGHT_OFFSET  

    mogrify -crop 128x128+0+0 FILE
    

# Convert svg to png @ SIZE per WIDTHxHEIGHT; maintains proportionality regardless

    convert -size x512 "FILE.svg" "FILE.png"


# Convert jpg to png; make background [@~COLOR~per~fuzz] TRANSPARENT

    convert "this.jpg" -fuzz 38% -transparent white     "that.png"
    convert "this.jpg" -fuzz 20% -transparent "#bac3de" "that.png"
    

# Convert png to jpg; make ALPHA channel background COLOR

    convert "this.png" -background white     -flatten -alpha off "that.jpg"
    convert "this.png" -background "#bac3de" -flatten -alpha off "that.jpg"


# THRESHOLD [white/black/color clip-to-max @ channel]
    
    mogrify -white-threshold VALUE% FILE      # clips white channel
    mogrify -threshold VALUE% FILE            # clips white/black
    mogrify -channel red -threshold 50% FILE  # clips red channel
    
    # [useful to clean dirty background]

    
# CONVERT [bits-per-pixel] [color-depth]; 8-bpp <==> 32-bpp [24-bpp + alpha] 

    convert this.png png32:that.jpg
    convert this.png png8:that.jpg

    # to GRAYSCALE

        mogrify -grayscale Rec709Luma FILE


    # to NEGATIVE [invert colors]

        mogrify -negate FILE
        
    
# COLOR / HUE / BALANCE  http://www.imagemagick.org/Usage/color_mods/

    mogrify -colorize 0,0,15 FILE  # R,G,B
    
    # ... FAILs !!! ... stuck in CMYK mode 

    
# BRIGHTNESS / SATURATION / HUE   "-negate" to invert

    mogrify -modulate BRIGHTNESS[,SATURATION,HUE] FILE
    
    # 100 = unchanged, 50 = half, 200 = double
    
    # Ex: create blue-tinted paper
        
        convert -size 1043x716 xc:rgb(245,245,255) FILE
        mogrify +noise laplacian -attenuate .3 FILE
        mogrify -modulate 100,20,100  FILE


# GAMMA correction [0.8 - 2.3]

    mogrify -gamma 1.6 FILE
    
    mogrify -auto-gamma FILE


# NORMALIZE

    mogrify -normalize FILE
    
    
# LEVELS

    mogrify -level BLACK_POINT[,WHITE_POINT][%][,GAMMA] FILE
    mogrify -level 2%,98%,1.5 FILE
    

# BRIGHTNESSxCONTRAST  [Increase/Decrease]

    -brightness-contrast BRIGHTNESS[xCONTRAST][%]]
    
    mogrify -brightness-contrast -10x50 FILE
    
    
# CONTRAST  [Increase('-')/Decrease] 

    mogrify -contrast FILE  
    mogrify +contrast FILE
    
    # Increase alot ...
    
    mogrify -contrast -contrast -contrast FILE

    
# CONTRAST STRETCHing the range of intensity values.

    mogrify -contrast-stretch BLACK_POINT[xWHITE_POINT][%]] FILE
    mogrify -contrast-stretch 0     FILE
    mogrify -contrast-stretch 1x1   FILE
    mogrify -contrast-stretch 30x30 FILE

    
# COLOR SWAP [alpha preserved]
    # RGB<-->GRB [swap G<-->R]
    convert SOURCE ( +clone -channel G -fx R ) +swap -channel R -fx v.G RESULT
    
    # RGB<-->BRG [if green, then to puple]; @ bash: '... \( ... \) ...'
    convert SOURCE ( +clone -channel R -fx B ) +swap -channel B -fx v.R FILE_1
    convert FILE_1 ( +clone -channel G -fx R ) +swap -channel R -fx v.G RESULT


# DESPECKLE [noise reduction]

    mogrify -despeckle FILE

    
# NOISE [create/add]

    mogrify +noise TYPE FILE

        # TYPE per type
        
            uniform   -attenuate 2.6
            random    -attenuate 100
            gaussian  -attenuate .17
            laplacian -attenuate .3

        
# COLOR PROFILE E.g., AdobeRGB1998.icc

    mogrify -profile PROFILE_FILE_PATH

        
# COMPOSE [mix 2 layers (2 files)]   http://www.imagemagick.org/Usage/compose/

    composite OVERLAY BACKGROUND [MASK] [-compose METHOD] RESULT

    convert  BACKGROUND OVERLAY  [MASK] [-compose METHOD] -composite RESULT

    # BLACK TRANSPARENT OVERLAY 

        convert IN.jpg -fill black -colorize 50% OUT.jpg

        convert IN.jpg  \
        # Proportional SCALING (pixels)
        -scale 1500 \
        # Black TRANSPARENT OVERLAY
        -fill black -colorize 50% \
        OUT.png 

    # -compose METHODs: Multiply, Screen, Bumpmap, Divide, Plus, Minus, ModulusAdd, ModulusSubtract, Difference, Exclusion, Lighten, Darken, LightenIntensity, DarkenIntensity

    # Over (basic; on top of)

        composite layer.png background.jpg  result.jpg
        
    # Multiply [x] (make white transparent)

        composite layer.jpg background.jpg -compose Multiply result.jpg

    # Screen [x] (make black transparent)

        composite layer.jpg background.jpg -compose Screen result.jpg

    # Bumpmap [x] (grayscale Multiply)

        composite 06.jpg bkgnd.jpg -compose Bumpmap result.jpg

    # Darken_Intensity [x] (grayscale Multiply)

        composite 06.jpg bkgnd.jpg -compose Darken_Intensity result.jpg
        composite 06.jpg bkgnd.jpg -compose Darken_Intensity -channel All result.jpg

    
# Get COLOR, Pixel-by-Pixel [histogram] ...

    # to stdout
    
    convert target_image.jpg -format %c -depth 8 histogram:info:-
    
    # to file
    
    convert target_image.jpg -format %c -depth 8 histogram:info:histogram.txt
    

# CREATE font-text image-file 

    # set size

        convert -size %_size% xc:#%_bkgnd% ^
            -fill #%_color% ^
            -font "%_font%" ^
            -gravity Center ^
            -weight 700 ^
            -pointsize %_pt% ^
            -annotate 0 "%_text%" ^
            "%~n0 [%_size%].png"
        
    # size per text

        convert -background #%_bkgnd% ^
            -fill #%_color% ^
            -font "%_font%" ^
            -pointsize %_pt% ^
            label:"%_text%" ^
            "%~n0 [%_pt%pt].png"

# CREATE Animated GIF 

    # ALWAYS start w/ PNGs as SOURCEs, NOT JPGs
    # else jpg to gif conversion; SLOW and BIG

    # loop:infinite, delay:hundredths-of-second per frame
    convert -loop 0 -delay 7 in1.png in2.png ... out.gif
    
    convert -loop 0 -delay 10 *.jpg anim.gif  
    
        # source MUST be alpah-num indexed sequence
        
        # @ bash; per list of source file-paths
        
            # build & sort list; JPG source file paths [@PWD]
            # proces list; remove newline-chars;
            # make animated GIF [out.gif]
            #  loop:inf, delay:0.07 [sec/frame]
            find -iname '*.jpg' | sort | sed 's/\n//g' | xargs -0 -I {} sh -c 'convert -loop 0 -delay 7 $@ out.gif' _ {}


# ImageMagick @ BASH

    # Processed extracted frames @ IrfanView/Batch: 
    # E.g., "Auto adjust colors" + Saturation:60 

    # convert JPGs to PNGs
    find -iname '*.jpg' -exec sh -c 'convert ${@} ${@%.*}.png' _ {} \;

    # convert PNGs to 1 animated gif
    convert -loop 0 -delay 7 *.png out.gif

    # convert PNGs to 1 MPEG or MP4 [@cmd, NOT Cygwin/bash]
    convert *.png out.mpeg 
    convert *.png out.mp4

        # can add `-quality 100` or whatever % qual

    exit 

    # build & sort list; JPG input file paths [@PWD]
    # proces list; remove newline-chars;
    # make animated GIF [out.gif]
    #  loop:inf, delay:0.07 [sec/frame]

    find -iname '*.jpg' | sort | sed 's/\n//g' | xargs -0 -I {} sh -c 'convert -loop 0 -delay 7 $@ out.gif' _ {}

        
        