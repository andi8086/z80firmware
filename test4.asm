#define ROMSIZE		2048
.org 0
	; ******** interrupts are disabled after reset ********
	im 1				; use interrupt mode 1

	; ********         test upper 32K RAM          ********
	ld hl, 08000h
	ld b, 0AAh
	ld c, 055h
_test_upper_32K:
	ld (hl), b
	ld a, (hl)
	xor 0AAh
	jp nz, _ram_error_upper
	ld (hl), c
	ld a, (hl)
	xor 055h
	jp nz, _ram_error_upper
	inc hl
	jr nz, _test_upper_32K

	; ********        copy firmware to F000        ********
	ld hl, 0
	ld de, 0F000h		; destination of rom image
	ld bc, ROMSIZE		; copy ROMSIZE bytes
	ldir			;

	jp $+0F003h		; jump to copied program
	out (15), a		; disable rom and enable ram bank 1

	jp 0F000h + continue_in_ram

.org 38h

_int_handler:

	ei
	reti


.org 66h

_nmi_handler:
	reti

hellomsg:
.ascii "Reichel Z80 System, 64K RAM OK", 0ah, 0dh
.ascii "FIFO Loader", 0ah, 0dh, 00h

continue_in_ram:
	ld hl, 7FFFh
	ld b, 0AAh
	ld c, 055h
_test_lower_32K:
	ld (hl), b
	ld a, (hl)
	xor 0AAh
	jp nz, 0F000h + _ram_error_lower
	ld (hl), c
	ld a, (hl)
	xor 055h
	jp nz, 0F000h + _ram_error_lower
	dec hl
	jr nz, _test_lower_32K

	ld hl, 0F000h
	ld de, 0
	ld bc, ROMSIZE
	ldir		; copy it back, ending up in ram

	jp _ram_entry	; rom code is now in ram, at the same address

_ram_entry:
	ld sp, 0FFFFh		; init stack

	call _fifo_await_usb_config

	ld hl, hellomsg
	call _fifo_print_str

	call _fifo_get_byte	; get target addr low
	ld (addr), a
	call _fifo_get_byte	; get target addr hi
	ld (addr+1), a
	call _fifo_get_byte	; get size low
	ld (size), a
	call _fifo_get_byte	; get size high
	ld (size+1), a
	call _fifo_get_byte	; get checksum low
	ld (cksum), a
	call _fifo_get_byte	; get checksum hi
	ld (cksum+1), a
	ld de, (addr)
	ld hl, (size)

	ld a, 'S'
	call _fifo_put_byte
	ld a, h
	call _print_hex_byte
	ld a, l
	call _print_hex_byte

_download_code:
	call _fifo_get_byte
	ld (de), a
	inc de
	dec l
	ld a, l
	cp 0FFh
	jr nz, _download_code
	ld a, h
	or a
	jr z, _download_finish
	dec h
	jr _download_code
_download_finish:
	dec de
	ld hl, 0
	ld bc, (size)
_calc_checksum
	ld a, (de)
	add a, l
	ld l, a
	jr nc, skip_carry
	inc h
skip_carry:
	dec de
	dec c
	ld a, c
	cp 0ffh
	jr nz, _calc_checksum
	ld a, b
	or a
	jr z, _finish_checksum
	dec b
	jr _calc_checksum
_finish_checksum:

	ld a, 'X'
	call _fifo_put_byte
	ld a, h
	call _print_hex_byte
	ld a, l
	call _print_hex_byte

	ld a, (cksum)
	cp l
	jr nz, _error_cksum
	ld a, (cksum+1)
	cp h
	jr nz, _error_cksum
	ld hl, cksum_ok_msg
	call _fifo_print_str
	ld hl, (addr)
	jp (hl)			; jump to downloaded code

_error_cksum:
	ld hl, cksum_error_msg
	call _fifo_print_str
	jp _ram_entry

_loop_forever:
	halt
	jp _loop_forever

addr:	.word 0
size:	.word 0
cksum:	.word 0

cksum_error_msg: .ascii "BAD CHKSUM", 0Ah, 0Dh, 0Ah, 0Dh, 00h
cksum_ok_msg: .ascii "CKSUM OK", 0Ah, 0Dh, 00h

_fifo_await_usb_config:
	in a, (1)
	and 4
	jr nz, _fifo_await_usb_config
	ret

_fifo_put_byte:
	ld c, 1
_await_txe:
	in b, (c)
	bit 1, b
	jr nz, _await_txe
	out (0), a
	ret

_fifo_get_byte:
	ld c, 1
_await_rxf:
	in b, (c)
	bit 0, b
	jr nz, _await_rxf
	in a, (0)
	call _print_hex_byte
	ret

_fifo_print_str:
	ld a, (hl)
	or a
	jr z, _fifo_print_str_exit
	call _fifo_put_byte
	inc hl
	jr _fifo_print_str
_fifo_print_str_exit:
	ret

_ram_error_upper:
	ld a, 'U'
	ld sp, 07FFFh
	call _fifo_put_byte
	jr _ram_error_upper

_ram_error_lower:
	ld a, 'L'
	ld sp, 0FFFFh
	call 0F000h + _fifo_put_byte
	jr _ram_error_lower

_print_hex_byte:
	push af
		srl a
		srl a
		srl a
		srl a
		add '0'
		cp '9'
		jp m, no_hex1
		jr z, no_hex1
		add 'A'-'9'-1
no_hex1:
		call _fifo_put_byte
	pop af
	push af
		and 0Fh
		add '0'
		cp '9'
		jp m, no_hex2
		jr z, no_hex2
		add 'A'-'9'-1
no_hex2:
		call _fifo_put_byte
		ld a, ' '
		call _fifo_put_byte
	pop af
	ret

.ds 0x800 - $
.end
