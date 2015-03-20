[BITS 16]

%DEFINE OS_VERSION "0.1"
%DEFINE API_VERSION 1

disk_buffer equ 6000h

os_call_vectors: ;Since main is called first, the other's don't actually execute
	jmp os_main ;Kernel.asm
	jmp os_get_vesa_info ;Display.asm
	jmp os_set_display_mode ;Display.asm
	jmp os_get_vesa_mode_info ;Display.asm
	jmp os_printstring ;Display.asm
	jmp os_vga_setup ;Display.asm
	jmp os_vga_printchar ;Display.asm
	jmp os_vga_set_cursor ;Display.asm
	jmp os_pause ;Misc.asm
	jmp os_get_api_version ;Misc.asm
	jmp os_fatal_error ;Misc.asm
	jmp os_string_length ;String.asm
	jmp os_string_reverse ;String.asm
	jmp os_find_char_in_string ;String.asm
	jmp os_string_charchange ;String.asm
	jmp os_string_uppercase ;String.asm
	jmp os_string_lowercase ;String.asm
	jmp os_string_copy ;String.asm
	jmp os_string_truncate ;String.asm
	jmp os_string_join ;String.asm
	jmp os_string_chomp ;String.asm
	jmp os_string_strip ;String.asm
	jmp os_string_compare ;String.asm
	jmp os_string_strincmp ;String.asm
	jmp os_string_parse ;String.asm
	jmp os_string_to_int ;String.asm
	jmp os_int_to_string ;String.asm
	jmp os_sint_to_string ;String.asm
	jmp os_long_int_to_string ;String.asm
	jmp os_set_time_fmt ;String.asm
	jmp os_get_time_string ;String.asm
	jmp os_set_date_fmt ;String.asm
	jmp os_get_date_string ;String.asm
	jmp os_string_tokenize ;String.asm
	jmp os_get_file_list ;Disk.asm
	jmp os_load_file ;Disk.asm
	jmp os_write_file ;Disk.asm
	jmp os_file_exists ;Disk.asm
	jmp os_create_file ;Disk.asm
	jmp os_remove_file ;Disk.asm
	jmp os_rename_file ;Disk.asm
	jmp os_get_file_size ;Disk.asm
	jmp os_wait_for_key ;Keyboard.asm
	jmp os_check_for_key ;Keyboard.asm
	jmp os_seed_random ;Math.asm
	jmp os_get_random ;Math.asm
	jmp os_bcd_to_int ;Math.asm
	jmp os_long_int_negate ;Math.asm
	jmp os_port_byte_out ;Ports.asm
	jmp os_port_byte_in ;Ports.asm
	jmp os_serial_port_enable ;Ports.asm
	jmp os_send_via_serial ;Ports.asm
	jmp os_get_via_serial ;Ports.asm

%include "api\disk.asm" ;Disk utilities
%include "api\math.asm" ;Math functions
%include "api\keyboard.asm" ;Keyboard functions
%include "api\misc.asm" ;Useful functions
%include "api\ports.asm" ;Serial port lib
%include "api\string.asm" ;String manipulation lib
%include "api\display.asm" ;Display configuration and output (WIP)
;%include "api\sound.asm" ;Sound configuration and output (WIP)
;%include "api\cli.asm" ;Command line interface (WIP)

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

; ------------------------------------------------------------------
; System Variables -- Storage for system wide information
fmt_12_24 db 0
fmt_date db 0, '/'