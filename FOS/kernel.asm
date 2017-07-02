BITS 16

disk_buffer	equ	24576  

	cli ; clear all interrupts
	mov ax , 0x0000 ; beginning of stack
	mov ss , ax 
	mov sp , 0xFFFF ; end of stack
	sti ; store all interrupts

	cld

	mov ax , 2000h ; address where kernel is loaded
	mov ds , ax ; data segment
	mov es , ax ; extra segment
	mov fs , ax ; general purpose segment
	mov gs , ax ; general purpose segment

init_env: ; initialize environment
	call clear_screen ; clear screen
	call set_cursor_shape ; change cursor shape to box
	call set_text_color
	mov si , info_message ; print message to screen
	call print_string
	call newline
	mov si,entry_message
	call print_string

input_command: ; main loop for inputing commands

	call newline

	mov si , prompt ; move first byte of message to SI
	call print_string

	mov di , input_buffer ; we move address of input_buffer to DI
	mov al , 0 
	mov cx , 64 ; size of our input buffer
	rep stosb ; stores byte in AL to ES:DI ( clears input_buffer )

	mov ax , input_buffer ; we move firstt address of input_buffer into AX
	mov di , input_buffer ; we move firstt address of input_buffer into DI 

keyboard_input: ; we start inputing characters from keyboard
	call read_key ; read one key from keyboard

	cmp al , 13 ; enter pressed
	je enter_pressed ; jump to enter_pressed label

	cmp al , 8 ; backspace pressed 
	je backspace_pressed

	jmp character_pressed ; if character is not enter jump to character_pressed label

character_pressed: ; if input is not enter
	stosb ; store next character into input_buffer
	call print_char ; print character in AL
	jmp keyboard_input ; input next character

backspace_pressed: ; if input is backspace
	mov si , input_buffer ; move address of input_buffer into SI
	cmp BYTE[si] , 0 ; check if input_buffer is empty
	je no_backspace ; if input_buffer is empty we don't do backspace
	mov ah , 02h ; parameter for interrupt ( get cursor position )

	dec di ; we decrement our input buffer so it doesn't contain last character
	mov al , 8 ; print backspace
	call print_char ; print character in AL
	mov al , 32 ; override it with blank character ( space )
	call print_char ; print character in AL
	mov al , 8 ; print backspace
	call print_char ; print character in AL
	jmp keyboard_input ; input next character

no_backspace:
	jmp keyboard_input ; input next character

enter_pressed: ; if enter is pressed
	mov ax , 0 ; store 0 at the end of input string
	stosb
	mov si , input_buffer ; mov address of input_buffer into si
	cmp BYTE[si] , 0 ; if byte at SI is zero ( no command ) then input new command
	je input_command 

; THIS CODE WILL CHECK FOR ALL BUILT-IN COMMAND

	mov di , clear_command
	call compare_string
	jc clear

	mov di , help_command
	call compare_string
	jc help

	mov di , debug_root_command
	call compare_string
	jc debug_root

	mov di , list_command
	call compare_string
	jc list

	mov di , test_command
	call compare_string
	jc test_floppy

	mov di , reset_command
	call compare_string
	jc reset

	mov di , execute_command
	call compare_string
	jc run_file

; THIS CODE EXECUTES WHEN NO COMMAND IS FOUND

	mov si , no_command_message ; else print that it's wron command
	call print_string
	jmp input_command ; jump to next command

clear: ; this is executed when 'clear' command is found
	call clear_screen
	jmp input_command

help: ; this code executes when 'help' command is found
	call newline
	mov si , help_message
	call print_string
	jmp input_command ; input next command

debug_root: ;  this code executes when 'debug root' command is found
	mov	ch, 0 ; track number
	mov	cl, 2 ; sector number
	mov	dh, 1 ; head number
	call read_sector ; function to read specific sector of floppy disk
	call newline
	call newline
	call print_sector_data ; this function will print sector content on screen
	call newline
	jmp input_command ; input next command

list: ; this command displays all files on floppy disk
	mov	ch, 0 ; track number
	mov	cl, 2 ; sector number
	mov	dh, 1 ; head number
	call read_sector ; function to read specific sector of floppy disk
	call newline
	call newline
	mov si , list_text
	call print_string
	call newline
	mov si , sector_data ; move address of sector data 

print_directory:
	lodsb ; loab byte from SI into AL

	cmp al, 0 ; if byte in AL is zero we go to next command
	je finish

	mov cx , 11 ; put 11 in CX ( all file names are 11 characters long)
	mov ah , 0Eh ; parameter for interrupt ( print character on screen)
	int 10h ; BIOS interrupt

print_file_name:
	mov al , [si] ; we move byte from SI into AL
	mov ah , 0Eh ; parameter for interrupt ( print character on screen)
	int 10h  ; BIOS interrupt
	inc si ; increment SI ( next time we will be printing next character of file name)
	loop print_file_name

	add si , 20 ; go to next file name
	call newline
	jmp print_directory

finish:
	jmp input_command ; input next command

test_floppy:
	call newline
	call get_disk_status ; calls function to checek for errors
	call newline
	jmp input_command ; input next command

reset: ; command for reseting drives
	call newline
	mov si , reset_prompt
	call print_string
	call read_key
	call print_char
	sub ax , 48 ; convert character to number
	mov ah , 0
	mov dl , al ; dl has to be device number
	int 13h
	jnc input_command ; input next command ( carry falg is set if there is no error)
	call newline
	mov si , reset_failed_message
	call print_string
	jmp input_command

run_file:
	call newline
	mov si , loading_file_message
	call print_string

	mov cx , 32768
	mov ax , filename
	call os_load_file

	mov ax, 0			
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov si, 0
	mov di, 0

	jc failed_to_load
	call 32768

failed_to_load:
	call newline
	mov si , failed_to_load_file
	call print_string
	jmp input_command

input_buffer times 64 db 0 ; we define our input buffer to hold maximum 64 characters
page_number db 0 ; page that is displayed
filename db "TEST.BIN",0

%INCLUDE "floppy.asm"
%INCLUDE "keyboard.asm"
%INCLUDE "string.asm"
%INCLUDE "screen.asm"
%INCLUDE "variables.asm"
%INCLUDE "load.asm"
