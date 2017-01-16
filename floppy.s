BITS 16

; We are using drive 0 which is floppy drive

reset_floppy: ; function to reset floppy drive
pusha ; push all registers to stack
xor ax, ax ; clear ax register
int 13h ; BIOS interrupt
popa ; pop all registers from stack
ret  ; retunrn from function

;------------------- get_disk_status

get_disk_status: ; function that will detect if there are any errors
pusha
mov ah , 01h ; interrupt parameter
int 13h
cmp al , 0 ; if al = 0 there are no errors
je .no_error
; execution will continue from here if error is found
mov si,error_found_message
call newline
call print_string
call newline
popa
ret ; return from function

.no_error:
mov si,no_error_message
call newline
call print_string
popa
ret ; return from function

;------------------- read_sector

read_sector: ; function to read one sector from floppy disk and put it's content into specified buffer
call reset_floppy ; first we need to reset floppy drive
mov ah , 02h ; parameter for interrupt
mov al , 1 ; number of sectors to read
; ch = track number
; cl = sector number    These 3 will be passed as arguments
; dh = head number
mov dl , 0 ; drive (0 is floppy)
mov bx , sector_data ; buffer that will store sector data
int 13h ; BIOS interrupt
jc .error ; if tehere is error we tell the user
ret ; if everything is good return from function

.error:
call newline
mov si , error_found_message
call print_string
call newline

;----------------- print_sector_data

print_sector_data: ; function to print content of sector in ASCII
mov si , sector_data ; string that we want to print
mov cx , 512 ; number of times to print character (size of sector)
print_loop: ; loop to print character
lodsb ; get character from SI
cmp al , 33 ; if AL is character
jl not_character ; if AL is not character than jump else continue
call print_sector_character ; print character that we have loaded into AL
loop print_loop ; print character 512 times
ret ; return from function

not_character:
mov al , '.' ; print "." character
call print_sector_character
dec cx ; decrement CX register
jmp print_loop ; go to next character

;------------ print_sector_character§

print_sector_character: ;function to print only 1 character from sector
mov ah , 0Eh ; parameter for interrupt
mov bl , 47h ; red text on grey background
int 10h ; BIOS interrupt
ret ; return from function

;------------------Data-----------------

no_error_message db "No errors found.",0
error_found_message db "Error found. To resolve problem try restarting floppy drive.",0
sector_data times 512 db 0 ; initialized 512 bytes for one sector

%INCLUDE "screen.s" ; Include functions for printing on screen (for error messages)
