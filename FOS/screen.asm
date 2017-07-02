BITS 16 ; We are in real mode

print_char: ; function for printing characters3
	pusha
	mov ah , 0Eh ; parameter for interrupts
	; al = character to print (will be passed as argument)
	int 10h ; BIOS interrupt
	popa
	ret

print_string: ; function to print string from address in SI to '^' (end of string)
	pusha
next_character:
	lodsb ; loads byte at address DS:SI into AL
	mov ah , 0Eh ; we print the char we have loaded
	cmp al,0 ; 0 marks the end of string
	je _end ; if we have reached end of string function will return
	int 10h ; BIOS interrupt
	jmp next_character ; we go to next char

_end:
	popa
	ret ; returns to line line where it was called

clear_screen: ; function to clear screen
	pusha
	
	mov ah , 02h ; parameter for interrupt
	mov dx, 0 ; Position cursor at top-left
	int 10h
	
	mov ah, 6 ; scroll full-screen
	mov al, 0 ; clear 
	mov bh, 02h ; green text on black background
	mov cx, 0 ; top-left
	mov dh, 24; tottom-right
	mov dl, 79
	int 10h

	popa
	ret

newline:
	pusha
	mov ah , 0Eh ; parameter for function
	mov al , 10 ; new line feed
	int 10h ; BIOS interrupt
	mov al , 13 ; carriage return
	int 10h ; BIOS interrupt
	popa

set_cursor_shape:
	pusha
	mov ah , 01h ; parameter for function
	mov cx , 0007h ; full-block cursor
	int 10h ; BIOS interrupt
	popa
	ret

set_text_color:
	pusha
	mov ah , 0Bh ; parameter for interrupt
	mov bh , 00h 
	mov bl , 12h
	int 10h
	popa
	ret


