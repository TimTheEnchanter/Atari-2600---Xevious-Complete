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
FAR_SCORE
	STA    SEL0                  ; FFE6
FAR_1
	STA    SEL0                  ; FFE9
FAR_2
	STA    SEL0                  ; FFEC
FAR_KERNEL
	STA    SEL1                  ; FFEF  -> bank 1 kernel (lands at $FFF2)
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

patch('run kernel from bank 1','bank2_orig0.asm',
"""	JMP    $B006                 ; F0C1
""","""	JMP    FAR_KERNEL            ; F0C1  M3: kernel now runs from bank 1
""")

patch('ship pre-kernel hook','bank2_orig0.asm',
"""	LDA    #$47                  ; F5AB
	STA    $DF                   ; F5AD
""","""	JSR    FAR_2                 ; F5AB  ship pre-kernel (bank 0 ShipPre; also does $DF=#$47)
	NOP                          ; F5AE
""")
patch('ship collision hook','bank2_orig0.asm',
"""	BIT    $31                   ; F70B
	BPL    LF770                 ; F70D
	LDX    $E2                   ; F70F
	LDA    $A7,X                 ; F711
	CMP    #$44                  ; F713
	BCS    LF770                 ; F715
	LDX    $E3                   ; F717
	BNE    LF73B                 ; F719
	LDA    $97                   ; F71B
""","""	JSR    FAR_1                 ; F70B  bank 0 Coll: C=1 none, else X=0 ship hit / X>0 shot
	BCS    LF770                 ; F70E
	TXA                          ; F710
	BNE    LF73B                 ; F711
	JMP    LF71B                 ; F713
	NOP
	NOP
	NOP
	NOP
	NOP
LF71B
	LDA    $97                   ; F71B
""")

patch('score add + arcade extra lives','bank2_orig0.asm',
"""LF964
	LSR                          ; F964
	LSR                          ; F965
	LSR                          ; F966
	LSR                          ; F967
	TAY                          ; F968
	LDA    $91                   ; F969
	BMI    LF98E                 ; F96B
	SED                          ; F96D
	CLC                          ; F96E
	LDA    $8A                   ; F96F
	ADC    DF94D,Y               ; F971
	STA    $8A                   ; F974
	LDA    $89                   ; F976
	ADC    DF958,Y               ; F978
	STA    $89                   ; F97B
	BCC    LF987                 ; F97D
	LDY    #$07                  ; F97F
	JSR    $B018                 ; F981
	INC    $85                   ; F984
	SEC                          ; F986
LF987
	LDA    $88                   ; F987
	ADC    #$00                  ; F989
	STA    $88                   ; F98B
	CLD                          ; F98D
LF98E
	RTS                          ; F98E
""","""; Score add moved to bank 0 (ScoreAdd): arcade extra lives at 20,000 then every 60,000
; (the prototype gave one every 10,000). C=1 on return -> play Tod's extra-life jingle.
LF964
	JSR    FAR_SCORE             ; F964
	BCC    LF98E
	LDY    #$07
	JSR    $B018
LF98E
	RTS
	DS.B   $F98F-$F96F, $00      ; freed: F96F-F98E
""")
