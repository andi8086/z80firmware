.ORG 0x1000

test:
	ld hl, 2520
	ld (track), hl
	ld a, 21
	ld (sector), a
	call CS_to_LBA
	push af
	call PRINTDEC32

	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a
	pop af

	add a, 0x30
	out (0), a

	jp 0x0000

CHS_SStoDS:
	; convert CS to CHS
	; every odd track is on head 1
	ld a, (track)
	rra		; track = track / 2
	xor a
	rl a		; head = track mod 2
	ld (head), a
	ret

CS_to_LBA:
	; convert CS to LBA
	ld ix, track
	ld hl, (ix)
	exx
	ld hl, 0
	exx
	ld a, 26
	call MUL_HLHL_A
	ld a, (sector)
	dec a
	add a, l
	ld l, a
	ld a, h
	adc a, 0
	ld h, a
	ld b, 0	; used further below
	exx
	ld a, l
	adc a, 0
	ld l, a
	ld a, h
	adc a, 0
	ld h, a
	;exx
	; H'L'HL now contains LBA for 128 byte sectors
	; divide it by 4 and get the rest as index in a
	;exx
	rr h
	rr l
	exx
	rr h
	rr l
	rl b
	exx
	rr h
	rr l
	exx
	rr h
	rr l
	rl b
	; H'L' now contains LBA for 512 byte sectors with a from 0 to 3
	; as partial 512 byte block index for 128 byte sub blocks
	ld a, b
	ret

track:	.byte 0, 0, 0, 0
head:	.byte 0
sector:	.byte 0

MUL_HLHL_A:
	; perform HL'HL := HL'HL * A
	ld de, 0
	exx
	ld de, 0
	exx
	ld b, 8		; check 8 bits
next_bit:
	rra
	push af
	jr nc, skip_bit
	ld a, e
	add a, l
	ld e, a
	ld a, d
	adc a, h
	ld d, a
	exx
	ld a, e
	adc a, l
	ld e, a
	ld a, d
	adc a, h
	ld d, a
	exx
skip_bit:
	pop af
	add hl, hl
	exx
	adc hl, hl
	exx
	dec b
	jr nz, next_bit
	ld hl, de
	exx
	ld hl, de
	exx
	ret


ADD32MI:
	; ix points to the 32-bit operands
	; A0, A1, B0, B1
	; A2, A4, B3, B4
	; where A := A + B
	ld hl, (ix)
	ld de, (ix+2)
	exx
	ld hl, (ix+4)
	ld de, (ix+6)
	exx
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
