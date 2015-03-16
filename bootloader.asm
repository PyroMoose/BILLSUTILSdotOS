[BITS 16]

jmp short bootloader
nop

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
	cli
	mov ax, 0x07c0
	mov ds, ax ;Set Data Segment to 0x07c0
	mov ax, [buffer]
	add ax, 0x0200
	mov ss, ax ;Set Stack Segment to 512 paragraphs ahead (8192 bytes)
	mov ax, 0x0400
	mov sp, ax ;Set Stack Pointer to 1024
	sti
	
	mov [bootdevice], dl ;Save boot medium number
	
	mov al, 0x03
	mov ah, 0x00
	int 0x10 ;Reset VGA (80x25)
	
	mov ah, 0x00
	mov dl, 0x07
	int 0x13 ;Seek to 0
	
testmemory:
	mov si, [memcheck]
	printstring
	mov eax, 0x0000e820
	int 0x15
	jc bootfailed
	test ax, ax
	jc bootfailed
	
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

bytetostring:
	
bootfailed:
	mov si, [bootfailed_msg]
	jmp printstring
	jmp $
;-------------------------------------------------------
;----------------------VARIABLES-----------------------
;-------------------------------------------------------
;-------------------------------------------------------
bootdevice db 0
memcheck db "Checking for memory... ", 10, 13
bootfailed_msg db "ERROR: System failed to boot", 10, 13
;-------------------------------------------------------
;-----------------------PADDING-------------------------
;-------------------------------------------------------
times 510-($-$$) db 0
dw 0xAA55

buffer