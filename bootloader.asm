[BITS 16]

jmp bootloader

;-------------------------------------------------------
OEMLabel			db "        "
BytesPerSector		dw 512
SectorsPerCluster	db 1
ReservedForBoot		dw 1
NumberOfFats		db 2
RootDirEntries		dw 224
LogicalSectors		dw 2880
MediaDesctiptor		db 0xF0
SectorsPerFat		dw 9
SectorsPerTrack		dw 18
Sides				dw 2
HiddenSectors		dd 0
LargeSectors		dd 0
DriveNo				dw 0
Signature			db 41
VolumeID			dd 0x00000000
VolumeLabel			db "BILLSUTILS"
FileSystem			db "FAT12   "
;-------------------------------------------------------

db 0x00

bootloader:

mov ax, 0x07c0
mov ds, ax
mov ah, 0x00
mov bh, 0x0F
mov cx, 0x0000
mov dx, 0x0000
int 10h
halt:
jmp halt
;-------------------------------------------------------
;-----------------------PADDING-------------------------
;-------------------------------------------------------
times 510-($-$$) db 0
dw 0xAA55