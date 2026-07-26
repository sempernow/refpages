# Linux on Lenovo's Cheaper Laptops

- **V series** : Budget Small-business
- **IdeaPad** : Consumers / Students

Yes, you can install Linux on a cheap-class Lenovo laptop, and it will often run much faster than Windows. 
Great lightweight choices include Linux Mint, Zorin OS Lite, and Lubuntu. 

## Why Cheap Lenovos Work Well with Linux

* Driver Support: Most basic hardware like keyboards, touchpads, and screens work right after installation.
* Low System Demands: Linux uses less memory and processor power than modern versions of Windows, breathing new life into low-cost or older hardware.
* Community Help: Beginner-friendly versions have large online groups to help you solve problems. 

## Best Lightweight Options

* Linux Mint (XFCE or Cinnamon Edition): Very easy for beginners coming from Windows.
* Zorin OS Lite: Designed specifically to look nice and run fast on low-end computers.
* Lubuntu: Built for minimal memory usage, perfect for extremely weak or older machines.

---

# Known Issues : BIOS Config Required

While budget Lenovo laptops (like the IdeaPad 1, IdeaPad 3, or Lenovo V series) run Linux beautifully once configured, getting them initially installed and fully functional frequently requires dealing with a few specific hardware and BIOS quirks. 

The most common "extra work" issues you likely remember include:

## 1. The Installer Cannot See the Hard Drive (Storage Mode)

* **Issue**: Many cheap Lenovo laptops ship with the storage controller configured to RAID or Intel RST mode instead of standard AHCI. When you boot the Linux installer, your hard drive or SSD won't show up at all. 
* **Fix**: You have to enter the BIOS configuration (usually by pressing F2 right when turning it on) and change the storage configuration from RAID to AHCI. 

## 2. Missing or Disconnecting Wi-Fi (Realtek Chips)

* **Issue**: To keep retail costs low, budget Lenovo laptops frequently switch between Wi-Fi manufacturers, often utilizing cheaper Realtek chipsets (like the RTL8852BE or RTL8852CE) instead of highly compatible Intel ones. Older Linux kernels do not recognize these out of the box, or they suffer from severe drops and random disconnections. 
* **Fix**: You may need to temporarily connect via an Ethernet cable or use USB tethering from your smartphone to download and install community-made Wi-Fi drivers from GitHub. Alternatively, using a distro with a highly modern kernel (like the Linux Mint "EDGE" Edition or a clean install of Ubuntu 24.04+) usually includes the driver natively. 

## 3. eMMC Storage Boot Failures

* **Issue**: The absolute cheapest Lenovo configurations use eMMC memory (the same storage type found in smartphones) instead of a traditional SSD. Standard Linux bootloaders sometimes struggle to write partition tables correctly to eMMC chips.
* **Fix**: You must ensure Windows Fast Startup is completely disabled inside Windows before formatting. In severe cases, you have to toggle the BIOS boot priority specifically to Legacy/CSM support instead of UEFI to get the eMMC drive to properly boot the new OS. 

## 4. Touchpad or Function Keys Not Working

* **Issue**: Lenovo sometimes uses proprietary I2C controllers for budget laptop trackpads, causing the cursor to freeze or fail to register entirely on older Linux builds.
* **Fix**: This usually requires adding a specific boot parameter (like pci=nocrs or i8042.nopnp) to your system's GRUB loading configuration file.

---

The fixes are very manageable once you know the exact steps. 
Most of these tweaks only take a few minutes in your laptop's settings menu.

## 📋 The Pre-Install Checklist

* Back Up Data: Copy important files to a USB drive or cloud storage. The installation will erase the drive.
* Disable Fast Startup: Open Windows Control Panel, go to Power Options, and turn off "Fast Startup" so Linux can access the drive.
* Get a USB Drive: You need a blank USB flash drive with at least 8 GB of space.

## 🛠️ Step-by-Step Fixes## Step 1: Change Storage to AHCI (If the Installer Can't See Your Drive)

1. Turn off your Lenovo completely.
2. Turn it on and immediately tap F2 repeatedly until the BIOS screen appears.
3. Use the arrow keys to find Configuration or Storage.
4. Change SATA Controller Mode (or Intel VMD/RST) from RAID to AHCI.
5. Press F10 to save and exit.

## Step 2: Disable Secure Boot (If the USB Won't Boot)

1. Enter the BIOS again using F2.
2. Go to the Security or Boot tab.
3. Find Secure Boot and change it to Disabled.
4. Press F10 to save and exit.

## Step 3: Flash the Linux USB

1. Download your preferred Linux version (like Linux Mint) on a working computer.
2. Download a free tool called BalenaEtcher or Rufus.
3. Plug in your USB drive, open the tool, select your downloaded Linux file, and click Flash.

## Step 4: Boot and Install

1. Plug the flashed USB into your cheap Lenovo.
2. Turn it on and immediately tap F12 repeatedly to open the Boot Menu.
3. Select your USB drive from the list.
4. Test the system in "Live Mode." If the Wi-Fi and touchpad work, click Install Linux on the desktop!


<!-- 

… ⋮ ︙ • ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
☢ ☣ ☠ ¦ ¶ § † ‡ ß µ Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 🡸 🡺 ➔
ℹ️ ⚠️ ✅ ⌛ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🥇 ✨️ 🔚

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# README HyperLink

README ([MD](__PATH__/README.md)|[HTML](__PATH__/README.html)) 

# Bookmark

- Target
<a name="foo"></a>

- Reference
[Foo](#foo)

-->
