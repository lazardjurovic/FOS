# Floppy Operating system

## Floppy Operating System ( FOS ) is a hobby project about designing operating system.It started at the end of 2016 at is supposed to be finished until September 2017. It is currently written in assembly language, but there will be more parts written in C language

## Modules :  
`bootload.asm` - bootloader written for MikesOS ( Another homemade OS )  
`floppy.asm` - floppy drive driver ( contains all functions for using floppy disks)    
`keyboard.asm` - contains all functions for reading charaters from keyboard  
`screen.asm` - this file contains all functions for printing text on screen , cursor , etc...  
`string.asm` - contains all functions that have to do something with strings  
`variables.asm` - contains all text and messages that will be printed on screen         
`kernel.asm` - our main kernel file ( combines all other files into one file)  


## Updates : 
*17.1.2017* - first successfull test of floppy drive driver

## How to use :
1) For using FOS you should have virtual or physical floppy drive  
2) First you have to write bootloader to your floppy disk ( FOS is using MikeOS bootloader )  
3) On Windows machines you open cmd, change directory to 'binary files' and type :  
			1) `debug bootload.bin`        
			2) `w 100 0 0 1`  
			3) `q`
4) Then you should copy your Kernel to floppy disk  
5) In cmd type:  
		`copy KERNEL.BIN A:\`  
6) Open any virtual machine or PC emulator and boot FOS from floppy drive