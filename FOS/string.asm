BITS 16

compare_string: ; function to compare strings that start at DI and SI
mov ah , [si] ; load character from first string
mov al , [di] ; load character from second string
cmp al , 0 ; check if we have reached end of string
je equal ; if we have reached the end then strings are equal
cmp al , ah ; compare characters
jne not_equal ; if characters are not equal than strings are not equal
inc si ; next time we look at next character
inc di
jmp compare_string

equal:
stc ; if strings are equal we store carry flag
ret ; return from functions

not_equal:
clc ; if strings are not equal we clear carry flag
ret ; return from functions
