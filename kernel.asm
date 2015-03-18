[BITS 16]

mov ax, 0x2000
mov ds, ax
mov si, [teststring]

printstring:
	mov ah, 0x0E
	
	.repeat:
		lodsb
		cmp al, 0
		je halt
		int 0x10
		jmp short .repeat

halt:
	jmp halt
	
teststring db "WE HAVE LOADED THE KERNEL!", 13, 10, 0