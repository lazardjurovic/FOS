BITS 16 ; We are in real mode

print_char: ; function for printing characters
mov ah , 0Eh ; parameter for interrupts
; al = character to print (will be passed as argument)
mov bl,0x0F ; white text on black background
int 10h ; BIOS interrupt
ret

print_string: ; function to print string from address in SI to '^' (end of string)
lodsb ; loads byte at address DS:SI into AL
mov ah , 0Eh ; else we print the char we have loaded
mov bl , 0x0F ; white text on black background
cmp al,0 ; 0 marks the end of string
je end ; if we have reached end of string function will return
int 10h ; BIOS interrupt
jmp print_string ; we go to next char

end:
ret ; returns to line line where it was called

clear_screen: ; function to clear screen
mov ah , 09h ; parameter for function
mov al , ' ' ; we print space character
mov bl , 0x0F ; white text on black background
mov cx , 2000 ; we print 2000 times because screen has 25x80 characters
int 10h ; BIOS interrupt
ret

newline:
mov al , 10 ; new line feed
int 10h ; BIOS interrupt
mov al , 13 ; carriage return
int 10h ; BIOS interrupt
ret

set_cursor_shape:
mov ah , 01h ; parameter for function
mov cx , 0007h ; full-block cursor
int 10h ; BIOS interrupt
ret
