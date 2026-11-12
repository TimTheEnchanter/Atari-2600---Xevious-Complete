; Xevious (Atari 2600) - completion project, 16K F6 (no extra RAM).
; Banks 2-3 hold the original 1-18-84 prototype by Tod Frye (old banks 0/1).
; On F6, the old hotspots $FFF8/$FFF9 select banks 2/3, so the original code
; runs unchanged; fixes are applied as named patches (tools/patches.py).
; Banks 0-1 are new space, reached through far-call slots.
	processor 6502
	include equates.asm
SEL0	= $FFF6
SEL1	= $FFF7
SEL2	= $FFF8		; original bank 0
SEL3	= $FFF9		; original bank 1

	MAC BANKHEADER	; power-up may start in any bank: go to bank 2 ($F003)
	STA SEL2
	ENDM

	include bank0.asm
	include bank1.asm
	include bank2_orig0.asm
	include bank3_orig1.asm
