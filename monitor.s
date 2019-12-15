.org 0xDF00
start:
	ld a, '*'
	out (0), a

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
	ld a, (cksum)
	cp l
	jr nz, _error_cksum
	ld a, (cksum+1)
	cp h
	jr nz, _error_cksum

	call _fifo_get_byte
	cp 'g'
	jr nz, dont_start
	ld hl, (addr)
	jp (hl)			; jump to downloaded code

_error_cksum:
	ld a, 'E'
	out (0), a
dont_start:
	jp start

addr:	.word 0
size:	.word 0
cksum:	.word 0

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
	ret

.end
