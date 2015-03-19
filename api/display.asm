; ==================================================================
; MikeOS -- The Mike Operating System kernel
; Copyright (C) 2006 - 2014 MikeOS Developers -- see doc/LICENSE.TXT
;
; DISPLAY ROUTINES
; ==================================================================

; ------------------------------------------------------------------
; os_get_vesa_info -- Retrieve system VBE data structure
; IN: Nothing; OUT: SI = Pointer to info structure

os_get_vesa_info:
	push ax
	push di
	clc
	
	mov ax, 4F00h
	mov di, .VbeSignature
	int 10h
	
	cmp ax, 004Fh
	jne .vesa_not_supported
	
	pop ax
	pop di
	mov si, .VbeSignature
	clc
	ret
	
.vesa_not_supported:
	pop ax
	pop di
	stc
	ret
	
;Beginning of 512 byte VbeInfoBlock
.VbeSignature db "VESA"
.VbeVersionLow db 0
.VbeVersionHigh db 0
.OemStringPtr dd 0
.Capabilities db 0, 0, 0, 0
.VideoModePtr dd 0
.TotalMemory dw 0
.Reserved times 236 db 0
.OemData times 256 db 0
;End of 512 byte VbeInfoBlock

; ------------------------------------------------------------------
; os_set_display_mode -- Change display mode
; IN: AX = mode number; OUT: SI = Pointer to info structure

os_set_display_mode:
	push ax
	push bx
	
	mov bx, ax
	mov ax, 4F02h
	int 10h
	
	pop ax
	pop bx
	ret
	
; ------------------------------------------------------------------
; os_get_vesa_mode_info -- Retrieve info of a VESA mode
; IN: AX = mode number; OUT: SI = Pointer to info structure

os_get_vesa_mode_info:
	push cx
	push ax
	push di
	
	mov cx, ax
	mov ax, 4F01h
	mov di, .ModeAttributes
	int 10h
	
	mov si, .ModeAttributes
	pop cx
	pop ax
	pop di
	ret
	
.ModeAttributes dw 0
.WinAAttributes db 0
.WinBAttributes db 0
.WinGranularity dw 0
.WinSize dw 0
.WinASegment dw 0
.WinBSegment dw 0
.WinFuncPtr dd 0
.BytesPerScanLine dw 0
;Resolution info
.XResolution dw 0
.YResolution dw 0
.XCharSize db 0
.YCharSize db 0
.NumberOfPlanes db 0
.BitsPerPixel  db 0
.NumberOfBanks db 0
.MemoryModel db 0
.BankSize db 0
.NumberOfImagePages db 0
.Reserved db 0
;Colour info
.RedMaskSize db 0
.RedFieldPosition db 0
.GreenMaskSize db 0
.GreenFieldPosition db 0
.BlueMaskSize db 0
.BlueFieldPosition db 0
.RsvdMaskSize db 0
.DirectColorModeInfo db 0
.Reserved2 times 216 db 0



; ==================================================================
DisplayResoultionX dw 0
DisplayResolutionY dw 0

; ==================================================================