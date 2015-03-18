[BITS 16]

%DEFINE OS_VERSION "0.1"
%DEFINE API_VERSION 1

;%include "api\disk.asm" ;Disk utils
%include "api\keyboard.asm" ;Keyboard functions
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
.repeat:
	lodsb
	cmp al, 0
	je .done
	mov ax, 0Eh
	int 10h
	jmp .repeat
.done: jmp $