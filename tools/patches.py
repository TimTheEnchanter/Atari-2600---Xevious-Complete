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

patch('air loop in bank 0','bank2_orig0.asm',
"""LF3D0
	LDA    #$03                  ; F3D0
	STA    $EB                   ; F3D2
	LDX    $A6                   ; F3D4
""","""; M4b: the 4-lane air-enemy loop now runs in bank 0 (AirLoop, air.asm) with
; distinct per-family behaviour. Tod's loop body below is no longer reached.
LF3D0
	JSR    FAR_2                 ; F3D0  bank 0 AirLoop (FAR_2 dispatch by return address)
	JMP    LF403                 ; F3D3
""")

patch('robust vblank wait (hook)','bank2_orig0.asm',
"""LF09E
	LDA    INTIM                 ; F09E
	BNE    LF09E                 ; F0A1
	LDA    #$E1                  ; F0A3
""","""LF09E
	JMP    VBWait                ; F09E  FIX: see VBWait
	NOP
	NOP
	LDA    #$E1                  ; F0A3
""")
patch('robust vblank wait','bank2_orig0.asm',
"""	DS.B   $F98F-$F96F, $00      ; freed: F96F-F98E
""","""; FIX: end-of-logic wait. Tod's LDA INTIM/BNE loop missed an already expired
; timer (rare heavy ticks) and then spun until INTIM wrapped, stretching the
; frame by 14-21 lines. INTIM reads $FF.. downward after expiry, so also stop
; on a negative value.
VBWait
	LDA    INTIM
	BEQ    .d
	BPL    VBWait
.d	JMP    $F0A3
	DS.B   $F98F-., $00          ; free
""")

patch('title hooks: TitleGo + demo check (dead air-loop body)','bank2_orig0.asm',
'LF3D6\n\tJSR    LFBDE                 ; F3D6\n\tLDY    $A7,X                 ; F3D9\n\tLDA    DFAD7,Y               ; F3DB\n\tSTA    $A7,X                 ; F3DE\nLF3E0\n\tLDA    DFA71,X               ; F3E0\n\tTAX                          ; F3E3\n\tLDA    $A7,X                 ; F3E4\n\tTAY                          ; F3E6\n\tLDA    #$04                  ; F3E7\n\tSTA    $E7                   ; F3E9\n\tLDA    DFA8D,Y               ; F3EB\n\tLSR                          ; F3EE\n\tBCC    LF3F3                 ; F3EF\n\tASL    $E7                   ; F3F1\nLF3F3\n\tLDA    $E7                   ; F3F3\n\tCLC                          ; F3F5\n\tADC    $A5                   ; F3F6\n\tCLC                          ; F3F8\n\tADC    #$04                  ; F3F9\n\tSTA    $A5                   ; F3FB\n\tDEC    $EB                   ; F3FD\n\tBPL    LF3D6                 ; F3FF\n\tSTX    $A6                   ; F401\n',"""; M5: Tod's air-loop body here is dead since M4b (AirLoop runs in bank 0).
; The space now holds the title-screen hooks.
LF3D6
LF3E0				; (still referenced by the dead $FBE3 handlers)
TitleGo				; power-on, game over and demo -> bank 0 Title
	JSR    FAR_2                 ; returns A=0 demo (RAM set up) / A=1 game
	BNE    .g
	JMP    LF8FA                 ; demo: Tod's object/frame init
.g	JMP    LF8D7                 ; game: Tod's new-game init
AttrChk				; demo frame (from $F111): back to the title on
	LDA    $81                   ; ~30 s of demo, Fire, or Select
	CMP    #DEMOT
	BCS    TitleGo
	BIT    $3C
	BPL    TitleGo
	LDA    $92
	BNE    TitleGo
	JMP    LF627                 ; Tod's demo frame
DEMOT	= 6
	DS.B   $F403-., $00          ; free
""")

patch('title hook: power-on','bank2_orig0.asm',
"""	LDA    #$80                  ; F033
	STA    $91                   ; F035
	LDA    #$04                  ; F037
	STA    $9E                   ; F039
	JMP    LF8F5                 ; F03B
""","""	LDA    #$02                  ; F033  M5: power-on -> title (short timer for its first wait)
	STA    TIM64T                ; F035
	NOP
	NOP
	NOP
	JMP    TitleGo               ; F03B
""")

patch('title hook: game over','bank2_orig0.asm',
"""	LDA    #$00                  ; F697
	STA    $81                   ; F699
	LDA    #$80                  ; F69B
	STA    $80                   ; F69D
	STA    $91                   ; F69F
LF6A1
	JMP    LF8FA                 ; F6A1
""","""	JMP    TitleGo               ; F697  M5: game over -> title (it sets up the demo)
	DS.B   $F6A1-., $EA
LF6A1
	JMP    LF8FA                 ; F6A1
""")

patch('title hook: demo frame','bank2_orig0.asm',
"""	LDA    $81                   ; F111
	BEQ    LF120                 ; F113
	BIT    $3C                   ; F115
	BMI    LF120                 ; F117
	LDA    $A4                   ; F119
	STA    $87                   ; F11B
	JMP    LF8D7                 ; F11D
LF120
""","""	JMP    AttrChk               ; F111  M5: demo -> title on timeout/Fire/Select
	DS.B   $F120-., $EA          ; (Tod's Fire-to-continue moved to the title)
LF120
""")

patch('area start jingle (hook)','bank2_orig0.asm',
"""LF938
	INC    $87                   ; F938
	LDA    $87                   ; F93A
	AND    #$0F                  ; F93C
	STA    $87                   ; F93E
LF940
""","""LF938
	JMP    AreaUp                ; F938  M5: next area + fanfare (sound 10)
	DS.B   $F940-., $EA
LF940
""")
patch('area start jingle','bank2_orig0.asm',
"""	DS.B   $F98F-., $00          ; free
""","""AreaUp				; next area, with the area-start fanfare
	INC    $87
	LDA    $87
	AND    #$0F
	STA    $87
	LDY    #10
	JSR    $B018
	JMP    LF940
	DS.B   $F98F-., $00          ; free
""")
