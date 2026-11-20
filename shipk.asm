; Solid P1 ship band for the bank 1 kernel (overlaid into bank 1 $BD00-$BEE6).
; L0 chain ($D9/$DA): during the ship span $DA=$BD, so Tod's low-byte targets
; $02/$25/$2E/$34/$3A/$7B land on ship-aware twins here. L2 chain ($DB/$DC) uses page $BE.
; RAM: $E7 next L1 ship row, $E8 fine HM (then pre-latch), $E9 coarse/hide (then row count).
	processor 6502
SFLG=$B960
SRA=$B974
SRB=$B988
SCOL=$B99C
COLUP1=$07
WSYNC=$02
HMOVE=$2A
GRP1=$1C
ENAM0=$1D
HMP1=$21
RESP1=$11
COLUPF=$08
NUSIZ1=$05
CXPPMM=$37
R0=%00011000
R1=%00111100
R2=%01111110
R3=%11011011
R4=%11111111
R5=%01000010

	ORG $BD00
	.byte 0,0
SB302	DEC $9F			; Tod's B302 minus the object start (objects in the span are skipped)
	LDY $F8
	LDX $B0F4,Y
	LDA $B7,X
	CMP $E5
	BNE SB302_s
	STX $F8
SB302_s	INC $E4
	LDA #$25
	JMP SPANTAIL
	ORG $BD25
SB325	INC $E4
	LDA #$7B
	JMP SPANTAIL
	ORG $BD2E
	JMP SB32EB
	ORG $BD34
	JMP SB334B
	ORG $BD3A
	JMP SB325
SPANTAIL			; A = next $D9 (HMP1 left alone: fine motion runs 4 lines)
	STA $D9
	LDA #0
	LDX $E7
	LDY $E5
	CPY $D4
	BNE SPANTAIL_nb
	LDA $F8
	STA $E1
	LDA #2
SPANTAIL_nb	STA WSYNC
	STA HMOVE
	STA ENAM0
	STX GRP1
	JMP ($00DD)
SB32EB	DEC $A1
	INC $E4
	LDA #$34
	JMP SPANTAIL
SB334B	DEC $A1
	INC $E4
	LDA #$7B
	JMP SPANTAIL
	ORG $BD7B
SL0	DEC $A1
	BMI SL0_row
	JMP SL0_col		; plain L0 line: ship row colour (M5), then Tod's tail
SL0_row	LDX #$02
	LDY $9F
	LDA ($A2),Y
	AND #$1F
	TAY
	LDA $BAC9,Y
	STA COLUPF
	LDA $BBC9,Y
	STA $A1
	LDA $BCC9,Y
	STA $E4
	STX $D9
	LDA #0
	LDY $E7
	STA WSYNC
	STA HMOVE
	STY GRP1
	STA ENAM0
	JMP ($00DD)

	ORG $BDB0
POSTK	LDX #3			; kernel exit: clear the ground objects ShipPre hid ($EA mask)
POSTK_l	LSR $EA
	BCC POSTK_n
	LDA $B7,X
	AND #$7F
	STA $B7,X
POSTK_n	DEX
	BPL POSTK_l
	JMP $F006		; Tod's exit: STA $FFF8 -> bank 2 $F009
	ORG $BDC4		; fixed entry (hooked from KB2A2)
SHIPDET	CPX #0			; from B2A2: X = shot/ship index, ship row reached
	BNE SHIPDET_shot
	BIT $E9
	BMI SHIPDET_hide
	LDA #<SHIPPOS
	STA $DB
	LDA #$BE
	STA $DC
	INC $E5
	LDX $F4
	LDA #0
	STA WSYNC
	STA HMOVE
	STA ENAM0
	STX GRP1
	JMP ($00DF)
SHIPDET_shot	LDA #$B0
	JMP $B2C2
SHIPDET_hide	LDA $E8
	JMP $B2C2

	ECHO "BD page end:", *
	ORG $BDF0
SL0_col	INC $E4			; @26: per-row ship colour from SCOL[$E9] (COLUP1 is shared with
	LDY $E9			; the ground objects, so ROW5 restores Tod's grey after the band)
	LDA SCOL,Y
	STA COLUP1		; @36
	LDA #$7B
	JMP SPANTAIL		; SPANTAIL's WSYNC lands by cycle 68

	ORG $BE00
SHIPPOS	STA RESP1		; @28; coarse 0-3 in $E8 bits 0-1 (fine in bits 4-7)
	LDA $E8
	AND #3
	TAX
	BEQ SHIPPOS_d
	STA RESP1
	DEX
	BEQ SHIPPOS_d
	STA RESP1
	DEX
	BEQ SHIPPOS_d
	STA RESP1
	DEX
SHIPPOS_d	LDA #$20		; P1 single width for the ship rows (missile width kept)
	STA NUSIZ1
	LDA #<ROW1
	STA $DB
	STA WSYNC		; ($E5 is incremented twice in ROW1)
	STX HMOVE
	STX ENAM0
	STX GRP1
	JMP ($00DF)
ROW1	LDA $E8
	STA HMP1		; fine motion: applied L3,L0,L1,L2
	LDA CXPPMM
	STA $E8			; pre-band P0/P1 latch (no ship pixels drawn yet)
	LDA #$BD
	STA $DA
	LDA #<ROWT
	STA $DB
	INC $E5
	INC $E5
	LDX #0
	STX $E7
	TXA
	STA WSYNC
	STA HMOVE
	STA ENAM0
	STX GRP1
	JMP ($00DF)
ROWT	LDY $E9			; row index set by ShipPre (frame*4+3)
	LDA SFLG,Y
	BMI ROW5
	BEQ ROWT_c
	LDA #0
	STA HMP1		; first row: stop fine motion
	JMP ROWT_r
ROWT_c	LDA $0284		; INTIM: Tod's end-of-kernel test
	CMP #9
	BCC KEND
ROWT_r	LDX SRB,Y
	LDA SRA,Y
	STA $E7
	DEC $E9
L2TAIL	INC $E5
	LDA #0
	STA WSYNC
	STA HMOVE
	STA ENAM0
	STX GRP1
	JMP ($00DF)
KEND	JMP $B251		; timer ran out inside the ship span: end the kernel like B28A
				; ($DA/$DC are reset by the pre-kernel each frame)
ROW5	LDA $0284
	CMP #9
	BCC KEND
	LDA #$25
	STA NUSIZ1		; back to Tod's double-width ground objects
	LDA #$08
	STA COLUP1		; and Tod's ground-object grey (M5)
	LDA #$B3
	STA $DA
	LDA #<ROW6
	STA $DB
	INC $E5			; L2TAIL inlined: saves the JMP and LDX #0 (5 cycles),
	LDA #0			; paying for the COLUP1 restore. Worst case is Tod's again
	STA WSYNC		; (store done by cycle 73 on the latest entry).
	STA HMOVE
	STA ENAM0
	STA GRP1
	JMP ($00DF)
ROW6	BIT CXPPMM
	BPL ROW6_n
	BIT $E8
	BMI ROW6_n
	LDA $F7
	ORA #$80
	STA $E3			; ship hit: bit7 + enemy lane
ROW6_n	LDA $0284
	CMP #9
	BCC KEND
	LDA #$B2
	STA $DC
	LDA #$8A
	STA $DB
	LDX #0
	JMP L2TAIL
