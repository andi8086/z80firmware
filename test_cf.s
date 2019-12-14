.org 1000h

; test the compact flash card

PRINT_HEX_BYTE = 01BDh

IDE_BASE = 38h		; changed from 0x30 to 0x38 because of IO conflicht
			; with FIFO buffer
IDE_DATA = IDE_BASE + 0 ; instead of 0 because of FIFO collision
IDE_FEATURE = IDE_BASE + 1 ; instead of 0 because of FIFO collision
IDE_SECC = IDE_BASE + 2 ; sector count
IDE_LBA0 = IDE_BASE + 3
IDE_LBA1 = IDE_BASE + 4
IDE_LBA2 = IDE_BASE + 5
IDE_LBA3 = IDE_BASE + 6
IDE_COMMAND = IDE_BASE + 7	;write
IDE_STATUS = IDE_BASE + 7	;read

IDE_CMD_SET_FEATURE	= 0xEF
IDE_CMD_IDENTIFY	= 0xEC
IDE_CMD_RESET		= 0x04
IDE_CMD_READ_SECTOR	= 0x20
IDE_CMD_WRITE_SECTOR	= 0x30

IDE_FEATURE_8BIT_TRANSFER = 0x01
IDE_FEATURE_NO_WRITE_CACHE = 0x82

IDE_STATUS_ERROR	= 0x01
IDE_STATUS_DRQ		= 0x40
IDE_STATUS_BUSY		= 0x80

IDE_FLAGS_LBA		= 0xE0	; upper part of LBA3 reg

init:
	ld a, 'S'
	out (0), a

reset_CF:
	call cf_init

	ld a, IDE_FEATURE_NO_WRITE_CACHE
	out (IDE_FEATURE), a
	ld a, IDE_CMD_SET_FEATURE
	out (IDE_COMMAND), a
	call cf_wait
	call cf_checkerror

	ld a, 'X'
	out (0), a

	ld a, IDE_CMD_IDENTIFY
	out (IDE_COMMAND), a
	call cf_wait
	call cf_read_512
	call cf_print_buff

	ld a, 'W'
	out (0), a

	ld a, '*'
	call fill_buffer

	ld a, 2
	ld (VAR_LBA0), a
	xor a
	ld (VAR_LBA1), a
	ld (VAR_LBA2), a
	ld (VAR_LBA3), a
	;call cf_write_lba

	ld a, 'X'
	out (0), a

;
;	ld bc, 0
;next_sector:
;	push bc
;	call cf_wait
;	ld a, 'b'
;	call fill_buffer
;	ld a, b
;	ld (VAR_LBA0), a
;	xor a
;	ld (VAR_LBA1), a
;	ld (VAR_LBA2), a
;	ld (VAR_LBA3), a
;	call cf_read_lba
;	call cf_print_buff
;	pop bc
;	inc b
;	ld a, 64
;	cp b
;	jr nz, next_sector

	ld bc, 33
	ld de, 72
	call DE_Times_BC
	ld c, 0	; don't skip any digits
	call DispHL_games


	halt
	jr $

cf_wait:
	in a, (IDE_STATUS)
	and IDE_STATUS_BUSY
	jr nz,cf_wait
	ret

cf_checkerror:
	in a, (IDE_STATUS)
	and IDE_STATUS_ERROR
	ret z
	; error occured
	ret

cf_load_lba_address:
	ld a, (VAR_LBA0)
	out (IDE_LBA0), a
	ld a, (VAR_LBA1)
	out (IDE_LBA1), a
	ld a, (VAR_LBA2)
	out (IDE_LBA2), a
	ld a, (VAR_LBA3)
	and 0x0F
	or IDE_FLAGS_LBA
	out (IDE_LBA3), a
	ret

cf_read_lba:
	call cf_load_lba_address
	ld a, IDE_CMD_READ_SECTOR
	out (IDE_COMMAND), a
	call cf_wait
cf_read_512:
	ld hl, 512
	ld de, sec_buff
read_bytes:
	in a, (IDE_STATUS)
	and IDE_STATUS_DRQ
	jr z, read_bytes     ; wait for DRQ
	in a, (IDE_DATA)
	dec hl
	ld (de),a
	inc de
	xor a
	or h
	or l
	jr nz, read_bytes
	ret

cf_write_lba:
	call cf_load_lba_address
	ld a, IDE_CMD_WRITE_SECTOR
	out (IDE_COMMAND), a
	call cf_wait
cf_write_512:
	ld hl, 512
	ld de, sec_buff
write_bytes:
	in a, (IDE_STATUS)
	and IDE_STATUS_DRQ
	jr z, write_bytes	; wait for DRQ
	ld a, (de)
	out (IDE_DATA), a
	inc de
	dec hl
	xor a
	or h
	or l
	jr nz, write_bytes
	ret

cf_init:
	ld a, IDE_CMD_RESET
	out (IDE_COMMAND), a
	call cf_wait
	ld a, IDE_FLAGS_LBA
	out (IDE_LBA3), a
	ld a, IDE_FEATURE_8BIT_TRANSFER
	out (IDE_FEATURE), a
	ld a, IDE_CMD_SET_FEATURE
	out (IDE_COMMAND), a
	call cf_wait
	call cf_checkerror
	ld a, 1
	out (IDE_SECC), a
	ret

cf_print_buff:
	ld hl, sec_buff
	ld b, 0
	ld c, 0
	otir
	otir
	ret

fill_buffer:
	ld de, sec_buff
	ld hl, 512
	push af
fill_bytes:
	pop af
	push af
	ld (de), a
	dec hl
	inc de
	xor a
	or h
	or l
	jr nz,fill_bytes
	pop af
	ret

read_sector_128:
	; we want to read 128 bytes and need to find the block
	; that contains the data

	; usually we are given cylinder, head and sector
	; we assume a double sided disk, i.e. 2 heads: 0 and 1
	; and we assume 26 sectors per track, like for 8" floppies

	; the parameters used are in the variables
	; VAR_CF_HEAD, VAR_CF_CYL, VAR_CF_SEC

	; first we calculate the 128-byte LBA_SMALL that simulates
	; 128 Byte sectors

	; check if sec is in range 1..SEC_PER_TRACK
	ld a, (VAR_CF_SEC)
	ld b, a
	ld a, (VAR_LBA_SEC_PER_TRACK)
	cp b	; subtract CF_SEC, if negative, error

	ret s

	; check head
	ld a, (VAR_CF_HEAD)
	and 0xFE
	ret nz	; return if any other bit is set except bit 0

	ld a, (VAR_CF_CYL_HI)
	and 0x80
	ret nz ; return if cylinder MSB is > 127

	; multiply cylinder with 2, to take heads into account
	ld a, (VAR_CF_HEAD)
	rr a	; rotate a to the right, head is in carry
	ld a, (VAR_CF_CYL_LO)
	rl a	; cyl = cyl * 2 + head
	ld (VAR_LBA_SMALL0), a
	ld a, (VAR_CF_CYL_HI)
	rl a
	ld (VAR_LBA_SMALL1), a	; LBA1:LBA0 = cyl * 2 + head

	; now multiply with sectors per track
	ret

A_Times_DE:
;211 for times 1
;331 tops
;Outputs:
;     HL is the product
;     B is 0
;     A,C,DE are not changed
;     z flag set
;
     ld hl,0
     or a
     ld b,h    ;remove this if you don't need b=0 for output. Saves 4 cycles, 1 byte
     ret z
     ld b,9
       rlca
       dec b
       jr nc,$-2
Loop1:
     add hl,de
Loop2:
     dec b
     ret z
     add hl,hl
     rlca
     jp c,Loop1      ;21|20
     jp Loop2
;22 bytes


DE_Times_BC:
;Inputs:
;     DE and BC are factors
;Outputs:
;     A is 0
;     BC is not changed
;     DEHL is the product
;
       ld hl,0
       ld a,16
Mul_Loop_1:
         add hl,hl
         rl e \ rl d
         jr nc,$+6
           add hl,bc
           jr nc,$+3
           inc de
         dec a
         jr nz,Mul_Loop_1
       ret

DispHLhex:
	; print a number in DEHL
	;Display a 16- or 8-bit number in hex.
	; Input:0 HL
	ld  c,h
	call  OutHex8
	ld  c,l
OutHex8:
	; Input: c
	ld  a,c
	rra
	rra
	rra
	rra
	call  Conv
	ld  a,c
Conv:
	and  $0F
	add  a,$90
	daa
	adc  a,$40
	daa
	out (0), a
	ret

;DispHL for games
;input: hl=num, c=number of algarisms to skip
;digits to display: 5 ; example: 65000
;output: hl displayed, with algarisms skiped and spaces for initial zeros
DispHL_games:
	inc c
	ld b,1		;skip 0 flag
	;Number in hl to decimal ASCII
	;Thanks to z80 Bits
	;inputs:	hl = number to ASCII
	;example: hl=300 outputs '  300'
	;destroys: af, hl, de used
	ld	de,-10000
	call	Num1
	ld	de,-1000
	call	Num1
	ld	de,-100
	call	Num1
	ld	e,-10
	call	Num1
	ld	e,-1
Num1:
	ld	a,'0'-1
Num2:	inc	a		; start with '0' in digit
	add	hl,de		; add -1*10^current digit
	jr	c,Num2		; if this was not too much, do it again
	sbc	hl,de		; else, revert last addition
	dec c			;c is skipping
	jr nz,skipnum		; this skips the digit if c < current digit
				;   but why calculate before????
	inc c
	djnz notcharnumzero
	cp '0'
	jr nz,notcharnumzero
leadingzero:
	inc b
skipnum:
	ld a,' '
notcharnumzero:
	out (0), a
	ret


VAR_LBA_SMALL0: .byte 0
VAR_LBA_SMALL1: .byte 0
VAR_LBA_SMALL2: .byte 0
VAR_LBA_SMALL3: .byte 0
VAR_LBA_SEC_PER_TRACK: .byte 26

VAR_CF_HEAD: .byte 0
VAR_CF_CYL_LO: .byte 0
VAR_CF_CYL_HI: .byte 0
VAR_CF_SEC: .byte 1

sec_buff: defs 512
VAR_LBA0: .byte 0
VAR_LBA1: .byte 0
VAR_LBA2: .byte 0
VAR_LBA3: .byte 0
