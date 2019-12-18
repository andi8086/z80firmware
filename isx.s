; Disassembly of Digital Research's ISIS emulator ISX.COM

wboot  =  0 
iobyte  =  3 
cpm_disk  =  4 
bdos  =  5 

vec_38  =  38h 
vec_40  =  40h 

unk_1  =  5Bh 
cpm_fcb  =  5Ch 
cpm_bfr  =  80h 

;----------------------------------------------------------------------

		org	100h

start:
		JP	main

loc_2:
		JP	bdos_ept

tr_level:	DEFM	0			; trace level
word_3:		DEFW	0
word_4:		DEFW	0
word_5:		DEFW	0

;		ds	115

;----------------------------------------------------------------------

		org	180h

; This BDOS subsystem (0180H - 0FFFH) replaces the CP/M BDOS,
; which is overlayed by ISIS application programs.
;
; This is basically a CP/M 2.2 BDOS, with a minor modification to
; support exact file sizes.

bdos_ept:
		JP	bdose

;----------------------------------------------------------------------

		LD	HL,(wboot+1)
		LD 	l,0		; boot?
		JP	(HL)	

dos_reset:
		LD	HL,(wboot+1)
		LD 	l,3		; BIOS wboot
		JP	(HL)	

b_const:
		LD	HL,(wboot+1)
		LD 	l,6		; BIOS const
		JP	(HL)	

b_conin:
		LD	HL,(wboot+1)
		LD 	l,9		; BIOS conin
		JP	(HL)	

b_conout:
		LD	HL,(wboot+1)
		LD 	l,0Ch		; BIOS conout
		JP	(HL)	

b_list:
		LD	HL,(wboot+1)
		LD 	l,0Fh		; BIOS list
		JP	(HL)	

b_punch:
		LD	HL,(wboot+1)
		LD 	l,12h		; BIOS punch
		JP	(HL)	

b_reader:
		LD	HL,(wboot+1)
		LD 	l,15h		; BIOS reader
		JP	(HL)	

b_home:
		LD	HL,(wboot+1)
		LD 	l,18h		; BIOS home
		JP	(HL)	

b_seldsk:
		LD	HL,(wboot+1)
		LD 	l,1Bh		; BIOS seldsk
		JP	(HL)	

b_settrk:
		LD	HL,(wboot+1)
		LD 	l,1Eh		; BIOS settrk
		JP	(HL)	

b_setsec:
		LD	HL,(wboot+1)
		LD 	l,21h		; BIOS setsec
		JP	(HL)	

b_setdma:
		LD	HL,(wboot+1)
		LD 	l,24h		; BIOS setdma
		JP	(HL)	

b_read:
		LD	HL,(wboot+1)
		LD 	l,27h		; BIOS read
		JP	(HL)	

b_write:
		LD	HL,(wboot+1)
		LD 	l,2Ah		; BIOS write
		JP	(HL)	

		LD	HL,(wboot+1)
		LD 	l,2Dh		; BIOS listst
		JP	(HL)	

b_sectran:
		LD	HL,(wboot+1)
		LD 	l,30h		; BIOS sectran
		JP	(HL)	

;----------------------------------------------------------------------

err_tbl:	DEFW	err_badsec
e_sel:		DEFW	err_select
e_ro:		DEFW	err_ro
e_filero:	DEFW	err_filero

;----------------------------------------------------------------------

bdose:
		EX	DE,HL	
		LD	(info),HL
		EX	DE,HL	
		LD 	a,e
		LD	(linfo),A
		LD	HL,0
		LD	(lret),HL
		ADD	HL,sp
		LD	(entsp),HL
		LD	sp,lstack
		XOR	a
		LD	(fcbdsk),A
		LD	(resel),A
		LD	HL,goback	; return address
		PUSH	HL
		LD 	a,c
		CP	41		; maxfunc + 1
		RET	NC	
		LD 	c,e
		LD	HL,dos_ftbl
		LD 	e,a
		LD 	d,0
		ADD	HL,DE
		ADD	HL,DE
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		LD	HL,(info)
		EX	DE,HL	
		JP	(HL)	

;----------------------------------------------------------------------

dos_ftbl:	DEFW	dos_reset
		DEFW	dos_conin
		DEFW	dos_conout
		DEFW	dos_rdrin
		DEFW	b_punch
		DEFW	b_list
		DEFW	dos_condir
		DEFW	dos_getiob
		DEFW	dos_setiob
		DEFW	dos_putstr
		DEFW	dos_conbfr
		DEFW	dos_const
		DEFW	dos_vers
		DEFW	dos_dskrst
		DEFW	dos_seldsk
		DEFW	dos_open
		DEFW	dos_close
		DEFW	dos_sfst
		DEFW	dos_snxt
		DEFW	dos_erase
		DEFW	dos_read
		DEFW	dos_write
		DEFW	dos_makef
		DEFW	dos_rename
		DEFW	dos_getlog
		DEFW	dos_getdsk
		DEFW	dos_setdma
		DEFW	dos_getalloc
		DEFW	dos_setro
		DEFW	dos_getro
		DEFW	dos_attrib
		DEFW	dos_getdpb
		DEFW	dos_user
		DEFW	dos_rndrd
		DEFW	dos_rndwr
		DEFW	dos_filesz
		DEFW	dos_setrec
		DEFW	dos_drvrst
		DEFW	func_ret
		DEFW	func_ret
		DEFW	dos_rndwrzf

;----------------------------------------------------------------------

err_badsec:
		LD	HL,bad_sec
		call	errflg
		CP	3
		JP	Z,wboot
		ret	

;----------------------------------------------------------------------

err_select:
		LD	HL,sel_errm
		JP	loc_6

err_ro:
		LD	HL,disk_ro
		JP	loc_6

err_filero:
		LD	HL,file_ro

loc_6:
		call	errflg
		JP	wboot

;----------------------------------------------------------------------

dos_errm:	DEFM	"Bdos Err On "
dsk_errm:	DEFM	" : $"
bad_sec:	DEFM	"Bad Sector$"
sel_errm:	DEFM	"Select$"
file_ro:	DEFM	"File "
disk_ro:	DEFM	"R/O$"

;----------------------------------------------------------------------

errflg:
		PUSH	HL
		call	dos_crlf	; dos cr/lf
		LD	A,(curdsk)
		ADD	A,'A'
		LD	(dsk_errm),A
		LD	BC,dos_errm
		call	dos_print
		POP	BC
		call	dos_print
d_conin:	LD	HL,kbchar
		LD 	a,(HL)
		LD 	(HL),0
		OR	a
		RET	NZ	
		JP	b_conin

;----------------------------------------------------------------------

conech:
		call	d_conin
		call	is_echoc
		RET	C	
		PUSH	AF
		LD 	c,a
		call	dos_conout
		POP	AF
		ret	

;----------------------------------------------------------------------

is_echoc:
		CP	0Dh		; cr
		RET	Z	
		CP	0Ah		; lf
		RET	Z	
		CP	9		; tab
		RET	Z	
		CP	8		; backspace
		RET	Z	
		CP	20h		; space
		ret	

;----------------------------------------------------------------------

conbrk:					; check for char ready
		LD	A,(kbchar)
		OR	a
		JP	NZ,conb1
		call	b_const
		AND	1
		RET	Z	
		call	b_conin
		CP	13h		; ctrl/s
		JP	NZ,conb0
		call	b_conin
		CP	3		; ctrl/c
		JP	Z,wboot
		XOR	a
		ret	

conb0:		LD	(kbchar),A
conb1:		LD 	a,1
		ret	

;----------------------------------------------------------------------

d_conout:
		LD	A,(compcol)
		OR	a
		JP	NZ,compout
		PUSH	BC
		call	conbrk		; check for char ready
		POP	BC
		PUSH	BC
		call	b_conout
		POP	BC
		PUSH	BC
		LD	A,(listcp)
		OR	a
		CALL	NZ,b_list
		POP	BC
compout:	LD 	a,c
		LD	HL,column
		CP	7Fh		; rubout
		RET	Z	
		INC	(HL)
		CP	' '
		RET	NC	
		DEC	(HL)
		LD 	a,(HL)
		OR	a
		RET	Z	
		LD 	a,c
		CP	8		; backspace
		JP	NZ,notbksp
		DEC	(HL)
		ret	

notbksp:	CP	0Ah		; lf
		RET	NZ	
		LD 	(HL),0
		ret	

;----------------------------------------------------------------------

ctlout:
		LD 	a,c
		call	is_echoc
		JP	NC,dos_conout
		PUSH	AF
		LD 	c,'^'
		call	d_conout
		POP	AF
		OR	40h
		LD 	c,a
dos_conout:
		LD 	a,c
		CP	9		; tab
		JP	NZ,d_conout
tab0:		LD 	c,' '
		call	d_conout
		LD	A,(column)
		AND	7
		JP	NZ,tab0
		ret	

;----------------------------------------------------------------------

backup:					; backup one screen position
		call	bckspc
		LD 	c,' '
		call	b_conout
bckspc:		LD 	c,8		; backspace
		JP	b_conout

;----------------------------------------------------------------------

crlfp:
		LD 	c,'#'
		call	d_conout
		call	dos_crlf	; dos cr/lf
crlfp0:		LD	A,(column)
		LD	HL,strtcol
		CP	(HL)
		RET	NC	
		LD 	c,' '
		call	d_conout
		JP	crlfp0

;----------------------------------------------------------------------

dos_crlf:
		LD 	c,0Dh		; cr
		call	d_conout
		LD 	c,0Ah		; lf
		JP	d_conout

;----------------------------------------------------------------------

dos_print:
		LD	A,(BC)
		CP	'$'
		RET	Z	
		INC	BC
		PUSH	BC
		LD 	c,a
		call	dos_conout
		POP	BC
		JP	dos_print

;----------------------------------------------------------------------

dos_conbfr:
		LD	A,(column)
		LD	(strtcol),A
		LD	HL,(info)
		LD 	c,(HL)
		INC	HL
		PUSH	HL
		LD 	b,0
readnx:		PUSH	BC
		PUSH	HL
readn0:		call	d_conin
		AND	7Fh
		POP	HL
		POP	BC
		CP	0Dh		; cr
		JP	Z,readen
		CP	0Ah		; lf
		JP	Z,readen
		CP	8		; backspace
		JP	NZ,noth
		LD 	a,b
		OR	a
		JP	Z,readnx
		DEC	b
		LD	A,(column)
		LD	(compcol),A
		JP	linelen

noth:		CP	7Fh		; rubout
		JP	NZ,notrub
		LD 	a,b
		OR	a
		JP	Z,readnx
		LD 	a,(HL)
		DEC	b
		DEC	HL
		JP	rdech1

notrub:		CP	5		; ctrl/e
		JP	NZ,notcte
		PUSH	BC
		PUSH	HL
		call	dos_crlf	; dos cr/lf
		XOR	a
		LD	(strtcol),A
		JP	readn0

notcte:		CP	10h		; ctrl/p
		JP	NZ,notctp
		PUSH	HL
		LD	HL,listcp
		LD 	a,1
		sub	(HL)
		LD 	(HL),a
		POP	HL
		JP	readnx

notctp:		CP	18h		; ctrl/x
		JP	NZ,notctx
		POP	HL
backx:		LD	A,(strtcol)
		LD	HL,column
		CP	(HL)
		JP	NC,dos_conbfr
		DEC	(HL)
		call	backup		; backup one screen position
		JP	backx

notctx:		CP	15h		; ctrl/u
		JP	NZ,notctu
		call	crlfp
		POP	HL		; discard starting position
		JP	dos_conbfr	; start all over

notctu:		CP	12h		; ctrl/r
		JP	NZ,notctr
linelen:	PUSH	BC
		call	crlfp
		POP	BC
		POP	HL
		PUSH	HL
		PUSH	BC
rep0:		LD 	a,b
		OR	a
		JP	Z,rep1
		INC	HL
		LD 	c,(HL)
		DEC	b
		PUSH	BC
		PUSH	HL
		call	ctlout
		POP	HL
		POP	BC
		JP	rep0

rep1:		PUSH	HL
		LD	A,(compcol)
		OR	a
		JP	Z,readn0
		LD	HL,column
		sub	(HL)
		LD	(compcol),A

backsp:		call	backup		; backup one screen position
		LD	HL,compcol
		DEC	(HL)
		JP	NZ,backsp
		JP	readn0

notctr:		INC	HL
		LD 	(HL),a
		INC	b
rdech1:		PUSH	BC
		PUSH	HL
		LD 	c,a
		call	ctlout
		POP	HL
		POP	BC
		LD 	a,(HL)
		CP	3		; ctrl/c
		LD 	a,b
		JP	NZ,notctc
		CP	1		; ctrl/c must be the first char
		JP	Z,wboot
notctc:		CP	c
		JP	C,readnx
readen:		POP	HL
		LD 	(HL),b
		LD 	c,0Dh
		JP	d_conout

;----------------------------------------------------------------------

dos_conin:
		call	conech
		JP	sta_ret

;----------------------------------------------------------------------

dos_rdrin:
		call	b_reader
		JP	sta_ret

;----------------------------------------------------------------------

dos_condir:
		LD 	a,c
		INC	a
		JP	Z,dirinp
		INC	a
		JP	Z,b_const
		JP	b_conout

;----------------------------------------------------------------------

dirinp:
		call	b_const
		OR	a
		JP	Z,retmon
		call	b_conin
		JP	sta_ret

;----------------------------------------------------------------------

dos_getiob:
		LD	A,(iobyte)
		JP	sta_ret

;----------------------------------------------------------------------

dos_setiob:
		LD	HL,iobyte
		LD 	(HL),c
		ret	

;----------------------------------------------------------------------

dos_putstr:
		EX	DE,HL	
		LD 	c,l
		LD 	b,h
		JP	dos_print

;----------------------------------------------------------------------

dos_const:				; check for char ready
		call	conbrk
sta_ret:
		LD	(lret),A
func_ret:
		ret	

;----------------------------------------------------------------------

setlret1:
		LD 	a,1
		JP	sta_ret

;----------------------------------------------------------------------

compcol:	DEFM	0		; true if computing column position
strtcol:	DEFM	0
column:		DEFM	0
listcp:		DEFM	0		; printer echo flag
kbchar:		DEFM	0
entsp:		DEFW	0

		DEFS	48
lstack  =  $ 

usrcode:	DEFM	0
curdsk:		DEFM	0
info:		DEFW	0
lret:		DEFW	0

;----------------------------------------------------------------------

sel_error:
		LD	HL,e_sel
goerr:
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		EX	DE,HL	
		JP	(HL)	

;----------------------------------------------------------------------

move:
		INC	c
move0:		DEC	c
		RET	Z	
		LD	A,(DE)
		LD 	(HL),a
		INC	DE
		INC	HL
		JP	move0

;----------------------------------------------------------------------

selectdisk:
		LD	A,(curdsk)
		LD 	c,a
		call	b_seldsk
		LD 	a,h
		OR	l
		RET	Z	
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		INC	HL
		LD	(cdrmaxa),HL
		INC	HL
		INC	HL
		LD	(curtrka),HL
		INC	HL
		INC	HL
		LD	(curreca),HL
		INC	HL
		INC	HL
		EX	DE,HL	
		LD	(tranv),HL
		LD	HL,buffa
		LD 	c,8		; addlist
		call	move
		LD	HL,(dpbaddr)
		EX	DE,HL	
		LD	HL,sectpt
		LD 	c,15		; dpblist
		call	move
		LD	HL,(maxall)
		LD 	a,h
		LD	HL,single
		LD 	(HL),0FFh
		OR	a
		JP	Z,retselect
		LD 	(HL),0

retselect:
		LD 	a,0FFh
		OR	a
		ret	

;----------------------------------------------------------------------

home:
		call	b_home
		XOR	a
		LD	HL,(curtrka)
		LD 	(HL),a
		INC	HL
		LD 	(HL),a
		LD	HL,(curreca)
		LD 	(HL),a
		INC	HL
		LD 	(HL),a
		ret	

;----------------------------------------------------------------------

rdbuff:
		call	b_read
		JP	diocomp

;----------------------------------------------------------------------

wrbuff:
		call	b_write
diocomp:
		OR	a
		RET	Z	
		LD	HL,err_tbl
		JP	goerr

;----------------------------------------------------------------------

seekdir:
		LD	HL,(dcnt)
		LD 	c,2		; dskshf
		call	hlrotr
		LD	(arecord),HL
		LD	(drec),HL
seek:		LD	HL,arecord
		LD 	c,(HL)
		INC	HL
		LD 	b,(HL)
		LD	HL,(curreca)
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		LD	HL,(curtrka)
		LD 	a,(HL)
		INC	HL
		LD 	h,(HL)
		LD 	l,a
seek0:		LD 	a,c
		sub	e
		LD 	a,b
		SBC	d
		JP	NC,seek1
		PUSH	HL
		LD	HL,(sectpt)
		LD 	a,e
		sub	l
		LD 	e,a
		LD 	a,d
		SBC	h
		LD 	d,a
		POP	HL
		DEC	HL
		JP	seek0

seek1:		PUSH	HL
		LD	HL,(sectpt)
		ADD	HL,DE
		JP	C,seek2
		LD 	a,c
		sub	l
		LD 	a,b
		SBC	h
		JP	C,seek2
		EX	DE,HL	
		POP	HL
		INC	HL
		JP	seek1

seek2:		POP	HL
		PUSH	BC
		PUSH	DE
		PUSH	HL
		EX	DE,HL	
		LD	HL,(offset)
		ADD	HL,DE
		LD 	b,h
		LD 	c,l
		call	b_settrk
		POP	DE
		LD	HL,(curtrka)
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		POP	DE
		LD	HL,(curreca)
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		POP	BC
		LD 	a,c
		sub	e
		LD 	c,a
		LD 	a,b
		SBC	d
		LD 	b,a
		LD	HL,(tranv)
		EX	DE,HL	
		call	b_sectran
		LD 	c,l
		LD 	b,h
		JP	b_setsec

;----------------------------------------------------------------------

dm_position:
		LD	HL,blkshf
		LD 	c,(HL)
		LD	A,(vrecord)
dmpos0:		OR	a
		RRA	
		DEC	c
		JP	NZ,dmpos0
		LD 	b,a
		LD 	a,8
		sub	(HL)
		LD 	c,a
		LD	A,(extval)
dmpos1:		DEC	c
		JP	Z,dmpos2
		OR	a
		RLA	
		JP	dmpos1

dmpos2:		ADD	A,b
		ret	

;----------------------------------------------------------------------

getdm:
		LD	HL,(info)
		LD	DE,10h		; dskmap
		ADD	HL,DE
		ADD	HL,BC
		LD	A,(single)
		OR	a
		JP	Z,getdmd
		LD 	l,(HL)
		LD 	h,0
		ret	

;----------------------------------------------------------------------

getdmd:
		ADD	HL,BC
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		EX	DE,HL	
		ret	

;----------------------------------------------------------------------

index:
		call	dm_position
		LD 	c,a
		LD 	b,0
		call	getdm
		LD	(arecord),HL
		ret	
;----------------------------------------------------------------------

allocated:
		LD	HL,(arecord)
		LD 	a,l
		OR	h
		ret	

;----------------------------------------------------------------------

atran:
		LD	A,(blkshf)
		LD	HL,(arecord)
atran0:		ADD	HL,HL
		DEC	a
		JP	NZ,atran0
		LD	(arecord1),HL
		LD	A,(blkmsk)
		LD 	c,a
		LD	A,(vrecord)
		AND	c
		OR	l
		LD 	l,a
		LD	(arecord),HL
		ret	

;----------------------------------------------------------------------

getexta:
		LD	HL,(info)
		LD	DE,0Ch		; extnum
		ADD	HL,DE
		ret	

;----------------------------------------------------------------------

getfcba:
		LD	HL,(info)
		LD	DE,0Fh		; reccnt
		ADD	HL,DE
		EX	DE,HL	
		LD	HL,11h		; nxtrec-reccnt
		ADD	HL,DE
		ret	

;----------------------------------------------------------------------

getfcb:
		call	getfcba
		LD 	a,(HL)
		LD	(vrecord),A
		EX	DE,HL	
		LD 	a,(HL)
		LD	(rcount),A
		call	getexta
		LD	A,(extmsk)
		AND	(HL)
		LD	(extval),A
		ret	

;----------------------------------------------------------------------

setfcb:
		call	getfcba
		LD	A,(seqio)
		CP	2		; check ranfill
		JP	NZ,setfcb1
		XOR	a
setfcb1:	LD 	c,a
		LD	A,(vrecord)
		ADD	A,c
		LD 	(HL),a
		EX	DE,HL	
		LD	A,(rcount)
		LD 	(HL),a
		ret	

;----------------------------------------------------------------------

hlrotr:
		INC	c		; in case zero
hlrotr0:	DEC	c
		RET	Z	
		LD 	a,h
		OR	a
		RRA	
		LD 	h,a
		LD 	a,l
		RRA	
		LD 	l,a
		JP	hlrotr0

;----------------------------------------------------------------------

compute_cs:
		LD 	c,80h		; recsiz
		LD	HL,(buffa)
		XOR	a
compcs0:	ADD	A,(HL)
		INC	HL
		DEC	c
		JP	NZ,compcs0
		ret	

;----------------------------------------------------------------------

hlrotl:
		INC	c		; in case zero
hlrotl0:	DEC	c
		RET	Z	
		ADD	HL,HL
		JP	hlrotl0

;----------------------------------------------------------------------

set_cdisk:
		PUSH	BC
		LD	A,(curdsk)
		LD 	c,a
		LD	HL,1
		call	hlrotl
		POP	BC
		LD 	a,c
		OR	l
		LD 	l,a
		LD 	a,b
		OR	h
		LD 	h,a
		ret	

;----------------------------------------------------------------------

nowrite:		; return true if dir checksum difference occurred
		LD	HL,(rodsk)
		LD	A,(curdsk)
		LD 	c,a
		call	hlrotr
		LD 	a,l
		AND	1
		ret	

;----------------------------------------------------------------------

dos_setro:
		LD	HL,rodsk
		LD 	c,(HL)
		INC	HL
		LD 	b,(HL)
		call	set_cdisk
		LD	(rodsk),HL
		LD	HL,(dirmax)
		INC	HL
		EX	DE,HL	
		LD	HL,(cdrmaxa)
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		ret	

;----------------------------------------------------------------------

check_rodir:
		call	getdptra
check_rofile:
		LD	DE,9		; rofile, offset to r/o bit
		ADD	HL,DE
		LD 	a,(HL)
		RLA	
		RET	NC	
		LD	HL,e_filero
		JP	goerr

;----------------------------------------------------------------------

check_write:
		call	nowrite
		RET	Z			; ok to write if not rodsk
		LD	HL,e_ro
		JP	goerr

;----------------------------------------------------------------------

getdptra:
		LD	HL,(buffa)
		LD	A,(dptr)
addh:		ADD	A,l
		LD 	l,a
		RET	NC	
		INC	h
		ret	

;----------------------------------------------------------------------

getmodnum:
		LD	HL,(info)
		LD	DE,0Eh		; modnum
		ADD	HL,DE
		LD 	a,(HL)
		ret	

;----------------------------------------------------------------------

clrmodnum:
		call	getmodnum
		LD 	(HL),0
		ret	

;----------------------------------------------------------------------

setfwf:
		call	getmodnum
		OR	80h		; fwfmsk (file write flag mask)
		LD 	(HL),a
		ret	

;----------------------------------------------------------------------

compcdr:
		LD	HL,(dcnt)
		EX	DE,HL	
		LD	HL,(cdrmaxa)
		LD 	a,e
		sub	(HL)
		INC	HL
		LD 	a,d
		SBC	(HL)
		ret	

;----------------------------------------------------------------------

setcdr:
		call	compcdr
		RET	C	
		INC	DE
		LD 	(HL),d
		DEC	HL
		LD 	(HL),e
		ret	

;----------------------------------------------------------------------

subdh:					; HL = DE - HL
		LD 	a,e
		sub	l
		LD 	l,a
		LD 	a,d
		SBC	h
		LD 	h,a
		ret	

;----------------------------------------------------------------------

newchecksum:
		LD 	c,0FFh		; true
checksum:	LD	HL,(drec)
		EX	DE,HL	
		LD	HL,(chksiz)
		call	subdh		; HL = DE - HL
		RET	NC	
		PUSH	BC
		call	compute_cs
		LD	HL,(checka)
		EX	DE,HL	
		LD	HL,(drec)
		ADD	HL,DE
		POP	BC
		INC	c
		JP	Z,initial_cs
		CP	(HL)
		RET	Z	
		call	compcdr
		RET	NC	
		call	dos_setro
		ret	

;----------------------------------------------------------------------

initial_cs:
		LD 	(HL),a
		ret	

;----------------------------------------------------------------------

wrdir:
		call	newchecksum
		call	setdir
		LD 	c,1		; indicates a write directory operation
		call	wrbuff
		JP	setdata

;----------------------------------------------------------------------

rd_dir:
		call	setdir
		call	rdbuff
setdata:
		LD	HL,dmaad
		JP	setdma

;----------------------------------------------------------------------

setdir:
		LD	HL,buffa
setdma:
		LD 	c,(HL)
		INC	HL
		LD 	b,(HL)
		JP	b_setdma

;----------------------------------------------------------------------

dir_to_user:
		LD	HL,(buffa)
		EX	DE,HL	
		LD	HL,(dmaad)
		LD 	c,80h		; recsiz
		JP	move

;----------------------------------------------------------------------

end_of_dir:
		LD	HL,dcnt
		LD 	a,(HL)
		INC	HL
		CP	(HL)
		RET	NZ	
		INC	a
		ret	

;----------------------------------------------------------------------

set_end_dir:
		LD	HL,0FFFFh
		LD	(dcnt),HL
		ret	

;----------------------------------------------------------------------

read_dir:
		LD	HL,(dirmax)
		EX	DE,HL	
		LD	HL,(dcnt)
		INC	HL
		LD	(dcnt),HL
		call	subdh		; HL = DE - HL
		JP	NC,read_dir0
		JP	set_end_dir

read_dir0:	LD	A,(dcnt)
		AND	3		; dskmsk
		LD 	b,5		; fcbshf
read_dir1:	ADD	A,a
		DEC	b
		JP	NZ,read_dir1
		LD	(dptr),A
		OR	a
		RET	NZ	
		PUSH	BC
		call	seekdir
		call	rd_dir
		POP	BC
		JP	checksum

;----------------------------------------------------------------------

getallocbit:
		LD 	a,c
		AND	111b
		INC	a
		LD 	e,a
		LD 	d,a
		LD 	a,c
		RRCA	
		RRCA	
		RRCA	
		AND	11111b
		LD 	c,a
		LD 	a,b
		ADD	A,a
		ADD	A,a
		ADD	A,a
		ADD	A,a
		ADD	A,a
		OR	c
		LD 	c,a
		LD 	a,b
		RRCA	
		RRCA	
		RRCA	
		AND	11111b
		LD 	b,a
		LD	HL,(alloca)
		ADD	HL,BC
		LD 	a,(HL)
rotl:		RLCA	
		DEC	e
		JP	NZ,rotl
		ret	

;----------------------------------------------------------------------

setallocbit:
		PUSH	DE
		call	getallocbit
		AND	11111110b
		POP	BC
		OR	c
rotr:		RRCA	
		DEC	d
		JP	NZ,rotr
		LD 	(HL),a
		ret	

;----------------------------------------------------------------------

scandm:
		call	getdptra
		LD	DE,10h		; dskmap
		ADD	HL,DE
		PUSH	BC
		LD 	c,11h		; fcblen-dskmap+1
scandm0:	POP	DE
		DEC	c
		RET	Z	
		PUSH	DE
		LD	A,(single)
		OR	a
		JP	Z,scandm1
		PUSH	BC
		PUSH	HL
		LD 	c,(HL)
		LD 	b,0
		JP	scandm2

scandm1:	DEC	c
		PUSH	BC
		LD 	c,(HL)
		INC	HL
		LD 	b,(HL)
		PUSH	HL
scandm2:	LD 	a,c
		OR	b
		JP	Z,scanm3
		LD	HL,(maxall)
		LD 	a,l
		sub	c
		LD 	a,h
		SBC	b
		CALL	NC,setallocbit
scanm3:		POP	HL
		INC	HL
		POP	BC
		JP	scandm0

;----------------------------------------------------------------------

initialize:
		LD	HL,(maxall)
		LD 	c,3		; maxall/8
		call	hlrotr
		INC	HL
		LD 	b,h
		LD 	c,l
		LD	HL,(alloca)
initial0:	LD 	(HL),0
		INC	HL
		DEC	BC
		LD 	a,b
		OR	c
		JP	NZ,initial0
		LD	HL,(dirblk)
		EX	DE,HL	
		LD	HL,(alloca)
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		call	home
		LD	HL,(cdrmaxa)
		LD 	(HL),3
		INC	HL
		LD 	(HL),0
		call	set_end_dir
initial2:	LD 	c,0FFh		; true
		call	read_dir
		call	end_of_dir
		RET	Z	
		call	getdptra
		LD 	a,0E5h		; empty
		CP	(HL)
		JP	Z,initial2	; go get another item
		LD	A,(usrcode)		; not empty, user code the same?
		CP	(HL)
		JP	NZ,pdollar
		INC	HL		; same user code, check for '$' submit
		LD 	a,(HL)
		SUB	'$'
		JP	NZ,pdollar
		DEC	a
		LD	(lret),A
pdollar:	LD 	c,1
		call	scandm
		call	setcdr
		JP	initial2

;----------------------------------------------------------------------

copy_dirloc:
		LD	A,(dirloc)
		JP	sta_ret

;----------------------------------------------------------------------

search:
		LD 	a,0FFh
		LD	(dirloc),A
		LD	HL,searchl
		LD 	(HL),c
		LD	HL,(info)
		LD	(searcha),HL
		call	set_end_dir
		call	home
searchn:	LD 	c,0		; false
		call	read_dir
		call	end_of_dir
		JP	Z,search_fin
		LD	HL,(searcha)
		EX	DE,HL	
		LD	A,(DE)
		CP	0E5h		; empty
		JP	Z,searchnext
		PUSH	DE
		call	compcdr
		POP	DE
		JP	NC,search_fin
searchnext:	call	getdptra
		LD	A,(searchl)
		LD 	c,a
		LD 	b,0
searchloop:	LD 	a,c
		OR	a
		JP	Z,endsearch
		LD	A,(DE)
		CP	'?'
		JP	Z,searchok
		LD 	a,b
		CP	13		; ubytes
		JP	Z,searchok
		CP	12		; extnum
		LD	A,(DE)
		JP	Z,searchext
		sub	(HL)
		AND	7Fh
		JP	NZ,searchn
		JP	searchok

searchext:	PUSH	BC
		LD	A,(extmsk)
		CPL	
		LD 	b,a
		AND	(HL)
		LD 	c,a
		LD	A,(DE)
		AND	b
		sub	c
		POP	BC
		JP	NZ,searchn
searchok:	INC	DE
		INC	HL
		INC	b
		DEC	c
		JP	searchloop

endsearch:	LD	A,(dcnt)
		AND	3
		LD	(lret),A
		LD	HL,dirloc
		LD 	a,(HL)
		RLA	
		RET	NC	
		XOR	a
		LD 	(HL),a
		ret	

search_fin:	call	set_end_dir
		LD 	a,0FFh
		JP	sta_ret

;----------------------------------------------------------------------

delete:
		call	check_write
		LD 	c,12		; extnum
		call	search
delete0:	call	end_of_dir
		RET	Z	
		call	check_rodir
		call	getdptra
		LD 	(HL),0E5h		; empty
		LD 	c,0
		call	scandm
		call	wrdir
		call	searchn
		JP	delete0

;----------------------------------------------------------------------

get_block:
		LD 	d,b
		LD 	e,c
lefttst:	LD 	a,c
		OR	b
		JP	Z,righttst
		DEC	BC
		PUSH	DE
		PUSH	BC
		call	getallocbit
		RRA	
		JP	NC,retblock
		POP	BC
		POP	DE
righttst:	LD	HL,(maxall)
		LD 	a,e
		sub	l
		LD 	a,d
		SBC	h
		JP	NC,retblock0
		INC	DE
		PUSH	BC
		PUSH	DE
		LD 	b,d
		LD 	c,e
		call	getallocbit
		RRA	
		JP	NC,retblock
		POP	DE
		POP	BC
		JP	lefttst

retblock:	RLA	
		INC	a
		call	rotr
		POP	HL
		POP	DE
		ret	

retblock0:	LD 	a,c
		OR	b
		JP	NZ,lefttst
		LD	HL,0
		ret	

;----------------------------------------------------------------------

copy_fcb:
		LD 	c,0
		LD 	e,20h		; fcblen
copy_dir:
		PUSH	DE
		LD 	b,0
		LD	HL,(info)
		ADD	HL,BC
		EX	DE,HL	
		call	getdptra
		POP	BC
		call	move
seek_copy:
		call	seekdir
		JP	wrdir

;----------------------------------------------------------------------

rename:
		call	check_write
		LD 	c,0Ch		; extnum
		call	search
		LD	HL,(info)
		LD 	a,(HL)
		LD	DE,10h		; dskmap
		ADD	HL,DE
		LD 	(HL),a
rename0:	call	end_of_dir
		RET	Z	
		call	check_rodir
		LD 	c,10h		; dskmap
		LD 	e,0Ch		; extnum
		call	copy_dir
		call	searchn
		JP	rename0

;----------------------------------------------------------------------

indicators:
		LD 	c,0Ch		; extnum
		call	search
indic0:		call	end_of_dir
		RET	Z	
		LD 	c,0
		LD 	e,0Ch		; extnum
		call	copy_dir
		call	searchn
		JP	indic0

;----------------------------------------------------------------------

open:
		LD 	c,0Fh		; namlen
		call	search
		call	end_of_dir
		RET	Z	
open_copy:
		call	getexta
		LD 	a,(HL)
		PUSH	AF
		PUSH	HL
		call	getdptra
		EX	DE,HL	
		LD	HL,(info)
		LD 	c,20h		; nxtrec
		PUSH	DE
		call	move
		call	setfwf
		POP	DE
		LD	HL,0Ch		; extnum
		ADD	HL,DE
		LD 	c,(HL)
		LD	HL,0Fh		; reccnt
		ADD	HL,DE
		LD 	b,(HL)
		POP	HL
		POP	AF
		LD 	(HL),a
		LD 	a,c
		CP	(HL)
		LD 	a,b
		JP	Z,open_rcnt
		LD 	a,0
		JP	C,open_rcnt
		LD 	a,128
open_rcnt:
		LD	HL,(info)
		LD	DE,0Fh		; reccnt
		ADD	HL,DE
		LD 	(HL),a
		ret	

;----------------------------------------------------------------------

mergezero:
		LD 	a,(HL)
		INC	HL
		OR	(HL)
		DEC	HL
		RET	NZ	
		LD	A,(DE)
		LD 	(HL),a
		INC	DE
		INC	HL
		LD	A,(DE)
		LD 	(HL),a
		DEC	DE
		DEC	HL
		ret	

;----------------------------------------------------------------------

close:
		XOR	a
		LD	(lret),A		; lret
		LD 	h,a
		LD 	l,a
		LD	(dcnt),HL
		call	nowrite
		RET	NZ	
		call	getmodnum
		AND	80h		; fwfmsk
		RET	NZ	
		LD 	c,0Fh		; namlen
		call	search		; locate file
		call	end_of_dir
		RET	Z	
		LD	BC,10h		; dskmap
		call	getdptra
		ADD	HL,BC
		EX	DE,HL	
		LD	HL,(info)
		ADD	HL,BC
		LD 	c,10h		; fcblen-dskmap
merge0:		LD	A,(single)
		OR	a
		JP	Z,merged
		LD 	a,(HL)
		OR	a
		LD	A,(DE)
		JP	NZ,fcbnzero
		LD 	(HL),a
fcbnzero:	OR	a
		JP	NZ,buffnzero
		LD 	a,(HL)
		LD	(DE),A
buffnzero:	CP	(HL)
		JP	NZ,mergerr
		JP	dmset

merged:		call	mergezero
		EX	DE,HL	
		call	mergezero
		EX	DE,HL	
		LD	A,(DE)
		CP	(HL)
		JP	NZ,mergerr
		INC	DE
		INC	HL
		LD	A,(DE)
		CP	(HL)
		JP	NZ,mergerr
		DEC	c
dmset:		INC	DE
		INC	HL
		DEC	c
		JP	NZ,merge0
		LD	BC,0FFECh	; -(fcblen-extnum)
		ADD	HL,BC
		EX	DE,HL	
		ADD	HL,BC
		LD	A,(DE)
		CP	(HL)
		JP	C,endmerge
		LD 	(HL),a
		INC	DE
		INC	HL
		LD	A,(DE)
		LD 	(HL),a
		LD	BC,2		; reccnt-ubytes
		ADD	HL,BC
		EX	DE,HL	
		ADD	HL,BC
		LD 	a,(HL)
		LD	(DE),A
endmerge:	LD 	a,0FFh		; true
		LD	(fcb_copied),A
		JP	seek_copy

mergerr:	LD	HL,lret
		DEC	(HL)
		ret	

;----------------------------------------------------------------------

make:
		call	check_write
		LD	HL,(info)
		PUSH	HL
		LD	HL,efcb
		LD	(info),HL
		LD 	c,1
		call	search
		call	end_of_dir
		POP	HL
		LD	(info),HL
		RET	Z	
		EX	DE,HL	
		LD	HL,0Fh		; namlen
		ADD	HL,DE
		LD 	c,11h		; fcblen-namlen
		XOR	a
make0:		LD 	(HL),a
		INC	HL
		DEC	c
		JP	NZ,make0
		LD	HL,0Dh		; ubytes
		ADD	HL,DE
		LD 	(HL),a
		call	setcdr
		call	copy_fcb
		JP	setfwf

;----------------------------------------------------------------------

open_reel:
		XOR	a
		LD	(fcb_copied),A
		call	close
		call	end_of_dir
		RET	Z	
		LD	HL,(info)
		LD	BC,0Ch		; extnum
		ADD	HL,BC
		LD 	a,(HL)
		INC	a
		AND	1Fh		; maxext
		LD 	(HL),a
		JP	Z,open_mod
		LD 	b,a
		LD	A,(extmsk)
		AND	b
		LD	HL,fcb_copied
		AND	(HL)
		JP	Z,open_reel0
		JP	open_reel1

open_mod:	LD	BC,2		; modnum-extnum
		ADD	HL,BC
		INC	(HL)
		LD 	a,(HL)
		AND	0Fh		; maxmod
		JP	Z,open_r_err
open_reel0:	LD 	c,0Fh		; namlen
		call	search
		call	end_of_dir
		JP	NZ,open_reel1
		LD	A,(rmf)
		INC	a
		JP	Z,open_r_err
		call	make
		call	end_of_dir
		JP	Z,open_r_err
		JP	open_reel2

open_reel1:	call	open_copy
open_reel2:	call	getfcb
		XOR	a
		JP	sta_ret

open_r_err:	call	setlret1
		JP	setfwf

;----------------------------------------------------------------------

seqdiskread:
		LD 	a,1
		LD	(seqio),A
diskread:
		LD 	a,0FFh		; true
		LD	(rmf),A
		call	getfcb
		LD	A,(vrecord)
		LD	HL,rcount
		CP	(HL)
		JP	C,recordok
		CP	128
		JP	NZ,diskeof
		call	open_reel
		XOR	a
		LD	(vrecord),A
		LD	A,(lret)
		OR	a
		JP	NZ,diskeof
recordok:	call	index
		call	allocated
		JP	Z,diskeof
		call	atran
		call	seek
		call	rdbuff
		JP	setfcb

;----------------------------------------------------------------------

diskeof:
		JP	setlret1

;----------------------------------------------------------------------

seqdiskwrite:
		LD 	a,1
		LD	(seqio),A

diskwrite:	LD 	a,0		; false
		LD	(rmf),A
		call	check_write
		LD	HL,(info)
		call	check_rofile
		call	getfcb
		LD	A,(vrecord)
		CP	128		; lstrec+1
		JP	NC,setlret1
		call	index
		call	allocated
		LD 	c,0
		JP	NZ,diskwr1
		call	dm_position
		LD	(dminx),A
		LD	BC,0
		OR	a
		JP	Z,nopblock
		LD 	c,a
		DEC	BC
		call	getdm
		LD 	b,h
		LD 	c,l
nopblock:	call	get_block
		LD 	a,l
		OR	h
		JP	NZ,blockok
		LD 	a,2
		JP	sta_ret

blockok:	LD	(arecord),HL
		EX	DE,HL	
		LD	HL,(info)
		LD	BC,10h		; dskmap
		ADD	HL,BC
		LD	A,(single)
		OR	a
		LD	A,(dminx)
		JP	Z,allocwd
		call	addh
		LD 	(HL),e
		JP	diskwru

allocwd:	LD 	c,a
		LD 	b,0
		ADD	HL,BC
		ADD	HL,BC
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
diskwru:	LD 	c,2
diskwr1:	LD	A,(lret)
		OR	a
		RET	NZ	
		PUSH	BC
		call	atran
		LD	A,(seqio)
		DEC	a
		DEC	a
		JP	NZ,diskwr11
		POP	BC
		PUSH	BC
		LD 	a,c
		DEC	a
		DEC	a
		JP	NZ,diskwr11
		PUSH	HL
		LD	HL,(buffa)
		LD 	d,a
fill0:		LD 	(HL),a
		INC	HL
		INC	d
		JP	P,fill0
		call	setdir
		LD	HL,(arecord1)
		LD 	c,2
fill1:		LD	(arecord),HL
		PUSH	BC
		call	seek
		POP	BC
		call	wrbuff
		LD	HL,(arecord)
		LD 	c,0
		LD	A,(blkmsk)
		LD 	b,a
		AND	l
		CP	b
		INC	HL
		JP	NZ,fill1
		POP	HL
		LD	(arecord),HL
		call	setdata
diskwr11:	call	seek
		POP	BC
		PUSH	BC
		call	wrbuff
		POP	BC
		LD	A,(vrecord)
		LD	HL,rcount
		CP	(HL)
		JP	C,diskwr2
		LD 	(HL),a
		INC	(HL)
		LD 	c,2
diskwr2:	DEC	c
		DEC	c
		JP	NZ,noupdate
		PUSH	AF
		call	getmodnum
		AND	7Fh		; not fwfmsk
		LD 	(HL),a
		POP	AF
noupdate:	CP	7Fh		; lstrec
		JP	NZ,diskwr3
		LD	A,(seqio)
		CP	1
		JP	NZ,diskwr3
		call	setfcb
		call	open_reel
		LD	HL,lret
		LD 	a,(HL)
		OR	a
		JP	NZ,nospace
		DEC	a
		LD	(vrecord),A
nospace:	LD 	(HL),0
diskwr3:	JP	setfcb

;----------------------------------------------------------------------

rseek:
		XOR	a
		LD	(seqio),A
rseek1:
		PUSH	BC
		LD	HL,(info)
		EX	DE,HL	
		LD	HL,21h		; ranrec
		ADD	HL,DE
		LD 	a,(HL)
		AND	7Fh
		PUSH	AF
		LD 	a,(HL)
		RLA	
		INC	HL
		LD 	a,(HL)
		RLA	
		AND	11111b
		LD 	c,a
		LD 	a,(HL)
		RRA	
		RRA	
		RRA	
		RRA	
		AND	1111b
		LD 	b,a
		POP	AF
		INC	HL
		LD 	l,(HL)
		INC	l
		DEC	l
		LD 	l,6		; produce error 6, seek past physical end
		JP	NZ,seekerr
		LD	HL,20h		; nxtrec
		ADD	HL,DE
		LD 	(HL),a
		LD	HL,0Ch		; extnum
		ADD	HL,DE
		LD 	a,c
		sub	(HL)
		JP	NZ,ranclose
		LD	HL,0Eh		; modnum
		ADD	HL,DE
		LD 	a,b
		sub	(HL)
		AND	7Fh
		JP	Z,seekok
ranclose:	PUSH	BC
		PUSH	DE
		call	close
		POP	DE
		POP	BC
		LD 	l,3		; cannot close error 3
		LD	A,(lret)
		INC	a
		JP	Z,badseek
		LD	HL,0Ch		; extnum
		ADD	HL,DE
		LD 	(HL),c
		LD	HL,0Eh		; modnum
		ADD	HL,DE
		LD 	(HL),b
		call	open
		LD	A,(lret)
		INC	a
		JP	NZ,seekok
		POP	BC
		PUSH	BC
		LD 	l,4		; seek to unwritten extent 4
		INC	c
		JP	Z,badseek
		call	make
		LD 	l,5		; cannot create new extent 5
		LD	A,(lret)
		INC	a
		JP	Z,badseek
seekok:		POP	BC
		XOR	a
		JP	sta_ret

badseek:	PUSH	HL
		call	getmodnum
		LD 	(HL),11000000b
		POP	HL
seekerr:	POP	BC
		LD 	a,l
		LD	(lret),A
		JP	setfwf

;----------------------------------------------------------------------

randiskread:
		LD 	c,0FFh		; true = read operation
		call	rseek
		CALL	Z,diskread
		ret	

;----------------------------------------------------------------------

randiskwrite:
		LD 	c,0		; false = write operation
		call	rseek
		CALL	Z,diskwrite
		ret	

;----------------------------------------------------------------------

compute_rr:
		EX	DE,HL	
		ADD	HL,DE
		LD 	c,(HL)
		LD 	b,0
		LD	HL,0Ch		; extnum
		ADD	HL,DE
		LD 	a,(HL)
		RRCA	
		AND	80h
		ADD	A,c
		LD 	c,a
		LD 	a,0
		ADC	A,b
		LD 	b,a
		LD 	a,(HL)
		RRCA	
		AND	0Fh
		ADD	A,b
		LD 	b,a
		LD	HL,0Eh		; modnum
		ADD	HL,DE
		LD 	a,(HL)
		ADD	A,a
		ADD	A,a
		ADD	A,a
		ADD	A,a
		PUSH	AF
		ADD	A,b
		LD 	b,a
		PUSH	AF
		POP	HL
		LD 	a,l
		POP	HL
		OR	l
		AND	1
		ret	

;----------------------------------------------------------------------

getfilesize:
		LD 	c,0Ch		; extnum
		call	search
		LD	HL,(info)
		LD	DE,21h		; ranrec
		ADD	HL,DE
		PUSH	HL
		LD 	(HL),d
		INC	HL
		LD 	(HL),d
		INC	HL
		LD 	(HL),d
getsize:	call	end_of_dir
		JP	Z,setsize
		call	getdptra
		LD	DE,0Fh		; reccnt
		call	compute_rr
		POP	HL
		PUSH	HL
		LD 	e,a
		LD 	a,c
		sub	(HL)
		INC	HL
		LD 	a,b
		SBC	(HL)
		INC	HL
		LD 	a,e
		SBC	(HL)
		JP	C,getnextsize
		LD 	(HL),e
		DEC	HL
		LD 	(HL),b
		DEC	HL
		LD 	(HL),c
getnextsize:	call	searchn
		JP	getsize

setsize:	POP	HL
		ret	

;----------------------------------------------------------------------

dos_setrec:
		LD	HL,(info)
		LD	DE,20h		; nxtrec
		call	compute_rr
		LD	HL,21h		; ranrec
		ADD	HL,DE
		LD 	(HL),c
		INC	HL
		LD 	(HL),b
		INC	HL
		LD 	(HL),a
		ret	

;----------------------------------------------------------------------

select:
		LD	HL,(dlog)
		LD	A,(curdsk)
		LD 	c,a
		call	hlrotr
		PUSH	HL
		EX	DE,HL	
		call	selectdisk
		POP	HL
		CALL	Z,sel_error
		LD 	a,l
		RRA	
		RET	C	
		LD	HL,(dlog)
		LD 	c,l
		LD 	b,h
		call	set_cdisk
		LD	(dlog),HL
		JP	initialize

;----------------------------------------------------------------------

dos_seldsk:
		LD	A,(linfo)
		LD	HL,curdsk
		CP	(HL)
		RET	Z	
		LD 	(HL),a
		JP	select

;----------------------------------------------------------------------

reselect:
		LD 	a,0FFh
		LD	(resel),A
		LD	HL,(info)
		LD 	a,(HL)
		AND	11111b
		DEC	a
		LD	(linfo),A
		CP	30
		JP	NC,noselect
		LD	A,(curdsk)
		LD	(olddsk),A
		LD 	a,(HL)
		LD	(fcbdsk),A
		AND	11100000b
		LD 	(HL),a
		call	dos_seldsk
noselect:	LD	A,(usrcode)
		LD	HL,(info)
		OR	(HL)
		LD 	(HL),a
		ret	

;----------------------------------------------------------------------

dos_vers:
		LD 	a,22h
		JP	sta_ret

;----------------------------------------------------------------------

dos_dskrst:
		LD	HL,0
		LD	(rodsk),HL
		LD	(dlog),HL
		XOR	a
		LD	(curdsk),A
		LD	HL,80h		; tbuff
		LD	(dmaad),HL
		call	setdata
		JP	select

;----------------------------------------------------------------------

dos_open:
		call	clrmodnum
		call	reselect
		JP	open

;----------------------------------------------------------------------

dos_close:
		call	reselect
		JP	close

;----------------------------------------------------------------------

dos_sfst:
		LD 	c,0
		EX	DE,HL	
		LD 	a,(HL)
		CP	'?'
		JP	Z,qselect
		call	getexta
		LD 	a,(HL)
		CP	'?'
		CALL	NZ,clrmodnum
		call	reselect
		LD 	c,0Fh		; namlen
qselect:	call	search
		JP	dir_to_user

;----------------------------------------------------------------------

dos_snxt:
		LD	HL,(searcha)
		LD	(info),HL
		call	reselect
		call	searchn
		JP	dir_to_user

;----------------------------------------------------------------------

dos_erase:
		call	reselect
		call	delete
		JP	copy_dirloc

;----------------------------------------------------------------------

dos_read:
		call	reselect
		JP	seqdiskread

;----------------------------------------------------------------------

dos_write:
		call	reselect
		JP	seqdiskwrite

;----------------------------------------------------------------------

dos_makef:
		call	clrmodnum
		call	reselect
		JP	make

;----------------------------------------------------------------------

dos_rename:
		call	reselect
		call	rename
		JP	copy_dirloc

;----------------------------------------------------------------------

dos_getlog:
		LD	HL,(dlog)
		JP	sthl_ret

;----------------------------------------------------------------------

dos_getdsk:
		LD	A,(curdsk)
		JP	sta_ret

;----------------------------------------------------------------------

dos_setdma:
		EX	DE,HL	
		LD	(dmaad),HL
		JP	setdata

;----------------------------------------------------------------------

dos_getalloc:
		LD	HL,(alloca)
		JP	sthl_ret

;----------------------------------------------------------------------

dos_getro:
		LD	HL,(rodsk)
		JP	sthl_ret

;----------------------------------------------------------------------

dos_attrib:
		call	reselect
		call	indicators
		JP	copy_dirloc

;----------------------------------------------------------------------

dos_getdpb:
		LD	HL,(dpbaddr)
sthl_ret:
		LD	(lret),HL
		ret	

;----------------------------------------------------------------------

dos_user:
		LD	A,(linfo)
		CP	0FFh
		JP	NZ,loc_7
		LD	A,(usrcode)
		JP	sta_ret

loc_7:		AND	1Fh
		LD	(usrcode),A
		ret

;----------------------------------------------------------------------

dos_rndrd:
		call	reselect
		JP	randiskread

;----------------------------------------------------------------------

dos_rndwr:
		call	reselect
		JP	randiskwrite

;----------------------------------------------------------------------

dos_filesz:
		call	reselect
		JP	getfilesize

;----------------------------------------------------------------------

dos_drvrst:
		LD	HL,(info)
		LD 	a,l
		CPL	
		LD 	e,a
		LD 	a,h
		CPL	
		LD	HL,(dlog)
		AND	h
		LD 	d,a
		LD 	a,l
		AND	e
		LD 	e,a
		LD	HL,(rodsk)
		EX	DE,HL	
		LD	(dlog),HL
		LD 	a,l
		AND	e
		LD 	l,a
		LD 	a,h
		AND	d
		LD 	h,a
		LD	(rodsk),HL
		ret	

;----------------------------------------------------------------------

goback:
		LD	A,(resel)
		OR	a
		JP	Z,retmon
		LD	HL,(info)
		LD 	(HL),0
		LD	A,(fcbdsk)
		OR	a
		JP	Z,retmon
		LD 	(HL),a
		LD	A,(olddsk)
		LD	(linfo),A
		call	dos_seldsk
retmon:		LD	HL,(entsp)
		LD	SP,HL	
		LD	HL,(lret)
		LD 	a,l
		LD 	b,h
		ret	

;----------------------------------------------------------------------

dos_rndwrzf:
		call	reselect
		LD 	a,2
		LD	(seqio),A
		LD 	c,0
		call	rseek1
		CALL	Z,diskwrite
		ret	

;----------------------------------------------------------------------

efcb:		DEFM	0E5h
rodsk:		DEFW	0		; read only disk vector
dlog:		DEFW	0		; logged-in disks
dmaad:		DEFW	80h		; initial dma address
cdrmaxa:	DEFW	0		; pointer to cur dir max value
curtrka:	DEFW	0		; current track address
curreca:	DEFW	0		; current record address
buffa:		DEFW	0		; pointer to directory dma address
dpbaddr:	DEFW	0		; current disk parameter block address
checka:		DEFW	0		; current checksum vector address
alloca:		DEFW	0		; current allocation vector address
sectpt:		DEFW	0		; sectors per track
blkshf:		DEFM	0		; block shift factor
blkmsk:		DEFM	0		; block mask
extmsk:		DEFM	0		; extent mask
maxall:		DEFW	0		; maximum allocation number
dirmax:		DEFW	0		; largest directory number
dirblk:		DEFW	0		; reserved allocation bits for directory
chksiz:		DEFW	0		; size of checksum vector
offset:		DEFW	0		; offset tracks at beginning
tranv:		DEFW	0		; address of translate vector
fcb_copied:	DEFM	0		; set true if copy_fcb called
rmf:		DEFM	0		; read mode flag for open_reel
dirloc:		DEFM	0		; directory flag in rename, etc.
seqio:		DEFM	0		; 1 if sequential i/o
linfo:		DEFM	0		; linfo = low(info)
dminx:		DEFM	0		; local for diskwrite
searchl:	DEFM	0		; search length
searcha:	DEFW	0		; search address
		DEFM	0
		DEFM	0  
single:		DEFM	0		; set true if single byte alloc map
resel:		DEFM	0		; reselection flag
olddsk:		DEFM	0		; disk on entry to bdos
fcbdsk:		DEFM	0		; disk named in fcb
rcount:		DEFM	0		; record count in current fcb
extval:		DEFM	0		; extent number and extmsk
vrecord:	DEFM	0		; current virtual record
		DEFM	0  
arecord:	DEFW	0		; current actual record
arecord1:	DEFW	0		; current actual block# * blkmsk
dptr:		DEFM	0		; directory pointer 0,1,2,3
dcnt:		DEFW	0		; directory counter 0,1,...,dirmax
drec:		DEFW	0		; directory record 0,1,...,dirmax/4

;		ds	58

;----------------------------------------------------------------------

		org	1000h

; The ISIS subsystem (1000H - 30FFH) starts here...
;
; The command line processor is based on CP/M CCP

isx_start:
		JP	isx_main

;----------------------------------------------------------------------
;
; Utility procedures

conin:
		LD 	c,1		; console input
		JP	bdos

;----------------------------------------------------------------------

printchar:
		LD 	e,a
		LD 	c,2		; console output
		JP	bdos

;----------------------------------------------------------------------

printbc:				; print char saving BC registers
		PUSH	BC
		call	printchar
		POP	BC
		ret	

;----------------------------------------------------------------------

put_spc:
		LD 	a,' '
		JP	printbc		; print char saving BC registers

;----------------------------------------------------------------------

crlf:
		LD 	a,0Dh
		call	printbc		; print char saving BC registers
		LD 	a,0Ah
		JP	printbc		; print char saving BC registers

;----------------------------------------------------------------------

ln_print:
		PUSH	BC
		call	crlf
		POP	DE
putstr:					; print string
		LD 	c,9
		JP	bdos

;----------------------------------------------------------------------

dsk_reset:
		LD 	c,0Dh		; reset disk
		call	bdos		; returns 0FFh if there is a file
					; whose name begins with '$' in A:
		PUSH	AF
		LD 	c,1Eh		; ??? set file attrib
		LD	DE,80h		; this is probably a bug,
					; I would expect 1A (set dma) here.
		call	bdos
		POP	AF
		ret	

;----------------------------------------------------------------------

seldsk:
		LD 	e,a
		LD 	c,0Eh		; select disk
		JP	bdos

;----------------------------------------------------------------------

openf:
		LD 	c,0Fh		; open file
		call	bdos
		LD	(i_dcnt),A		; bdos return code
		INC	a
		ret	

;----------------------------------------------------------------------

openc:					; open comfcb
		XOR	a
		LD	(comrec),A		; comfcb rc byte
		LD	DE,comfcb
		JP	openf

;----------------------------------------------------------------------

closef:
		LD 	c,10h		; close file
		call	bdos
		LD	(i_dcnt),A		; bdos return code
		INC	a
		ret	

;----------------------------------------------------------------------

srchfst:
		LD 	c,11h		; search for first
		call	bdos
		LD	(i_dcnt),A		; bdos return code
		INC	a
		ret	

;----------------------------------------------------------------------

srchnxt:
		LD 	c,12h		; search for next
		call	bdos
		LD	(i_dcnt),A		; bdos return code
		INC	a
		ret	

;----------------------------------------------------------------------

srchcom:
		LD	DE,comfcb
		JP	srchfst

;----------------------------------------------------------------------

erasef:
		LD 	c,13h		; delete file
		JP	bdos

;----------------------------------------------------------------------

readf:
		LD 	c,14h		; read
		call	bdos
		OR	a
		ret	

;----------------------------------------------------------------------

readc:					; read the comfcb file
		LD	DE,comfcb
		JP	readf

;----------------------------------------------------------------------

writef:
		LD 	c,15h		; write
		call	bdos
		OR	a
		ret	

;----------------------------------------------------------------------

makef:
		LD 	c,16h		; make file
		call	bdos
		LD	(i_dcnt),A		; bdos return code
		ret	

;----------------------------------------------------------------------

irename:
		LD 	c,17h		; rename file
		JP	bdos

;----------------------------------------------------------------------

rndrd:
		LD 	c,21h		; read random
		JP	bdos

;----------------------------------------------------------------------

fsize:
		LD 	c,23h		; compute file size
		JP	bdos

;----------------------------------------------------------------------

adec:
		PUSH	AF
		LD 	c,100
		call	sbcnt
		PUSH	BC
		call	print_digit
		POP	BC
		POP	AF
		sub	d
		PUSH	AF
		LD 	c,10
		call	sbcnt
		PUSH	BC
		call	print_digit
		POP	BC
		POP	AF
		sub	d
		call	print_digit
		ret	

;----------------------------------------------------------------------

sbcnt:
		LD 	b,0FFh
sbc1:		INC	b
		sub	c
		JP	NC,sbc1
		LD 	a,b
		ret	

;----------------------------------------------------------------------

print_digit:
		PUSH	BC
		ADD	A,'0'
		call	printchar
		POP	BC
		INC	b
		XOR	a
prd2:		DEC	b
		JP	Z,prd1
		ADD	A,c
		JP	prd2

prd1:		LD 	d,a
		ret	

;----------------------------------------------------------------------

hex_nibble:
		SUB	10
		JP	NC,hn1
		ADD	A,'9'+1
		JP	printchar
hn1:
		ADD	A,'A'
		JP	printchar

;----------------------------------------------------------------------

ahex:
		PUSH	AF
		RRCA	
		RRCA	
		RRCA	
		RRCA	
		AND	0Fh
		call	hex_nibble
		POP	AF
		AND	0Fh
		JP	hex_nibble

;----------------------------------------------------------------------

; Trace table, used by the tr_dump routine to figure out function
; names and arguments, etc.

tr_tbl:		DEFW	tr_open
		DEFW	tr_close
		DEFW	tr_delete
		DEFW	tr_read
		DEFW	tr_write
		DEFW	tr_seek
		DEFW	tr_load
		DEFW	tr_rename
		DEFW	tr_console
		DEFW	tr_exit
		DEFW	tr_attrib
		DEFW	tr_rescan
		DEFW	tr_error
		DEFW	tr_whocon
		DEFW	tr_spath

tr_open:	DEFW	fn_open
aOpen:		DEFM	"OPEN    "	; ISIS function name
		DEFM	5		; number of arguments
		DEFM	80h,3,2,2,80h	; type of arguments:
					;  01h - file number (file descriptor)
					;  02h - word value
					;  03h - pointer to ASCII string
					;  04h - word? buffer?
					;  80h - pointer to word or buffer
					; Hi-bit set means pointer (e.g.
					; 82h is pointer to word)
					; Note that 80h always ends the list

tr_close:	DEFW	fn_close
aClose:		DEFM	"CLOSE   "
		DEFM	2
		DEFM	1,80h

tr_delete:	DEFW	fn_delete
aDelete:	DEFM	"DELETE  "
		DEFM	2
		DEFM	3,80h

tr_read:	DEFW	fn_read
aRead:		DEFM	"READ    "
		DEFM	5
		DEFM	1,80h,2,80h,80h

tr_write:	DEFW	fn_write
aWrite:		DEFM	"WRITE   "
		DEFM	4
		DEFM	1,4,2,80h

tr_seek:	DEFW	fn_seek
aSeek:		DEFM	"SEEK    "
		DEFM	5
		DEFM	1,2,82h,82h,80h

tr_load:	DEFW	fn_load
aLoad:		DEFM	"LOAD    "
		DEFM	5
		DEFM	3,2,2,80h,80h

tr_rename:	DEFW	fn_rename
aRename:	DEFM	"RENAME  "
		DEFM	3
		DEFM	3,3,80h

tr_console:	DEFW	fn_console
aConsole:	DEFM	"CONSOLE "
		DEFM	3
		DEFM	3,3,80h

tr_exit:	DEFW	fn_exit
aExit:		DEFM	"EXIT    "
		DEFM	1
		DEFM	80h

tr_attrib:	DEFW	fn_attrib
aAttrib:	DEFM	"ATTRIB  "
		DEFM	4
		DEFM	3,2,2,80h

tr_rescan:	DEFW	fn_rescan
aRescan:	DEFM	"RESCAN  "
		DEFM	2
		DEFM	1,80h

tr_error:	DEFW	fn_error
aError:		DEFM	"ERROR   "
		DEFM	2
		DEFM	2,80h

tr_whocon:	DEFW	fn_whocon
aWhocon:	DEFM	"WHOCON  "
		DEFM	3
		DEFM	1,80h,80h

tr_spath:	DEFW	fn_spath
aSpath:		DEFM	"SPATH   "
		DEFM	3
		DEFM	3,80h,80h

;----------------------------------------------------------------------

hlhex:
		PUSH	HL
		LD 	a,h
		call	ahex
		POP	HL
		LD 	a,l
		JP	ahex

;----------------------------------------------------------------------

type_spc:
		LD 	a,' '
		JP	printchar

;----------------------------------------------------------------------

type_arrow:
		LD 	a,'-'
		call	printchar
		LD 	a,'>'
		JP	printchar

;----------------------------------------------------------------------

stype_a:
		PUSH	HL
		PUSH	BC
		call	printchar
		POP	BC
		POP	HL
		ret	

;----------------------------------------------------------------------

sahex:
		PUSH	HL
		call	ahex
		POP	HL
		ret	

;----------------------------------------------------------------------

type_spch:				; type space, saving HL
		PUSH	HL
		call	type_spc
		POP	HL
		ret	

;----------------------------------------------------------------------

dump_ascii:				; display ascii char, or '.' if
					; not printable
		CP	7Fh
		JP	NC,dmp_dot
		CP	' '
		JP	NC,dmp_ok
dmp_dot:	LD 	a,'.'
dmp_ok:		JP	stype_a

;----------------------------------------------------------------------

end_dmp:
		EX	DE,HL
		LD	HL,(dmp_to)
		LD 	a,l
		sub	e
		LD 	a,h
		SBC	d
		EX	DE,HL	
		ret	

;----------------------------------------------------------------------

dump_mem:				; dump memory contents from dmp_from
					; address to dmp_to
		LD	HL,(dmp_from)
		call	hlhex		; display start address
		LD 	a,'-'
		call	printchar
		LD	HL,(dmp_to)
		call	hlhex		; display end address
		call	crlf
		LD	HL,(dmp_from)
		XOR	a
		sub	l
		LD 	l,a
		LD 	a,0
		SBC	h
		LD 	h,a
		LD	(word_15),HL		; word_15 = -dmp_from
dmp_16:		call	crlf
		call	break_key
		RET	NZ	
		LD	HL,(dmp_from)
		LD	(word_17),HL
		PUSH	HL
		EX	DE,HL	
		LD	HL,(word_15)
		ADD	HL,DE
		call	hlhex		; display address as relative offset
		POP	HL
dmp_h:		call	type_spch
		LD 	a,(HL)
		call	sahex
		INC	HL
		call	end_dmp
		JP	C,dmp_a
		EX	DE,HL	
		LD	HL,(word_15)
		ADD	HL,DE
		EX	DE,HL	
		LD 	a,e
		AND	0Fh
		JP	NZ,dmp_h
dmp_a:		LD	(dmp_from),HL
		call	type_spc
		LD	HL,(word_17)
dmp_a1:		LD 	a,(HL)
		call	dump_ascii
		INC	HL
		EX	DE,HL	
		LD	HL,(dmp_from)
		EX	DE,HL	
		LD 	a,e
		sub	l
		JP	NZ,dmp_a1
		LD 	a,d
		SBC	h
		JP	NZ,dmp_a1
		LD	HL,(dmp_from)
		call	end_dmp
		RET	C	
		JP	dmp_16

;----------------------------------------------------------------------

outnamf:				; type D and get word @ HL+E
		PUSH	DE
		LD 	a,' '
		call	stype_a
		POP	DE
		LD 	a,d
		LD 	d,0
		PUSH	HL
		ADD	HL,DE
		LD 	e,(HL)		; DE = word from (HL+E)
		INC	HL
		LD 	d,(HL)
		POP	HL
		PUSH	DE
		call	stype_a
		POP	DE
		ret	

;----------------------------------------------------------------------

out_byte:
		call	outnamf		; type D and get word @ HL+E
		LD 	a,e
		call	sahex
		ret	

;----------------------------------------------------------------------

out_word:
		call	outnamf		; type D and get word @ HL+E
		EX	DE,HL	
		PUSH	DE
		call	hlhex
		POP	HL
		ret	

;----------------------------------------------------------------------

tr_dump:
		LD	HL,0
		LD	(dmp_from),HL
		call	crlf
		LD	A,(pgm_c)
		call	adec		; output C (function code)
		LD 	a,':'
		call	printchar
		call	type_spc
		LD	HL,pgm_c		; function code
		LD 	e,(HL)		;  into DE
		LD 	d,0
		LD	HL,tr_tbl	; offset into trace table
		ADD	HL,DE
		ADD	HL,DE
		LD 	e,(HL)		; fetch pointer
		INC	HL
		LD 	d,(HL)
		EX	DE,HL	
		LD 	e,(HL)		; get handling routine address
		INC	HL
		LD 	d,(HL)
		INC	HL
		PUSH	HL
		EX	DE,HL	
		call	hlhex		; output DOS routine address
		call	type_spc
		LD 	c,8
		POP	HL
tr_outname:	LD 	a,(HL)
		INC	HL
		PUSH	HL
		PUSH	BC
		call	printchar	; output function name
		POP	BC
		POP	HL
		DEC	c
		JP	NZ,tr_outname
		PUSH	HL
		call	type_spc
		LD	HL,(pgm_de)
		call	hlhex		; output DE (argument) value
		call	type_spc
		LD 	a,'('
		call	printchar
		LD	HL,(pgm_sp)
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		LD	HL,-3
		ADD	HL,DE
		call	hlhex		; output program PC (calling addr)
		LD 	a,')'
		call	printchar
		call	crlf
		POP	HL
		LD 	c,(HL)		; C - number of arguments
		INC	HL
		EX	DE,HL	
		LD 	b,0
		LD	HL,(pgm_de)
loc_21:		PUSH	BC
		PUSH	DE
		PUSH	HL
		PUSH	BC
		call	type_spc
		call	type_spc
		call	type_spc
		POP	AF		; A - previous value of B
		call	adec		; output argument number
		LD 	a,':'
		call	printchar
		POP	HL
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)		; DE - word pointed by pgm_de
		INC	HL
		PUSH	HL
		PUSH	DE
		EX	DE,HL	
		call	hlhex		; print argument value
		POP	DE
		POP	HL
		EX	(SP),HL	
		LD 	a,(HL)		; get argument type
		INC	HL
		PUSH	HL
		CP	2
		JP	Z,tr_02
		LD 	b,a
		AND	80h
		LD 	a,b
		JP	Z,tr_0x
		PUSH	AF
		PUSH	DE
		call	type_arrow	; type "->"
		POP	DE
		POP	AF
		AND	7Fh
		JP	NZ,loc_22
		LD	HL,byte_23
		LD 	c,(HL)
		INC	(HL)
		LD	HL,word_24
		LD 	b,0
		ADD	HL,BC
		ADD	HL,BC
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		JP	tr_02

loc_22:		CP	2
		JP	NZ,tr_0x
		EX	DE,HL	
		LD 	e,(HL)
		INC	HL
		LD 	h,(HL)
		LD 	l,e
		call	hlhex
		JP	tr_02

tr_0x:		CP	1
		JP	NZ,loc_25
		LD	HL,fd_tab
		LD 	d,0		; E - fileno
		ADD	HL,DE
		LD 	a,(HL)
		PUSH	AF
		call	type_spc
		POP	AF
		PUSH	AF
		call	ahex		; show fd flags byte
		call	type_spc
		POP	AF
		RLA			; 'in use' bit set?
		JP	NC,tr_02		; jump if not
		RRA	
		RRA	
		RRA	
		AND	1Fh
		LD	HL,f_dscrptrs
		LD	DE,28h		; 40 - file descriptor length
tr_fnddescr:	OR	a
		JP	Z,tr_found
		ADD	HL,DE
		DEC	a
		JP	tr_fnddescr

tr_found:	LD	(dmp_from),HL
		call	type_spch	; type space, saving HL
		LD 	a,(HL)
		OR	a
		JP	Z,tr_nodisk
		DEC	a
		ADD	A,'A'		; output disk name
		call	stype_a
		LD 	a,':'
		call	stype_a
tr_nodisk:	LD 	c,11		; filename length (8+3)
tr_typefname:	INC	HL
		LD 	a,c
		CP	3
		JP	NZ,tr_nofsep
		LD 	a,'.'		; type ext separator
		call	stype_a
tr_nofsep:	LD 	a,(HL)
		CP	' '
		CALL	NZ,stype_a
		DEC	c
		JP	NZ,tr_typefname
		LD	HL,(dmp_from)
		LD	DE,450Ch		; D = 'E', E = byte offset
		call	out_byte	; fcb ex
		LD	DE,550Dh		; 'U'
		call	out_byte	; fcb s1
		LD	DE,520Fh		; 'R'
		call	out_byte	; fcb rc
		LD	DE,4320h		; 'C'
		call	out_byte	; fcb cr
		LD	DE,4C21h		; 'L'
		call	out_byte	; fcb r0
		LD	DE,4023h		; '0'
		call	out_word
		LD	DE,4225h		; 'B'
		call	out_word	; number of records
		LD	DE,2C27h		; ','
		call	out_byte	; last record byte count
		JP	tr_02

loc_25:		CP	3
		JP	NZ,tr_02
		EX	DE,HL	
tr_03:		LD 	a,(HL)
		CP	21h
		JP	C,tr_02
		PUSH	HL
		call	printchar
		POP	HL
		INC	HL
		JP	tr_03

tr_02:		call	crlf
		POP	DE
		POP	HL
		POP	BC
		INC	b
		DEC	c
		JP	NZ,loc_21
		LD	A,(tr_level)
		AND	4
		JP	Z,locret_26
		LD	HL,(dmp_from)
		LD 	a,l
		OR	h
		JP	Z,locret_26
		LD	DE,23h
		ADD	HL,DE
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		LD	HL,7Fh
		ADD	HL,DE
		LD	(dmp_to),HL
		EX	DE,HL	
		LD	(dmp_from),HL
		call	dump_mem
		call	crlf
locret_26:	ret	

;----------------------------------------------------------------------

sub_27:
		LD	A,(byte_23)
		OR	a
		RET	Z	
		LD	HL,byte_23
		LD 	c,(HL)
		LD 	(HL),0
		LD	HL,word_24
loc_28:		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		INC	HL
		PUSH	BC
		PUSH	HL
		PUSH	DE
		call	type_spc
		call	type_spc
		call	type_spc
		POP	HL
		PUSH	HL
		call	hlhex
		LD 	a,'='
		call	printchar
		POP	HL
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		EX	DE,HL	
		call	hlhex
		POP	HL
		POP	BC
		DEC	c
		JP	NZ,loc_28
		call	crlf
		ret

;----------------------------------------------------------------------

get_trlvl:
		LD	BC,tr_lvl	; "trace level: "
		call	ln_print
		XOR	a
		LD	(tr_level),A
loc_29:		call	conin
		CP	'1'
		JP	NZ,loc_30
		LD	HL,tr_level
		LD 	a,(HL)
		ADD	A,a		; shift existing bits to the left
		INC	a		; and add a '1' bit to the right
		LD 	(HL),a
		JP	loc_29

loc_30:		CP	'#'
		JP	NZ,loc_31
		EX	(SP),HL	
		INC	HL
		EX	(SP),HL	
		rst	38h
		ret	

;----------------------------------------------------------------------

		ret	

;----------------------------------------------------------------------

loc_31:		CP	0Dh		; cr
		JP	NZ,get_trlvl	; get trace level
		call	crlf
		ret	

tr_lvl:		DEFM	"TRACE LEVEL: $"

;----------------------------------------------------------------------

setup_40h:
		LD	HL,vec_40
		LD	DE,save_40
		LD 	c,3
sav40:		LD 	a,(HL)
		LD	(DE),A
		INC	DE
		INC	HL
		DEC	c
		JP	NZ,sav40
		LD 	a,0C3h		; jmp
		LD	(vec_40),A		; 0040H
		LD	HL,idos_ept	; isis dos entry point
		LD	(vec_40+1),HL	; 0041H
		ret	

;----------------------------------------------------------------------

res_40h:
		LD	HL,vec_40	; 0040H
		LD	DE,save_40
		LD 	c,3
res40:		LD	A,(DE)
		LD 	(HL),a
		INC	DE
		INC	HL
		DEC	c
		JP	NZ,res40
		ret	

;----------------------------------------------------------------------

toupper:
		CP	'a'
		RET	C	
		CP	'{'
		RET	NC	
		AND	5Fh
		ret	

;----------------------------------------------------------------------

readcom:
		LD	A,(submit)		; submit file present?
		OR	a
		JP	Z,nosub		; no, read command from console
		LD	A,(cur_disk)
		OR	a
		LD 	a,0
		CALL	NZ,seldsk
		LD	A,(subrc)
		DEC	a
		LD	(subcr),A
		LD	DE,subfcb
		call	readf
		JP	NZ,nosub
		LD	DE,buflen
		LD	HL,cpm_bfr	; 0080H
		LD 	b,128
		call	copy
		LD	HL,subrc
		DEC	(HL)		; one less record
		LD	HL,submod
		LD 	(HL),0		; clear fwflag
		LD	DE,subfcb
		call	closef
		JP	Z,nosub
		LD	A,(cur_disk)
		OR	a
		CALL	NZ,seldsk
		LD 	c,9		; print string
		LD	DE,combuf
		call	bdos
		call	break_key
		JP	Z,noread
		call	del_sub		; remove $$$.SUB file
		JP	cli

nosub:		call	del_sub		; remove $$$.SUB file
		LD 	c,0Ah		; read console buffer
		LD	DE,rbuff
		call	bdos
noread:		LD	HL,buflen
		LD 	b,(HL)
readcom0:	INC	HL
		LD 	a,b
		OR	a
		JP	Z,readcom1
		LD 	a,(HL)
		call	toupper
		LD 	(HL),a
		DEC	b
		JP	readcom0

readcom1:	LD 	(HL),a
		LD	HL,combuf
		LD	(comaddr),HL
		ret	

;----------------------------------------------------------------------

break_key:
		LD 	c,0Bh		; get console status
		call	bdos
		OR	a
		RET	Z	
		call	conin
		OR	a
		ret	

;----------------------------------------------------------------------

getdsk:
		LD 	c,19h		; get current disk
		JP	bdos

;----------------------------------------------------------------------

loc_32:					; not used...
		LD	A,(DE)
		LD 	(HL),a
		INC	DE
		INC	HL
		DEC	c
		JP	NZ,loc_32
		ret	

;----------------------------------------------------------------------

isetdma:
		LD 	c,1Ah		; set dma
		JP	bdos

;----------------------------------------------------------------------

dma80:
		LD	DE,cpm_bfr	; 0080h
		call	isetdma
		ret	

;----------------------------------------------------------------------

del_sub:
		LD	HL,submit	; remove $$$.SUB file
		LD 	a,(HL)
		OR	a
		RET	Z	
		LD 	(HL),0
		XOR	a
		call	seldsk		; select disk A:
		LD	DE,subfcb
		call	erasef		; erase $$$.SUB file
		LD	A,(cur_disk)
		JP	seldsk

;----------------------------------------------------------------------

comerr:
		call	crlf
		LD	HL,(staddr)
cmd_e1:		LD 	a,(HL)
		CP	' '
		JP	Z,cmd_e2
		OR	a
		JP	Z,cmd_e2
		PUSH	HL
		call	printchar
		POP	HL
		INC	HL
		JP	cmd_e1

cmd_e2:		LD 	a,'?'
		call	printchar
		call	crlf
		call	del_sub		; delete $$$.SUB file
		JP	cli

;----------------------------------------------------------------------

loc_33:
		LD	A,(DE)
loc_34:		CP	'*'
		JP	Z,loc_35
		CP	'?'
		JP	Z,loc_35
		PUSH	AF
		SUB	'A'
		CP	1Ah
		JP	C,loc_36
		POP	AF
		PUSH	AF
		SUB	'0'
		CP	0Ah
		JP	C,loc_36
		POP	AF
		CP	a
		ret	

loc_36:		POP	AF
loc_35:		OR	a
		ret	

;----------------------------------------------------------------------

skip_spc:
		LD	A,(DE)
		OR	a
		RET	Z	
		CP	' '
		RET	NZ	
		INC	DE
		JP	skip_spc

;----------------------------------------------------------------------

add_hla:
		ADD	A,l
		LD 	l,a
		RET	NC	
		INC	h
		ret	

;----------------------------------------------------------------------

loc_37:
		PUSH	AF
		LD	HL,(comaddr)
		EX	DE,HL	
		call	skip_spc
		LD	HL,3
		ADD	HL,DE
		LD 	a,(HL)
		CP	':'		; device or disk specified?
		POP	BC
		JP	NZ,no_dev
		LD 	c,0
		LD	A,(DE)
		CP	':'		; first char is a isis disk/dev delimiter?
		JP	NZ,cpm_dev		; no -> probably is a CP/M device
		PUSH	DE
		INC	DE
		LD	A,(DE)
		CP	'F'		; isis disk name?
		INC	DE
		LD	A,(DE)
		POP	DE
		JP	NZ,isis_dev	; no -> probably a isis dev
		SUB	'0'
		CP	6		; :F0: ... :F5: ?
		JP	C,no_dev		; yes -> not a device.
isis_dev:	LD 	c,4
cpm_dev:	LD 	a,b
		DEC	a
		ADD	A,a
		ADD	A,c
		LD	HL,dev_tbl
		call	add_hla
		LD 	a,(HL)
		INC	HL
		LD 	h,(HL)
		LD 	l,a
		LD 	c,0
loc_39:		LD 	a,(HL)
		OR	a
		JP	Z,bad_dev
		LD 	b,3
		INC	c
loc_40:		LD	A,(DE)
		CP	(HL)
		JP	NZ,loc_41
		INC	DE
		INC	HL
		DEC	b
		JP	NZ,loc_40
		LD 	a,c		; valid device name found
		OR	a
		ret	

loc_41:		LD	A,(DE)
		CP	':'
		JP	Z,loc_42
		call	loc_34
		JP	Z,no_dev
loc_42:		INC	DE
		INC	HL
		DEC	b
		JP	NZ,loc_41
		DEC	DE
		DEC	DE
		DEC	DE
		JP	loc_39

bad_dev:	LD 	a,0FFh		; invalid ISIS or CP/M device name
		OR	a
		ret	

no_dev:		XOR	a
		ret	

;----------------------------------------------------------------------

dev_tbl:	DEFW	cpm_idev
		DEFW	cpm_odev
		DEFW	isx_idev
		DEFW	isx_odev

cpm_idev:	DEFM	"CONRDRTTYCRTUC1PTRUR1UR2EMP",0
cpm_odev:	DEFM	"CONLSTPUNTTYCRTUC1LPTUL1PTPUP1UP2EMP",0
isx_idev:	DEFM	":CI:RD:TI:VI:I1:HR:R1:R2:BB",0
isx_odev:	DEFM	":CO:LS:PN:TO:VO:O1:LP:L1:HP:P1:P2:BB",0

byte_43:	DEFM	17h, 0Ch, 0Ch,  8,  0Ah, 0Dh, 0Eh
		DEFM	0Fh, 16h, 18h, 14h, 10h,  7,   9
		DEFM	0Bh, 14h, 15h, 11h, 12h, 13h, 16h

;----------------------------------------------------------------------

fillfcb0:
		LD 	a,0
fillfcb:	LD	HL,comfcb
		call	add_hla
		PUSH	HL
		PUSH	HL
		XOR	a
		LD	(sdisk),A
		LD	HL,(comaddr)
		EX	DE,HL	
		call	skip_spc
		EX	DE,HL	
		LD	(staddr),HL
		EX	DE,HL	
		POP	HL
		LD	A,(DE)
		OR	a
		JP	Z,setcur0
		CP	':'		; check for isis disk specification :Fn:
		JP	NZ,loc_44
		INC	DE
		LD	A,(DE)
		CP	'F'
		JP	NZ,setcur
		INC	DE
		LD	A,(DE)
		SUB	'0'
		CP	6
		JP	NC,loc_45
		INC	a
		LD 	b,a		; save possible disk code in B
		INC	DE
		LD	A,(DE)
		CP	':'
		JP	Z,setdsk
		DEC	DE
loc_45:		DEC	DE
		JP	setcur

loc_44:		SBC	'A'-1		; check for CP/M disk specification d:
		LD 	b,a		; save possible disk code in B
		INC	DE
		LD	A,(DE)
		CP	':'
		JP	Z,setdsk
setcur:		DEC	DE
setcur0:	LD	A,(cur_disk)
		LD 	(HL),a
		JP	setname

setdsk:		LD 	a,b		; disk code
		LD	(sdisk),A
		LD 	(HL),b		; save it in fcb too
		INC	DE
setname:	LD 	b,8
setnam0:	call	loc_33		; is a legal filespec character?
		JP	Z,padname
		INC	HL
		CP	'*'		; '*' ?
		JP	NZ,setnam1
		LD 	(HL),'?'		; yes, fill the remaining with '?'
		JP	setnam2

setnam1:	LD 	(HL),a
		INC	DE
setnam2:	DEC	b
		JP	NZ,setnam0
trname:		call	loc_33
		JP	Z,settype
		INC	DE
		JP	trname

padname:	INC	HL
		LD 	(HL),' '
		DEC	b
		JP	NZ,padname
settype:	LD 	b,3
		CP	'.'
		JP	NZ,padtype
		INC	DE
settyp0:	call	loc_33
		JP	Z,padtype
		INC	HL
		CP	'*'
		JP	NZ,settyp1
		LD 	(HL),'?'
		JP	settyp2

settyp1:	LD 	(HL),a
		INC	DE
settyp2:	DEC	b
		JP	NZ,settyp0
trtype:		call	loc_33
		JP	Z,efill
		INC	DE
		JP	trtype

padtype:	INC	HL
		LD 	(HL),' '
		DEC	b
		JP	NZ,padtype
efill:		LD 	b,3
efill0:		INC	HL
		LD 	(HL),0
		DEC	b
		JP	NZ,efill0
		EX	DE,HL	
		LD	(comaddr),HL
		POP	HL
		LD	BC,11
scnq:		INC	HL
		LD 	a,(HL)
		CP	'?'
		JP	NZ,scnq0
		INC	b
scnq0:		DEC	c
		JP	NZ,scnq
		LD 	a,b
		OR	a
		ret	

;----------------------------------------------------------------------

intcmd_tbl:	DEFM	"DBUG"
		DEFM	"DIR "
		DEFM	"ERA "
		DEFM	"TYPE"
		DEFM	"REN "

;----------------------------------------------------------------------

intrinsic:
		LD	HL,intcmd_tbl	; search for a cli internal command
		LD 	c,0
intrin0:	LD 	a,c
		CP	5
		RET	NC	
		LD	DE,comfcb+1	; cmd fcb file name
		LD 	b,4
intrin1:	LD	A,(DE)
		CP	(HL)		; match?
		JP	NZ,intrin2
		INC	DE
		INC	HL
		DEC	b
		JP	NZ,intrin1
		LD	A,(DE)
		CP	' '
		JP	NZ,intrin3
		LD 	a,c		; return command code in C
		ret	

intrin2:	INC	HL
		DEC	b
		JP	NZ,intrin2
intrin3:	INC	c
		JP	intrin0

;----------------------------------------------------------------------

loc_46:
		OR	a
		JP	NZ,loc_47
		LD	DE,subfcb	; $$$.SUB fcb
		call	openf
		JP	Z,loc_47
		LD 	a,0FFh
		JP	loc_48

loc_47:		XOR	a
loc_48:		LD	(submit),A
		ret	

;----------------------------------------------------------------------

cmp_hlde:				; CY if HL > DE
		LD 	a,e
		sub	l
		LD 	a,d
		SBC	h
		ret	

;----------------------------------------------------------------------

ld_getbyte:
		LD	HL,bptr
		INC	(HL)
		JP	NZ,loc_49
		LD 	(HL),80h
		PUSH	BC
		PUSH	DE
		PUSH	HL
		LD	DE,comfcb
		call	readf
		JP	NZ,ld_exit
		POP	HL
		POP	DE
		POP	BC
loc_49:		LD	HL,(bptr)
		LD 	a,c
		ADD	A,(HL)
		LD 	c,a		; C - checksum?
		DEC	DE
		LD 	a,d
		OR	e
		LD 	a,(HL)
		ret	

;----------------------------------------------------------------------

ld_getword:
		call	ld_getbyte
		JP	Z,ld_exit
		PUSH	AF
		call	ld_getbyte
		JP	Z,ld_exit
		LD 	h,a
		POP	AF
		LD 	l,a
		ret	

;----------------------------------------------------------------------

load:
		call	dma80		; set dma to default 0080H
		LD	HL,0FFh
		LD	(bptr),HL
		LD	HL,0
		LD	(word_50),HL
		LD	(word_4),HL
		LD	(word_5),HL
		ADD	HL,sp
		LD	(save_sp),HL
loc_51:		LD 	c,0
		call	ld_getbyte
		PUSH	AF
		call	ld_getword
		EX	DE,HL	
		POP	AF
		CP	2
		JP	Z,loc_52
		CP	4
		JP	NZ,loc_53
		call	ld_getbyte
		CP	1
		JP	NZ,loc_52
		call	ld_getbyte
		call	ld_getword
		LD	(word_4),HL
		JP	loc_52

loc_53:		CP	18h
		JP	Z,loc_52
		CP	16h
		JP	Z,loc_52
		CP	6
		JP	NZ,loc_54
		call	ld_getbyte
		OR	a
		JP	NZ,ld_exit
		call	ld_getword
		PUSH	DE
		EX	DE,HL	
		LD	HL,(word_55)
		ADD	HL,DE
		POP	DE
		PUSH	DE
		PUSH	HL
		ADD	HL,DE
		EX	DE,HL	
		LD	HL,(bdos+1)		; mem top
		call	cmp_hlde	; CY if HL > DE
		JP	NC,ld_exit
		LD	HL,(word_5)
		call	cmp_hlde	; CY if HL > DE
		JP	C,loc_56
		EX	DE,HL	
		LD	(word_5),HL
		EX	DE,HL	
loc_56:		LD	HL,loc_57	; 3100h
		POP	DE
		PUSH	DE
		call	cmp_hlde	; CY if HL > DE
		JP	C,ld_exit
		LD	HL,(word_50)
		LD 	a,h
		OR	l
		JP	Z,loc_58
		call	cmp_hlde	; CY if HL > DE
		JP	NC,loc_59
loc_58:		EX	DE,HL	
		LD	(word_50),HL
loc_59:		POP	HL
		POP	DE
loc_60:		PUSH	HL
		call	ld_getbyte
		POP	HL
		JP	Z,loc_61
		LD 	(HL),a
		INC	HL
		JP	loc_60

loc_54:		CP	12h
		JP	Z,loc_52
		CP	8
		JP	Z,loc_52
		CP	0Eh
		JP	NZ,loc_52
		LD	HL,(word_50)
		LD 	a,h
		OR	l
		JP	Z,ld_exit
		ret	

loc_52:		call	ld_getbyte
		JP	NZ,loc_52
loc_61:		LD 	a,c
		OR	a
		JP	Z,loc_51
ld_exit:	LD	HL,(save_sp)
		LD	SP,HL	
		XOR	a
		ret	

;----------------------------------------------------------------------

isx_main:
		XOR	a
		LD	(byte_62),A
		LD 	a,0FFh
		LD	(unk_1),A
		LD	HL,(wboot+1)
		LD	DE,loc_2	; 0103H
		DEC	HL
		LD 	(HL),d
		DEC	HL
		LD 	(HL),e
		DEC	HL
		LD	(bdos+1),HL
		LD	HL,0
		LD	(word_3),HL
		LD	sp,stack
		call	getdsk
		LD 	c,a
		PUSH	BC
		PUSH	BC
		LD	BC,logmsg
		call	ln_print
		call	dsk_reset	; 0FFh in accum if $ file present
		POP	BC
		PUSH	AF
		LD 	a,c
		call	seldsk
		POP	AF
		POP	BC
		INC	a
		OR	c
		call	loc_46		; open $$$.SUB file, if exists
cli:		LD	sp,stack
		call	crlf
		call	getdsk
		LD	(cur_disk),A
		ADD	A,'0'
		call	printchar
		LD 	a,'>'		; prompt
		call	printchar
		LD	DE,cpm_bfr	; 0080H
		call	isetdma
		call	readcom
		call	fillfcb0
		CALL	NZ,comerr
		LD	A,(sdisk)		; disk explicitely specified?
		OR	a
		JP	NZ,cmd_run		; yes, take the file name as a command to load
		call	intrinsic	; search for a cli internal command
		LD	HL,jmp_tbl
		LD 	e,a
		LD 	d,0
		ADD	HL,DE
		ADD	HL,DE
		LD 	a,(HL)
		INC	HL
		LD 	h,(HL)
		LD 	l,a
		JP	(HL)			; execute the command

;----------------------------------------------------------------------

jmp_tbl:	DEFW	cmd_dbug
		DEFW	cmd_dir
		DEFW	cmd_era
		DEFW	cmd_type
		DEFW	cmd_ren
		DEFW	cmd_run

logmsg:		DEFM	0Dh,0Ah,"ISIS-II INTERFACE VERS 1.4",0Dh,0Ah,'$'

;----------------------------------------------------------------------

err_read:
		LD	BC,rd_err
		JP	ln_print

rd_err:		DEFM	"READ ERROR$"

;----------------------------------------------------------------------

err_nofile:
		LD	BC,no_file
		JP	ln_print

no_file:	DEFM	"NOT FOUND$"


;----------------------------------------------------------------------

		LD 	b,3
copy:		LD 	a,(HL)
		LD	(DE),A
		INC	HL
		INC	DE
		DEC	b
		JP	NZ,copy
		ret	

;----------------------------------------------------------------------

cfetch:
		LD	HL,cpm_bfr	; 0080h
		ADD	A,c
		call	add_hla
		LD 	a,(HL)
		ret	

;----------------------------------------------------------------------

set_disk:
		XOR	a
		LD	(comfcb),A
		LD	A,(sdisk)
		OR	a
		RET	Z	
		DEC	a
		LD	HL,cur_disk
		CP	(HL)
		RET	Z	
		JP	seldsk

;----------------------------------------------------------------------

reset_disk:
		LD	A,(sdisk)		; restore disk
		OR	a
		RET	Z	
		DEC	a
		LD	HL,cur_disk
		CP	(HL)
		RET	Z	
		LD	A,(cur_disk)
		JP	seldsk

;----------------------------------------------------------------------

cmd_dbug:
		call	get_trlvl	; get trace level
		LD	A,(tr_level)
		LD	(byte_62),A
		JP	cmd_exit

;----------------------------------------------------------------------

cmd_dir:
		call	fillfcb0
		call	set_disk
		LD	HL,comfcb+1
		LD 	a,(HL)
		CP	' '
		JP	NZ,cmd_d2
		LD 	b,11
cmd_d1:		LD 	(HL),'?'
		INC	HL
		DEC	b
		JP	NZ,cmd_d1
cmd_d2:		LD 	e,0
		PUSH	DE
		call	srchcom
		CALL	Z,err_nofile
dir_loop:	JP	Z,cmd_dex
		LD	A,(i_dcnt)		; bdos return code
		RRCA	
		RRCA	
		RRCA	
		AND	1100000b
		LD 	c,a
		LD 	a,0Ah		; sysfile
		call	cfetch		; get byte pointed by C from cpm_bfr
		RLA	
		JP	C,cmd_d3		; skip if system file
		POP	DE
		LD 	a,e
		INC	e
		PUSH	DE
		AND	3
		PUSH	AF
		JP	NZ,cmd_d4
		call	crlf
		PUSH	BC
		LD 	a,'F'
		call	printchar
		call	getdsk
		CP	10
		JP	C,cmd_d10
		PUSH	AF
		LD 	a,'1'
		call	printchar
		POP	AF
		SUB	10
cmd_d10:	ADD	A,'0'
		call	printchar
		LD 	a,':'
		call	printchar
		POP	BC
		JP	cmd_d5

cmd_d4:		call	put_spc
		LD 	a,':'
		call	printbc		; print char saving BC registers
cmd_d5:		call	put_spc
		LD 	b,1
cmd_d6:		LD 	a,b
		call	cfetch		; get byte pointed by C from cpm_bfr
		AND	7Fh
		CP	' '
		JP	NZ,cmd_d7
		POP	AF
		PUSH	AF
		CP	3
		JP	NZ,cmd_d9
		LD 	a,9
		call	cfetch		; get byte pointed by C from cpm_bfr
		AND	7Fh
		CP	' '
		JP	Z,cmd_d8
cmd_d9:		LD 	a,' '
cmd_d7:		call	printbc
		INC	b
		LD 	a,b
		CP	12
		JP	NC,cmd_d8
		CP	9
		JP	NZ,cmd_d6
		call	put_spc
		JP	cmd_d6

cmd_d8:		POP	AF
cmd_d3:		call	break_key
		JP	NZ,cmd_dex
		call	srchnxt
		JP	dir_loop

cmd_dex:	POP	DE
		JP	cmd_exit

;----------------------------------------------------------------------

cmd_era:
		call	fillfcb0
		CP	11
		JP	NZ,cmd_rm1
		LD	BC,msg_all	; "all files?"
		call	ln_print
		call	readcom
		LD	HL,buflen
		DEC	(HL)
		JP	NZ,cli
		INC	HL
		LD 	a,(HL)
		CP	'Y'
		JP	NZ,cli
		INC	HL
		LD	(comaddr),HL
		LD	HL,comfcb
		LD 	(HL),'?'
cmd_rm1:	call	set_disk
		LD	DE,comfcb
		call	erasef
		INC	a
		CALL	Z,err_nofile
		JP	cmd_exit

msg_all:	DEFM	"ALL FILES (Y/N)?$"

;----------------------------------------------------------------------

cmd_type:
		call	fillfcb0
		JP	NZ,comerr
		call	set_disk
		call	openc		; open the file
		JP	Z,typerr
		call	crlf
		LD	HL,bptr
		LD 	(HL),0FFh
type_loop:	LD	HL,bptr
		LD 	a,(HL)
		CP	128		; end buffer?
		JP	C,cmd_t3
		PUSH	HL
		call	readc		; read the comfcb file
		POP	HL
		JP	NZ,typeof
		XOR	a
		LD 	(HL),a
cmd_t3:		INC	(HL)
		LD	HL,cpm_bfr	; 0080H
		call	add_hla
		LD 	a,(HL)
		CP	1Ah		; end of text file?
		JP	Z,cmd_exit
		call	printchar
		call	break_key
		JP	NZ,cmd_exit
		JP	type_loop

;----------------------------------------------------------------------

typeof:
		DEC	a
		JP	Z,cmd_exit
		call	err_read
typerr:		call	reset_disk
		JP	comerr

;----------------------------------------------------------------------

cmd_ren:
		call	fillfcb0
		JP	NZ,comerr		; must be unambiguous
		LD	A,(sdisk)
		PUSH	AF
		call	set_disk
		call	srchcom
		JP	NZ,err_exists
		LD	HL,comfcb
		LD	DE,comfcb+10h	; fcb 1 + 16
		LD 	b,16
		call	copy
		LD	HL,(comaddr)
		EX	DE,HL	
		call	skip_spc
		CP	'='
		JP	Z,cmd_r1
		CP	'_'
		JP	NZ,cmd_r2
cmd_r1:		EX	DE,HL	
		INC	HL
		LD	(comaddr),HL
		call	fillfcb0
		JP	NZ,cmd_r2
		POP	AF
		LD 	b,a
		LD	HL,sdisk
		LD 	a,(HL)
		OR	a
		JP	Z,cmd_r3
		CP	b
		LD 	(HL),b
		JP	NZ,cmd_r2
cmd_r3:		LD 	(HL),b
		XOR	a
		LD	(comfcb),A
		call	srchcom
		JP	Z,cmd_r4
		LD	DE,comfcb
		call	irename
		JP	cmd_exit

cmd_r4:		call	err_nofile
		JP	cmd_exit

cmd_r2:		call	reset_disk
		JP	comerr

err_exists:
		LD	BC,f_exists
		call	ln_print
		JP	cmd_exit

f_exists:	DEFM	"FILE EXISTS$"

;----------------------------------------------------------------------

cmd_run:
		LD	A,(comfcb+1)
		CP	' '
		JP	NZ,cmd_x1
		LD	A,(sdisk)
		OR	a
		JP	Z,cmd_exit1
		DEC	a
		LD	(cur_disk),A
		LD	(cpm_disk),A
		call	seldsk
		JP	cmd_exit1

cmd_x1:		call	set_disk
		call	openc		; open the file
		JP	Z,cmd_x2
		LD	HL,0
		LD	(word_55),HL
		call	load
		JP	Z,cmd_x2
		LD	HL,(word_4)
		LD 	a,h
		OR	l
		JP	NZ,cmd_x3
		LD	HL,(word_50)
		LD	(word_4),HL
cmd_x3:		call	reset_disk
		call	fillfcb0
		LD	HL,sdisk
		PUSH	HL
		LD 	a,(HL)
		LD	(comfcb),A
		LD 	a,16
		call	fillfcb
		POP	HL
		LD 	a,(HL)
		LD	(comfcb+10h),A
		XOR	a
		LD	(comrec),A		; comfcb rc byte
		LD	DE,cpm_fcb	; 005CH
		LD	HL,comfcb
		LD 	b,33
		call	copy
		LD	HL,combuf
cmd_x4:		LD 	a,(HL)
		OR	a
		JP	Z,cmd_x5
		CP	' '
		JP	Z,cmd_x5
		INC	HL
		JP	cmd_x4

cmd_x5:		LD 	b,0
		LD	DE,cpm_bfr+1
cmd_x6:		LD 	a,(HL)
		LD	(DE),A
		OR	a
		JP	Z,cmd_x7
		INC	b
		INC	HL
		INC	DE
		JP	cmd_x6

cmd_x7:		LD 	a,b
		LD	(cpm_bfr),A
		call	crlf
		LD	A,(cur_disk)
		LD	(cpm_disk),A
		LD	DE,cpm_bfr	; 0080H
		call	isetdma
		call	loc_63
		LD	HL,pgm_return	; return address
		PUSH	HL
		call	setup_40h
		LD	HL,(word_3)
		LD 	a,h
		OR	l
		JP	Z,cmd_x8
		JP	(HL)	

cmd_x8:		LD	HL,(word_4)
		JP	(HL)	

;----------------------------------------------------------------------

pgm_return:
		LD	sp,stack
		call	res_40h
		LD	A,(cur_disk)
		call	seldsk
		JP	cli

;----------------------------------------------------------------------

cmd_x2:
		call	reset_disk
		JP	comerr

;----------------------------------------------------------------------

		LD	BC,ld_err
		call	ln_print
		JP	cmd_exit

ld_err:		DEFM	"LOAD ERROR$"

;----------------------------------------------------------------------

cmd_exit:
		call	reset_disk
cmd_exit1:
		call	fillfcb0
		LD	A,(comfcb+1)
		SUB	20h
		LD	HL,sdisk
		OR	(HL)
		JP	NZ,comerr
		JP	cli

;----------------------------------------------------------------------

loc_64:
		LD	HL,(fd_ptr)
		LD	DE,21h
		ADD	HL,DE
		LD 	c,(HL)
		INC	HL
		LD 	b,(HL)
		INC	HL
		LD 	e,(HL)		; DE = fd bfr addr
		INC	HL
		LD 	d,(HL)
		LD	HL,(word_65)
		EX	DE,HL	
		ret	

;----------------------------------------------------------------------

loc_66:
		LD	HL,(word_65)
		LD 	a,l
		sub	e
		LD 	l,a
		LD 	a,h
		SBC	d
		LD 	h,a		; HL = HL - DE
		LD	(word_67),HL
		LD	HL,(fd_ptr)
		LD	DE,21h
		ADD	HL,DE
		LD 	(HL),c
		INC	HL
		LD 	(HL),b
		ret	

;----------------------------------------------------------------------

loc_68:
		LD	HL,(fd_ptr)		; fd
		EX	DE,HL	
		LD	HL,0Ch		; fcb ex
		ADD	HL,DE
		LD 	b,(HL)
		LD	HL,20h		; fcb cr
		ADD	HL,DE
		LD 	c,(HL)
		LD	HL,21h		; fcb r0
		ADD	HL,DE
		LD 	a,(HL)
		LD 	l,b
		LD 	h,0
		ADD	HL,HL
		ADD	HL,HL
		ADD	HL,HL
		ADD	HL,HL
		ADD	HL,HL
		ADD	HL,HL
		ADD	HL,HL		; *128 (rec size)
		LD 	b,0
		ADD	HL,BC
		CP	80h
		JP	C,loc_69
		INC	HL
		SUB	80h
loc_69:		LD 	e,a
		LD 	d,0
		LD	A,(byte_70)
		AND	3		; check mode bits
		CP	1		; write?
		JP	NZ,loc_71
		DEC	HL
loc_71:		LD	(num_recs),HL
		LD 	a,e
		LD	(lrec_bcnt),A	; last record byte count
		ret	

;----------------------------------------------------------------------

loc_72:
		call	loc_68
		LD 	b,a
		XOR	a
		LD 	a,h
		RRA	
		LD 	e,a
		LD 	a,l
		RRA	
		LD 	h,a
		RRA	
		AND	80h
		OR	b
		LD 	l,a
		PUSH	HL
		PUSH	DE
		LD	HL,(fd_ptr)
		EX	DE,HL	
		LD	HL,27h		; fd last record byte cnt
		ADD	HL,DE
		LD 	a,(HL)
		LD	HL,25h		; fd num of records
		ADD	HL,DE
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		LD 	h,a
		XOR	a
		LD 	a,d
		RRA	
		LD 	b,a
		LD 	a,e
		RRA	
		LD 	c,a
		RRA	
		AND	80h
		OR	h
		POP	DE
		POP	HL
		OR	a
		sub	l
		LD 	l,a
		LD 	a,c
		SBC	h
		LD 	h,a
		LD 	a,b
		SBC	e
		LD 	e,a
		ret	

;----------------------------------------------------------------------

loc_73:
		LD 	a,l
		AND	7Fh
		LD 	c,a
		LD 	a,l
		ADD	A,a
		LD 	a,h
		RLA	
		LD 	b,a
		ret	

;----------------------------------------------------------------------

loc_74:
		PUSH	HL
		PUSH	BC
		call	isetdma
		LD	HL,(fd_ptr)
		PUSH	HL
		EX	DE,HL	
		call	readf
		POP	HL
		JP	NZ,loc_75
		LD	DE,20h
		ADD	HL,DE
		DEC	(HL)
loc_75:		POP	BC
		POP	HL
		ret	

;----------------------------------------------------------------------

loc_76:
		PUSH	HL
		PUSH	BC
		call	isetdma
		LD	HL,(fd_ptr)		; fcb addr
		EX	DE,HL	
		call	readf		; bdos read record
		POP	BC
		POP	HL
		ret	

;----------------------------------------------------------------------

loc_77:
		PUSH	BC
		PUSH	DE
		PUSH	HL
		EX	DE,HL	
		call	isetdma
		LD	HL,(fd_ptr)		; fcb addr
		EX	DE,HL	
		call	writef
		POP	HL
		POP	DE
		POP	BC
		ret	

;----------------------------------------------------------------------

loc_78:
		call	loc_72
		JP	NC,loc_79
		LD	HL,0
		LD	(word_65),HL
		JP	loc_80

loc_79:		JP	NZ,loc_80
		EX	DE,HL	
		LD	HL,(word_65)
		LD 	a,e
		sub	l
		LD 	a,d
		SBC	h
		JP	NC,loc_80
		EX	DE,HL	
		LD	(word_65),HL
loc_80:		call	loc_64
		PUSH	HL
		LD	HL,(word_81)
		EX	(SP),HL	
		XOR	a
		LD	(byte_82),A
		LD	A,(byte_70)
		AND	3
		CP	3
		JP	NZ,loc_83
		LD 	a,d
		OR	a
		JP	NZ,loc_84
		LD 	a,80h
		sub	c
		sub	e
		JP	NC,loc_83
loc_84:		call	loc_77		; write record, HL = buffer
		LD 	a,0FFh
		LD	(byte_82),A
loc_83:		LD 	a,c
		OR	a
		JP	M,loc_85
		LD 	a,d
		OR	e
		JP	Z,loc_86
		PUSH	HL
		ADD	HL,BC
		LD 	a,(HL)
		POP	HL
		INC	BC
		EX	(SP),HL	
		LD 	(HL),a
		INC	HL
		EX	(SP),HL	
		DEC	DE
		JP	loc_83

loc_85:		LD 	a,d
		OR	a
		JP	NZ,loc_87
		LD 	a,e
		OR	a
		JP	M,loc_87
		JP	Z,loc_86
		PUSH	DE
		LD 	d,h
		LD 	e,l
		call	loc_76		; read record, DE = bfr
		POP	DE
		JP	NZ,loc_86
		LD	BC,0
		JP	loc_83

loc_87:		EX	(SP),HL	
		PUSH	DE
		LD 	d,h
		LD 	e,l
		call	loc_76		; read record, DE = buffer
		POP	DE
		ADD	HL,BC
		EX	(SP),HL	
		JP	NZ,loc_86
		PUSH	HL
		LD	HL,0FF80h
		ADD	HL,DE
		EX	DE,HL	
		POP	HL
		JP	loc_85

loc_86:		LD	A,(byte_82)
		OR	a
		JP	Z,loc_88
		LD 	a,c
		OR	a
		JP	P,loc_89
		PUSH	DE
		LD 	d,h
		LD 	e,l
		call	loc_76		; read record, DE = buffer
		POP	DE
		LD	BC,0
		JP	NZ,loc_88
loc_89:		PUSH	DE
		PUSH	HL
		LD	HL,(fd_ptr)
		LD	DE,20h
		ADD	HL,DE
		DEC	(HL)
		POP	HL
		POP	DE
loc_88:		POP	HL
		call	loc_66
		call	dma80		; set dma to default 0080H
		ret	

;----------------------------------------------------------------------

loc_90:
		call	loc_72
		JP	C,loc_91
		JP	NZ,loc_92
		LD 	a,h
		OR	l
		JP	Z,loc_91
loc_92:		call	loc_64
		LD 	a,c
		OR	a
		JP	P,loc_93
		LD 	d,h
		LD 	e,l
		call	loc_76		; read record, DE = buffer
		PUSH	AF
		call	dma80		; set dma to default 0080H
		POP	AF
		JP	NZ,loc_91
		LD	BC,0
loc_93:		ADD	HL,BC
		LD 	a,(HL)
		LD	HL,(fd_ptr)
		LD	DE,21h
		ADD	HL,DE
		INC	BC
		LD 	(HL),c
		INC	HL
		LD 	(HL),b
		AND	7Fh
		ret	

loc_91:		LD 	a,1Ah
		ret	

;----------------------------------------------------------------------

loc_94:
		LD	HL,(fd_ptr)
		LD	DE,0Dh
		ADD	HL,DE
		LD 	(HL),0
		call	loc_64
		PUSH	HL
		LD	HL,(word_81)
		EX	(SP),HL	
loc_95:		LD 	a,c
		OR	a
		JP	Z,loc_96
		JP	P,loc_97
		PUSH	DE
		LD 	d,h
		LD 	e,l
		call	loc_77		; write record, HL = buffer
		POP	DE
		LD	BC,0
		JP	NZ,loc_98
		JP	loc_96

loc_97:		LD 	a,e
		OR	d
		JP	Z,loc_99
		EX	(SP),HL	
		LD 	a,(HL)
		INC	HL
		EX	(SP),HL	
		PUSH	HL
		ADD	HL,BC
		LD 	(HL),a
		POP	HL
		INC	BC
		DEC	DE
		JP	loc_95

loc_96:		LD 	a,d
		OR	a
		JP	NZ,loc_100
		LD 	a,e
		OR	a
		JP	M,loc_100
		PUSH	AF
		LD	A,(byte_70)
		AND	3
		CP	3
		JP	NZ,loc_101
		PUSH	DE
		LD 	d,h
		LD 	e,l
		call	loc_74
		POP	DE
loc_101:	POP	AF
		JP	Z,loc_99
loc_102:	EX	(SP),HL	
		LD 	a,(HL)
		INC	HL
		EX	(SP),HL	
		PUSH	HL
		ADD	HL,BC
		LD 	(HL),a
		POP	HL
		INC	BC
		DEC	DE
		LD 	a,e
		OR	d
		JP	NZ,loc_102
		JP	loc_99

loc_100:	EX	(SP),HL	
		PUSH	HL
		call	loc_77		; write record, HL = buffer
		POP	HL
		EX	(SP),HL	
		JP	NZ,loc_98
		LD	BC,80h
		EX	(SP),HL	
		ADD	HL,BC
		EX	(SP),HL	
		LD	BC,0FF80h
		EX	DE,HL	
		ADD	HL,BC
		EX	DE,HL	
		LD	BC,0
		JP	loc_96

loc_98:		LD 	a,0FFh
		LD	(byte_103),A
loc_99:		POP	HL
		call	loc_66
		call	dma80		; set dma to default 0080H
		LD	HL,(fd_ptr)
		EX	DE,HL	
		LD	HL,21h
		ADD	HL,DE
		LD 	a,80h
		sub	(HL)
		CP	80h
		RET	Z	
		LD	HL,0Dh
		ADD	HL,DE
		LD 	(HL),a
		ret	

;----------------------------------------------------------------------

loc_104:
		PUSH	BC
		LD	HL,(word_105)
		LD	DE,21h
		ADD	HL,DE
		LD 	c,(HL)
		INC	HL
		LD 	b,(HL)
		INC	HL
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		EX	DE,HL	
		LD 	a,c
		OR	a
		JP	P,loc_106
		PUSH	HL
		EX	DE,HL	
		call	isetdma
		LD	HL,(word_105)
		PUSH	HL
		LD	DE,0Dh
		ADD	HL,DE
		LD 	(HL),0
		POP	DE
		call	writef
		POP	HL
		JP	NZ,loc_107
		LD	BC,0
loc_106:	ADD	HL,BC
		POP	DE
		LD 	(HL),e
		LD	HL,(word_105)
		EX	DE,HL	
		LD	HL,21h
		ADD	HL,DE
		INC	BC
		LD 	(HL),c
		INC	HL
		LD 	(HL),b
		LD	HL,0Dh
		ADD	HL,DE
		LD 	a,80h
		sub	c
		LD 	(HL),a
		LD	HL,27h
		ADD	HL,DE
		INC	(HL)
		LD 	a,(HL)
		SUB	80h
		RET	C	
		LD 	(HL),a
		LD	HL,25h
		ADD	HL,DE
		INC	(HL)
		RET	NZ	
		INC	HL
		INC	(HL)
		ret	

loc_107:	POP	DE
		LD	HL,byte_103
		LD 	(HL),0FFh
		ret	

;----------------------------------------------------------------------

set_iobyte:
		PUSH	AF
		LD	A,(iobyte)
		LD	(old_iobyte),A
		POP	AF
		LD	(iobyte),A
		ret	

;----------------------------------------------------------------------

res_iobyte:
		LD	A,(old_iobyte)
		LD	(iobyte),A
		ret	

;----------------------------------------------------------------------

loc_63:
		LD	HL,f_dscrptrs
		LD	DE,28h		; 40 - size of struct fd
		LD 	c,6
loc_108:	LD 	(HL),0E5h
		ADD	HL,DE
		DEC	c
		JP	NZ,loc_108
		LD	HL,fd_tab
		LD	DE,byte_109
		LD 	c,8
		XOR	a
loc_110:	LD 	(HL),a
		LD	(DE),A
		INC	DE
		INC	HL
		DEC	c
		JP	NZ,loc_110
		LD 	a,6
		LD	(fd_tab),A
		LD 	a,5
		LD	(fd_tab+1),A
		LD	HL,0
		LD	(word_111),HL
		LD	HL,loc_57	; 3100H
loc_112:	PUSH	HL
		LD	HL,(word_50)
		EX	DE,HL	
		LD	HL,(bdos+1)
		call	cmp_hlde	; CY if HL > DE
		JP	C,loc_113
		EX	DE,HL	
loc_113:	POP	HL
		PUSH	HL
loc_114:	LD	BC,80h
		ADD	HL,BC
		call	cmp_hlde	; CY if HL > DE
		POP	DE
		JP	C,loc_115
		LD	HL,(word_111)
		EX	DE,HL	
		LD	(word_111),HL
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		LD	DE,7Fh
		ADD	HL,DE
		JP	loc_112

loc_115:	LD	HL,unk_116
		LD	DE,buflen
		LD	A,(DE)
		LD 	(HL),a
		INC	(HL)
		INC	(HL)
		LD 	b,a
loc_117:	INC	DE
		INC	HL
		LD 	a,b
		OR	a
		JP	Z,loc_118
		DEC	b
		LD	A,(DE)
		LD 	(HL),a
		JP	loc_117

loc_118:	LD 	(HL),0Dh		; cr
		INC	HL
		LD 	(HL),0Ah		; lf
		LD	HL,unk_119
		LD 	b,0
loc_120:	LD 	a,(HL)
		CP	0Dh		; cr
		JP	Z,loc_121
		CP	' '
		JP	Z,loc_121
		INC	HL
		INC	b
		JP	loc_120

loc_121:	LD	HL,unk_122
		LD 	(HL),b
		INC	HL
		LD 	(HL),7Eh
		ret	

;----------------------------------------------------------------------

loc_123:
		LD	HL,(word_111)
		LD 	a,l
		OR	h
		RET	Z	
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		DEC	HL
		EX	DE,HL	
		LD	(word_111),HL
		ret	

;----------------------------------------------------------------------

loc_124:
		LD	HL,(word_111)
		EX	DE,HL	
		LD	(word_111),HL
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		ret	

;----------------------------------------------------------------------

loc_125:
		LD	HL,f_dscrptrs
		LD 	b,6		; 6 fd's
loc_126:	LD	DE,comfcb
		LD 	c,11		; filename length (8+3)
		PUSH	HL
		LD 	a,0E5h
		CP	(HL)		; empty fd?
		JP	Z,loc_127		; yes -> try next
loc_128:	LD	A,(DE)
		CP	(HL)		; same file name?
		JP	NZ,loc_127		; no -> try next
		INC	DE
		INC	HL
		DEC	c
		JP	NZ,loc_128
		POP	HL
		ret	

loc_127:	POP	HL
		LD	DE,28h		; 40 - sizeof struct fd
		ADD	HL,DE
		DEC	b
		JP	NZ,loc_126
		INC	b
		ret	

;----------------------------------------------------------------------

loc_129:
		call	dma80		; set dma to default 0080H
		LD	DE,comfcb
		call	fsize		; compute file size
		XOR	a
		LD	(comfcb+0Ch),A	; set ex = 0
		LD	(lrec_bcnt),A	; last record byte count
		LD 	l,a
		LD 	h,a
		LD	(num_recs),HL
		LD	DE,comfcb
		call	openf
		RET	Z	
		LD	HL,(comrnd)		; get the file size from r0,r1
		LD 	a,h
		OR	l		; file has zero records?
		JP	Z,loc_130		; yes -> exit
		PUSH	HL
		DEC	HL
		LD	(comrnd),HL
		LD	DE,comfcb
		call	rndrd		; read the last record
		POP	HL
		LD	A,(comfcb+0Dh)	; s1 byte (last record byte count?)
		OR	a
		JP	Z,loc_131
		DEC	HL
		LD 	b,a
		LD 	a,80h
		sub	b
loc_131:	LD	(lrec_bcnt),A	; last record byte count
		LD	(num_recs),HL
		LD	HL,0
		LD	(comrnd),HL
		LD	DE,comfcb
		call	rndrd		; read the first record
loc_130:	XOR	a
		DEC	a
		ret	

;----------------------------------------------------------------------

close_fd:
		LD	HL,f_dscrptrs
		LD	DE,28h		; 40 - size of struct fd
loc_132:	OR	a
		JP	Z,loc_133
		ADD	HL,DE
		DEC	a
		JP	loc_132

loc_133:	LD	(fd_ptr),HL		; save fd address
		LD 	a,(HL)
		CP	0E5h		; in use?
		JP	Z,loc_134
		LD 	a,b
		LD	DE,21h		; offset to r0,r1,r2 in fcb
		ADD	HL,DE
		LD 	c,(HL)
		INC	HL
		LD 	b,(HL)
		INC	HL
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		AND	3
		CP	1
		JP	Z,loc_135
		LD 	a,b
		OR	c
		JP	Z,loc_135
		PUSH	DE
		EX	DE,HL	
		ADD	HL,BC
		LD 	a,c
loc_136:	CP	80h
		JP	Z,loc_137
		LD 	(HL),1Ah
		INC	a
		INC	HL
		JP	loc_136

loc_137:	POP	HL
		PUSH	HL
		call	loc_77		; write record, HL = buffer
		POP	DE
		JP	Z,loc_135
		call	loc_124
		LD 	b,1
		JP	loc_138

loc_135:	PUSH	DE
		LD	HL,(fd_ptr)
		EX	DE,HL	
		call	closef		; close the file
		POP	DE
		LD 	b,30		; error code = close error
		JP	Z,loc_138
		call	loc_124
		call	dma80		; set dma to default 0080H
loc_134:	LD 	b,0		; no error
loc_138:	LD	HL,(fd_ptr)
		LD 	(HL),0E5h		; mark the fd as unused
		ret	

;----------------------------------------------------------------------

store_word:
		PUSH	DE
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		EX	DE,HL	
		POP	DE
		LD 	(HL),a
		INC	HL
		LD 	(HL),0
		ret	

;----------------------------------------------------------------------

loc_139:
		LD 	e,a
		CP	1		; :CI: ?
		JP	NZ,loc_140
		LD	DE,unk_122
		OR	a
		ret	

loc_140:	LD	HL,byte_109
		call	add_hla
		LD 	a,(HL)
		OR	a
		RET	Z	
		LD 	d,0
		LD	HL,word_141
		ADD	HL,DE
		ADD	HL,DE
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		DEC	HL
		ret	

;----------------------------------------------------------------------

next_arg:				; get word pointed by pgm_de
		LD	HL,(pgm_de)
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		INC	HL
		LD	(pgm_de),HL
		ret	

;----------------------------------------------------------------------

get_filename:
		call	next_arg	; get word pointed by pgm_de
		LD 	c,16		; max isis filespec length
		LD	HL,buflen
		LD 	(HL),c
get_fn0:	INC	HL
		LD	A,(DE)
		LD 	(HL),a
		INC	DE
		DEC	c
		JP	NZ,get_fn0
		JP	noread		; uppercase the buffer

;----------------------------------------------------------------------

get_rw_args:
		call	next_arg	; get word pointed by pgm_de
		LD 	a,e
		LD	(fileno),A
		call	next_arg	; get word pointed by pgm_de
		EX	DE,HL	
		LD	(word_81),HL		; save ptr to buffer
		call	next_arg	; get word pointed by pgm_de
		EX	DE,HL	
		LD	(word_65),HL		; save count
		CP	8		; fileno > 7 ?
		JP	NC,loc_142		; yes -> error
		LD	HL,fd_tab
		call	add_hla
		LD 	a,(HL)
		OR	a		; free fd ?
		JP	Z,loc_142		; yes -> error
		LD	(byte_70),A		; save byte from fd_tab
		ret			; returns nz

loc_142:	LD 	b,2
		XOR	a
		ret	

;----------------------------------------------------------------------

find_fd:
		LD	HL,f_dscrptrs
		LD	DE,28h		; 40 - size of struct fd
find_fd0:	OR	a
		RET	Z	
		ADD	HL,DE
		DEC	a
		JP	find_fd0

;----------------------------------------------------------------------

dev_read:
		LD	HL,byte_143
		LD 	e,(HL)
		LD	HL,idrv_tbl
		LD 	d,0
		ADD	HL,DE
		ADD	HL,DE
		LD 	a,(HL)
		INC	HL
		LD 	h,(HL)
		LD 	l,a
		JP	(HL)	

;----------------------------------------------------------------------

idrv_tbl:	DEFW	loc_144
		DEFW	con_input
		DEFW	rdr_input
		DEFW	tty_input
		DEFW	crt_input
		DEFW	uc1_input
		DEFW	ptr_input
		DEFW	ur1_input
		DEFW	ur2_input
		DEFW	emp_input

;----------------------------------------------------------------------

con_in:
		LD 	c,1		; console input
		call	bdos
		LD 	e,a
		ret	

;----------------------------------------------------------------------

rdr_in:
		LD 	c,3		; reader input
		call	bdos
		LD 	e,a
		ret

;----------------------------------------------------------------------

loc_144:
		call	loc_90
		JP	io_ex2

;----------------------------------------------------------------------

con_input:
		call	con_in
		JP	io_ex1

;----------------------------------------------------------------------

rdr_input:
		call	rdr_in
		JP	io_ex1

;----------------------------------------------------------------------

tty_input:
		LD 	a,0		; TTY:
		call	set_iobyte
		call	con_in
		JP	io_exit

;----------------------------------------------------------------------

crt_input:
		LD 	a,1		; CRT:
		call	set_iobyte
		call	con_in
		JP	io_exit

;----------------------------------------------------------------------

uc1_input:
		LD 	a,3		; UC1:
		call	set_iobyte
		call	con_in
		JP	io_exit

;----------------------------------------------------------------------

ptr_input:
		LD 	a,4		; PTR:
		call	set_iobyte
		call	rdr_in
		JP	io_exit

;----------------------------------------------------------------------

ur1_input:
		LD 	a,8		; UR1:
		call	set_iobyte
		call	rdr_in
		JP	io_exit

;----------------------------------------------------------------------

ur2_input:
		LD 	a,0Ch		; UR2:
		call	set_iobyte
		call	rdr_in
		JP	io_exit

;----------------------------------------------------------------------

emp_input:
		LD 	e,1Ah
		JP	io_ex1

;----------------------------------------------------------------------

io_exit:
		call	res_iobyte
io_ex1:		LD 	a,e
io_ex2:		CP	1Ah
		JP	NZ,io_return
		LD	HL,byte_145
		LD 	(HL),0FFh
io_return:	ret
	
;----------------------------------------------------------------------

dev_write:
		LD	HL,byte_146
		LD 	e,(HL)
		LD	HL,odrv_tbl
		LD 	d,0
		ADD	HL,DE
		ADD	HL,DE
		LD 	a,(HL)
		INC	HL
		LD 	h,(HL)
		LD 	l,a
		LD 	e,c
		JP	(HL)	

;----------------------------------------------------------------------

odrv_tbl:	DEFW	loc_147
		DEFW	con_output
		DEFW	lst_output
		DEFW	pun_output
		DEFW	tty_output
		DEFW	crt_output
		DEFW	uc1_output
		DEFW	lpt_output
		DEFW	ul1_output
		DEFW	ptp_output
		DEFW	up1_output
		DEFW	up2_output
		DEFW	emp_output

;----------------------------------------------------------------------

con_out:
		LD 	c,2		; console output
		JP	bdos

;----------------------------------------------------------------------

pun_out:
		LD 	c,4		; punch output
		JP	bdos

;----------------------------------------------------------------------

lst_out:
		LD 	c,5		; list output
		JP	bdos

;----------------------------------------------------------------------

loc_147:
		call	loc_104
		JP	o_return

;----------------------------------------------------------------------

con_output:
		call	con_out
		JP	o_return

;----------------------------------------------------------------------

lst_output:
		call	lst_out
		JP	o_return

;----------------------------------------------------------------------

pun_output:
		call	pun_out
		JP	o_return

;----------------------------------------------------------------------

tty_output:
		LD 	a,0		; TTY:
		call	set_iobyte
		call	con_out
		JP	o_exit

;----------------------------------------------------------------------

crt_output:
		LD 	a,1		; CRT:
		call	set_iobyte
		call	con_out
		JP	o_exit

;----------------------------------------------------------------------

uc1_output:
		LD 	a,3		; UC1:
		call	set_iobyte
		call	con_out
		JP	o_exit

;----------------------------------------------------------------------

lpt_output:
		LD 	a,80h		; LPT:
		call	set_iobyte
		call	lst_out
		JP	o_exit

;----------------------------------------------------------------------

ul1_output:
		LD 	a,0C0h		; UL1:
		call	set_iobyte
		call	lst_out
		JP	o_exit

;----------------------------------------------------------------------

ptp_output:
		LD 	a,10h		; PTP:
		call	set_iobyte
		call	pun_out
		JP	o_exit

;----------------------------------------------------------------------

up1_output:
		LD 	a,20h		; UP1:
		call	set_iobyte
		call	pun_out
		JP	o_exit

;----------------------------------------------------------------------

up2_output:
		LD 	a,30h		; UP2:
		call	set_iobyte
		call	pun_out
		JP	o_exit

;----------------------------------------------------------------------

emp_output:
		JP	o_return

;----------------------------------------------------------------------

o_exit:					; restore original iobyte value
		call	res_iobyte
o_return:
		ret	

;----------------------------------------------------------------------

idos_ept:				; isis dos entry point
		EX	DE,HL	
		LD	(pgm_de),HL		; save DE
		LD 	a,c
		LD	(pgm_c),A		; save C
		LD	HL,0
		ADD	HL,sp
		LD	(pgm_sp),HL		; save program SP
		LD	sp,stack
		call	res_40h		; restore the original ram contents at 0040H
		LD	A,(pgm_c)
		CP	0Fh
		JP	C,loc_148
		LD 	a,18		; error code
		JP	error

;----------------------------------------------------------------------

loc_148:
		LD	A,(byte_62)
		OR	a
		JP	Z,loc_149
		call	break_key
		JP	Z,loc_149
		call	get_trlvl	; get trace level
loc_149:	XOR	a
		LD	(byte_23),A
		LD	A,(tr_level)
		OR	a
		JP	Z,no_trace
		call	tr_dump		; trace dump
no_trace:	LD	A,(pgm_c)
		LD	HL,ifn_tbl
		LD 	e,a
		LD 	d,0
		ADD	HL,DE
		ADD	HL,DE
		LD 	a,(HL)
		INC	HL
		LD 	d,(HL)
		LD 	e,a
		LD	HL,(pgm_de)
		EX	DE,HL	
		JP	(HL)	

;----------------------------------------------------------------------

ifn_tbl:	DEFW	fn_open
		DEFW	fn_close
		DEFW	fn_delete
		DEFW	fn_read
		DEFW	fn_write
		DEFW	fn_seek
		DEFW	fn_load
		DEFW	fn_rename
		DEFW	fn_console
		DEFW	fn_exit
		DEFW	fn_attrib
		DEFW	fn_rescan
		DEFW	fn_error
		DEFW	fn_whocon
		DEFW	fn_spath

;----------------------------------------------------------------------

fn_open:
		call	next_arg	; get word pointed by pgm_de
		EX	DE,HL	
		LD	(fileno),HL		; ptr to fileno
		call	get_filename
		call	next_arg	; get access
		LD 	a,e
		OR	a
		JP	Z,fn_open_err22
		CP	4
		JP	NC,fn_open_err22
		LD	(byte_70),A
		CP	3
		JP	Z,fn_open_file
		call	loc_37		; test for device name
		JP	Z,fn_open_file
		CP	0FFh
		LD 	b,5		; error: invalid device name
		JP	Z,fn_open_ex1
		CP	2
		JP	NC,loc_150
		LD	A,(byte_70)
		CP	1
		JP	Z,loc_151
		XOR	a
loc_151:	LD	HL,(fileno)		; ptr to fileno
		LD 	(HL),a
		LD 	b,0		; no error
		INC	HL
		LD 	(HL),b
		JP	fn_open_ex1	; exit with no error

loc_150:	ADD	A,a
		ADD	A,a
		JP	loc_152

;----------------------------------------------------------------------

fn_open_file:
		call	fillfcb0
		LD	A,(comfcb+1)
		CP	' '		; empty fcb?
		LD 	b,23		; error: bad file name
		JP	Z,fn_open_ex1
		call	loc_125		; file already open?
		LD 	b,12		; error: file already open
		JP	Z,fn_open_ex1	; yes -> error
		LD	A,(byte_70)		; file access
		CP	2
		JP	NZ,loc_153
		LD	DE,comfcb
		call	erasef
		JP	loc_154

loc_153:	call	loc_129		; open the file and get the file size
		LD 	b,13		; error: file not found
		JP	NZ,loc_155
		LD	A,(byte_70)		; file access
		CP	3
		JP	NZ,fn_open_ex1
loc_154:	LD	DE,comfcb
		call	makef
		INC	a
		LD 	b,9		; error: can't create file
		JP	Z,fn_open_ex1
		LD	HL,0
		LD	(num_recs),HL
		XOR	a
		LD	(lrec_bcnt),A	; last record byte count
loc_155:	XOR	a
		LD	(comrec),A		; comfcb rc byte
		LD	HL,f_dscrptrs	; find a free fd
		LD	DE,28h
		LD	BC,6
		LD 	a,0E5h
loc_156:	CP	(HL)
		JP	Z,loc_157
		INC	b
		ADD	HL,DE
		DEC	c
		JP	NZ,loc_156
		LD 	b,3		; error: not enough fd's
		JP	fn_open_ex1

loc_157:	LD 	c,33		; fcb length
		LD	DE,comfcb
loc_158:	LD	A,(DE)
		LD 	(HL),a		; copy the fcb to the fd
		INC	DE
		INC	HL
		DEC	c
		JP	NZ,loc_158
		LD	DE,0
		LD	A,(byte_70)		; file access
		CP	1
		JP	NZ,loc_159
		LD	DE,80h
loc_159:	LD 	(HL),e
		INC	HL
		LD 	(HL),d
		INC	HL
		PUSH	HL
		call	loc_123
		POP	HL
		JP	NZ,loc_160
		LD 	b,1		; error code
		JP	fn_open_ex1

loc_160:	LD 	(HL),e
		INC	HL
		LD 	(HL),d
		INC	HL
		EX	DE,HL	
		LD	HL,(num_recs)
		EX	DE,HL	
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		INC	HL
		LD	A,(lrec_bcnt)	; last record byte count
		LD 	(HL),a
		LD 	a,b		; B = fd number
		ADD	A,a
		ADD	A,a		; shift left two bits
		OR	80h		; set "has fd" bit
loc_152:	LD	HL,byte_70	; file access
		OR	(HL)		; add the file access bits
		LD 	(HL),a
		LD	HL,fd_tab
		XOR	a
		LD	BC,8
loc_161:	CP	(HL)		; search for an empty entry in fd_tab
		JP	Z,loc_162
		INC	b
		INC	HL
		DEC	c
		JP	NZ,loc_161
		LD 	b,3		; error: not enough fd's
		JP	fn_open_ex1

loc_162:	LD	A,(byte_70)
		LD 	(HL),a		; save entry in fd_tab
		LD 	a,b
		LD	HL,(fileno)		; ptr to fileno
		LD 	(HL),a		; set the fileno return value
		INC	HL
		LD 	(HL),0
		LD	(fileno),A		; change to fileno value
		call	next_arg	; get echo mode
		LD	HL,byte_109
		call	add_hla
		LD 	(HL),0
		LD 	a,e
		CP	8
		JP	NC,fn_open_err25
		OR	a
		JP	Z,fn_open_ok
		PUSH	HL
		LD	HL,fd_tab
		call	add_hla
		LD 	a,(HL)
		AND	3
		POP	HL
		CP	2
		JP	NZ,fn_open_err25
		PUSH	DE
		PUSH	HL
		call	loc_123
		POP	HL
		POP	BC
		JP	NZ,loc_163
		LD 	a,1		; error code
		JP	fn_open_exit

loc_163:	LD 	(HL),c
		PUSH	DE
		LD	A,(fileno)
		call	loc_139
		POP	DE
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		EX	DE,HL	
		XOR	a
		LD 	(HL),a
		INC	HL
		LD 	(HL),78h
		INC	HL
		LD 	(HL),a

fn_open_ok:	LD 	a,0		; no error
		JP	fn_open_exit

;----------------------------------------------------------------------

fn_open_err25:
		LD 	a,25		; error code
fn_open_exit:
		LD	HL,(pgm_de)
		call	store_word
		JP	idos_exit

;----------------------------------------------------------------------

fn_open_err22:
		LD 	b,22		; error: invalid access
fn_open_ex1:
		call	next_arg	; skip echo parameter
		LD 	a,b
		call	store_word
		JP	idos_exit

;----------------------------------------------------------------------

fn_close:
		call	next_arg	; get word pointed by pgm_de
		LD 	a,e
		CP	8		; valid file numbers = 0..7
		JP	NC,fn_clserr
		CP	2
		JP	C,fn_clsok	; don't close :CI: and :CO:
		LD	HL,fd_tab
		call	add_hla
		LD 	a,(HL)
		LD 	(HL),0		; clear the fd entry in fd_tab
		OR	a
		JP	Z,fn_clsok	; return if already closed
		PUSH	AF
		LD 	a,e
		call	loc_139
		CALL	NZ,loc_124
		POP	AF
		JP	P,fn_clsok	; return if not a disk file
		PUSH	AF
		AND	3
		LD 	b,a
		POP	AF
		RRCA	
		RRCA	
		AND	1Fh		; get the number of the associated file descriptor (fcb)
		call	close_fd
		JP	fn_clsexit

fn_clsok:	LD 	b,0
		JP	fn_clsexit

fn_clserr:	LD 	b,9		; error: invalid file number
fn_clsexit:	LD	HL,(pgm_de)
		LD 	a,b
		call	store_word	; store the return value
		JP	idos_exit

;----------------------------------------------------------------------

fn_delete:
		call	get_filename
		call	fillfcb0
		LD	DE,comfcb
		call	erasef
		XOR	a		; no error
		LD	HL,(pgm_de)
		call	store_word	; store the return code
		JP	idos_exit

;----------------------------------------------------------------------

fn_read:
		call	get_rw_args
		JP	Z,fn_rderr
		LD	A,(byte_70)		; byte from fd_tab
		AND	3		; mask file access bits
		CP	2		; read allowed?
		JP	NZ,loc_164
		LD 	b,8		; error: bad file access
		JP	fn_rderr

loc_164:	LD	A,(byte_70)
		OR	a		; fd (fcb) associated ?
		JP	P,loc_165		; no ->
		RRA	
		RRA	
		AND	1Fh
		call	find_fd
		LD	(fd_ptr),HL
		XOR	a
		JP	loc_166

loc_165:	RRA	
		RRA	
		AND	1Fh
loc_166:	LD	(byte_143),A
		XOR	a
		LD	(byte_145),A
		LD	(byte_103),A
		LD	HL,(word_81)
		LD	(dmp_from),HL
		LD	HL,0
		LD	(word_67),HL
		LD	A,(fileno)
		CP	1		; :CI: ?
		JP	NZ,loc_167
		LD	HL,unk_122
		LD	(word_168),HL
		LD 	a,(HL)
		INC	HL
		INC	HL
		CP	(HL)
		JP	NZ,loc_169
		LD 	c,0Ah		; read console buffer
		LD	DE,unk_170
		call	bdos
		LD	HL,unk_122
		LD 	(HL),0
		INC	HL
		INC	HL
		LD 	a,(HL)		; chars read
		INC	(HL)
		INC	(HL)		; add two extra chars: cr and lf
		INC	HL
		call	add_hla
		LD 	(HL),0Dh		; cr
		INC	HL
		LD 	(HL),0Ah		; lf
		call	crlf
		JP	loc_169

loc_167:	LD	HL,byte_109
		call	add_hla
		LD 	a,(HL)
		OR	a
		JP	Z,loc_171
		LD	(byte_146),A
		LD	A,(fileno)
		call	loc_139
		EX	DE,HL	
		LD	(word_168),HL
		LD 	a,(HL)
		INC	HL
		INC	HL
		CP	(HL)
		JP	NZ,loc_169
		LD	A,(byte_146)
		LD	HL,fd_tab
		call	add_hla
		LD 	a,(HL)
		OR	a
		JP	M,loc_172
		RRA	
		RRA	
		AND	1Fh
		JP	loc_173

loc_172:	RRA	
		RRA	
		AND	1Fh
		call	find_fd
		LD	(word_105),HL
		XOR	a
loc_173:	LD	(byte_146),A
		LD 	c,0
		LD	HL,(word_168)
		LD 	(HL),c
		INC	HL
		INC	HL
		LD 	(HL),c
loc_174:	LD	HL,(word_168)
		INC	HL
		LD 	b,(HL)
		INC	HL
		LD 	a,(HL)
		CP	b
		JP	NC,loc_169
		INC	(HL)
		call	add_hla
		INC	HL
		PUSH	HL
		LD 	a,c
		OR	a
		JP	NZ,loc_175
loc_176:	call	dev_read
		CP	0Ah
		JP	Z,loc_176
loc_175:	POP	HL
		LD 	(HL),a
		LD 	c,a
		PUSH	BC
		call	dev_write
		POP	BC
		LD	A,(byte_103)
		OR	a
		LD 	b,7
		JP	NZ,loc_177
		LD 	a,c
		LD 	c,0
		CP	0Ah		; lf
		JP	Z,loc_178
		CP	0Dh		; cr
		JP	NZ,loc_174
		LD 	c,0Ah		; lf
		JP	loc_174

loc_178:	LD	HL,(word_168)
		INC	HL
		INC	HL
		LD 	a,(HL)
		CP	3
		JP	NZ,loc_169
		INC	HL
		LD 	a,(HL)
		CP	1Ah
		JP	NZ,loc_169
		DEC	HL
		LD 	(HL),0
loc_169:	LD	HL,(word_168)
		LD 	b,(HL)
		INC	HL
		INC	HL
		LD 	a,(HL)
		sub	b
		LD 	b,a
		LD	HL,(word_65)
		EX	DE,HL	
loc_179:	LD 	a,b
		OR	a
		JP	Z,loc_180
		LD 	a,d
		OR	e
		JP	Z,loc_180
		DEC	b
		DEC	DE
		LD	HL,(word_168)
		LD 	a,(HL)
		INC	(HL)
		INC	HL
		INC	HL
		INC	HL
		call	add_hla
		LD 	a,(HL)
		LD	HL,(word_81)
		LD 	(HL),a
		INC	HL
		LD	(word_81),HL
		CP	1Ah
		JP	NZ,loc_179
loc_180:	LD	HL,(word_65)
		LD 	a,l
		sub	e
		LD 	l,a
		LD 	a,h
		SBC	d
		LD 	h,a
		LD	(word_67),HL
		JP	loc_181

;----------------------------------------------------------------------

loc_171:
		LD	A,(byte_143)
		OR	a
		JP	NZ,loc_182
		call	loc_78
		JP	loc_181

loc_182:	LD	A,(byte_145)
		OR	a
		JP	NZ,loc_181
		LD	HL,(word_65)
		LD 	a,l
		OR	h
		JP	Z,loc_177
		DEC	HL
		LD	(word_65),HL
		call	dev_read
		LD	HL,(word_81)
		LD 	(HL),a
		INC	HL
		LD	(word_81),HL
		LD	HL,(word_67)
		INC	HL
		LD	(word_67),HL
		JP	loc_182

loc_181:	LD 	b,0		; no error
loc_177:	call	next_arg	; get word pointed by pgm_de
		LD	HL,(word_67)
		EX	DE,HL	
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		LD	HL,(pgm_de)
		LD 	a,b
		call	store_word
		LD	A,(tr_level)
		AND	8
		JP	Z,idos_exit
		call	crlf
		LD	HL,(dmp_from)
		EX	DE,HL	
		LD	HL,(word_67)
		LD 	a,l
		OR	h
		JP	Z,idos_exit
		ADD	HL,DE
		DEC	HL
		LD	(dmp_to),HL
		call	dump_mem
		call	crlf
		JP	idos_exit

;----------------------------------------------------------------------

fn_rderr:
		call	next_arg	; skip next word
		LD 	a,b
		call	store_word	; store the return code
		JP	idos_exit

;----------------------------------------------------------------------

fn_write:
		call	get_rw_args
		JP	Z,loc_183
		LD	A,(byte_70)		; byte from fd_tab
		AND	3		; mask access bits
		CP	1
		JP	NZ,loc_184
		LD 	b,6		; error: bad file access
		JP	loc_183

loc_184:	LD	A,(byte_70)
		OR	a		; fd (fcb) associated?
		JP	P,loc_185		; no ->
		RRA	
		RRA	
		AND	1Fh
		call	find_fd
		LD	(fd_ptr),HL
		XOR	a
		JP	loc_186

loc_185:	RRA	
		RRA	
		AND	1Fh
loc_186:	LD	(byte_146),A
		XOR	a
		LD	(byte_103),A
		LD	A,(tr_level)	; check trace level
		AND	10h
		JP	Z,loc_187
		call	crlf
		LD	HL,(word_65)
		LD 	a,l
		OR	h
		JP	Z,loc_187
		EX	DE,HL	
		LD	HL,(word_81)
		LD	(dmp_from),HL
		ADD	HL,DE
		DEC	HL
		LD	(dmp_to),HL
		call	dump_mem
		call	crlf
loc_187:	LD	A,(byte_146)
		OR	a
		JP	NZ,loc_188
		call	loc_94
		LD	A,(byte_103)
		OR	a
		JP	Z,loc_189
		LD 	b,7
		JP	loc_183

loc_189:	call	loc_68
		LD 	c,l
		LD 	b,h
		LD	HL,(fd_ptr)
		LD	DE,25h
		ADD	HL,DE
		LD 	a,(HL)
		sub	c
		LD 	e,a
		INC	HL
		LD 	a,(HL)
		SBC	b
		JP	C,loc_190
		OR	e
		JP	NZ,loc_191
		LD	A,(lrec_bcnt)	; last record byte count
		LD 	c,a
		LD	HL,(fd_ptr)
		LD	DE,27h
		ADD	HL,DE
		LD 	a,(HL)
		sub	c
		JP	NC,loc_191
		LD 	(HL),c
		JP	loc_191

loc_190:	LD 	(HL),b
		DEC	HL
		LD 	(HL),c
		LD	HL,(fd_ptr)
		LD	DE,27h
		ADD	HL,DE
		LD	A,(lrec_bcnt)	; last record byte count
		LD 	(HL),a
		JP	loc_191

loc_188:	LD	A,(byte_103)
		OR	a
		LD 	b,a
		JP	NZ,loc_183
		LD	HL,(word_65)
		LD 	a,l
		OR	h
		JP	Z,loc_191
		DEC	HL
		LD	(word_65),HL
		LD	HL,(word_81)
		LD 	c,(HL)
		INC	HL
		LD	(word_81),HL
		call	dev_write
		JP	loc_188

loc_191:	LD 	b,0		; no error
loc_183:	LD	HL,(pgm_de)
		LD 	a,b
		call	store_word	; store the return code
		JP	idos_exit

;----------------------------------------------------------------------

fn_seek:
		call	dma80		; set dma to default 0080H
		XOR	a
		LD	(byte_192),A
		call	next_arg	; get word pointed by pgm_de
		LD 	a,e
		LD	(fileno),A
		call	next_arg	; get word pointed by pgm_de
		LD 	a,e
		LD	(seek_mode),A
		call	next_arg	; get word pointed by pgm_de
		EX	DE,HL	
		LD	(word_193),HL	; block ptr
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		EX	DE,HL	
		LD	(word_194),HL	; block value
		call	next_arg	; get word pointed by pgm_de
		EX	DE,HL	
		LD	(word_195),HL	; byte ptr
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		EX	DE,HL	
		LD	(word_196),HL	; byte value
		LD	A,(seek_mode)
		DEC	a
		CP	3
		JP	NC,loc_197
		LD	HL,word_196	; byte value
		LD 	a,(HL)
		AND	7Fh
		LD 	c,a
		LD 	a,(HL)
		RLCA	
		AND	1
		LD 	e,a
		LD 	(HL),c
		INC	HL
		LD 	a,(HL)
		LD 	(HL),0
		ADD	A,a
		PUSH	AF
		OR	e
		LD 	e,a
		POP	AF
		RLCA	
		AND	1
		LD 	d,a
		LD	HL,(word_194)	; block value
		ADD	HL,DE
		LD	(word_194),HL
loc_197:	LD	A,(fileno)
		CP	8
		LD 	b,2		; error: bad file number
		JP	NC,loc_198
		LD	HL,fd_tab
		call	add_hla
		LD 	a,(HL)
		LD 	c,a
		AND	3		; mask access bits
		JP	Z,loc_198
		LD 	b,31		; error code
		CP	2
		JP	Z,loc_198
		LD	(byte_70),A
		LD 	a,c
		ADD	A,a
		LD 	b,2
		JP	NC,loc_198
		LD 	a,c
		RRA	
		RRA	
		AND	1Fh
		call	find_fd
		LD	(fd_ptr),HL		; fd
		call	loc_68
		LD	A,(seek_mode)
		OR	a
		JP	NZ,loc_199
		PUSH	HL
		LD	HL,(word_195)	; byte ptr
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		POP	DE
		LD	HL,(word_193)	; block ptr
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		JP	loc_200

loc_199:	DEC	a
		JP	NZ,loc_201
		PUSH	HL
		LD	HL,word_196
		LD 	a,e
		sub	(HL)
		POP	BC
		JP	P,loc_202
		DEC	HL
		ADD	A,80h
loc_202:	LD 	e,a
		LD	HL,word_194
		LD 	a,c
		sub	(HL)
		LD 	c,a
		INC	HL
		LD 	a,b
		SBC	(HL)
		LD 	h,a
		LD 	l,c
		JP	P,loc_203
		LD 	a,14h
		LD	(byte_192),A
		LD	HL,0
		LD 	e,l
		JP	loc_203

loc_201:	DEC	a
		JP	NZ,loc_204
		LD	HL,(word_196)
		EX	DE,HL	
		LD	HL,word_194
		LD 	a,(HL)
		INC	HL
		LD 	h,(HL)
		LD 	l,a
		JP	loc_203

loc_204:	DEC	a
		JP	NZ,loc_205
		PUSH	HL
		LD	HL,word_196
		LD 	a,e
		ADD	A,(HL)
		POP	HL
		CP	80h
		JP	C,loc_206
		INC	HL
		SUB	80h
loc_206:	LD 	e,a
		LD 	c,l
		LD 	b,h
		LD	HL,word_194
		LD 	a,(HL)
		ADD	A,c
		LD 	c,a
		INC	HL
		LD 	a,(HL)
		ADC	A,b
		LD 	h,a
		LD 	l,c
		JP	loc_203

loc_205:	DEC	a
		LD 	b,27		; error code
		JP	NZ,loc_198
		LD	HL,(fd_ptr)
		EX	DE,HL	
		LD	HL,25h
		ADD	HL,DE
		LD 	c,(HL)
		INC	HL
		LD 	b,(HL)
		LD	HL,27h
		ADD	HL,DE
		LD 	e,(HL)
		LD 	d,0
		LD 	h,b
		LD 	l,c
loc_203:	PUSH	DE
		PUSH	HL
		LD	HL,(fd_ptr)
		EX	DE,HL	
		LD	HL,25h
		ADD	HL,DE
		LD	(word_193),HL
		LD	HL,27h
		ADD	HL,DE
		LD	(word_195),HL
		POP	HL
		POP	DE
		LD	A,(byte_70)
		CP	1
		JP	Z,loc_207
		JP	loc_208

;----------------------------------------------------------------------

loc_209:
		LD	HL,21h
		ADD	HL,DE
		LD 	a,(HL)
		OR	a
		RET	Z	
		LD	HL,23h
		ADD	HL,DE
		LD 	a,(HL)
		INC	HL
		LD 	h,(HL)
		LD 	l,a
		call	loc_77		; write record, HL = buffer
		RET	Z	
		LD 	b,7
		JP	loc_198

;----------------------------------------------------------------------

loc_210:
		PUSH	HL
		LD	HL,(word_193)
		LD 	a,(HL)
		INC	HL
		LD 	b,(HL)
		POP	HL
		sub	l
		LD 	c,a
		LD 	a,b
		SBC	h
		RET	C	
		OR	c
		RET	NZ	
		PUSH	HL
		LD	HL,(word_195)
		LD 	a,(HL)
		POP	HL
		sub	e
		ret	

;----------------------------------------------------------------------

loc_208:
		call	loc_73
		PUSH	HL
		PUSH	DE
		LD	HL,(fd_ptr)
		EX	DE,HL	
		LD	HL,0Ch
		ADD	HL,DE
		LD 	a,b
		CP	(HL)
		JP	NZ,loc_211
		LD	HL,20h
		ADD	HL,DE
		LD 	a,c
		CP	(HL)
		JP	NZ,loc_212
		LD	HL,21h
		ADD	HL,DE
		POP	DE
		LD 	(HL),e
		POP	HL
		JP	loc_200

;----------------------------------------------------------------------

loc_212:
		call	loc_209
		JP	loc_213

;----------------------------------------------------------------------

loc_211:
		call	loc_209
		call	closef
		LD 	b,9
		JP	Z,loc_198
loc_213:	POP	DE
		POP	HL
		call	loc_210
		JP	NC,loc_214
		PUSH	DE
		PUSH	HL
		LD	HL,(word_195)
		LD 	e,(HL)
		LD 	d,0
		LD	HL,(word_193)
		LD 	a,(HL)
		INC	HL
		LD 	h,(HL)
		LD 	l,a
		call	loc_73
		LD	HL,(fd_ptr)
		LD	(word_105),HL
		EX	DE,HL	
		LD	HL,0Ch
		ADD	HL,DE
		LD 	a,b
		CP	(HL)
		JP	Z,loc_215
		LD 	(HL),a
		PUSH	BC
		PUSH	DE
		call	openf
		LD 	b,19		; error code
		JP	Z,loc_198
		POP	DE
		POP	BC
loc_215:	LD	HL,20h
		ADD	HL,DE
		LD 	(HL),c
		PUSH	HL
		PUSH	DE
		LD	HL,23h
		ADD	HL,DE
		LD 	a,(HL)
		INC	HL
		LD 	d,(HL)
		LD 	e,a
		call	isetdma
		POP	DE
		PUSH	DE
		call	readf
		POP	DE
		POP	HL
		OR	a
		JP	NZ,loc_216
		DEC	(HL)
loc_216:	XOR	a
		LD	(byte_103),A
		LD	HL,(word_195)
		LD 	c,(HL)
		LD	HL,21h
		ADD	HL,DE
		LD 	(HL),c
		POP	HL
		POP	DE
loc_217:	call	loc_210
		JP	NC,loc_218
		PUSH	DE
		PUSH	HL
		LD 	c,0
		call	loc_104
		POP	HL
		POP	DE
		LD	A,(byte_103)
		LD	(byte_192),A
		OR	a
		JP	Z,loc_217
loc_218:	JP	loc_200

;----------------------------------------------------------------------

loc_214:
		call	loc_73
		PUSH	DE
		PUSH	HL
		LD	HL,(fd_ptr)
		EX	DE,HL	
		LD	HL,0Ch
		ADD	HL,DE
		LD 	a,b
		CP	(HL)
		JP	Z,loc_219
		LD 	(HL),a
		PUSH	BC
		PUSH	DE
		PUSH	DE
		LD	DE,80h
		call	isetdma
		POP	DE
		call	openf
		LD 	b,19		; error code
		JP	Z,loc_198
		POP	DE
		POP	BC
loc_219:	LD	HL,20h
		ADD	HL,DE
		LD 	(HL),c
		LD	HL,23h
		ADD	HL,DE
		PUSH	DE
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		call	loc_74
		POP	DE
		LD	HL,21h
		ADD	HL,DE
		POP	BC
		POP	DE
		LD 	(HL),e
		JP	loc_200

;----------------------------------------------------------------------

loc_220:
		PUSH	DE
		LD	HL,23h		; fd bfr addr
		ADD	HL,DE
		LD 	e,(HL)
		INC	HL
		LD 	d,(HL)
		call	loc_76		; read record, DE = buffer
		POP	DE
		ret	

;----------------------------------------------------------------------

loc_207:
		EX	DE,HL	
		PUSH	HL
		LD	HL,(word_193)
		LD 	a,(HL)
		INC	HL
		LD 	b,(HL)
		sub	e
		LD 	c,a
		LD 	a,b
		SBC	d
		POP	HL
		EX	DE,HL	
		LD 	b,33		; error code
		JP	C,loc_198
		OR	c
		JP	NZ,loc_221
		PUSH	HL
		LD	HL,(word_195)
		LD 	a,(HL)
		POP	HL
		sub	e
		JP	C,loc_198
loc_221:	call	loc_73
		LD	HL,lrec_bcnt	; last record byte count
		LD 	(HL),e
		LD	HL,(fd_ptr)
		EX	DE,HL	
		LD	HL,0Ch		; fcb ex
		ADD	HL,DE
		LD 	a,b
		CP	(HL)
		JP	Z,loc_222
		PUSH	BC
		LD 	(HL),a
		PUSH	DE
		call	openf
		INC	a
		LD 	b,19		; error code
		JP	Z,loc_198
		POP	DE
		POP	BC
		LD	HL,20h		; fcb cr
		ADD	HL,DE
		LD 	(HL),0
		LD	HL,21h
		ADD	HL,DE
		LD 	(HL),80h
loc_222:	LD	HL,21h
		ADD	HL,DE
		LD 	a,(HL)
		CP	80h
		JP	C,loc_223
		LD	HL,20h
		ADD	HL,DE
		LD 	a,c
		CP	(HL)
		JP	NZ,loc_224
		call	loc_220
		JP	loc_225

loc_223:	LD	HL,20h
		ADD	HL,DE
		LD 	a,c
		INC	a
		CP	(HL)
		JP	Z,loc_225
loc_224:	LD 	(HL),c
		call	loc_220		; read record
loc_225:	LD	HL,21h
		ADD	HL,DE
		LD	A,(lrec_bcnt)	; last record byte count
		LD 	(HL),a
loc_200:	LD 	b,0
loc_198:	LD 	a,b
		LD	HL,byte_192
		OR	(HL)
		LD	HL,(pgm_de)
		call	store_word	; store return value
		call	dma80		; set dma to default 0080H
		JP	idos_exit

;----------------------------------------------------------------------

fn_load:				; set dma to default 0080H
		call	dma80
		call	get_filename
		call	next_arg	; get word pointed by pgm_de
		EX	DE,HL	
		LD	(word_55),HL
		call	fillfcb0
		LD 	b,4		; error code
		JP	NZ,loc_226
		call	openc		; open comfcb
		LD 	b,13		; error code
		JP	Z,loc_226
		call	next_arg	; get word pointed by pgm_de
		LD 	a,e
		CP	2
		JP	NC,loc_226
		PUSH	DE
		call	next_arg	; get word pointed by pgm_de
		PUSH	DE
		call	load
		LD 	b,15		; error code
		JP	Z,loc_227
		call	dma80		; set dma to default 0080H
		POP	DE
		POP	BC
		LD 	a,c
		OR	a
		JP	NZ,loc_228
		LD	HL,(word_4)
		EX	DE,HL	
		LD 	(HL),e
		INC	HL
		LD 	(HL),d
		LD 	b,a
		JP	loc_226

loc_228:	LD	HL,(word_4)
		LD 	a,h
		OR	l
		JP	NZ,loc_229
		LD	HL,(word_50)
loc_229:	PUSH	HL
		LD	HL,0
		ADD	HL,sp
		LD	(pgm_sp),HL
		JP	idos_exit

loc_226:	LD	HL,(pgm_de)
		LD 	a,b
		call	store_word
		JP	idos_exit

loc_227:	JP	comerr

;----------------------------------------------------------------------

fn_rename:
		call	dma80		; set dma to default 0080H
		call	get_filename
		call	fillfcb0
		LD 	b,4		; error code
		JP	NZ,loc_230
		LD	A,(comfcb+1)
		CP	20h
		LD 	b,4		; error code
		JP	Z,loc_230
		call	get_filename
		LD 	a,10h
		call	fillfcb
		LD 	b,4		; error code
		JP	NZ,loc_231
		LD	DE,comfcb+10h
		call	srchfst
		LD 	b,11		; error code
		JP	NZ,loc_231
		call	srchcom
		LD 	b,13		; error code
		JP	Z,loc_231
		LD	HL,comfcb
		LD	A,(sdisk)
		CP	(HL)
		LD 	b,4		; error code
		JP	NZ,loc_230
		EX	DE,HL	
		call	irename
		LD 	b,0		; no error
		JP	loc_231

loc_230:	call	next_arg	; get word pointed by pgm_de
loc_231:	LD	HL,(pgm_de)
		LD 	a,b
		call	store_word
		JP	idos_exit

;----------------------------------------------------------------------

fn_console:
		JP	idos_exit

;----------------------------------------------------------------------

fn_exit:
		LD	HL,fd_tab
		LD	BC,8		; close all open files
close_all:
		LD 	a,b
		CP	2
		JP	C,dont_close	; don't close :CI: and :CO:
		LD 	a,(HL)
		OR	a
		JP	Z,fn_ex_freefd
		PUSH	HL
		PUSH	BC
		LD 	a,b
		call	loc_139
		CALL	NZ,loc_124
		POP	BC
		POP	HL
		LD 	a,(HL)
		OR	a
		JP	P,fn_ex_freefd
		LD 	a,(HL)
		LD 	b,a
		RRA	
		RRA	
		AND	1Fh
		PUSH	HL
		PUSH	BC
		call	close_fd
		POP	BC
		POP	HL
fn_ex_freefd:	LD 	(HL),0		; mark entry in fd_tab as unused
dont_close:	INC	b
		INC	HL
		DEC	c
		JP	NZ,close_all
		call	dma80		; set dma to default 0080H
		JP	cli		; transfer control to the command processor

;----------------------------------------------------------------------

fn_attrib:
		JP	idos_exit

;----------------------------------------------------------------------

fn_rescan:
		call	next_arg	; get word pointed by pgm_de
		LD 	a,e
		call	loc_139
		LD 	b,21		; error code
		JP	Z,loc_232
		LD 	a,0
		LD	(DE),A
		LD 	b,a		; no error
loc_232:	LD	HL,(pgm_de)
		LD 	a,b
		call	store_word	; store the return value
		JP	idos_exit

;----------------------------------------------------------------------

fn_error:
		LD	HL,2
		ADD	HL,DE		; HL - ptr to return var, keep DE
		XOR	a
		call	store_word	; return value = 0
		LD	A,(DE)		; get error code
error:		PUSH	AF
		LD	BC,errmsg	; "error "
		call	ln_print
		POP	AF
		call	adec		; print error code
		LD	DE,atpcmsg	; "at user PC "
		call	putstr
		LD	HL,(pgm_sp)
		INC	HL
		LD 	a,(HL)		; print program PC from stack
		PUSH	HL
		call	ahex
		POP	HL
		DEC	HL
		LD 	a,(HL)
		call	ahex
		call	crlf
		JP	idos_exit

;----------------------------------------------------------------------

errmsg:		DEFM	"ERROR $"
atpcmsg:	DEFM	", AT USER PC $"

;----------------------------------------------------------------------

fn_whocon:				; not implemented
		JP	idos_exit

;----------------------------------------------------------------------

fn_spath:
		call	get_filename
		LD 	a,1
		call	loc_37
		JP	Z,loc_233
		INC	a
		JP	Z,loc_233
		SUB	2
		LD 	b,1
		JP	loc_234

loc_233:	LD	HL,combuf
		LD	(comaddr),HL
		LD 	a,2
		call	loc_37
		JP	Z,loc_235
		INC	a
		JP	Z,loc_236
		ADD	A,7
		LD 	b,0
loc_234:	LD	HL,byte_43
		call	add_hla
		LD 	a,(HL)
		call	next_arg	; get word pointed by pgm_de
		PUSH	DE
		LD	(DE),A
		EX	DE,HL	
		XOR	a
		LD 	c,9
loc_237:	INC	HL
		LD 	(HL),a
		DEC	c
		JP	NZ,loc_237
		INC	HL
		LD 	(HL),b
		INC	HL
		LD 	(HL),0FFh
		JP	loc_238

loc_235:	call	fillfcb0
		LD	A,(comfcb+1)
		CP	' '
		JP	Z,loc_236
		LD	A,(comfcb)
		DEC	a
		JP	P,loc_239
		LD	A,(cur_disk)
loc_239:	call	next_arg	; get word pointed by pgm_de
		LD	(DE),A
		PUSH	DE
		LD 	b,a
		LD 	c,6
		LD	HL,comfcb
loc_240:	INC	DE
		INC	HL
		LD 	a,(HL)
		CP	' '
		JP	NZ,loc_241
		XOR	a
loc_241:	LD	(DE),A
		DEC	c
		JP	NZ,loc_240
		LD	HL,comfcb+8
		LD 	c,3
loc_242:	INC	DE
		INC	HL
		LD 	a,(HL)
		CP	' '
		JP	NZ,loc_243
		XOR	a
loc_243:	LD	(DE),A
		DEC	c
		JP	NZ,loc_242
		EX	DE,HL	
		INC	HL
		LD 	(HL),3
		INC	HL
		LD 	(HL),1
		LD 	a,b
		CP	10h
		JP	C,loc_238
		LD 	(HL),0
loc_238:	POP	HL
		LD	A,(tr_level)
		OR	a
		JP	Z,loc_244
		LD	(dmp_from),HL
		LD	DE,11
		ADD	HL,DE
		LD	(dmp_to),HL
		call	dump_mem
		call	crlf
loc_244:	XOR	a
		JP	loc_245

;----------------------------------------------------------------------

loc_236:
		LD 	a,4
		call	next_arg	; get word pointed by pgm_de
loc_245:	LD	HL,(pgm_de)
		call	store_word
		JP	idos_exit

idos_exit:	call	sub_27
		call	setup_40h
		LD	HL,(pgm_sp)
		LD	SP,HL	
		ret	

;----------------------------------------------------------------------

		DEFW	0,0,0,0,0,0,0,0
		DEFW	0,0,0,0,0,0,0,0
		DEFW	0,0,0,0,0,0,0,0

stack  =  $ 

save_40:	DEFM	0,0,0		; save here the original contents of the jmp vector at 0040H

submit:		DEFM	0		; submit file present flag

subfcb:		DEFM	0
		DEFM	"$$$     SUB"
		DEFM	0
		DEFM	0
submod:		DEFM	0  
subrc:		DEFM	0
		DEFM	0,0,0,0		; ds 16 (fcb block map)
		DEFM	0,0,0,0
		DEFM	0,0,0,0
		DEFM	0,0,0,0
subcr:		DEFM	0

comfcb:		DEFM	0,0,0,0,0
		DEFM	0,0,0,0,0
		DEFM	0,0,0,0,0
		DEFM	0,0,0,0,0
		DEFM	0,0,0,0,0
		DEFM	0,0,0,0,0
		DEFM	0,0
comrec:		DEFM	0		; comfcb rc byte
comrnd:		DEFW	0		; comfcb r0,r1,r2
		DEFM	0

rbuff:		DEFM	126
buflen:		DEFM	0
combuf:		DEFM	126,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7Eh,0,0,0
		DEFM	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		DEFM	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		DEFM	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		DEFM	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		DEFM	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

comaddr:	DEFW	0
staddr:		DEFW	0
byte_23:	DEFM	0
byte_62:	DEFM	0
word_24:	DEFW	0,0,0,0,0
dmp_from:	DEFW	0
dmp_to:		DEFW	0
word_15:	DEFW	0
word_17:	DEFW	0
i_dcnt:		DEFM	0		; bdos return code
cur_disk:	DEFM	0		; current disk
sdisk:		DEFM	0		; disk code, for cli means that disk was
					; explicitely specified on command line
bptr:		DEFW	0		; buffer pointer
save_sp:	DEFW	0		; saved SP for some r/w routines
word_55:	DEFW	0
word_50:	DEFW	0
pgm_sp:		DEFW	0
pgm_de:		DEFW	0
pgm_c:		DEFM	0
old_iobyte:	DEFM	0
byte_70:	DEFM	0
fileno:		DEFM	0		; current fileno value, or fileno_ptr (fn_open)
seek_mode:	DEFM	0		; seek mode or hi(fileno_ptr)
fd_tab:		DEFM	0,0,0,0,0,0,0,0
byte_109:	DEFM	0,0,0,0,0,0,0,0
word_141:	DEFW	0,0,0,0,0,0,0,0
unk_122:	DEFM	0  
unk_170:	DEFM	0  
unk_116:	DEFM	0  

unk_119:	DEFS	128

word_81:	DEFW	0
word_65:	DEFW	0
word_67:	DEFW	0
fd_ptr:		DEFW	0		; pointer to fd (fcb)
word_105:	DEFW	0
word_168:	DEFW	0
byte_143:	DEFM	0
byte_146:	DEFM	0
byte_145:	DEFM	0
byte_103:	DEFM	0
word_111:	DEFW	0
		DEFM	0  
byte_82:	DEFM	0
		DEFM	0  
		DEFM	0  
		DEFM	0  
num_recs:	DEFW	0
lrec_bcnt:	DEFM	0		; last record byte count
word_193:	DEFW	0
word_195:	DEFW	0
word_194:	DEFW	0
word_196:	DEFW	0
byte_192:	DEFM	0
f_dscrptrs:	DEFM	0		; space for 6 file desciptors of 40 bytes each
					; = 240 (F0H) bytes total, this overwrites main
					; which is not longer needed.
		DEFM	0  
		DEFM	0  
		DEFM	0  

;----------------------------------------------------------------------

main:
		LD	HL,(wboot+1)
		DEC	HL
		DEC	HL
		DEC	HL		; HL = base of BIOS
		LD	DE,0F700h
		LD 	a,l
		sub	e
		LD 	a,h
		SBC	d		; BIOS base > F700 ?
		JP	C,main1		; yes -> main1
		PUSH	HL
		LD	HL,3
		ADD	HL,DE
		LD	(wboot+1),HL
		POP	HL
		LD 	c,33h
biosv_move:	LD 	a,(HL)
		LD	(DE),A
		INC	HL
		INC	DE
		DEC	c
		JP	NZ,biosv_move
main1:		LD	BC,80h
		LD	HL,loc_57	; 3100H
		LD	DE,0F800h
mdsv_move:	LD 	a,c
		OR	b
		JP	Z,isx_start
		DEC	BC
		LD 	a,(HL)
		LD	(DE),A
		INC	HL
		INC	DE
		JP	mdsv_move

;----------------------------------------------------------------------

;		ds	199

;----------------------------------------------------------------------

		org	3100h

loc_57:
		JP	0F826h		; F800 - error
		JP	0F829h		; F803 - console input
		JP	0F82Fh		; F806 - error
		JP	0F832h		; F809 - console output
		JP	0F838h		; F80C - punch output
		JP	0F83Eh		; F80F - list output
		JP	0F844h		; F812 - console status
		JP	0F84Ah		; F815 - get i/o byte
		JP	0F84Fh		; F818 - set i/o byte
		JP	0F854h		; F81B - get mem top
		JP	0F85Bh		; F81E - error
		JP	0F85Eh		; F821 - error

;----------------------------------------------------------------------

		DEFM	0  
		DEFM	0  

;----------------------------------------------------------------------

;0F826h:				; error
		JP	0F86Ah

;0F829h:				; console input
		LD	HL,6
		JP	0F878h

;0F82Fh:				; error
		JP	0F86Ah

;0F832h:				; console output
		LD	HL,9
		JP	0F878h

;0F838h:				; punch output
		LD	HL,0Fh
		JP	0F878h

;0F83Eh:				; list output
		LD	HL,0Ch
		JP	0F878h

;0F844h:				; console status
		LD	HL,3
		JP	0F878h

;0F84Ah:				; get I/O byte
		LD	HL,3
		LD 	(HL),c
		ret	

;0F84Fh:				; set I/O byte
		LD	HL,3
		LD 	a,(HL)
		ret	

;0F854h:				; get mem top
		LD	HL,(bdos+1)		; 0006H
		DEC	HL
		LD 	a,l
		LD 	b,h
		ret	

;0F85Bh:				; error
		JP	0F86Ah

;0F85Eh:				; error
		JP	0F86Ah

;0F861h:
		LD	HL,(word_3)		; 0107H
		LD 	a,l
		OR	h
		JP	Z,0F86Ah
		rst	38h
;0F86Ah:
		LD 	c,0Ch		; isis error
		LD	DE,0F872h
		JP	vec_40		; 0040H

;0F872h:
		DEFW	255
		DEFW	0F876h
;0F876h:
		DEFW	0

;0F878h:
		EX	DE,HL	
		LD	HL,(wboot+1)
		ADD	HL,DE
		JP	(HL)	

;----------------------------------------------------------------------

		DEFM	0  
		DEFM	0  
		DEFM	0  

		end	start
