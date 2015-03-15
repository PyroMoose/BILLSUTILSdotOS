@echo off

REM BILLSUTILSdotOS Boot Disk Assembler

echo Assembling bootloader...
nasm -O0 -f bin -o bootload.bin bootload.asm

echo Assembling kernel...
nasm -O0 -f bin -o kernel.bin kernel.asm

echo Assembling programs...
cd ..\programs
 for %%i in (*.asm) do nasm -O0 -fbin %%i
 for %%i in (*.bin) do del %%i
 for %%i in (*.) do ren %%i %%i.bin
cd ..

echo Adding bootsector to disk image...
cd disk_images
partcopy ..\bootload.bin 0 200 BILLSUTILSdotOS.flp 0
cd ..

echo Mounting disk image...
imdisk -a -f disk_images\mikeos.flp -s 1440K -m B:

echo Copying kernel and applications to disk image...
copy kernel.bin B:\
copy programs\*.bin B:\

echo Dismounting disk image...
imdisk -D -m B:

echo Done!
