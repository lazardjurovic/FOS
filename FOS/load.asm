;------------------------------------------------------------------
; os_load_file -- Load file into RAM
; IN: AX = location of filename, CX = location in RAM to load file
; OUT: BX = file size (in bytes), carry set if file not found

os_load_file:
	call os_string_uppercase
	call int_filename_convert

	mov [.filename_loc], ax		; Store filename location
	mov [.load_position], cx	; And where to load the file!

	mov eax, 0			; Needed for some older BIOSes

	call reset_floppy		; In case floppy has been changed
	jnc .floppy_ok			; Did the floppy reset OK?

	mov ax, .err_msg_floppy_reset	; If not, bail out
	jmp os_fatal_error


.floppy_ok:				; Ready to read first block of data
	mov ax, 19			; Root dir starts at logical sector 19
	call disk_convert_l2hts

	mov si, disk_buffer		; ES:BX should point to our buffer
	mov bx, si

	mov ah, 2			; Params for int 13h: read floppy sectors
	mov al, 14			; 14 root directory sectors

	pusha				; Prepare to enter loop


.read_root_dir:
	popa
	pusha

	stc				; A few BIOSes clear, but don't set properly
	int 13h				; Read sectors
	jnc .search_root_dir		; No errors = continue

	call reset_floppy		; Problem = reset controller and try again
	jnc .read_root_dir

	popa
	jmp .root_problem		; Double error = exit

.search_root_dir:
	popa

	mov cx, word 224		; Search all entries in root dir
	mov bx, -32			; Begin searching at offset 0 in root dir

.next_root_entry:
	add bx, 32			; Bump searched entries by 1 (offset + 32 bytes)
	mov di, disk_buffer		; Point root dir at next entry
	add di, bx

	mov al, [di]			; First character of name

	cmp al, 0			; Last file name already checked?
	je .root_problem

	cmp al, 229			; Was this file deleted?
	je .next_root_entry		; If yes, skip it

	mov al, [di+11]			; Get the attribute byte

	cmp al, 0Fh			; Is this a special Windows entry?
	je .next_root_entry

	test al, 18h			; Is this a directory entry or volume label?
	jnz .next_root_entry

	mov byte [di+11], 0		; Add a terminator to directory name entry

	mov ax, di			; Convert root buffer name to upper case
	call os_string_uppercase

	mov si, [.filename_loc]		; DS:SI = location of filename to load

	call compare_string		; Current entry same as requested?
	jc .found_file_to_load

	loop .next_root_entry

.root_problem:
	mov bx, 0			; If file not found or major disk error,
	stc				; return with size = 0 and carry set
	ret


.found_file_to_load:			; Now fetch cluster and load FAT into RAM
	mov ax, [di+28]			; Store file size to return to calling routine
	mov word [.file_size], ax

	cmp ax, 0			; If the file size is zero, don't bother trying
	je .end				; to read more clusters

	mov ax, [di+26]			; Now fetch cluster and load FAT into RAM
	mov word [.cluster], ax

	mov ax, 1			; Sector 1 = first sector of first FAT
	call disk_convert_l2hts

	mov di, disk_buffer		; ES:BX points to our buffer
	mov bx, di

	mov ah, 2			; int 13h params: read sectors
	mov al, 9			; And read 9 of them

	pusha

.read_fat:
	popa				; In case registers altered by int 13h
	pusha

	stc
	int 13h
	jnc .read_fat_ok

	call reset_floppy
	jnc .read_fat

	popa
	jmp .root_problem


.read_fat_ok:
	popa


.load_file_sector:
	mov ax, word [.cluster]		; Convert sector to logical
	add ax, 31

	call disk_convert_l2hts		; Make appropriate params for int 13h

	mov bx, [.load_position]


	mov ah, 02			; AH = read sectors, AL = just read 1
	mov al, 01

	stc
	int 13h
	jnc .calculate_next_cluster	; If there's no error...

	call reset_floppy		; Otherwise, reset floppy and retry
	jnc .load_file_sector

	mov ax, .err_msg_floppy_reset	; Reset failed, bail out
	jmp os_fatal_error


.calculate_next_cluster:
	mov ax, [.cluster]
	mov bx, 3
	mul bx
	mov bx, 2
	div bx				; DX = [CLUSTER] mod 2
	mov si, disk_buffer		; AX = word in FAT for the 12 bits
	add si, ax
	mov ax, word [ds:si]

	or dx, dx			; If DX = 0 [CLUSTER] = even, if DX = 1 then odd

	jz .even			; If [CLUSTER] = even, drop last 4 bits of word
					; with next cluster; if odd, drop first 4 bits

.odd:
	shr ax, 4			; Shift out first 4 bits (belong to another entry)
	jmp .calculate_cluster_cont	; Onto next sector!

.even:
	and ax, 0FFFh			; Mask out top (last) 4 bits

.calculate_cluster_cont:
	mov word [.cluster], ax		; Store cluster

	cmp ax, 0FF8h
	jae .end

	add word [.load_position], 512
	jmp .load_file_sector		; Onto next sector!


.end:
	mov bx, [.file_size]		; Get file size to pass back in BX
	clc				; Carry clear = good load
	ret


	.bootd		db 0 		; Boot device number
	.cluster	dw 0 		; Cluster of the file we want to load
	.pointer	dw 0 		; Pointer into disk_buffer, for loading 'file2load'

	.filename_loc	dw 0		; Temporary store of filename location
	.load_position	dw 0		; Where we'll load the file
	.file_size	dw 0		; Size of the file

	.string_buff	times 12 db 0	; For size (integer) printing

	.err_msg_floppy_reset	db 'os_load_file: Floppy failed to reset', 0
	
os_fatal_error:
mov si , os_error
call print_string

disk_convert_l2hts:
	push bx
	push ax

	mov bx, ax			; Save logical sector

	mov dx, 0			; First the sector
	div word [SecsPerTrack]		; Sectors per track
	add dl, 01h			; Physical sectors start at 1
	mov cl, dl			; Sectors belong in CL for int 13h
	mov ax, bx

	mov dx, 0			; Now calculate the head
	div word [SecsPerTrack]		; Sectors per track
	mov dx, 0
	div word [Sides]		; Floppy sides
	mov dh, dl			; Head/side
	mov ch, al			; Track

	pop ax
	pop bx

	ret 
	
os_string_uppercase:
	pusha

	mov si, ax			; Use SI to access string

.more:
	cmp byte [si], 0		; Zero-termination of string?
	je .done			; If so, quit

	cmp byte [si], 'a'		; In the lower case A to Z range?
	jb .noatoz
	cmp byte [si], 'z'
	ja .noatoz

	sub byte [si], 20h		; If so, convert input char to upper case

	inc si
	jmp .more

.noatoz:

	inc si
	jmp .more

.done:
	popa
	ret

int_filename_convert:
	pusha

	mov si, ax

	call os_string_length
	cmp ax, 14			; Filename too long?
	jg .failure			; Fail if so

	cmp ax, 0
	je .failure			; Similarly, fail if zero-char string

	mov dx, ax			; Store string length for now

	mov di, .dest_string

	mov cx, 0
.copy_loop:
	lodsb
	cmp al, '.'
	je .extension_found
	stosb
	inc cx
	cmp cx, dx
	jg .failure			; No extension found = wrong
	jmp .copy_loop

.extension_found:
	cmp cx, 0
	je .failure			; Fail if extension dot is first char

	cmp cx, 8
	je .do_extension		; Skip spaces if first bit is 8 chars

	; Now it's time to pad out the rest of the first part of the filename
	; with spaces, if necessary

.add_spaces:
	mov byte [di], ' '
	inc di
	inc cx
	cmp cx, 8
	jl .add_spaces

	; Finally, copy over the extension
.do_extension:
	lodsb				; 3 characters
	cmp al, 0
	je .failure
	stosb
	lodsb
	cmp al, 0
	je .failure
	stosb
	lodsb
	cmp al, 0
	je .failure
	stosb

	mov byte [di], 0		; Zero-terminate filename

	popa
	mov ax, .dest_string
	clc				; Clear carry for success
	ret


.failure:
	popa
	stc				; Set carry for failure
	ret


	.dest_string	times 13 db 0
	
os_string_length:
	pusha

	mov bx, ax			; Move location of string to BX

	mov cx, 0			; Counter

.more:
	cmp byte [bx], 0		; Zero (end of string) yet?
	je .done
	inc bx				; If not, keep adding
	inc cx
	jmp .more


.done:
	mov word [.tmp_counter], cx	; Store count before restoring other registers
	popa

	mov ax, [.tmp_counter]		; Put count back into AX before returning
	ret


	.tmp_counter	dw 0

os_error db "Fatal error",0
Sides dw 2
SecsPerTrack dw 18

disk_buffer:
