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

bootloader:
	
	mov ax, 0x07c0
	mov ds, ax
	
	mov al, 0x03
	mov ah, 0x00
	int 0x10 ;Clear Screen by setting VGA mode (80 x 25)
	
	mov ch, 0x00
	mov cl, 0x07
	mov ah, 0x01
	int 0x10 ;Make cursor a blinking box
	
	mov si, bootsplash
	jmp printstring
	
	
halt:
	jmp halt
	
printstring:
	mov ah, 0x0E
	
	.repeat:
		lodsb
		cmp al, 0
		je .done
		int 0x10
		jmp short .repeat

	.done:
		ret

;-------------------------------------------------------
;----------------------VARIABLES-----------------------
;-------------------------------------------------------
bootsplash		db "Booting BILLSUTILSdotOS...", 13, 10 ;String followed by CR and LF chars
;-------------------------------------------------------

;-------------------------------------------------------
;-----------------------PADDING-------------------------
;-------------------------------------------------------
times 510-($-$$) db 0
dw 0xAA55