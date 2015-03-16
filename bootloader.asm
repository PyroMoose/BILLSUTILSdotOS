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
	mov ax, buffer
	add ax, 0x0200
	mov ss, ax ;Set Stack Segment to 512 paragraphs ahead (8192 bytes) of disk buffer
	mov ax, 0x0400
	mov sp, ax ;Set Stack Pointer to 1024
	sti
	
	mov [bootdevice], dl ;Save boot medium number
	
	mov al, 0x03
	mov ah, 0x00
	int 0x10 ;Reset VGA (80x25)
	
	mov ah, 0x08
	int 0x13 ;Get drive parameters
	jc bootfailed
	and cx, 0x3f
	mov [SectorsPerTrack], cx ;Now we know sectors per track
	movzx dx, dh ;Set DX to DH
	add dx, 1
	mov [Sides], dx ;Total heads number
	
	mov ax, 19 ;Root dir
	call l2hts ;Convert it to CHS

	mov si, buffer
	mov bx, ds
	mov es, bx
	mov bx, si
	pusha

readfloppy:
	mov ah, 2 ;Read sectors into memory
	mov al, 14 ;Read 14 sectors
	int 13h
	jnc search ;Find kernel if load successful
	
	mov ax, 0 ;Reset drive
	mov dl, [bootdev] ;Our drive
	int 13h
	jnc readfloppy ;Try again (Floppy is good, though)
	jmp bootfailed ;Floppy causing error
	
search:
	popa
	mov ax, ds
	mov es, ax ;Move Extra Segment to the Data Segment
	mov di, buffer ;Now ES:DI is at our buffer
	
	mov cx, word[RootDirEntries] ;224 entries
	mov ax, 0 ;Offset 0
	
nextrootfile:
	xchg cx, dx ;Move RootDirEntries to DX. CX is which file we are reading
	mov si, kernelname
	mov cx, 11 ;Number of characters (8.3 Filename has 11)
	rep cmpsb ;Repeat compare 11 times
	je filefound ;We found KERNEL.BIN
	
	add ax, 32 ;Else, Increment offset
	mov di, buffer ;Point at buffer
	add di, ax ;Add offset to buffer pointer
	
	xchg cx, dx ;Retrieve CX for loop counter
	loop nextrootfile ;Loop, counting down until we have gone through all entries
	jmp bootfailed ;No file found
	
filefound: ;Load Kernel into memory
	jmp halt

bootfailed: ;Boot failing message and jmp loop
	mov si, bootfailed_msg
	jmp printstring
	jmp halt
	
printstring: ;Print whatever is in SI until NULL
	mov ah, 0x0E
	
	.repeat:
		lodsb
		cmp al, 0
		je short .done
		int 0x10
		jmp short .repeat

	.done:
		ret
	
l2hts: ;LBA to HTS. ax = logical sector. OUTPUT is same for int 13h input
	push bx
	push ax

	mov bx, ax			; Save logical sector

	mov dx, 0			; First the sector
	div word [SectorsPerTrack]
	add dl, 01h			; Physical sectors start at 1
	mov cl, dl			; Sectors belong in CL for int 13h
	mov ax, bx

	mov dx, 0			; Now calculate the head
	div word [SectorsPerTrack]
	mov dx, 0
	div word [Sides]
	mov dh, dl			; Head/side
	mov ch, al			; Track

	pop ax
	pop bx

	mov dl, [bootdevice]		; Set correct device

	ret
	
halt:
	jmp short halt
;-------------------------------------------------------
;----------------------VARIABLES-----------------------
;-------------------------------------------------------
;-------------------------------------------------------
bootdevice db 0
kernelname db "KERNEL  BIN"
bootfailed_msg db "ERROR: BILLSUTILSdotOS failed to boot", 10, 13
;-------------------------------------------------------
;-----------------------PADDING-------------------------
;-------------------------------------------------------
times 510-($-$$) db 0
dw 0xAA55

buffer: