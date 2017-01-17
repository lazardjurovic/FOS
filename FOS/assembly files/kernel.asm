BITS 16

cli
mov ax , 0x0000 ; beginning of stack
mov ss , ax
mov sp , 0xFFFF ; end of stack
sti

mov ax , 2000h ; address where kernel is loaded
mov ds , ax ; data segment
mov es , ax ; extra segment
mov fs , ax ; general purpose segment
mov gs , ax ; general purpose segment

call clear_screen ; clear screen
call set_cursor_shape ; change cursor shape to box
call newline ; draw new line
call newline 
mov si , welcome_message ; move first address of string into SI
call print_string ; function to print string
call newline 
call newline

mov dh , 0; head
mov ch , 0; track
mov cl , 1; sector
call read_sector ; read boot sector from floppy drive 
call print_sector_data ; print data that we have loaded from floppy

cli 
hlt

%INCLUDE "floppy.asm"
%INCLUDE "keyboard.asm"
%INCLUDE "string.asm"
%INCLUDE "screen.asm"
%INCLUDE "variables.asm"

