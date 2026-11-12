# Named source patches applied to the original banks (2 = old bank 0 @F000, 3 = old bank 1 @B000).
P=[]
def patch(name,f,old,new): P.append((name,f,old,new))

patch('fast-scroll ramp (bank 2)','bank2_orig0.asm',
"""	LDA    $82                   ; F0B6
	LSR                          ; F0B8
	LDA    #$03                  ; F0B9
	BCS    LF0BF                 ; F0BB
	LDA    #$02                  ; F0BD
LF0BF
	STA    $E7                   ; F0BF
	JMP    $B006                 ; F0C1
""","""; FIX(fast scroll): the kernel inserts 0-3 blank lines at the top of the screen
; as a fine-scroll ramp between 4-line coarse steps. The prototype used
; (tick>>1)&3 in slow mode (8 ticks/step, smooth) but (tick>>1)&2 in fast mode
; (4 ticks/step) -> 0,0,0,0 then 2,2,2,2 = 2/6-line jerks. Fast mode now uses
; tick&3. $E7 carries the pre-shifted tick; the kernel masks it with #3.
	LDA    $82                   ; bit0 set = slow scroll
	LSR
	LDA    $80                   ; frame tick
	BCC    .fast
	LSR
.fast
	STA    $E7
	NOP                          ; pad: keeps original layout
	JMP    $B006                 ; F0C1
""")
patch('fast-scroll ramp (kernel)','bank3_orig1.asm',
"""	LDA    $80                   ; B085
	LSR                          ; B087
	AND    $E7                   ; B088
	TAX                          ; B08A
""","""	LDA    $E7                   ; B085  FIX(fast scroll): pre-shifted tick
	AND    #$03                  ; B087
	TAX                          ; B089
	NOP                          ; B08A
""")
patch('Andor Genesis frame 5 page','bank2_orig0.asm',
"""	LDX    #$BE                  ; F440
	STX    $F0                   ; F442
""","""	JSR    FAR_ANDORPAGE         ; F440  FIX: core frame at $BF0B was read from $BE0B
	NOP                          ; F443
""")
patch('far-call slots (bank 2)','bank2_orig0.asm',
"""FREE_FFE5	; ---- unused space (19 bytes) ----
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00
""","""; ---- far-call slots into new bank 0 (see bank0.asm) ----
; JSR FAR_x here -> STA SEL0 switches to bank 0, which continues at FAR_x+3
; with JMP to the routine; it returns via FARRET0 (STA SEL2 at $FFE2), landing
; on the RTS at $FFE5 below.
	RTS                          ; FFE5  far-call return landing
FAR_ANDORPAGE
	STA    SEL0                  ; FFE6
FAR_1
	STA    SEL0                  ; FFE9
FAR_2
	STA    SEL0                  ; FFEC
FAR_3
	STA    SEL0                  ; FFEF
	.byte $00,$00,$00,$00,$00,$00 ; FFF2-FFF7 (FFF6/7 are F6 hotspots)
""")
patch('score table BCD','bank2_orig0.asm',
"""DF958
	.byte $00,$00,$00,$01,$01,$02,$03,$07
	.byte $08,$0A,$14,$4B
""","""DF958	; FIX: hundreds byte is BCD; prototype had decimal 10/20/75 typed as hex
	.byte $00,$00,$00,$01,$01,$02,$03,$07
	.byte $08,$10,$20,$75
""")
