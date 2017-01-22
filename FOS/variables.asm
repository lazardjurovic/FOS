;This file contains all text messages that will be printed

welcome_message 	db "                       Floppy Operating System                  ",0
prompt          	db "A:\>",0 
info_command		db "info",0
clear_command 		db "clear",0
help_command 		db "help",0
list_command		db "list",0
test_command		db "test floppy",0
list_text			db "  NAME  | TYPE ", 10 , 13 , "----------------" , 0 
debug_root_command 	db "debug root",0
info_message		db 10 , 13 , 10 , 13 , "Floppy Operatign System v1.0" , 10 , 13 , "Made by Lazar Djurovic 2016-2017", 10 , 13 , 0
no_command_message 	db 10 , 13 , "Command not found",0
help_message		db 10 , 13 , "info - displays informations about operatins system" , 10 , 13 , "clear - clears screen" , 10 , 13 , "help - shows help message " , 10 , 13 , "debug root - displays contents of root directory in ASCII " , 10 , 13 , "list - shows all files on floppy disk" , 10 , 13 , "test floppy - checks for errors on floppy drive" , 10 , 13 , 0