# [SD Card](https://en.wikipedia.org/wiki/Secure_Digital "Wikipedia :: Secure Digital card") 

## [SD Cards](https://www.amazon.com/s/field-keywords=sd+u3+a2+uhs-1 "Amazon.com :: U3 A2 UHS-1") (`microSD` FF)
- [Samsung 32GB U1  ... (MB-ME32GA/AM)](https://www.amazon.com/gp/product/B06XWN9Q99 "R:95MB/s W:20MB/s") (bought; $8)

- [Samsung 64GB U3 V10  ... (MB-ME64GA/AM)](https://www.amazon.com/dp/B06XX29S9Q "R:100MB/s W:60MB/s") ($14)  

- [SanDisk 64GB U3 A2  (SDSQXA2-064G-GN6MA)](https://www.amazon.com/dp/B07FCMBLV6 "R:160MB/s W:60MB/s") (Faster; $21)

- [SanDisk 64GB U3 A2  (Pro)](https://www.amazon.com/dp/B07FCMBLV6 "R:170MB/s W:90MB/s") (Fastest; $40)

## SD Card Flash Utility 
- [Etcher](https://www.balena.io/etcher/ "balena.io") ([GitHub](https://github.com/balena-io/etcher "balena-io/etcher @ GitHub"))  an [Electron](https://github.com/electron/electron "GitHub") app.  
Creates filesystem and copies (OS) image file (`.img`), byte-for-byte, onto target media.  

    - If __USB stick__, the burned filesystem is _oddly_ __accessible__ at both Win-10 and TV-box.  
    Win-10 reports filesystem as `FAT`, and can `r/w`, but also prompts to format it.  
    If __SD card__, the burned filesystem is entirely __inaccessible__ at Win-10.

## Firmware Mod Utilities
- [Amlogic Customization Tool](http://www.mediafire.com/file/mzw8lwitz6d7lr4/CustomizationTool_setup_v2.0.10.zip)  
Modify image (`.img`) before burning it. 

- [Armbian Configuration Utility](https://github.com/armbian/config "GitHub")  
Configure an Armbian distro at command line (SSH session):  
 `armbian-config`

## Firmware Mod Methods

1. Flash image onto SD card or USB stick using Etcher. 
    - Perform image mods, optionally, prior to burning.
    - Bootloader must be setup to handle OS __selection__;    
     external (`SD`/`USB`) vs. internal  [(`eMMC`/`NAND`)](https://en.wikipedia.org/wiki/MultiMediaCard#eMMC "Wikipedia :: MultiMediaCard"). 

2. Flash image using device's internal __pre-boot menu__.   
With source _image file_ (`.img`) copied to an SD card or USB stick. 


### &nbsp;
