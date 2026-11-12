;======================================================================
; BANK 0 (new code)
;======================================================================
	SEG bank0
	ORG $0000
	RORG $F000
	BANKHEADER

;----------------------------------------------------------------------
; Andor Genesis: frame table entries are low bytes in page $BE, but the
; last core frame lives at $BF0B. In: A = low byte. Out: $F0 = page.
AndorPage SUBROUTINE
	LDX    #$BE
	CMP    #$20
	BCS    .ok
	INX
.ok	STX    $F0
	JMP    FARRET0

;----------------------------------------------------------------------
; far-call landing pads (must line up with bank 2's slots at $FFE5..)
	ORG $0FE2
	RORG $FFE2
FARRET0	STA    SEL2                  ; -> bank 2 continues at $FFE5 (RTS)
	.byte  $00                   ; FFE5 (bank 2's RTS)
	.byte  $00,$00,$00           ; FFE6 (bank 2's STA SEL0)
	JMP    AndorPage             ; FFE9 = FAR_ANDORPAGE+3
	JMP    FARRET0               ; FFEC = FAR_1+3 (unused)
	JMP    FARRET0               ; FFEF = FAR_2+3 (unused)
	.byte  0,0,0                 ; FFF2 (bank 1 landing, not bank 0)
	ORG $0FFC
	RORG $FFFC
	.word $F000,$F000
