; CP/M RZ80 FIFO Loader
; loads a program into TPA

; first it must relocate itself to D000
; therefore, the binary consists of a loader stub, starting at 0x100
; and the actual image for 0xD000, beginning at 0x200
; binaries are concatenated images

.ORG 100h

start:
	LD HL, 0x200
	LD DE, 0xD000
	LD BC, 1024
	LDIR
	JP 0xD000

.ds 0x200 - $
.END
