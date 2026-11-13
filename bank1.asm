;======================================================================
; BANK 1  (new kernel bank; started as a copy of bank 3)
;======================================================================
	SEG bank1
	ORG $1000
	RORG $B000
	STA    $FFF8                 ; B000
	.byte $4C,$1C,$F0
KLB006
	STA    $FFF8                 ; B006
KLB009
	JMP    KLB01E                 ; B009
KLB00C
	STA    $FFF8                 ; B00C
KLB00F
	JMP    KLBD21                 ; B00F
KLB012
	STA    $FFF8                 ; B012
KLB015
	JMP    KLBF17                 ; B015
KLB018
	STA    $FFF8                 ; B018
KLB01B
	JMP    KLBD0A                 ; B01B
KLB01E
	LDA    $87                   ; B01E
	CLC                          ; B020
	ASL                          ; B021
	TAY                          ; B022
	LDA    KDB761,Y               ; B023
	STA    $A2                   ; B026
	LDA    KDB762,Y               ; B028
	STA    $A3                   ; B02B
	LDA    $9E                   ; B02D
	STA    $9F                   ; B02F
	LDY    $9F                   ; B031
	DEC    $9F                   ; B033
	LDA    ($A2),Y               ; B035
	AND    #$1F                  ; B037
	TAY                          ; B039
	LDA    KDBAC9,Y               ; B03A
	STA    COLUPF                ; B03D
	LDA    KDBCC9,Y               ; B03F
	CLC                          ; B042
	ADC    KDBBC9,Y               ; B043
	CLC                          ; B046
	ADC    #$02                  ; B047
	SEC                          ; B049
	SBC    $A0                   ; B04A
	STA    $E4                   ; B04C
	LDX    $F7                   ; B04E
	LDY    $A7,X                 ; B050
	LDX    KDB694,Y               ; B052
	LDA    KDB0FA,X               ; B055
	STA    NUSIZ0                ; B058
	LDA    $91                   ; B05A
	AND    #$02                  ; B05C
	BNE    KLB06E                 ; B05E
	LDX    $F8                   ; B060
	LDA    $B3,X                 ; B062
	AND    #$3F                  ; B064
	TAX                          ; B066
	LDA    KDB6DE,X               ; B067
	STA    $EF                   ; B06A
	STA    $F1                   ; B06C
KLB06E
	LDY    $E4                   ; B06E
	LDA    KDBA00,Y               ; B070
	STA    PF1                   ; B073
	LDA    KDBB00,Y               ; B075
	STA    PF2                   ; B078
	LDA    KDBC00,Y               ; B07A
	STA    COLUBK                ; B07D
	LDA    $A0                   ; B07F
	STA    $A1                   ; B081
	STA    WSYNC                 ; B083
	LDA    $E7                   ; B085  FIX(fast scroll): pre-shifted tick
	AND    #$03                  ; B087
	TAX                          ; B089
	NOP                          ; B08A
	LDA    #$00                  ; B08B
	CPX    #$00                  ; B08D
	BEQ    KLB0AB                 ; B08F
	CPX    #$01                  ; B091
	BEQ    KLB0A5                 ; B093
	CPX    #$02                  ; B095
	BEQ    KLB09F                 ; B097
	STA    WSYNC                 ; B099
	STA    HMOVE                 ; B09B
	STA    VBLANK                ; B09D
KLB09F
	STA    WSYNC                 ; B09F
	STA    HMOVE                 ; B0A1
	STA    VBLANK                ; B0A3
KLB0A5
	STA    WSYNC                 ; B0A5
	STA    HMOVE                 ; B0A7
	STA    VBLANK                ; B0A9
KLB0AB
	STA    WSYNC                 ; B0AB
	STA    HMOVE                 ; B0AD
	STA    VBLANK                ; B0AF
	JMP    ($00D9)               ; B0B1
KDB0B4
	.byte $79,$69,$59,$49,$39,$29,$19,$09
	.byte $F9,$E9,$D9,$C9,$B9,$A9,$99,$70
	.byte $60,$50,$40,$30,$20,$10,$00,$F0
	.byte $E0,$D0,$C0,$B0,$A0,$90,$73,$63
	.byte $53,$43,$33,$23,$13,$03,$F3,$E3
	.byte $D3,$C3,$B3,$A3,$93,$76,$66,$56
	.byte $46,$36,$26,$16,$06,$F6,$E6,$D6
	.byte $C6,$B6,$A6,$96,$96,$96,$70,$70
KDB0F4
	.byte $03,$00,$01,$02
KDB0F8
	.byte $04,$08
KDB0FA
	.byte $30,$35,$00,$00,$00,$00
KLB100
	JMP    KLB212                 ; B100
KLB103
	JMP    KLB215                 ; B103
KLB106
	JMP    KLB21C                 ; B106
KLB109
	JMP    KLB200                 ; B109
KLB10C
	LDA    $F3                   ; B10C
	STA    GRP0                  ; B10E
	LDY    $F5                   ; B110
	BPL    KLB13B                 ; B112
	LDX    $F7                   ; B114
	LDY    KDB3E3,X               ; B116
	STY    $F7                   ; B119
	LDX    $A7,Y                 ; B11B
	LDY    KDB694,X               ; B11D
	LDA    KDB0F8,Y               ; B120
	STA    $F5                   ; B123
	LDA    KDB0FA,Y               ; B125
	STA    NUSIZ0                ; B128
	LDA    #$00                  ; B12A
	STA    $F3                   ; B12C
	LDX    #$88                  ; B12E
	STX    $DD                   ; B130
	STA    WSYNC                 ; B132
	STA    HMOVE                 ; B134
	STA    GRP0                  ; B136
	JMP    ($00D9)               ; B138
KLB13B
	LDA    ($ED),Y               ; B13B
	STA    $F3                   ; B13D
	LDA    ($EB),Y               ; B13F
	DEC    $F5                   ; B141
	LDX    #$57                  ; B143
	STX    $DD                   ; B145
	STA    WSYNC                 ; B147
	STA    HMOVE                 ; B149
	STA    GRP0                  ; B14B
	JMP    ($00D9)               ; B14D
KLB150
	LDA    #$00                  ; B150
	STA    $F3                   ; B152
	JMP    KLB16D                 ; B154
KLB157
	LDA    $F3                   ; B157
	STA    GRP0                  ; B159
	LDX    #$0C                  ; B15B
	STX    $DF                   ; B15D
	LDY    $F5                   ; B15F
	BMI    KLB150                 ; B161
	STY    HMP0                  ; B163
	LDA    ($ED),Y               ; B165
	STA    $F3                   ; B167
	LDA    ($EB),Y               ; B169
	DEC    $F5                   ; B16B
KLB16D
	TAX                          ; B16D
	LDY    $E4                   ; B16E
	LDA    KDBC00,Y               ; B170
	STA    WSYNC                 ; B173
	STA    HMOVE                 ; B175
	STA    COLUBK                ; B177
	STX    GRP0                  ; B179
KLB17B
	LDA    KDBA00,Y               ; B17B
	STA    PF1                   ; B17E
	LDA    KDBB00,Y               ; B180
	STA    PF2                   ; B183
	JMP    ($00DB)               ; B185
KLB188
	LDX    $F7                   ; B188
	LDY    $A7,X                 ; B18A
	LDA    KDB64A,Y               ; B18C
	STA    COLUP0                ; B18F
	LDA    KDB600,Y               ; B191
	STA    $ED                   ; B194
	STA    $EB                   ; B196
	LDA    $BF,X                 ; B198
	AND    #$3F                  ; B19A
	TAY                          ; B19C
	LDA    KDB0B4,Y               ; B19D
	STA    HMP0                  ; B1A0
	AND    #$0F                  ; B1A2
	STA    $DF                   ; B1A4
	LDY    $E4                   ; B1A6
	LDA    KDBC00,Y               ; B1A8
	STA    WSYNC                 ; B1AB
	STA    HMOVE                 ; B1AD
	STA    COLUBK                ; B1AF
	JMP    KLB17B                 ; B1B1
	.byte $00,$07,$2E,$0E,$21,$12,$0E,$0E
	.byte $23,$35,$03,$35,$30,$12,$2E,$07
	.byte $21,$07,$47,$0F,$07,$00
KLB1CA
	DEC    $A1                   ; B1CA
	INC    $E4                   ; B1CC
	LDA    $B5                   ; B1CE
	CMP    $E5                   ; B1D0
	BCS    KLB1E6                 ; B1D2
	LDY    $F6                   ; B1D4
	BMI    KLB1E2                 ; B1D6
	LDA    ($EF),Y               ; B1D8
	DEC    $F6                   ; B1DA
KLB1DC
	STA    $F4                   ; B1DC
	TAX                          ; B1DE
	JMP    KLB3BD                 ; B1DF
KLB1E2
	LDA    #$7B                  ; B1E2
	STA    $D9                   ; B1E4
KLB1E6
	LDA    #$00                  ; B1E6
	JMP    KLB1DC                 ; B1E8
KFREE_B1EB	; ---- unused space (21 bytes) ----
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00
; end free B1EB
KLB200
	NOP                          ; B200
	LDA    $F7                   ; B201
	LDX    $F9                   ; B203
	BIT    $31                   ; B205
	STA    RESP0                 ; B207
	BMI    KLB20F                 ; B209
	STA    $E2                   ; B20B
	STA    $E2                   ; B20D
KLB20F
	JMP    KLB239                 ; B20F
KLB212
	JMP    KLB226                 ; B212
KLB215
	INC    $2D                   ; B215
	INC    $2D                   ; B217
	JMP    KLB226                 ; B219
KLB21C
	INC    $2D                   ; B21C
	INC    $2D                   ; B21E
	DEC    $2D                   ; B220
	DEC    $2D                   ; B222
	STA    $2D                   ; B224
KLB226
	LDA    $F7                   ; B226
	LDX    $F9                   ; B228
	BIT    $31                   ; B22A
	BPL    KLB233                 ; B22C
	NOP                          ; B22E
	NOP                          ; B22F
	JMP    KLB237                 ; B230
KLB233
	STA    $E2                   ; B233
	STA    $E2                   ; B235
KLB237
	STA    RESP0                 ; B237
KLB239
	LDA    #$57                  ; B239
	STA    WSYNC                 ; B23B
	STA    HMOVE                 ; B23D
	STA    $DD                   ; B23F
	JMP    ($00D9)               ; B241
	.byte $A9,$00,$85,$02,$85,$2A,$A5,$F4
	.byte $85,$1C,$6C,$DD,$00
KLB251
	LDY    #$FF                  ; B251
	LDA    #$00                  ; B253
	STA    WSYNC                 ; B255
	STA    HMOVE                 ; B257
	STA    GRP0                  ; B259
	STA    GRP1                  ; B25B
	STA    ENAM1                 ; B25D
	STA    ENAM0                 ; B25F
	LDA    INTIM                 ; B261
	CMP    #$05                  ; B264
	BCS    KLB251                 ; B266
	LDA    #$00                  ; B268
	STA    WSYNC                 ; B26A
	STA    HMOVE                 ; B26C
	STA    PF0                   ; B26E
	STA    PF1                   ; B270
	STA    PF2                   ; B272
	STA    COLUBK                ; B274
	LDY    $9E                   ; B276
	LDA    ($A2),Y               ; B278
	STA    $F7                   ; B27A
	AND    #$1F                  ; B27C
	TAY                          ; B27E
	LDA    KDBBC9,Y               ; B27F
	STA    $F8                   ; B282
	JMP    $BDB0                 ; B284 -> POSTK (shipk.asm)
KLB287
	JMP    KLB251                 ; B287
KLB28A
	LDA    #$00                  ; B28A
	STA    ENAM1                 ; B28C
	STA    ENAM0                 ; B28E
	LDA    INTIM                 ; B290
	CMP    #$09                  ; B293
	BCC    KLB287                 ; B295
	JMP    KLB2C4                 ; B297
KLB29A
	LDX    $F9                   ; B29A
	LDA    $BB,X                 ; B29C
	CMP    $E5                   ; B29E
	BCS    KLB2A7                 ; B2A0
	JMP    $BDC4                 ; B2A2 -> SHIPDET (shipk.asm)
	NOP
	NOP
KLB2A7
	BIT    $31                   ; B2A7
	BMI    KLB2AD                 ; B2A9
	STX    $E3                   ; B2AB
KLB2AD
	JMP    KLB2C4                 ; B2AD
KLB2B0
	NOP                          ; B2B0
	NOP                          ; B2B1
	NOP                          ; B2B2
	STA    RESM1                 ; B2B3
	LDX    $F9                   ; B2B5
	LDA    $CF,X                 ; B2B7
	ASL                          ; B2B9
	STA    HMM1                  ; B2BA
	LDA    #$D5                  ; B2BC
	BCC    KLB2C2                 ; B2BE
	STA    RESM1                 ; B2C0
KLB2C2
	STA    $DB                   ; B2C2
KLB2C4
	INC    $E5                   ; B2C4
	LDX    $F4                   ; B2C6
	LDA    #$00                  ; B2C8
	STA    WSYNC                 ; B2CA
	STA    HMOVE                 ; B2CC
	STA    ENAM0                 ; B2CE
	STX    GRP1                  ; B2D0
	JMP    ($00DF)               ; B2D2
KLB2D5
	LDY    $E6                   ; B2D5
	STY    ENAM1                 ; B2D7
	STY    HMM1                  ; B2D9
	DEC    $F9                   ; B2DB
	LDA    #$E2                  ; B2DD
	JMP    KLB2C2                 ; B2DF
KLB2E2
	LDX    #$00                  ; B2E2
	STX    HMM1                  ; B2E4
	LDA    #$F3                  ; B2E6
	LDY    $F9                   ; B2E8
	BMI    KLB2F0                 ; B2EA
	STX    ENAM1                 ; B2EC
	LDA    #$9A                  ; B2EE
KLB2F0
	JMP    KLB2C2                 ; B2F0
KLB2F3
	LDA    #$8A                  ; B2F3
	JMP    KLB2C2                 ; B2F5
KFREE_B2F8	; ---- unused space (8 bytes) ----
	.byte $00,$00,$00,$00,$00,$00,$00,$00
; end free B2F8
	.byte $EA,$EA
KLB302
	DEC    $9F                   ; B302
	LDY    $F8                   ; B304
	LDX    KDB0F4,Y               ; B306
	LDA    $B7,X                 ; B309
	CMP    $E5                   ; B30B
	BNE    KLB320                 ; B30D
	STX    $F8                   ; B30F
	LDA    #$03                  ; B311
	STA    $F6                   ; B313
	LDA    #$3A                  ; B315
KLB317
	INC    $E4                   ; B317
	STA    $D9                   ; B319
	LDX    #$00                  ; B31B
	JMP    KLB3BD                 ; B31D
KLB320
	LDA    #$25                  ; B320
	JMP    KLB317                 ; B322
KLB325
	LDA    #$FF                  ; B325
	STA    $F6                   ; B327
	LDA    #$7B                  ; B329
	JMP    KLB317                 ; B32B
KLB32E
	DEC    $A1                   ; B32E
	LDA    #$34                  ; B330
	BNE    KLB317                 ; B332
	DEC    $A1                   ; B334
	LDA    #$7B                  ; B336
	BNE    KLB317                 ; B338
	INC    $E4                   ; B33A
	LDX    #$7B                  ; B33C
	STX    $D9                   ; B33E
	LDX    $F8                   ; B340
	LDA    $FA,X                 ; B342
	ASL                          ; B344
	STA    HMP1                  ; B345
	STA    RESP1                 ; B347
	LDA    $B3,X                 ; B349
	AND    #$3F                  ; B34B
	TAY                          ; B34D
	LDA    KDB6DE,Y               ; B34E
	STA    $EF                   ; B351
	BCC    KLB357                 ; B353
	STA    RESP1                 ; B355
KLB357
	STA    $F1                   ; B357
	LDY    $E5                   ; B359
	CPY    $D4                   ; B35B
	BNE    KLB36E                 ; B35D
	LDA    $F8                   ; B35F
	LDX    #$02                  ; B361
	STA    WSYNC                 ; B363
	STX    HMOVE                 ; B365
	STA    $E1                   ; B367
	STX    ENAM0                 ; B369
	JMP    ($00DD)               ; B36B
KLB36E
	LDX    #$00                  ; B36E
	STA    WSYNC                 ; B370
	STX    HMOVE                 ; B372
	STX    ENAM0                 ; B374
	STX    ENAM0                 ; B376
	JMP    ($00DD)               ; B378
KLB37B
	INC    $E4                   ; B37B
	DEC    $A1                   ; B37D
	BPL    KLB3AE                 ; B37F
	LDX    #$02                  ; B381
	LDY    $9F                   ; B383
	LDA    ($A2),Y               ; B385
	AND    #$1F                  ; B387
	TAY                          ; B389
	LDA    KDBAC9,Y               ; B38A
	STA    COLUPF                ; B38D
	LDA    KDBBC9,Y               ; B38F
	STA    $A1                   ; B392
	LDA    KDBCC9,Y               ; B394
	STA    $E4                   ; B397
	STX    $D9                   ; B399
	LDY    $E5                   ; B39B
	CPY    $D4                   ; B39D
	BNE    KLB36E                 ; B39F
	LDA    $F8                   ; B3A1
	STA    WSYNC                 ; B3A3
	STX    HMOVE                 ; B3A5
	STA    $E1                   ; B3A7
	STX    ENAM0                 ; B3A9
	JMP    ($00DD)               ; B3AB
KLB3AE
	LDY    $F6                   ; B3AE
	STY    HMP1                  ; B3B0
	BMI    KLB3D9                 ; B3B2
	LDA    ($F1),Y               ; B3B4
	STA    $F4                   ; B3B6
	LDA    ($EF),Y               ; B3B8
	TAX                          ; B3BA
	DEC    $F6                   ; B3BB
KLB3BD
	LDY    $E5                   ; B3BD
	CPY    $D4                   ; B3BF
	BNE    KLB3D4                 ; B3C1
	LDA    $F8                   ; B3C3
	STA    $E1                   ; B3C5
	LDA    #$02                  ; B3C7
KLB3C9
	STA    WSYNC                 ; B3C9
	STA    HMOVE                 ; B3CB
	STA    ENAM0                 ; B3CD
	STX    GRP1                  ; B3CF
	JMP    ($00DD)               ; B3D1
KLB3D4
	LDA    #$00                  ; B3D4
	JMP    KLB3C9                 ; B3D6
KLB3D9
	LDX    #$00                  ; B3D9
	STX    $F4                   ; B3DB
	JMP    KLB3BD                 ; B3DD
KLB3E0
	JMP    KLB1CA                 ; B3E0
KDB3E3
	.byte $0B,$00,$01,$02,$03,$04,$05,$06
	.byte $07,$08,$09,$0A
KFREE_B3EF	; ---- unused space (19 bytes) ----
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00
; end free B3EF
	.byte $00,$00,$00,$00,$00,$99,$BD,$FF
	.byte $81,$00,$5A,$7E,$7E,$42,$00,$3C
	.byte $3C,$3C,$18,$00,$5A,$7E,$7E,$42
	.byte $00,$18,$34,$7E,$10,$00,$58,$36
	.byte $3C,$24,$00,$1A,$74,$3C,$08,$00
	.byte $F1,$DD,$7F,$2C,$00,$E0,$E2,$7B
	.byte $30,$00,$C0,$B0,$8C,$00,$00,$00
	.byte $43,$5C,$70,$00,$87,$BD,$D8,$30
	.byte $00,$78,$36,$36,$78,$00,$0C,$16
	.byte $16,$0C,$00,$1C,$3C,$3C,$1C,$00
	.byte $3C,$F6,$F6,$3C,$00,$6C,$D6,$C6
	.byte $38,$00,$7C,$7C,$6C,$38,$00,$38
	.byte $38,$38,$10,$00,$10,$10,$10,$10
	.byte $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.byte $FF,$00,$7E,$7E,$7E,$7E,$FF,$FF
	.byte $FF,$00,$00,$00,$00,$3C,$7E,$7E
	.byte $FF,$00,$00,$00,$00,$00,$00,$3C
	.byte $FF,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$FF,$00,$00,$00,$00,$00,$00
	.byte $00,$7E,$18,$00,$00,$00,$00,$00
	.byte $FF,$FF,$7E,$3C,$3C,$00,$00,$00
	.byte $FF,$FF,$FF,$FF,$7E,$7E,$7E,$00
	.byte $00,$80,$17,$FE,$C7,$00,$80,$15
	.byte $CE,$34,$00,$00,$02,$0C,$1C,$00
	.byte $00,$00,$08,$1C,$00,$3C,$7E,$2C
	.byte $00,$00,$22,$C1,$21,$2C,$00,$00
	.byte $08,$08,$00,$00
KFREE_B4D6	; ---- unused space (44 bytes) ----
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00
; end free B4D6
	.byte $00,$00,$00,$00,$00,$18,$B5,$F7
	.byte $DB,$00,$18,$7E,$7E,$5A,$00,$18
	.byte $1C,$1C,$18,$00,$18,$6E,$6E,$5A
	.byte $00,$08,$7E,$34,$18,$00,$04,$3C
	.byte $74,$18,$00,$20,$3C,$36,$58,$00
	.byte $7F,$F1,$BD,$76,$00,$00,$FE,$62
	.byte $3F,$00,$E0,$80,$B4,$FC,$00,$00
	.byte $7F,$5C,$60,$00,$FE,$BB,$BD,$60
	.byte $00,$00,$5C,$FA,$5C,$00,$00,$0C
	.byte $3A,$0C,$00,$00,$18,$30,$18,$00
	.byte $00,$74,$AA,$74,$00,$38,$C6,$D6
	.byte $6C,$00,$38,$6C,$7C,$7C,$00,$10
	.byte $38,$38,$38,$00,$10,$10,$10,$10
	.byte $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.byte $FF,$00,$00,$7E,$7E,$7E,$FF,$FF
	.byte $FF,$FF,$00,$00,$00,$3C,$3C,$7E
	.byte $FF,$FF,$00,$00,$00,$00,$00,$18
	.byte $7E,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$FF,$00,$00,$00,$00,$00,$00
	.byte $00,$FF,$3C,$00,$00,$00,$00,$00
	.byte $00,$FF,$7E,$7E,$3C,$00,$00,$00
	.byte $00,$FF,$FF,$FF,$7E,$7E,$7E,$7E
	.byte $00,$2C,$6A,$5B,$6E,$00,$44,$48
	.byte $42,$0C,$00,$00,$28,$18,$08,$00
	.byte $00,$00,$00,$08,$00,$3C,$7E,$7E
	.byte $3C,$00,$56,$84,$82,$48,$00,$00
	.byte $00,$14,$00,$00
KFREE_B5D6	; ---- unused space (42 bytes) ----
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00
; end free B5D6
KDB600
	.byte $02,$02,$02,$1B,$20,$25,$07,$0C
	.byte $11,$16,$43,$48,$4D,$52,$52,$4D
	.byte $48,$43,$2A,$2F,$2F,$34,$34,$39
	.byte $39,$3E,$3E,$39,$39,$34,$34,$2F
	.byte $2F,$2A,$57,$57,$5C,$61,$66,$61
	.byte $5C,$57,$5C,$61,$66,$61,$5C,$02
	.byte $C7,$6B,$74,$7D,$86,$8F,$98,$A1
	.byte $AA,$6B,$74,$7D,$86,$8F,$98,$A1
	.byte $AA,$D1,$CC,$BD,$B3,$B8,$B3,$B8
	.byte $BD,$C2
KDB64A
	.byte $FF,$FF,$FF,$06,$06,$06,$0F,$88
	.byte $0F,$88,$F6,$F8,$FA,$FC,$F6,$F8
	.byte $FA,$FC,$8C,$8A,$8A,$0F,$0F,$0C
	.byte $0C,$08,$8C,$8A,$8A,$0F,$0F,$0C
	.byte $0C,$08,$08,$08,$08,$08,$08,$04
	.byte $04,$04,$04,$04,$04,$08,$08,$FF
	.byte $00,$08,$08,$08,$08,$04,$04,$04
	.byte $04,$04,$04,$04,$04,$04,$08,$08
	.byte $08,$0C,$0C,$3A,$38,$3C,$3F,$3C
	.byte $36,$3A
KDB694
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00
KDB6DE
	.byte $02,$4D,$52,$4D,$52,$57,$5C,$57
	.byte $02,$34,$39,$3E,$43,$07,$0C,$07
	.byte $0C,$07,$0C,$11,$16,$1B,$20,$1B
	.byte $25,$2A,$2F,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$38,$FE,$FE,$38,$00,$38,$FE
	.byte $FE,$38,$00,$E0,$D8,$E0,$F0,$00
	.byte $E0,$D8,$E0,$F0,$00,$81,$DD,$DD
	.byte $7C,$00,$80,$C0,$62,$18,$00,$24
	.byte $FD,$66,$18,$00,$24,$FD,$6E,$18
	.byte $00,$24,$FD,$7E,$18,$00,$FE,$FE
	.byte $FE,$00,$00,$FE,$EE,$FE,$00,$00
	.byte $FE,$FA,$FE,$00,$00,$80,$C0,$EA
	.byte $00,$00,$80,$FC,$FA,$7C,$00,$C7
	.byte $FE,$17,$80,$00,$34,$CE,$15,$80
	.byte $00,$1C,$0C,$02,$00,$00,$1C,$08
	.byte $00,$00,$00
KDB761
	.byte $81
KDB762
	.byte $B7,$97,$B7,$AD,$B7,$8D,$B8,$31
	.byte $B9,$79,$B8,$C1,$B7,$61,$B8,$C4
	.byte $B8,$B4,$B1,$DB,$B8,$F8,$B8,$0D
	.byte $B9,$21,$B9,$A8,$B8,$48,$B9,$00
	.byte $07,$07,$07,$07,$27,$07,$07,$A7
	.byte $07,$A7,$07,$47,$07,$07,$AA,$AA
	.byte $AA,$2A,$07,$07,$00,$00,$09,$09
	.byte $02,$08,$27,$27,$27,$42,$08,$A7
	.byte $07,$22,$23,$11,$29,$49,$21,$02
	.byte $A1,$11,$00,$00,$07,$47,$08,$28
	.byte $22,$08,$08,$02,$67,$27,$27,$A4
	.byte $11,$02,$21,$21,$11,$08,$00,$00
	.byte $07,$2F,$07,$2F,$07,$6F,$07,$35
	.byte $35,$2F,$47,$2F,$27,$07,$27,$27
	.byte $47,$27,$27,$07,$07,$07
KFREE_B7D8	; ---- unused space (42 bytes) ----
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00
; end free B7D8
	.byte $00,$00,$00,$00,$00,$00,$6C,$AA
	.byte $6C,$00,$00,$7C,$EE,$7C,$00,$E0
	.byte $D8,$E0,$F0,$00,$E0,$D8,$E0,$F0
	.byte $00,$FF,$FD,$DD,$C5,$00,$FF,$FE
	.byte $FD,$24,$00,$18,$7A,$ED,$3C,$00
	.byte $18,$7A,$FD,$3C,$00,$18,$7A,$FD
	.byte $3C,$00,$FE,$FE,$FE,$00,$00,$FE
	.byte $FE,$FE,$00,$00,$FE,$C2,$EA,$00
	.byte $00,$FE,$FC,$F8,$7C,$00,$FE,$80
	.byte $C0,$68,$00,$6E,$5B,$6A,$2C,$00
	.byte $0C,$42,$48,$44,$00,$08,$18,$28
	.byte $00,$00,$08,$00,$00,$00,$00,$00
	.byte $07,$07,$07,$08,$09,$A1,$14,$25
	.byte $25,$65,$25,$25,$25,$65,$13,$21
	.byte $11,$07,$07,$A2,$07,$07,$00,$00
	.byte $09,$A9,$08,$09,$09,$47,$06,$02
	.byte $30,$30,$30,$11,$47,$30,$11,$07
	.byte $21,$11,$00,$00,$07,$27,$08,$47
	.byte $A2,$09,$07,$09,$07,$A8,$09,$07
	.byte $08,$09,$07,$09,$2E,$4E,$AE,$0E
	.byte $21,$51,$27,$07,$07,$00,$00,$A7
	.byte $27,$A7,$A7,$27,$A7,$A7,$A7,$27
	.byte $A7,$A7,$A7,$27,$A7,$27,$A7,$E7
	.byte $27,$A7,$A7,$27,$E7,$A7,$A7,$A7
	.byte $A7,$00,$00,$07,$47,$07,$07,$2E
	.byte $2D,$2E,$2D,$07,$02,$07,$67,$27
	.byte $07,$24,$07,$07,$70,$21,$11,$47
	.byte $00,$00,$00,$08,$22,$07,$08,$09
	.byte $01,$03,$06,$21,$02,$21,$11,$08
	.byte $02,$07,$68,$29,$28,$08,$08,$01
	.byte $11,$08,$22,$21,$11,$00,$00,$07
	.byte $47,$A7,$A7,$27,$A3,$A3,$A3,$A3
	.byte $A3,$A3,$A3,$A3,$A7,$A7,$07,$27
	.byte $07,$27,$00,$00,$07,$0D,$2D,$2D
	.byte $54,$05,$A5,$05,$A5,$05,$A5,$13
	.byte $B0,$30,$11,$07,$27,$07,$00,$00
	.byte $07,$07,$27,$A7,$03,$22,$03,$22
	.byte $27,$A7,$27,$27,$27,$07,$00,$00
	.byte $07,$27,$07,$63,$94,$05,$25,$05
	.byte $25,$05,$25,$05,$25,$05,$25,$13
	.byte $27,$07,$27,$07,$07,$00,$00,$07
	.byte $27,$47,$07,$07,$03,$22,$03,$22
	.byte $03,$22,$03,$22,$06,$07,$27,$07
	.byte $07
KFREE_B95B	; ---- unused space (165 bytes) ----
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00
; end free B95B
KDBA00
	.byte $00,$00,$00,$00,$00,$00,$00,$20
	.byte $10,$20,$40,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$08,$44,$80,$03,$06
	.byte $06,$2D,$7B,$EF,$36,$9D,$69,$23
	.byte $90,$C9,$24,$00,$5C,$38,$10,$20
	.byte $00,$00,$00,$00,$00,$00,$14,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$40,$80,$D0,$60,$80,$40
	.byte $00,$00,$00,$00,$00,$00,$00,$01
	.byte $04,$08,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$07
	.byte $08,$10,$20,$44,$28,$11,$0A,$04
	.byte $02,$01,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$08,$44,$80,$03
	.byte $06,$06,$2D,$7B,$EF,$36,$9D,$69
	.byte $23,$90,$C9,$24,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$10
	.byte $10,$10,$10,$00,$00,$00,$00,$00
	.byte $00,$00,$99,$66,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$30,$00,$30,$00
	.byte $00,$00,$30,$00,$30,$00,$00,$00
	.byte $00
KDBAC9
	.byte $C2,$0F,$C0,$0F,$F4,$0F,$C2,$C2
	.byte $C4,$C6,$C2,$C2,$C4,$F4,$F4,$F4
	.byte $0F,$C2,$F4,$C0,$C0,$F8,$C2,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00
KDBB00
	.byte $00,$00,$00,$00,$02,$01,$00,$00
	.byte $00,$00,$00,$04,$08,$04,$00,$00
	.byte $00,$00,$00,$10,$88,$46,$6F,$DE
	.byte $B9,$74,$9A,$3C,$69,$D6,$FB,$7D
	.byte $D6,$BA,$60,$00,$40,$A0,$E0,$70
	.byte $A0,$50,$A0,$E0,$40,$80,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$02,$05,$02
	.byte $01,$00,$00,$00,$40,$60,$D0,$A8
	.byte $70,$10,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$80,$40,$40,$40,$40
	.byte $40,$20,$10,$10,$20,$40,$40,$3F
	.byte $00,$00,$00,$00,$01,$08,$04,$22
	.byte $51,$08,$45,$42,$40,$20,$20,$20
	.byte $10,$10,$48,$48,$44,$24,$22,$12
	.byte $94,$48,$50,$00,$10,$88,$46,$6F
	.byte $DE,$B9,$74,$9A,$3C,$69,$D6,$FB
	.byte $7D,$D6,$BA,$60,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$21
	.byte $21,$21,$21,$00,$00,$00,$00,$00
	.byte $00,$00,$55,$AA,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$30,$00,$30,$00
	.byte $00,$00,$30,$00,$30,$00,$00,$00
	.byte $00
KDBBC9
	.byte $2C,$09,$07,$0C,$27,$09,$5F,$0E
	.byte $0D,$0E,$09,$09,$09,$07,$0D,$05
	.byte $06,$03,$03,$03,$03,$05,$08,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00
KDBC00
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $F0,$82,$80,$80,$80,$80,$80,$80
	.byte $82,$F0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$F0,$F2,$F4,$86,$84,$82
	.byte $80,$80,$80,$80,$80,$80,$80,$80
	.byte $80,$80,$80,$80,$82,$84,$86,$F6
	.byte $F4,$F2,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
	.byte $C0,$C0,$C0,$C0,$F2,$F2,$F2,$F2
	.byte $F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2
	.byte $F2,$F2,$F2,$F2,$F2,$C0,$F2,$F2
	.byte $F2,$F2,$F2,$F2,$F2,$00,$02,$02
	.byte $02,$02,$02,$02,$00,$00,$02,$02
	.byte $02,$02,$02,$02,$02,$02,$02,$02
	.byte $00,$02,$00,$02,$02,$02,$02,$02
	.byte $00,$02,$02,$02,$02,$02,$00,$02
	.byte $C0
KDBCC9
	.byte $01,$AD,$30,$B9,$62,$50,$01,$13
	.byte $3A,$00,$13,$3A,$00,$8C,$8C,$9D
	.byte $B9,$1E,$97,$4A,$5C,$A5,$3A
KDBCE0
	.byte $00,$00,$02,$06,$00,$00,$06,$00
	.byte $05,$05
KDBCEA
	.byte $00,$0D,$17,$00,$00,$00,$00,$E2
	.byte $26,$6C,$00
KDBCF5
	.byte $00,$08,$12,$30,$A1,$A8,$0F,$AF
	.byte $1C,$37
KDBCFF
	.byte $00,$84,$84,$88,$88,$85,$8D,$8D
	.byte $88,$8D,$01
KLBD0A
	CPY    $98                   ; BD0A
	BCC    KLBD1E                 ; BD0C
	STY    $98                   ; BD0E
	LDA    KDBCF5,Y               ; BD10
	STA    $9C                   ; BD13
	LDA    KDBCEA,Y               ; BD15
	STA    $99                   ; BD18
	LDA    #$00                  ; BD1A
	STA    $9A                   ; BD1C
KLBD1E
	JMP    $F018                 ; BD1E
KLBD21
	LDX    $98                   ; BD21
	LDA    KDBCFF,X               ; BD23
	BMI    KLBD3B                 ; BD26
	STA    AUDC0                 ; BD28
	LDA    KDBCF5,X               ; BD2A
	STA    AUDV0                 ; BD2D
	LDA    KDBCE0,X               ; BD2F
	STA    AUDF0                 ; BD32
	LDA    #$00                  ; BD34
	STA    $98                   ; BD36
	JMP    KLBD58                 ; BD38
KLBD3B
	LDX    $98                   ; BD3B
	DEC    $9A                   ; BD3D
	BPL    KLBD51                 ; BD3F
	INC    $99                   ; BD41
	INC    $9C                   ; BD43
	LDA    KDBCE0,X               ; BD45
	STA    $9A                   ; BD48
	LDA    KDBCFF,X               ; BD4A
	STA    AUDC0                 ; BD4D
	STA    AUDC1                 ; BD4F
KLBD51
	LDY    $9C                   ; BD51
	LDA    KDBDD2,Y               ; BD53
	BNE    KLBD70                 ; BD56
KLBD58
	STA    $9C                   ; BD58
	STA    $98                   ; BD5A
	LDA    #$04                  ; BD5C
	STA    AUDC0                 ; BD5E
	LDA    $9D                   ; BD60
	BNE    KLBD70                 ; BD62
	LDA    $91                   ; BD64
	AND    #$06                  ; BD66
	BEQ    KLBD70                 ; BD68
	LDA    #$09                  ; BD6A
	STA    AUDC0                 ; BD6C
	LDA    #$8F                  ; BD6E
KLBD70
	STA    AUDF0                 ; BD70
	LSR                          ; BD72
	LSR                          ; BD73
	LSR                          ; BD74
	LSR                          ; BD75
	ORA    #$01                  ; BD76
	STA    AUDV0                 ; BD78
	LDY    $99                   ; BD7A
	LDA    KDBDD2,Y               ; BD7C
	BNE    KLBD8F                 ; BD7F
	STA    $99                   ; BD81
	LDA    $9B                   ; BD83
	AND    #$1F                  ; BD85
	TAX                          ; BD87
	LDA    #$04                  ; BD88
	STA    AUDC1                 ; BD8A
	LDA    KDBDB1,X               ; BD8C
KLBD8F
	STA    AUDF1                 ; BD8F
	LSR                          ; BD91
	LSR                          ; BD92
	LSR                          ; BD93
	LSR                          ; BD94
	ORA    #$01                  ; BD95
	STA    AUDV1                 ; BD97
	LDA    $9B                   ; BD99
	CLC                          ; BD9B
	ADC    #$20                  ; BD9C
	BCC    KLBDA6                 ; BD9E
	ADC    #$00                  ; BDA0
	AND    #$1F                  ; BDA2
	ORA    #$60                  ; BDA4
KLBDA6
	STA    $9B                   ; BDA6
	LDA    $9D                   ; BDA8
	BEQ    KLBDAE                 ; BDAA
	INC    $9D                   ; BDAC
KLBDAE
	JMP    $F00C                 ; BDAE
KDBDB1
	.byte $3D,$4E,$4F,$4E,$4B,$4E,$4F,$4E
	.byte $3D,$4E,$50,$4E,$4B,$4E,$50,$4E
	.byte $3D,$4E,$51,$4E,$4B,$4E,$51,$4E
	.byte $3D,$4E,$52,$4E,$4B,$4E,$52,$4E
	.byte $00
KDBDD2
	.byte $00,$00,$A7,$00,$A8,$A8,$A8,$00
	.byte $A4,$A7,$AA,$AF,$00,$9F,$98,$94
	.byte $92,$00,$AB,$AE,$A9,$AC,$00,$AF
	.byte $B2,$AE,$B1,$00,$FE,$DE,$BE,$7E
	.byte $7E,$5E,$5E,$3E,$3E,$00,$FF,$DF
	.byte $BF,$7F,$6F,$5F,$5F,$3F,$3F,$00
	.byte $B6,$96,$76,$56,$36,$36,$00,$B2
	.byte $B2,$B2,$B2,$B2,$01,$AF,$B2,$AF
	.byte $AB,$AF,$01,$B2,$B1,$01,$B1,$B1
	.byte $B1,$B1,$AD,$AD,$AD,$AD,$B1,$B1
	.byte $B1,$B1,$B2,$B2,$B2,$B2,$01,$AF
	.byte $B2,$AF,$AB,$AF,$01,$B2,$B1,$01
	.byte $B1,$B1,$B1,$B1,$B2,$B2,$B2,$B2
	.byte $B2,$B2,$B2,$00,$BF,$BF,$BF,$BF
	.byte $BF,$01,$B7,$BF,$B7,$B2,$B7,$01
	.byte $BF,$BB,$01,$BB,$BB,$BB,$BB,$B4
	.byte $B4,$B4,$B4,$BB,$BB,$BB,$BB,$BF
	.byte $BF,$BF,$BF,$01,$B7,$BF,$B7,$B2
	.byte $B7,$01,$BF,$BB,$01,$BB,$BB,$BB
	.byte $BB,$BF,$BF,$BF,$BF,$BF,$BF,$BF
	.byte $00,$38,$56,$73,$8F,$AA,$C4,$00
	.byte $B0,$AE,$8C,$6A,$48,$28,$00,$AD
	.byte $ED,$ED,$ED,$ED,$AD,$AD,$B0,$F0
	.byte $F0,$F0,$F0,$B0,$B0,$B4,$F4,$F4
	.byte $F4,$F4,$B4,$B4,$B4,$B4,$94,$94
	.byte $94,$54,$54,$54,$F4,$F4,$F4,$F4
	.byte $B4,$B4,$B0,$F0,$F0,$F0,$F0,$B0
	.byte $B0,$AD,$ED,$ED,$ED,$ED,$AD,$AD
	.byte $AD,$00,$B0,$F0,$F0,$F0,$F0,$B0
	.byte $B0,$B4,$F4,$F4,$F4,$F4,$B4,$B4
	.byte $BB,$FB,$FB,$FB,$FB,$BB,$BB,$BB
	.byte $FB,$FB,$FB,$FB,$BB,$BB,$BB,$FB
	.byte $FB,$FB,$FB,$BB,$BB,$B4,$F4,$F4
	.byte $F4,$F4,$B4,$B4,$B0,$F0,$F0,$F0
	.byte $F0,$B0,$B0,$B0,$00,$38,$7C,$FE
	.byte $FE,$D6,$EE,$EE,$D6,$FE,$FE,$7C
	.byte $38,$38,$7C,$FE,$D6,$BA,$EE,$EE
	.byte $BA,$D6,$FE,$7C,$38,$38,$7C,$FE
	.byte $92,$BA,$FE,$FE,$BA,$92,$FE,$7C
	.byte $38,$38,$7C,$FE,$D6,$BA,$FE,$FE
	.byte $BA,$D6,$FE,$7C,$38
KLBF17
	LDY    $96                   ; BF17
	LDA    $F7                   ; BF19
	AND    #$1F                  ; BF1B
	CMP    #$16                  ; BF1D
	BNE    KLBF25                 ; BF1F
	LDA    #$08                  ; BF21
	BNE    KLBF2C                 ; BF23
KLBF25
	LDA    $F7                   ; BF25
	AND    #$80                  ; BF27
	ORA    KDBF44,Y               ; BF29
KLBF2C
	STA    $B3,X                 ; BF2C
	LDA    KDBF45,Y               ; BF2E
	STA    $CB,X                 ; BF31
	LDA    #$FF                  ; BF33
	STA    $F6                   ; BF35
	LDA    #$00                  ; BF37
	STA    $B7,X                 ; BF39
	LDA    $91                   ; BF3B
	ORA    #$08                  ; BF3D
	STA    $91                   ; BF3F
	JMP    $F012                 ; BF41
KDBF44
	.byte $0D
KDBF45
	.byte $0A,$17,$1E,$17,$1C,$17,$28,$17
	.byte $2C,$17,$1E,$17,$1E,$17,$3C,$17
	.byte $28,$17,$05,$0D,$F7,$0D,$F7,$0D
	.byte $F7,$0D,$F7,$16,$32,$17,$0A,$08
	.byte $00,$0D,$F7,$0D,$F7,$0D,$19,$16
	.byte $23,$0D,$D4,$0D,$9E,$0F,$0A,$11
	.byte $A8,$0F,$14,$11,$4A,$0D,$9E,$0D
	.byte $E8,$0D,$1E,$0D,$8A,$0D,$32,$18
	.byte $3C,$18,$0A,$0D,$B2,$0D,$23,$0D
	.byte $19,$16,$23,$17,$0A,$0D,$0A,$18
	.byte $0A,$0D,$0A,$08,$14,$0D,$14,$17
	.byte $0A,$0D,$3C,$08,$00,$16,$0A,$0D
	.byte $00,$0D,$00,$17,$3C,$17,$3C,$16
	.byte $19,$17,$0A,$16,$0A,$17,$28
KFREE_BFB4	; ---- unused space (68 bytes) ----
	DS.B $BFF2-., 0
	JMP    KLB01E                ; $FFF2 (offset) = landing for bank 2 FAR_KERNEL
	DS.B $BFF8-., 0
; end free BFB4
; bankswitch hotspots / vectors
	.byte $00,$00
	.byte $00,$00,$00,$F0,$00,$F0
