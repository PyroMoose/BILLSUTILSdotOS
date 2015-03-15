jmp bootloader

;bootsector info goes here

bootloader:

jmp bootloader

times 510-($-$$) db 0
dw 0AA55h