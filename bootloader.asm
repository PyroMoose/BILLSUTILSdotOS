[BITS 16]

jmp bootloader

;Insert bootsector info here

bootloader:

mov ax, 0x07c0
mov ds, ax

hang:
jmp hang




times 510-($-$$) db 0
dw 0xAA55