exit
rem  Recommended Configuration
rem  https://technet.microsoft.com/en-us/library/hh825686.aspx
rem  Includes Recovery Partition
rem    DiskPart commands to create five partitions
rem    @ UEFI/GPT-based PC.
rem    Adjust partition sizes to fill the drive. 
rem == 0. Select target disk & convert it to GPT ...
select disk 0
clean
convert gpt

rem == 1. EFI System Partition (ESP)
create partition efi size=100
format quick fs=fat32 label="System"

rem == 2. Microsoft Reserved (MSR)
create partition msr size=16

rem == 3. Windows Partition
create partition primary
format quick fs=ntfs label="Windows"
assign letter="C"

rem == 4. Recovery Partition (Place AFTER Windows, size ~750MB)
create partition primary size=750
format quick fs=ntfs label="Recovery"
set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac"
gpt attributes=0x8000000000000001

list disk
list partition
list volume

exit

:: To reset Win11 boot after restore on boot fail, 
:: 1. Run DISKPART, find EFI partition (100MB), and assign it "S" 
assign letter=S 
:: 2. Exit diskpart and run:
bcdboot C:\Windows /s S: /f UEFI
