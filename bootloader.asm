[BITS 16]

;-------------BILLSUTILSdotOS Bootloader----------------
;--------------Based on code in Mike OS-----------------
;--------------Last Edited: 16/03/2015------------------

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
	mov ds, ax ;Set Data Segment to 0x07c0 (Where the BIOS loads us)
	mov ax, buffer
	add ax, 0x0200
	mov ss, ax ;Set Stack Segment to 512 paragraphs ahead (8192 bytes) of disk buffer
	mov ax, 0x0400
	mov sp, ax ;Set Stack Pointer to 1024 so we get 1024 bytes of stack
	sti
	
	mov [bootdevice], dl ;Save boot medium number
	
	mov al, 0x03
	mov ah, 0x00
	int 0x10 ;Reset VGA (80x25)
	
	mov ah, 0x08
	int 0x13 ;Get drive parameters
	jc bootfailed
	and cx, 0x3f
	mov [SectorsPerTrack], cx ;Max sector number
	movzx dx, dh ;Max head number
	add dx, 1
	mov [Sides], dx ;Total heads number
	
	mov ax, 19 ;Root dir
	call l2hts ;Convert it to CHS
	
	mov si, buffer
	mov bx, ds
	mov es, bx
	mov bx, si
	pusha
	
	mov ah, 2 ;Read sectors into memory
	mov al, 14 ;Read 14 sectors
	pusha
	
readfloppy:
	popa
	pusha
	stc
	int 13h ;This puts the entire root directory (It's entries) into the 8k buffer
	jnc search
	
	mov ax, 0 ;Reset drive
	mov dl, [bootdevice] ;Our drive
	stc
	int 13h
	jnc readfloppy ;Try again (Floppy is good, though)
	jmp bootfailed ;Floppy causing error
	
search: ;Beginning to find the kernel entry
	popa
	mov ax, ds
	mov es, ax ;Move Extra Segment to the Data Segment
	mov di, buffer ;Now ES:DI is at our buffer
	
	mov cx, word[RootDirEntries] ;224 entries into counter
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
	
filefound: ;Now that we know what file it is, let's go get it
	mov ax, word[es:di]
	add ax, 0x000f
	mov [cluster], ax
	
	mov ax, 1
	call l2hts ;Find HTS of first sector
	
	mov di, buffer ;Move data index to buffer start
	mov bx, di ;Now ES:BX points to our buffer
	
	mov ah, 2 ;Read
	mov al, 9 ;9 sectors
	pusha
	
readfat: ;Let's retrieve the contents of KERNEL.BIN
	popa ;Refresh our ah and al in case int 0x13 screws it up
	pusha
	stc
	int 0x13
	jnc fatread ;Past tense as we read it successfully
	
	mov ax, 0 ;Reset drive
	mov dl, [bootdevice] ;Our drive
	stc
	int 0x13
	jnc readfat ;Try again after floppy reset
	jmp bootfailed
	
fatread:
	popa ;Let's not take up our whole stack :P
	
	mov ax, 0x2000 ;Kernel segment
	mov es, ax ;Move extra segment there
	mov bx, 0 ;Starting from the start, so we don't need an offset
	
	mov ah, 2 ;Set up for reading
	mov al, 1 ;Reading them one at a time
	push ax ;We need to save this for later
	
loadcluster: ;Ok we need the HTS of our first sector
	mov ax, word[cluster]
	add ax, 31 ;Starting offset
	call l2hts ;Turn into int 0x13 values
	
	mov ax, 0x2000
	mov es, ax ;Buffer segment
	mov bx, word[pointer]
	pop ax ;Get kernel segment back
	push ax ;Save it to stack JIC
	
	stc
	int 0x13 ;Read the sector to memory
	jc findnextcluster
	mov ax, 0 ;Reset drive
	mov dl, [bootdevice] ;Our drive
	stc
	int 0x13
	jmp loadcluster
	
findnextcluster:
	mov ax, [cluster]
	mov dx, 0
	mov bx, 3
	mul bx ;Multiply cluster by 3
	mov bx, 2
	div bx ;Divide cluster by 2
	mov si, buffer ;Set segment index to buffer address
	add si, ax ;Add the offset for the 12 bit file entry
	mov ax, word[ds:si] ;Set ax to si value
	
	or dx, dx ;Check to see if remainder is even or odd
	jz even ;Goto even if remainder is even. Else, goto odd
	
odd:
	shr ax, 4 ;Shift out first 4 bits (they belong to another entry)
	jmp findnextclustercont

even:
	and ax, 0x0fff ;Mask out final 4 bits and goto findnextclustercont

findnextclustercont: ;Now that we have the Kernel cluster location, let's retrieve the actual kernel
	mov word[cluster], ax ;Store ax cluster value

	cmp ax, 0x0ff8 ;FF8h is FAT12 EOF
	jmp bootkernel

	add word[pointer], 512 ;Move pointer ahead a cluster
	jmp loadcluster

bootkernel:
	pop ax ;Clean up stack
	mov dl, byte[bootdevice] ;Pass bootdevice to kernel
	
	mov si, loadingkernel_msg
	call printstring
	
	jmp 0x0000:0x0000 ;Jump to kernel at 0x2000:0x0000
	
;-------------------------------------------------------
;-----------------------FUNCTIONS-----------------------
;-------------------------------------------------------

bootfailed: ;Boot failed message and jmp loop
	mov si, bootfailed_msg
	jmp printstring
	jmp $
	
printstring: ;Print whatever is in SI until NULL
	pusha
	mov ah, 0x0E
	
	.repeat:
		lodsb
		cmp al, 0
		je short .done
		int 0x10
		jmp short .repeat

	.done:
		popa
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

;-------------------------------------------------------
;-----------------------VARIABLES-----------------------
;-------------------------------------------------------
bootdevice db 0
cluster dw 0
pointer dw 0
kernelname db "KERNEL  BIN"
bootfailed_msg db "ERROR: BILLSUTILSdotOS failed to boot", 10, 13
loadingkernel_msg db "Loading", 10, 13
;-------------------------------------------------------
;-----------------------PADDING-------------------------
;-------------------------------------------------------
times 510-($-$$) db 0
dw 0xAA55

buffer: ;Buffer pointer