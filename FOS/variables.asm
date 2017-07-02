;This file contains all text messages that will be printed

prompt          	 db "A:\>",0 
clear_command 		 db "clear",0
help_command 		 db "help",0
list_command		 db "list",0
reset_command        db "reset",0
execute_command	     db "exec",0
execute_prompt	     db "Enter name of file to execute >>> ",0
kern_filename		 db "KERNEL.BIN"
reset_prompt		 db "Drive to reset(0 - floppy) >> ",0
failed_to_load_file  db "Failed to load file.",0
test_command		 db "test floppy",0
list_text			 db "  NAME | TYPE ", 10 , 13 , "----------------" , 0 
debug_root_command 	 db "debug root",0
reset_failed_message db "Failed to reset the device.",0
info_message		 db "Floppy Operatign System v1.0" , 10 , 13 , "Made by Lazar Djurovic 2016-2017", 0
no_command_message 	 db 10 , 13 , "Command not found",0
help_message		 db 10 , 13 , "clear - clears screen" , 10 , 13 , "help - shows help message " , 10 , 13 , "debug root - displays contents of root directory in ASCII " , 10 , 13 , "list - shows all files on floppy disk" , 10 , 13 , "test floppy - checks for errors on floppy drive" , 10 , 13 , "reset - resets specified drive " , 10 , 13 ,  0
entry_message 		 db "For the list of commands type 'help' ", 10 , 13 , 0
loading_file_message db "Loading file . . . ",0
