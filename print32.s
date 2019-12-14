.ORG 0x1000

test:
	ld hl, 0xBFEB
	exx
	ld hl, 0x01CB
	exx		; h'l'hl = 0x01CBBFEB (305130155)
	call PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	ld hl, 0x0001
	exx
	ld hl, 0
	exx
	call PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	ld hl, 0x27FF
	exx
	ld hl, 0xEE6B
	exx
	call PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	ld hl, 0xF238
	exx
	ld hl, 0xAC30
	exx
	call PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	ld hl, 0x0000
	exx
	ld hl, 0x0010
	exx
	call PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	ld hl, 0x0000
	exx
	ld hl, 0x0001
	exx
	call PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	ld hl, 0x0011
	exx
	ld hl, 0
	exx
	CALL PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	ld hl, 0x2000
	exx
	ld hl, 0
	exx
	CALL PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	ld hl, 0x0400
	exx
	ld hl, 0
	exx
	CALL PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	ld hl, 0x0100
	exx
	ld hl, 0
	exx
	CALL PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	ld hl, 0x0010
	exx
	ld hl, 0
	exx
	CALL PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	ld hl, 0
	exx
	ld hl, 0
	exx
	CALL PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	ld hl, 0
	exx
	ld hl, 0x02
	exx
	CALL PRINTDEC32
	ld a, 0x0D
	out (0),a
	ld a, 0x0A
	out (0),a

	jp 0x0000

ADD32MI:
	; ix points to the 32-bit operands
	; A0, A1, B0, B1
	; A2, A4, B3, B4
	; where A := A + B
	ld l, (ix)
	ld h, (ix+1)
	ld e, (ix+2)
	ld d, (ix+3)
	exx
	ld l, (ix+4)
	ld h, (ix+5)
	ld e, (ix+6)
	ld d, (ix+7)
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
