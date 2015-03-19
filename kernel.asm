[BITS 16]

%DEFINE OS_VERSION "0.1"
%DEFINE API_VERSION 1

os_call_vectors: ;Since main is called first, the other's don't actually execute
	jmp os_main
	jmp os_get_vesa_info
	jmp os_set_display_mode
	jmp os_get_vesa_mode_info
	jmp os_printstring

;%include "api\disk.asm" ;Disk utils
;%include "api\keyboard.asm" ;Keyboard functions
;%include "api\misc.asm" ;Useful functions
;%include "api\ports.asm" ;Serial port lib
;%include "api\string.asm" ;String manip lib
%include "api\display.asm" ;Display config and output
;%include "api\sound.asm" ;Sound config and output

os_main:
	cli
	mov ax, 0
	mov ss, ax
	mov ax, 500h
	mov sp, ax
	sti
	
	cld
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	call os_get_vesa_info
	mov si, os_get_vesa_info.VideoModePtr
	
	lodsw
	mov bx, ax
	lodsw
	mov ds, bx
	mov si, ax
	
.find_nontext:
	lodsw
	push ds
	push si
	push ax
	call os_get_vesa_mode_info
	lodsw
	and ax, 0000000000001000b
	cmp ax, 0000000000001000b
	pop ds
	pop si
	pop ax
	jne .find_nontext
	xor ax, 0100000000000000b
	call os_set_display_mode
	
	jmp $
	
os_printstring:
	push ax
	push cx
	mov ah, 00h
	mov al, 03h
	or al, 01000000b
	int 10h ;Ensure display mode allows for output and if it is already satisfactory,
	        ;leave the screen buffer alone
	mov ah, 0Eh
.repeat:
	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp .repeat
.done:
	pop ax
	pop cx
	ret