.org 1000h

; test the compact flash card

PRINT_HEX_BYTE = 01BDh

IDE_BASE = 30h
IDE_DATA = IDE_BASE + 0
IDE_FEATURE = IDE_BASE + 1
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
	call cf_write_lba

	ld a, 'X'
	out (0), a
	ld bc, 0
next_sector:
	push bc
	call cf_wait
	ld a, 'b'
	call fill_buffer
	ld a, b
	ld (VAR_LBA0), a
	xor a
	ld (VAR_LBA1), a
	ld (VAR_LBA2), a
	ld (VAR_LBA3), a
	call cf_read_lba
	call cf_print_buff
	pop bc
	inc b
	ld a, 64
	cp b
	jr nz, next_sector
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

sec_buff: defs 512
VAR_LBA0: .byte 0
VAR_LBA1: .byte 0
VAR_LBA2: .byte 0
VAR_LBA3: .byte 0
