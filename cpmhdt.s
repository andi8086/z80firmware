.org 0F000h
;*****************************************************
;*                                                   *
;*      SECTOR DEBLOCKING ALGORITHMS FOR CP/M 2.0    *
;*                                                   *
;*****************************************************
;
;       UTILITY MACRO TO COMPUTE SECTOR MASK
SMASK   .MACRO   HBLK
;;      COMPUTE LOG2(HBLK), RETURN @X AS RESULT
;;      (2 ** @X = HBLK ON RETURN)
SMASK_Y DEFL    HBLK
SMASK_X DEFL    0
;;      COUNT RIGHT SHIFTS OF @Y UNTIL = 1
        .REPT    8
        .IF      SMASK_Y = 1
        .EXITM
        .ENDIF
;;      @Y IS NOT 1, SHIFT RIGHT ONE POSITION
SMASK_Y DEFL    SMASK_Y SHR 1
SMASK_X DEFL    SMASK_X + 1
        .ENDM
;
;*****************************************************
;*                                                   *
;*         CP/M TO HOST DISK CONSTANTS               *
;*                                                   *
;*****************************************************
BLKSIZ   DEFL 2048 ;CP/M ALLOCATION SIZE</a>
HSTSIZ   DEFL  512 ;HOST DISK SECTOR SIZE
HSTSPT   DEFL   16 ;HOST DISK SECTORS/TRK
HSTBLK   DEFL  HSTSIZ/128 ;CP/M SECTS/HOST BUFF
CPMSPT   DEFL  HSTBLK*HSTSPT ;CP/M SECTORS/TRACK
SECMSK   DEFL  HSTBLK-1 ;SECTOR MASK
;	SMASK   HSTBLK          ;COMPUTE SECTOR MASK
;SECSHF   DEFL  SMASK_X ;LOG2(HSTBLK)
SECSHF	EQU	2	; LOG2(4) = 2
;
;*****************************************************
;*                                                   *
;*        BDOS CONSTANTS ON ENTRY TO WRITE           *
;*                                                   *
;*****************************************************
WRALL  DEFL  0 ;WRITE TO ALLOCATED
WRDIR  DEFL  1 ;WRITE TO DIRECTORY
WRUAL  DEFL  2 ;WRITE TO UNALLOCATED
;
;*****************************************************
;*                                                   *
;*      THE BDOS ENTRY POINTS GIVEN BELOW SHOW THE   *
;*      CODE WHICH IS RELEVANT TO DEBLOCKING ONLY.   *
;*                                                   *
;*****************************************************
;
;       DISKDEF MACRO, OR HAND CODED TABLES GO HERE
DPBASE  =  $ ;DISK PARAM BLOCK BASE
;
WBOOT:
        ;ENTER HERE ON SYSTEM BOOT TO INITIALIZE
        XOR     A               ;0 TO ACCUMULATOR
        LD     (HSTACT),A          ;HOST BUFFER INACTIVE
        LD     (UNACNT),A          ;CLEAR UNALLOC COUNT
        RET
;
        ;HOME THE SELECTED DISK
HOME:
        LD     A,(HSTWRT)  ;CHECK FOR PENDING WRITE
        OR     A
        JP	NZ,HOMED
        LD     (HSTACT),A  ;CLEAR HOST ACTIVE FLAG
HOMED:
        RET
;
SELDSK:
        ;SELECT DISK
        LD      A,C             ;SELECTED DISK NUMBER
        LD     (SEKDSK),A          ;SEEK DISK NUMBER
        LD      L,A             ;DISK NUMBER TO HL
        LD      H,0
        ADD	HL,HL
        ADD	HL,HL
        ADD	HL,HL
        ADD	HL,HL
        LD     DE,DPBASE        ;BASE OF PARM BLOCK
        ADD	HL,DE               ;HL=.DPB(CURDSK)
        RET
;
SETTRK:
        ;SET TRACK GIVEN BY REGISTERS BC
        LD      H,B
        LD      L,C
        LD    (SEKTRK),HL          ;TRACK TO SEEK
        RET
;
SETSEC:
        ;SET SECTOR GIVEN BY REGISTER C
        LD      A,C
        LD     (SEKSEC),A          ;SECTOR TO SEEK
        RET
;
SETDMA:
        ;SET DMA ADDRESS GIVEN BY BC
        LD      H,B
        LD      L,C
        LD    (DMAADR),HL
        RET
;
SECTRAN:
        ;TRANSLATE SECTOR NUMBER BC
        LD      H,B
        LD      L,C
        RET
;
;*****************************************************
;*                                                   *
;*      THE READ ENTRY POINT TAKES THE PLACE OF      *
;*      THE PREVIOUS BIOS DEFINTION FOR READ.        *
;*                                                   *
;*****************************************************
READ:
        ;READ THE SELECTED CP/M SECTOR
        XOR     A
        LD     (UNACNT),A
        LD      A,1
        LD     (READOP),A          ;READ OPERATION
        LD     (RSFLAG),A          ;MUST READ DATA
        LD      A,WRUAL
        LD     (WRTYPE),A          ;TREAT AS UNALLOC
        JP     RWOPER          ;TO PERFORM THE READ
;
;*****************************************************
;*                                                   *
;*      THE WRITE ENTRY POINT TAKES THE PLACE OF     *
;*      THE PREVIOUS BIOS DEFINTION FOR WRITE.       *
;*                                                   *
;*****************************************************
WRITE:
        ;WRITE THE SELECTED CP/M SECTOR
        XOR     A               ;0 TO ACCUMULATOR
        LD     (READOP),A          ;NOT A READ OPERATION
        LD      A,C             ;WRITE TYPE IN C
        LD     (WRTYPE),A
        CP     WRUAL           ;WRITE UNALLOCATED?
        JP	NZ,CHKUNA          ;CHECK FOR UNALLOC
;
;       WRITE TO UNALLOCATED, SET PARAMETERS
        LD      A,BLKSIZ/128    ;NEXT UNALLOC RECS
        LD     (UNACNT),A
        LD     A,(SEKDSK)          ;DISK TO SEEK
        LD     (UNADSK),A          ;UNADSK = SEKDSK
        LD    HL,(SEKTRK)
        LD    (UNATRK),HL          ;UNATRK = SECTRK
        LD     A,(SEKSEC)
        LD     (UNASEC),A          ;UNASEC = SEKSEC
;
CHKUNA:
        ;CHECK FOR WRITE TO UNALLOCATED SECTOR
        LD     A,(UNACNT)          ;ANY UNALLOC REMAIN?
        OR     A
        JP	Z,ALLOC           ;SKIP IF NOT
;
;       MORE UNALLOCATED RECORDS REMAIN
        DEC     A               ;UNACNT = UNACNT-1
        LD     (UNACNT),A
        LD     A,(SEKDSK)          ;SAME DISK?
        LD     HL,UNADSK
        CP     (HL)               ;SEKDSK = UNADSK?
        JP	NZ,ALLOC           ;SKIP IF NOT
;
;       DISKS ARE THE SAME
        LD     HL,UNATRK
        CALL    SEKTRKCMP       ;SEKTRK = UNATRK?
        JP	NZ,ALLOC           ;SKIP IF NOT
;
;       TRACKS ARE THE SAME
        LD     A,(SEKSEC)          ;SAME SECTOR?
        LD     HL,UNASEC
        CP     (HL)               ;SEKSEC = UNASEC?
        JP	NZ,ALLOC           ;SKIP IF NOT
;
;       MATCH, MOVE TO NEXT SECTOR FOR FUTURE REF
        INC     (HL)               ;UNASEC = UNASEC+1
        LD      A,(HL)             ;END OF TRACK?
        CP     CPMSPT          ;COUNT CP/M SECTORS
        JP	C,NOOVF           ;SKIP IF NO OVERFLOW
;
;       OVERFLOW TO NEXT TRACK
        LD      (HL),0             ;UNASEC = 0
        LD    HL,(UNATRK)
        INC     HL
        LD    (UNATRK),HL          ;UNATRK = UNATRK+1
;
NOOVF:
        ;MATCH FOUND, MARK AS UNNECESSARY READ
        XOR     A               ;0 TO ACCUMULATOR
        LD     (RSFLAG),A          ;RSFLAG = 0
        JP     RWOPER          ;TO PERFORM THE WRITE
;
ALLOC:
        ;NOT AN UNALLOCATED RECORD, REQUIRES PRE-READ
        XOR     A               ;0 TO ACCUM
        LD     (UNACNT),A          ;UNACNT = 0
        INC     A               ;1 TO ACCUM
        LD     (RSFLAG),A          ;RSFLAG = 1
;
;*****************************************************
;*                                                   *
;*      COMMON CODE FOR READ AND WRITE FOLLOWS       *
;*                                                   *
;*****************************************************
RWOPER:
        ;ENTER HERE TO PERFORM THE READ/WRITE
        XOR     A               ;ZERO TO ACCUM
        LD     (ERFLAG),A          ;NO ERRORS (YET)
        LD     A,(SEKSEC)          ;COMPUTE HOST SECTOR
	.REPT    SECSHF
        OR     A               ;CARRY = 0
        RRA                     ;SHIFT RIGHT
        .ENDM
        LD     (SEKHST),A          ;HOST SECTOR TO SEEK
;
;       ACTIVE HOST SECTOR?
        LD     HL,HSTACT        ;HOST ACTIVE FLAG
        LD      A,(HL)
        LD      (HL),1             ;ALWAYS BECOMES 1
        OR     A               ;WAS IT ALREADY?
        JP	Z,FILHST          ;FILL HOST IF NOT
;
;       HOST BUFFER ACTIVE, SAME AS SEEK BUFFER?
        LD     A,(SEKDSK)
        LD     HL,HSTDSK        ;SAME DISK?
        CP     (HL)               ;SEKDSK = HSTDSK?
        JP	NZ,NOMATCH
;
;       SAME DISK, SAME TRACK?
        LD     HL,HSTTRK
        CALL    SEKTRKCMP       ;SEKTRK = HSTTRK?
        JP	NZ,NOMATCH
;
;       SAME DISK, SAME TRACK, SAME BUFFER?
        LD     A,(SEKHST)
        LD     HL,HSTSEC        ;SEKHST = HSTSEC?
        CP     (HL)
        JP	Z,MATCH           ;SKIP IF MATCH
;
NOMATCH:
        ;PROPER DISK, BUT NOT CORRECT SECTOR
        LD     A,(HSTWRT)          ;HOST WRITTEN?
        OR     A
        CALL	NZ,WRITEHST        ;CLEAR HOST BUFF
;
FILHST:
        ;MAY HAVE TO FILL THE HOST BUFFER
        LD     A,(SEKDSK)
        LD     (HSTDSK),A
        LD    HL,(SEKTRK)
        LD    (HSTTRK),HL
        LD     A,(SEKHST)
        LD     (HSTSEC),A
        LD     A,(RSFLAG)          ;NEED TO READ?
        OR     A
        CALL	NZ,READHST         ;YES, IF 1
        XOR     A               ;0 TO ACCUM
        LD     (HSTWRT),A          ;NO PENDING WRITE
;
MATCH:
        ;COPY DATA TO OR FROM BUFFER
        LD     A,(SEKSEC)          ;MASK BUFFER NUMBER
        AND     SECMSK          ;LEAST SIGNIF BITS
        LD      L,A             ;READY TO SHIFT
        LD      H,0             ;DOUBLE COUNT
        REPT    7               ;SHIFT LEFT 7
        ADD	HL,HL
        ENDM
        ADD	HL,HL
        ADD	HL,HL
        ADD	HL,HL
        ADD	HL,HL
        ADD	HL,HL
        ADD	HL,HL
        ADD	HL,HL
;       HL HAS RELATIVE HOST BUFFER ADDRESS
        LD     DE,HSTBUF
        ADD	HL,DE               ;HL = HOST ADDRESS
        EX	DE,HL                    ;NOW IN DE
        LD    HL,(DMAADR)          ;GET/PUT CP/M DATA
        LD      C,128           ;LENGTH OF MOVE
        LD     A,(READOP)          ;WHICH WAY?
        OR     A
        JP	NZ,RWMOVE          ;SKIP IF READ
;
;       WRITE OPERATION, MARK AND SWITCH DIRECTION
        LD      A,1
        LD     (HSTWRT),A          ;HSTWRT = 1
        EX	DE,HL                    ;SOURCE/DEST SWAP
;
RWMOVE:
        ;C INITIALLY 128, DE IS SOURCE, HL IS DEST
        LD    A,(DE)               ;SOURCE CHARACTER
        INC     DE
        LD      (HL),A             ;TO DEST
        INC     HL
        DEC     C               ;LOOP 128 TIMES
        JP	NZ,RWMOVE
;
;       DATA HAS BEEN MOVED TO/FROM HOST BUFFER
        LD     A,(WRTYPE)          ;WRITE TYPE
        CP     WRDIR           ;TO DIRECTORY?
        LD     A,(ERFLAG)          ;IN CASE OF ERRORS
        RET	NZ                     ;NO FURTHER PROCESSING
;
;       CLEAR HOST BUFFER FOR DIRECTORY WRITE
        OR     A               ;ERRORS?
        RET	NZ                     ;SKIP IF SO
        XOR     A               ;0 TO ACCUM
        LD     (HSTWRT),A          ;BUFFER WRITTEN
        CALL    WRITEHST
        LD     A,(ERFLAG)
        RET
;
;*****************************************************
;*                                                   *
;*      UTILITY SUBROUTINE FOR 16-BIT COMPARE        *
;*                                                   *
;*****************************************************
SEKTRKCMP:
        ;HL = .UNATRK OR .HSTTRK, COMPARE WITH SEKTRK
        EX	DE,HL
        LD     HL,SEKTRK
        LD    A,(DE)               ;LOW BYTE COMPARE
        CP     (HL)               ;SAME?
        RET	NZ                     ;RETURN IF NOT
;       LOW BYTES EQUAL, TEST HIGH 1S
        INC     DE
        INC     HL
        LD    A,(DE)
        CP     (HL)       ;SETS FLAGS
        RET
;
;*****************************************************
;*                                                   *
;*      WRITEHST PERFORMS THE PHYSICAL WRITE TO      *
;*      THE HOST DISK, READHST READS THE PHYSICAL    *
;*      DISK.                                        *
;*                                                   *
;*****************************************************
WRITEHST:
        ;HSTDSK = HOST DISK #, HSTTRK = HOST TRACK #,
        ;HSTSEC = HOST SECT #. WRITE "HSTSIZ" BYTES
        ;FROM HSTBUF AND RETURN ERROR FLAG IN ERFLAG.
        ;RETURN ERFLAG NON-ZERO IF ERROR
        RET
;
READHST:
        ;HSTDSK = HOST DISK #, HSTTRK = HOST TRACK #,
        ;HSTSEC = HOST SECT #. READ "HSTSIZ" BYTES
        ;INTO HSTBUF AND RETURN ERROR FLAG IN ERFLAG.
        RET
;
;*****************************************************
;*                                                   *
;*      UNITIALIZED RAM DATA AREAS                   *
;*                                                   *
;*****************************************************
;
SEKDSK: DEFS      1               ;SEEK DISK NUMBER
SEKTRK: DEFS      2               ;SEEK TRACK NUMBER
SEKSEC: DEFS      1               ;SEEK SECTOR NUMBER
;
HSTDSK: DEFS      1               ;HOST DISK NUMBER
HSTTRK: DEFS      2               ;HOST TRACK NUMBER
HSTSEC: DEFS      1               ;HOST SECTOR NUMBER
;
SEKHST: DEFS      1               ;SEEK SHR SECSHF
HSTACT: DEFS      1               ;HOST ACTIVE FLAG
HSTWRT: DEFS      1               ;HOST WRITTEN FLAG
;
UNACNT: DEFS      1               ;UNALLOC REC CNT
UNADSK: DEFS      1               ;LAST UNALLOC DISK
UNATRK: DEFS      2               ;LAST UNALLOC TRACK
UNASEC: DEFS      1               ;LAST UNALLOC SECTOR
;
ERFLAG: DEFS      1               ;ERROR REPORTING
RSFLAG: DEFS      1               ;READ SECTOR FLAG
READOP: DEFS      1               ;1 IF READ OPERATION
WRTYPE: DEFS      1               ;WRITE OPERATION TYPE
DMAADR: DEFS      2               ;LAST DMA ADDRESS
HSTBUF: DEFS      HSTSIZ          ;HOST BUFFER
;
;*****************************************************
;*                                                   *
;*      THE ENDEF MACRO INVOCATION GOES HERE         *
;*                                                   *
;*****************************************************
        END
