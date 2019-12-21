; this program is the image concatenated to fifoload
; it is transfered from 0x200 to 0xD000

.ORG 0xD000

DRIVE	= 4			; drive byte
BDOS	= 5			; vector to BDOS
FCB	= 05Ch			; default FCB

start:
	ld a, (FCB)	; load drive byte from FCB
	or a
	jr nz, drivespec
	ld a, (DRIVE)	; use current drive from OS
	inc a
drivespec:		; user specified a drive
	add 'A'		; make it relative to 'A'
	dec a
	ld e, a
	cp '@'
	jr c, nodrive	; something below A
	jp start_transfer
nodrive:
	ld de, invaldrive_msg
	ld c, 9
	call BDOS
	ret		; return to BDOS
start_transfer:
	ld a, '*'
	out (0), a
	ld d, 11
	ld hl, FCB+1
get_fname:
	call _fifo_get_byte	; get 8+3 filename
	or a
	ret z			; exit on null byte
	ld (hl), a		; store filename
	inc hl
	dec d
	jr nz, get_fname
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

	LD DE, TransferOK
	jp create_file

_error_cksum:
	LD DE, TransferERR
	LD C, 9
	CALL 5
	LD C, 0
	CALL 5

create_file:
	ld c, 11h
	ld de, FCB
	call BDOS	; file name occupied?
	cp 0FFh
	jr z, createfile2	; no? continue
	ld de, fileexists_msg
	ld c, 9
	call BDOS
	ret
createfile2:
	xor a
	ld (FCB+32), a  ; set current record to 0
	ld (FCB+12), a  ; set current extent to 0
	ld c, 16h	; create file function
	ld de, FCB
	call BDOS
	cp 0FFh
	jr nz, write_file
createerror:
	ld de, nocreate_msg
	ld c, 9
	call BDOS
	ret
write_file:
	ld hl, (addr)
next_rec:
	ld de, 80h
	ld bc, 128
	ldir		; copy to default dma buffer
write_record:
	ld de, FCB
	ld c, 15h	; write sequential
	call BDOS
	or a
	jr z, prepare_next_rec
error_write_record:
	ld de, writerecerr_msg
	ld c, 9
	call BDOS
	ret
prepare_next_rec:
	ld c, 128
	ld b, 0
	ld hl, (size)
	scf		; set carry
	ccf		; complement carry
	sbc hl, bc
	jr c, close_file
	ld a, l
	or h
	jr z, close_file
	ld (size), hl	; update size
	ld hl, (addr)
	ld bc, 128
	add hl, bc
	ld (addr), hl
	jr next_rec
close_file:
	ld c, 10h	; close file
	ld de, FCB
	call BDOS
	jp start_transfer


addr:	.word 0
size:	.word 0
cksum:	.word 0

TransferOK: .ascii "Transfer Complete", 0Ah, 0Dh, "$"
TransferERR: .ascii "Wrong Checksum", 0Ah, 0Dh, "$"
invaldrive_msg: .ascii "Invalid drive", 0Ah, 0Dh, "$"
fileexists_msg: .ascii "File already exists", 0Ah, 0Dh, "$"
nocreate_msg: .ascii "Could not create file", 0Ah, 0Dh, "$"
writerecerr_msg: .ascii "Write record error", 0Ah, 0Dh, "$"

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

