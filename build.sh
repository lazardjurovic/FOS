
echo Building ...
nasm -f elf screen.s -o screen.o
nasm -f elf floppy.s -o floppy.o
nasm -f elf string.s -o string.o
nasm -f elf keyboard.s -o keyboard.o
