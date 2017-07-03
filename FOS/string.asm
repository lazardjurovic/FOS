BITS 16

compare_string: ; function to compare strings that start at DI and SI
pusha
next_char:
mov ah , [si] ; load character from first string
mov al , [di] ; load character from second string
cmp al , 0 ; check if we have reached end of string
je check_length ; if we have reached the end then strings are equal
cmp al , ah ; compare characters
jne not_equal ; if characters are not equal than strings are not equal
inc si ; next time we look at next character
inc di
jmp next_char

check_length:
cmp ah , 0
je equal
jmp not_equal

equal:
popa
stc ; if strings are equal we store carry flag
ret ; return from functions

not_equal:
popa
clc ; if strings are not equal we clear carry flag
ret ; return from functions
