; ==================================================================
; MikeOS -- The Mike Operating System kernel
; Copyright (C) 2006 - 2014 MikeOS Developers -- see doc/LICENSE.TXT
;
; DISPLAY ROUTINES
; ==================================================================

; ------------------------------------------------------------------
; os_get_vesa_info -- Retrieve system 
; IN: Nothing; OUT: SI = Pointer to info structure
;                   Carry on failure

os_get_vesa_info:
	push ax
	push di
	clc
	
	mov ax, 4F00h
	mov di, VESASignature
	int 10h
	
	cmp al, 4Fh
	jne .vesa_not_supported
	cmp ah, 00h
	jne .vesa_not_supported
	
	pop ax
	pop di
	mov si, VESASignature
	clc
	ret
	
.vesa_not_supported:
	pop ax
	pop di
	stc
	ret
	
VESASignature db "    "
VESAVersion dw 0
OemStringPtr dd 0
Capabilities dd 0
VideoModePtr dd 0
TotalMemory dw 0
;VESA 2.0 info
OemSoftwareRev dw 0
OemVentorNamePtr dd 0
OemProductNamePtr dd 0
OemProductRevPtr dd 0
	
; ==================================================================