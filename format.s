; CP/M 2.2 DISK FORMAT UTILITY
; (c) 2019 A.J.Reichel

WBOOT =01h	; BIOS WBOOT ENTRY
BDOS = 05h	; BDOS ENTRY

BIOS_SELDISK = 24
BIOS_SETTRK = 27
BIOS_SETSEC = 30
BIOS_SETDMA = 33
BIOS_READ = 36
BIOS_WRITE = 39

.ORG 100h

.MACRO BIOSCALL %NUM
	LD IX, (WBOOT)
	LD DE, %NUM
	ADD IX, DE	; BIOS SET DRIVE ; just to be sure ;)
	LD HL, (IX+1)
	LD DE, $+6
	PUSH DE
	PUSH HL
	RET
.ENDM

start:
	LD DE, WelcomeMSG
	LD C, 9
	CALL BDOS


	LD DE, FormattingMSG
	LD C, 9
	CALL BDOS

	LD C, 19h
	CALL BDOS
	PUSH AF
	 LD IX, CurrentDisk
	 ADD (IX)
	 LD (IX), A

	 LD DE, CurrentDiskMSG
	 LD C, 9
	 CALL BDOS

	 LD DE, Question
	 LD C, 9
	 CALL BDOS

	 LD C, 1
	 CALL BDOS
	 CP 'Y'
	 JR Z, Continue
	POP AF
	; Return to CP/M
	LD C, 0
	CALL BDOS
Continue:
	POP AF
	LD C, A
	BIOSCALL BIOS_SELDISK

	LD DE, HL
	LD IX, DE	; Pointer to DPH
	LD DE, (IX+10)	; Pointer to DPB
	LD HL, DPBAddress
	LD (HL), DE
	LD IX, DE
	LD DE, (IX)	; sectors per track

	LD HL, SectorsPerTrack
	LD (HL),DE
	LD HL, DE
	EXX
	LD HL, 0
	EXX
	CALL PRINTDEC32
	LD DE, SectorsPerTrackMSG
	LD C, 9
	CALL BDOS

	LD IX, DPBAddress
	LD DE, (IX)
	LD IX, DE
	LD C, (IX+2)
	LD A, 255
	ADD 1
calc_blocksize:
	rla
	dec c
	jr nz, calc_blocksize
	LD H, A
	LD L, 0
	EXX
	LD HL, 0
	EXX
	CALL PRINTDEC32

	LD DE, BlocksizeMSG
	LD C, 9
	CALL BDOS

	LD IX, DPBAddress
	LD DE, (IX)
	LD IX, DE
	LD A, (IX+13)

	PUSH AF
	 ADD '0'
	 LD C, 2
	 LD E, A
	 CALL BDOS

	 LD DE, ReservedTracksMSG
	 LD C, 9
	 CALL BDOS
	POP AF

	LD B, 0
	LD C, A
	BIOSCALL BIOS_SETTRK

	; now just format the whole first non-reserved track
	LD A, 0xE5
	LD C, 128
	LD DE, Buffer
fill_buffer:
	LD (DE), A
	INC DE
	DEC C
	JR NZ, fill_buffer

	; set the dma address
	LD BC, Buffer
	BIOSCALL BIOS_SETDMA

	LD HL, SectorsPerTrack
	LD DE, (HL)
format_track:
	PUSH DE

	LD BC, DE
	DEC BC
	BIOSCALL BIOS_SETSEC
	BIOSCALL BIOS_WRITE
	POP DE
	PUSH DE
	LD HL, DE
	EXX
	LD HL, 0
	EXX
	CALL PRINTDEC32
	LD E, ' '
	LD C, 2
	CALL BDOS
	POP DE
	DEC DE
	XOR A
	LD A, D
	OR E
	JR nz, format_track

	LD DE, FormatCompleteMSG
	LD C, 9
	CALL BDOS

	; Return to CP/M
	LD C, 0
	CALL BDOS

; 32-bit addition
; H'L'HL = H'L'HL + D'E'DE
ADD32:
	ADD	HL, DE;	16-bit ADD of HL and DE
	EXX
	ADC	HL, DE;	16-bit ADD of HL and DE with carry
	EXX
	RET

SBC32:
	SBC	HL, DE
	EXX
	SBC	HL, DE
	EXX
	RET


digit32:
	ld e, (ix)
	ld d, (ix+1)
	exx
	ld e, (ix+2)
	ld d, (ix+3)
	exx
	ld a, '0'-1
digit32s:
	inc a
	call ADD32
	jr c, digit32s
	call SBC32
	ld b, a
	and 0x0F
	or (iy)
	ret z
	ld a, b
	out (0),a
	ld (first_digit), a
	ret

digit16:
	ld e, (ix)
	ld d, (ix+1)
	ld a, '0'-1
digit16s:
	inc a
	add hl, de
	jr c, digit16s
	sbc hl, de
	ld b, a
	and 0x0F
	or (iy)
	ret z
	ld a, b
	out (0),a
	ld (first_digit), a
	ret

first_digit: .byte 0
PRINTDEC32:
	ld iy, first_digit
	ld a, 0
	ld (iy), a
	ld ix, CONST_DEC_MINUS_10_9
	call digit32
	ld ix, CONST_DEC_MINUS_10_8
	call digit32
	ld ix, CONST_DEC_MINUS_10_7
	call digit32
	ld ix, CONST_DEC_MINUS_10_6
	call digit32
	ld ix, CONST_DEC_MINUS_10_5
	call digit32
	ld ix, CONST_DEC_MINUS_10_4
	call digit32
	ld ix, CONST_DEC_MINUS_10_3
	call digit16
	ld ix, CONST_DEC_MINUS_10_2
	call digit16
	ld ix, CONST_DEC_MINUS_10_1
	call digit16
	; only 0-9 left
	ld a, '0'
	add l
	out (0), a
	ret

CONST_DEC_MINUS_10_9: .byte 0x00, 0x36, 0x65, 0xC4
CONST_DEC_MINUS_10_8: .byte 0x00, 0x1F, 0x0A, 0xFA
CONST_DEC_MINUS_10_7: .byte 0x80, 0x69, 0x67, 0xFF
CONST_DEC_MINUS_10_6: .byte 0xC0, 0xBD, 0xF0, 0xFF
CONST_DEC_MINUS_10_5: .byte 0x60, 0x79, 0xFE, 0xFF
CONST_DEC_MINUS_10_4: .byte 0xF0, 0xD8, 0xFF, 0xFF
CONST_DEC_MINUS_10_3: .byte 0x18, 0xFC
CONST_DEC_MINUS_10_2: .byte 0x9C, 0xFF
CONST_DEC_MINUS_10_1: .byte 0xF6, 0xFF

DPBAddress: defw 0

WelcomeMSG: .ascii "CP/M FORMAT 1.0 FOR RZ80 Computer", 0Ah, 0Dh
            .ascii "  (C)Copyright 2019 by A.J.Reichel", 0Ah, 0Dh, "$"
FormattingMSG: .ascii 0Ah,0Dh,"Formatting...$"
Question: .ascii "Are you sure (Y/N)?$"
CurrentDiskMSG: .ascii "Selected Drive is "
CurrentDisk: defm "A"
CurrentDiskMSG2: .ascii 0Ah,0Dh,"$"
SectorsPerTrackMSG: .ascii " sectors per track",0Ah,0Dh,"$"
ReservedTracksMSG: .ascii " reserved system tracks",0Ah,0Dh,"$"
BlocksizeMSG: .ascii " bytes per block", 0Ah, 0Dh, "$"
SectorsPerTrack: .word 0
FormatCompleteMSG: .ascii "Complete", 0Ah, 0Dh, "$"
Buffer: .byte 0
.END
