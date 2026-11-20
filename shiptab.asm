; ship / explosion row tables, overlaid into bank 1 at $B960 (free, one page)
	processor 6502
	ORG $B960
SFLG	.byte $80,$00,$00,$40,$80,$00,$00,$40,$80,$00,$00,$40,$80,$00,$00,$40,$80,$00,$00,$40
SRA	.byte $00,$24,$FF,$3C,$00,$00,$18,$24,$00,$42,$99,$24,$00,$81,$42,$00,$00,$00,$00,$00
SRB	.byte $00,$BD,$5A,$18,$00,$24,$18,$00,$00,$24,$99,$42,$00,$00,$42,$81,$00,$00,$00,$00
; per-row P1 colour, same index as above (M5): Solvalou grey, then the explosion
; burns yellow -> orange -> red
SCOL	.byte $08,$08,$08,$08, $1C,$1E,$1E,$0E, $2A,$2C,$2C,$1E, $42,$44,$36,$2C, $00,$00,$00,$00
