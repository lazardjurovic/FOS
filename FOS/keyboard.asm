BITS 16

read_key: ; function to read pressed key from keyboard
	pusha ; push all register on stack
	mov ax,0 ; clear ax register
	mov ah , 10h ; parameter for interrupt
	int 16h ; BIOS interrupt
	mov [.buffer], ax ; store byte at buffer into ax register
	popa ; pop all registers from stack
	mov ax, [.buffer] ; move scan code into ax
ret ; return from function

.buffer dw 0 ; buffer that will store key code
             ; it is temporary variable , so it has to be
             ; defined at the end of function

get_string:
	pusha
	xor bx , bx ; clear bx
	mov di , string ; we move address of out string to di
	get_char:
	call read_key ; read key from keyboard
	stosb ; store that char into di
	mov ah , 0Eh
	int 10h ; print character to the screen
	cmp al , 13 ; if enter has been pressed
	je finished_input ; we jump to the end of function
	jmp get_char ; else get next character
		
finished_input:
popa
ret

string times 32 db 0
	
	

