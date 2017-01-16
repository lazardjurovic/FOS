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
