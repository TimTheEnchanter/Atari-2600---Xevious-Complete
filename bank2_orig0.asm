;======================================================================
; BANK 2  (original bank 0, runs at $F000)
;======================================================================
	SEG bank2
	ORG $2000
	RORG $F000
	STA    $FFF8                 ; F000
LF003
	JMP    LF01C                 ; F003
LF006
	STA    $FFF9                 ; F006
LF009
	JMP    LFD93                 ; F009
LF00C
	STA    $FFF9                 ; F00C
LF00F
	JMP    LF120                 ; F00F
LF012
	STA    $FFF9                 ; F012
LF015
	JMP    LF213                 ; F015
LF018
	STA    $FFF9                 ; F018
LF01B
	RTS                          ; F01B
LF01C
	CLI                          ; F01C
	CLD                          ; F01D
	LDX    #$FF                  ; F01E
	TXS                          ; F020
	INX                          ; F021
	TXA                          ; F022
LF023
	STA    VSYNC,X               ; F023
	INX                          ; F025
	BNE    LF023                 ; F026
	STA    SWACNT                ; F028
	STA    SWBCNT                ; F02B
	DEX                          ; F02E
	STX    $83                   ; F02F
	STX    $84                   ; F031
	LDA    #$80                  ; F033
	STA    $91                   ; F035
	LDA    #$04                  ; F037
	STA    $9E                   ; F039
	JMP    LF8F5                 ; F03B
LF03E
	LDA    INTIM                 ; F03E
	BNE    LF03E                 ; F041
	LDA    #$03                  ; F043
	STA    WSYNC                 ; F045
	STA    VSYNC                 ; F047
	LDA    $83                   ; F049
	ASL                          ; F04B
	EOR    $83                   ; F04C
	ASL                          ; F04E
	ASL                          ; F04F
	ROL    $83                   ; F050
	ROL    $84                   ; F052
	STA    WSYNC                 ; F054
	LDA    $82                   ; F056
	AND    #$FE                  ; F058
	STA    $82                   ; F05A
	LDA    #$40                  ; F05C
	STA    $E7                   ; F05E
	LDA    $91                   ; F060
	AND    #$01                  ; F062
	BEQ    LF068                 ; F064
	ASL    $E7                   ; F066
LF068
	LDA    SWCHB                 ; F068
	AND    $E7                   ; F06B
	BEQ    LF071                 ; F06D
	INC    $82                   ; F06F
LF071
	STA    WSYNC                 ; F071
	STA    WSYNC                 ; F073
	LDA    #$00                  ; F075
	STA    VSYNC                 ; F077
	LDA    #$22                  ; F079
	STA    TIM64T                ; F07B
	LDA    $82                   ; F07E
	CLC                          ; F080
	ADC    #$20                  ; F081
	BCC    LF08D                 ; F083
	INC    $97                   ; F085
	LDA    $82                   ; F087
	AND    #$1F                  ; F089
	ORA    #$60                  ; F08B
LF08D
	STA    $82                   ; F08D
	LDA    $97                   ; F08F
	BNE    LF09B                 ; F091
	INC    $80                   ; F093
	BNE    LF09B                 ; F095
	INC    $81                   ; F097
	LDA    $81                   ; F099
LF09B
	JMP    LF3B5                 ; F09B
LF09E
	LDA    INTIM                 ; F09E
	BNE    LF09E                 ; F0A1
	LDA    #$E1                  ; F0A3
	STA    TIM64T                ; F0A5
	LDA    #$01                  ; F0A8
	STA    CTRLPF                ; F0AA
	STA    PF0                   ; F0AC
	LDA    #$08                  ; F0AE
	STA    COLUP1                ; F0B0
	STA    HMCLR                 ; F0B2
	STA    CXCLR                 ; F0B4
; FIX(fast scroll): the kernel inserts 0-3 blank lines at the top of the screen
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
	JMP    FAR_KERNEL            ; F0C1  M3: kernel now runs from bank 1
LF0C4
	STA    WSYNC                 ; F0C4
	LDX    #$FF                  ; F0C6
	TXS                          ; F0C8
	STX    VBLANK                ; F0C9
	INX                          ; F0CB
	STX    VDELP0                ; F0CC
	STX    VDELP1                ; F0CE
	LDA    SWCHB                 ; F0D0
	AND    #$01                  ; F0D3
	BNE    LF0DA                 ; F0D5
	JMP    LF8D1                 ; F0D7
LF0DA
	LDA    SWCHB                 ; F0DA
	EOR    #$FF                  ; F0DD
	AND    #$02                  ; F0DF
	BEQ    LF101                 ; F0E1
	INC    $97                   ; F0E3
	LDA    $91                   ; F0E5
	ORA    #$80                  ; F0E7
	STA    $91                   ; F0E9
	INC    $92                   ; F0EB
	LDA    $92                   ; F0ED
	CMP    #$0A                  ; F0EF
	BEQ    LF0F7                 ; F0F1
	CMP    #$28                  ; F0F3
	BNE    LF103                 ; F0F5
LF0F7
	INC    $93                   ; F0F7
	LDA    $93                   ; F0F9
	AND    #$07                  ; F0FB
	STA    $93                   ; F0FD
	LDA    #$0B                  ; F0FF
LF101
	STA    $92                   ; F101
LF103
	BIT    $91                   ; F103
	BPL    LF123                 ; F105
	LDA    #$00                  ; F107
	STA    AUDV0                 ; F109
	STA    AUDV1                 ; F10B
	STA    AUDC0                 ; F10D
	STA    AUDC1                 ; F10F
	LDA    $81                   ; F111
	BEQ    LF120                 ; F113
	BIT    $3C                   ; F115
	BMI    LF120                 ; F117
	LDA    $A4                   ; F119
	STA    $87                   ; F11B
	JMP    LF8D7                 ; F11D
LF120
	JMP    LF627                 ; F120
LF123
	JMP    $B00C                 ; F123
LF126
	LDA    $82                   ; F126
	LSR                          ; F128
	LDA    #$07                  ; F129
	BCS    LF12E                 ; F12B
	LSR                          ; F12D
LF12E
	AND    $80                   ; F12E
	ASL                          ; F130
	TAX                          ; F131
	LDA    DF146,X               ; F132
	STA    $DF                   ; F135
	LDA    DF147,X               ; F137
	STA    $E0                   ; F13A
	LDX    $95                   ; F13C
	LDA    DFB67,X               ; F13E
	STA    $E7                   ; F141
	JMP    ($00DF)               ; F143
DF146
	.byte $56
DF147
	.byte $F1,$97,$F7
	.word LF1C0                ; F14A
	.word LF1F9                ; F14C
	.byte $1D,$F2,$97,$F7,$80,$F1,$80,$F1
LF156
	LDA    $D3                   ; F156
	AND    #$07                  ; F158
	BEQ    LF164                 ; F15A
	LDA    $E6                   ; F15C
	ORA    #$04                  ; F15E
	STA    $E6                   ; F160
	INC    $D4                   ; F162
LF164
	LDA    $91                   ; F164
	AND    #$02                  ; F166
	BNE    LF175                 ; F168
	LDX    #$03                  ; F16A
LF16C
	INC    $B7,X                 ; F16C
	BNE    LF172                 ; F16E
	DEC    $B7,X                 ; F170
LF172
	DEX                          ; F172
	BPL    LF16C                 ; F173
LF175
	LDA    $F8                   ; F175
	SEC                          ; F177
	ADC    #$01                  ; F178
	CMP    $A0                   ; F17A
	BEQ    LF181                 ; F17C
	INC    $A0                   ; F17E
	RTS                          ; F180
LF181
	LDA    #$00                  ; F181
	STA    $A0                   ; F183
	LDA    $91                   ; F185
	AND    #$08                  ; F187
	BEQ    LF197                 ; F189
	LDA    $91                   ; F18B
	AND    #$F7                  ; F18D
	STA    $91                   ; F18F
	LDX    $D7                   ; F191
	LDA    #$01                  ; F193
	STA    $B7,X                 ; F195
LF197
	LDA    $91                   ; F197
	AND    #$02                  ; F199
	BEQ    LF1AD                 ; F19B
	LDA    $91                   ; F19D
	AND    #$FD                  ; F19F
	STA    $91                   ; F1A1
	LDA    #$00                  ; F1A3
	STA    $B3                   ; F1A5
	STA    $B4                   ; F1A7
	STA    $B5                   ; F1A9
	STA    $B6                   ; F1AB
LF1AD
	INC    $9E                   ; F1AD
	LDY    $87                   ; F1AF
	LDA    DFA1D,Y               ; F1B1
	CMP    $9E                   ; F1B4
	BNE    LF1BF                 ; F1B6
	LDA    #$01                  ; F1B8
	STA    $9E                   ; F1BA
	JSR    LF938                 ; F1BC
LF1BF
	RTS                          ; F1BF
LF1C0
	LDA    $A0                   ; F1C0
	BNE    LF1F8                 ; F1C2
	LDA    $9F                   ; F1C4
	AND    #$03                  ; F1C6
	CLC                          ; F1C8
	ADC    $86                   ; F1C9
	TAX                          ; F1CB
	LDA    DFB41,X               ; F1CC
	STA    $94                   ; F1CF
	LDA    $F7                   ; F1D1
	AND    #$40                  ; F1D3
	BEQ    LF1F8                 ; F1D5
	INC    $95                   ; F1D7
	LDX    $95                   ; F1D9
	CPX    #$2D                  ; F1DB
	BNE    LF1E3                 ; F1DD
	LDX    #$00                  ; F1DF
	STX    $95                   ; F1E1
LF1E3
	LDX    $95                   ; F1E3
	LDA    DFB67,X               ; F1E5
	AND    #$40                  ; F1E8
	BNE    LF1F8                 ; F1EA
	INC    $86                   ; F1EC
	LDA    $86                   ; F1EE
	CMP    #$21                  ; F1F0
	BNE    LF1F8                 ; F1F2
	LDA    #$00                  ; F1F4
	STA    $86                   ; F1F6
LF1F8
	RTS                          ; F1F8
LF1F9
	LDA    $F8                   ; F1F9
	SEC                          ; F1FB
	SBC    $A0                   ; F1FC
	CMP    #$05                  ; F1FE
	BNE    LF1F8                 ; F200
	LDA    $F7                   ; F202
	AND    #$20                  ; F204
	BEQ    LF1F8                 ; F206
	LDX    $D7                   ; F208
	LDA    DFA7D,X               ; F20A
	STA    $D7                   ; F20D
	TAX                          ; F20F
	JMP    $B012                 ; F210
LF213
	INY                          ; F213
	INY                          ; F214
	CPY    #$70                  ; F215
	BCC    LF21B                 ; F217
	LDY    #$00                  ; F219
LF21B
	STY    $96                   ; F21B
	RTS                          ; F21D
LF21E
	LDY    #$C0                  ; F21E
	LDA    $BF,X                 ; F220
	AND    #$3F                  ; F222
	STA    $E7                   ; F224
	LSR                          ; F226
	CMP    $D5                   ; F227
	BCS    LF22D                 ; F229
	LDY    #$80                  ; F22B
LF22D
	TYA                          ; F22D
	ORA    $E7                   ; F22E
	STA    $BF,X                 ; F230
	LDA    $A5                   ; F232
	LSR                          ; F234
	SEC                          ; F235
	SBC    $BB                   ; F236
	BPL    LF23C                 ; F238
	EOR    #$FF                  ; F23A
LF23C
	LSR                          ; F23C
	STA    $E7                   ; F23D
	LDA    $BF,X                 ; F23F
	AND    #$3F                  ; F241
	LSR                          ; F243
	SEC                          ; F244
	SBC    $D5                   ; F245
	BPL    LF24B                 ; F247
	EOR    #$FF                  ; F249
LF24B
	CMP    $E7                   ; F24B
	BCS    LF255                 ; F24D
	LDA    $BF,X                 ; F24F
	AND    #$7F                  ; F251
	STA    $BF,X                 ; F253
LF255
	RTS                          ; F255
DF256
	.byte $01,$01,$01,$01,$03,$02,$03,$03
	.byte $01,$01,$01,$01,$01,$02,$01,$02
	.byte $02,$02,$02,$02,$03,$02,$03,$02
	.byte $03,$03,$03,$03,$04,$03,$04,$03
	.byte $00,$00,$00,$00,$02,$02,$02,$02
	.byte $01,$01,$01,$01,$02,$02,$02,$01
LF286
	LDY    $A7,X                 ; F286
	LDA    DFA8D,Y               ; F288
	AND    #$0E                  ; F28B
	ASL                          ; F28D
	ASL                          ; F28E
LF28F
	STA    $E8                   ; F28F
	LDA    $BF,X                 ; F291
	STA    $E7                   ; F293
	LDA    $80                   ; F295
	AND    #$0F                  ; F297
	LSR                          ; F299
	LSR                          ; F29A
	BIT    $E7                   ; F29B
	BPL    LF2A1                 ; F29D
	ORA    #$04                  ; F29F
LF2A1
	ORA    $E8                   ; F2A1
	TAY                          ; F2A3
	LDA    $E7                   ; F2A4
	AND    #$3F                  ; F2A6
	BVS    LF2B1                 ; F2A8
	CLC                          ; F2AA
	ADC    DF256,Y               ; F2AB
	JMP    LF2B7                 ; F2AE
LF2B1
	AND    #$3F                  ; F2B1
	SEC                          ; F2B3
	SBC    DF256,Y               ; F2B4
LF2B7
	BMI    LF2BD                 ; F2B7
	CMP    #$3C                  ; F2B9
	BCC    LF2C5                 ; F2BB
LF2BD
	SEC                          ; F2BD
	LDY    $A7,X                 ; F2BE
	LDA    #$00                  ; F2C0
	STA    $A7,X                 ; F2C2
	RTS                          ; F2C4
LF2C5
	STA    $E7                   ; F2C5
	LDA    $BF,X                 ; F2C7
	AND    #$C0                  ; F2C9
	ORA    $E7                   ; F2CB
	STA    $BF,X                 ; F2CD
	RTS                          ; F2CF
LF2D0
	LDA    #$28                  ; F2D0
	JSR    LF28F                 ; F2D2
	BCC    LF2DF                 ; F2D5
	LDA    $BF,X                 ; F2D7
	EOR    #$40                  ; F2D9
	STA    $BF,X                 ; F2DB
	STY    $A7,X                 ; F2DD
LF2DF
	RTS                          ; F2DF
DF2E0
	.byte $3A,$19,$1A,$1A,$1C,$1A,$1C,$1A
	.byte $1C,$1C,$1C,$1C
LF2EC
	LDA    $91                   ; F2EC
	AND    #$02                  ; F2EE
	BNE    LF34D                 ; F2F0
	LDA    $A0                   ; F2F2
	CMP    #$06                  ; F2F4
	BNE    LF31E                 ; F2F6
	LDA    $F7                   ; F2F8
	AND    #$1F                  ; F2FA
	CMP    #$06                  ; F2FC
	BNE    LF31E                 ; F2FE
	LDA    $91                   ; F300
	ORA    #$02                  ; F302
	STA    $91                   ; F304
	LDA    #$D8                  ; F306
	STA    $BA                   ; F308
	LDA    #$FF                  ; F30A
	STA    $B4                   ; F30C
	LDA    #$01                  ; F30E
	STA    $B5                   ; F310
	STA    $B3                   ; F312
	STA    $B8                   ; F314
	LDA    $82                   ; F316
	LSR                          ; F318
	BCS    LF31D                 ; F319
	ASL    $B8                   ; F31B
LF31D
	RTS                          ; F31D
LF31E
	LDA    $D7                   ; F31E
	ORA    #$0C                  ; F320
	STA    $D7                   ; F322
LF324
	TAX                          ; F324
	JSR    LFCEB                 ; F325
	LDA    $80                   ; F328
	AND    #$07                  ; F32A
	BNE    LF33C                 ; F32C
	LDA    $A7,X                 ; F32E
	AND    #$3F                  ; F330
	TAY                          ; F332
	LDA    $A7,X                 ; F333
	AND    #$C0                  ; F335
	ORA    DFD2F,Y               ; F337
	STA    $A7,X                 ; F33A
LF33C
	LDA    LF3A4+1,X             ; F33C
	CMP    $D7                   ; F33F
	BNE    LF324                 ; F341
	AND    #$03                  ; F343
	STA    $D7                   ; F345
	RTS                          ; F347
DF348
	.byte $00,$02,$03,$04,$01
LF34D
	LDA    $B8                   ; F34D
	CLC                          ; F34F
	LDX    $B3                   ; F350
	BEQ    LF3A9                 ; F352
	LDA    DF348,X               ; F354
	STA    $B3                   ; F357
	LDA    $A0                   ; F359
	AND    #$07                  ; F35B
	BNE    LF36B                 ; F35D
	LDA    $A0                   ; F35F
	LSR                          ; F361
	LSR                          ; F362
	LSR                          ; F363
	LSR                          ; F364
	TAX                          ; F365
	LDA    DF2E0,X               ; F366
	STA    $94                   ; F369
LF36B
	LDA    #$30                  ; F36B
	LDX    $B8                   ; F36D
	BMI    LF373                 ; F36F
	LDA    #$D0                  ; F371
LF373
	CLC                          ; F373
	ADC    $B9                   ; F374
	STA    $B9                   ; F376
	BCC    LF39C                 ; F378
	LDA    $B5                   ; F37A
	CMP    #$14                  ; F37C
	BCC    LF386                 ; F37E
	LDA    $B8                   ; F380
	EOR    #$FF                  ; F382
	STA    $B8                   ; F384
LF386
	LDA    $B8                   ; F386
	BPL    LF393                 ; F388
	LDA    $B5                   ; F38A
	BNE    LF3A9                 ; F38C
	LDA    $B4                   ; F38E
	BPL    LF3A3                 ; F390
	RTS                          ; F392
LF393
	LDA    $BA                   ; F393
	BPL    LF39D                 ; F395
	CLC                          ; F397
	ADC    $B8                   ; F398
	STA    $BA                   ; F39A
LF39C
	RTS                          ; F39C
LF39D
	LDA    $B4                   ; F39D
	CMP    #$0B                  ; F39F
	BEQ    LF3A9                 ; F3A1
LF3A3
	CLC                          ; F3A3
LF3A4
	ADC    $B8                   ; F3A4
	STA    $B4                   ; F3A6
	RTS                          ; F3A8
LF3A9
	CLC                          ; F3A9
	LDA    $B5                   ; F3AA
	ADC    $B8                   ; F3AC
	STA    $B5                   ; F3AE
	RTS                          ; F3B0
	.byte $0F,$0C,$0D,$0E
LF3B5
	LDA    $97                   ; F3B5
	BEQ    LF3BC                 ; F3B7
	JMP    LF424                 ; F3B9
LF3BC
	LDA    $80                   ; F3BC
	AND    #$03                  ; F3BE
	BNE    LF3D0                 ; F3C0
	JSR    LF2EC                 ; F3C2
	LDX    $D6                   ; F3C5
	STX    $A6                   ; F3C7
	LDA    $D8                   ; F3C9
	STA    $A5                   ; F3CB
	JMP    LF403                 ; F3CD
LF3D0
	LDA    #$03                  ; F3D0
	STA    $EB                   ; F3D2
	LDX    $A6                   ; F3D4
LF3D6
	JSR    LFBDE                 ; F3D6
	LDY    $A7,X                 ; F3D9
	LDA    DFAD7,Y               ; F3DB
	STA    $A7,X                 ; F3DE
LF3E0
	LDA    DFA71,X               ; F3E0
	TAX                          ; F3E3
	LDA    $A7,X                 ; F3E4
	TAY                          ; F3E6
	LDA    #$04                  ; F3E7
	STA    $E7                   ; F3E9
	LDA    DFA8D,Y               ; F3EB
	LSR                          ; F3EE
	BCC    LF3F3                 ; F3EF
	ASL    $E7                   ; F3F1
LF3F3
	LDA    $E7                   ; F3F3
	CLC                          ; F3F5
	ADC    $A5                   ; F3F6
	CLC                          ; F3F8
	ADC    #$04                  ; F3F9
	STA    $A5                   ; F3FB
	DEC    $EB                   ; F3FD
	BPL    LF3D6                 ; F3FF
	STX    $A6                   ; F401
LF403
	JSR    LF126                 ; F403
	LDA    $80                   ; F406
	AND    #$03                  ; F408
	STA    $E7                   ; F40A
	BNE    LF419                 ; F40C
	JSR    LF98F                 ; F40E
	JMP    LF424                 ; F411
DF414
	.byte $E7,$E7,$F3,$FF,$0B
LF419
	LDX    #$03                  ; F419
LF41B
	LDA    $BB,X                 ; F41B
	BMI    LF421                 ; F41D
	DEC    $BB,X                 ; F41F
LF421
	DEX                          ; F421
	BNE    LF41B                 ; F422
LF424
	LDX    #$B7                  ; F424
	STX    $F0                   ; F426
	INX                          ; F428
	STX    $F2                   ; F429
	LDA    #$25                  ; F42B
	STA    NUSIZ1                ; F42D
	LDA    #$7B                  ; F42F
	STA    $D9                   ; F431
	LDA    $91                   ; F433
	AND    #$02                  ; F435
	BEQ    LF45C                 ; F437
	LDX    $B3                   ; F439
	LDA    DF414,X               ; F43B
	STA    $EF                   ; F43E
	JSR    FAR_ANDORPAGE         ; F440  FIX: core frame at $BF0B was read from $BE0B
	NOP                          ; F443
	LDA    #$00                  ; F444
	STA    $F8                   ; F446
	LDA    DFA38                 ; F448
	STA    $FA                   ; F44B
	LDA    $B4                   ; F44D
	STA    $F6                   ; F44F
	LDX    #$E0                  ; F451
	STX    $D9                   ; F453
	LDA    #$27                  ; F455
	STA    NUSIZ1                ; F457
	JMP    LF4A7                 ; F459
LF45C
	LDX    #$03                  ; F45C
LF45E
	LDA    $CB,X                 ; F45E
	LSR                          ; F460
	AND    #$1F                  ; F461
	TAY                          ; F463
	LDA    DFA2D,Y               ; F464
	STA    $FA,X                 ; F467
	DEX                          ; F469
	BPL    LF45E                 ; F46A
	LDA    $91                   ; F46C
	AND    #$08                  ; F46E
	BEQ    LF496                 ; F470
	LDX    $D7                   ; F472
	STX    $F8                   ; F474
	LDA    $B7,X                 ; F476
	TAY                          ; F478
	LDA    DF48E,Y               ; F479
	STA    $D9                   ; F47C
	LDA    DF486,Y               ; F47E
	STA    $F6                   ; F481
	JMP    LF4A7                 ; F483
DF486
	.byte $FF,$FF,$00,$01,$02,$03,$03,$03
DF48E
	.byte $7B,$7B,$7B,$7B,$7B,$7B,$34,$2E
LF496
	LDX    $D7                   ; F496
	STX    $F8                   ; F498
	LDA    DFA7D,X               ; F49A
	STA    $F8                   ; F49D
	LDA    #$FF                  ; F49F
	STA    $F6                   ; F4A1
	LDA    #$7B                  ; F4A3
	STA    $D9                   ; F4A5
LF4A7
	LDA    $D6                   ; F4A7
	STA    $F7                   ; F4A9
	LDX    #$03                  ; F4AB
LF4AD
	LDA    $BB,X                 ; F4AD
	BPL    LF4B4                 ; F4AF
	DEX                          ; F4B1
	BNE    LF4AD                 ; F4B2
LF4B4
	STX    $F9                   ; F4B4
	STX    $E3                   ; F4B6
	LDA    #$88                  ; F4B8
	STA    $DD                   ; F4BA
	LDA    #$B1                  ; F4BC
	STA    $DE                   ; F4BE
	STA    WSYNC                 ; F4C0
	NOP                          ; F4C2
	NOP                          ; F4C3
	NOP                          ; F4C4
	INC    $E7                   ; F4C5
	INC    $E7                   ; F4C7
	INC    $E7                   ; F4C9
	LDX    $F8                   ; F4CB
	LDA    $FA,X                 ; F4CD
	ASL                          ; F4CF
	STA    HMP1                  ; F4D0
	STA    RESP1                 ; F4D2
	INC    $E7                   ; F4D4
	INC    $E7                   ; F4D6
	INC    $E7                   ; F4D8
	BCC    LF4DE                 ; F4DA
	STA    RESP1                 ; F4DC
LF4DE
	LDA    $A0                   ; F4DE
	STA    $E4                   ; F4E0
	LDA    #$00                  ; F4E2
	STA    $E5                   ; F4E4
	STA    $F4                   ; F4E6
	STA    $F3                   ; F4E8
	LDA    $D8                   ; F4EA
	STA    $F5                   ; F4EC
	INC    $E7                   ; F4EE
	LDA    $E6                   ; F4F0
	EOR    #$E0                  ; F4F2
	ORA    #$12                  ; F4F4
	STA    $E6                   ; F4F6
	LDX    #$B4                  ; F4F8
	STX    $EC                   ; F4FA
	INX                          ; F4FC
	STX    $EE                   ; F4FD
	LDA    #$00                  ; F4FF
	STA    $EB                   ; F501
	STA    $ED                   ; F503
	LDA    #$9A                  ; F505
	STA    $DB                   ; F507
	LDA    #$B2                  ; F509
	STA    $DC                   ; F50B
	LDA    #$B3                  ; F50D
	STA    $DA                   ; F50F
	LDA    #$88                  ; F511
	STA    $DD                   ; F513
	LDA    #$B1                  ; F515
	STA    $DE                   ; F517
	STA    WSYNC                 ; F519
	JSR    LF5BB                 ; F51B
	JSR    LF5BB                 ; F51E
	INC    $E7                   ; F521
	NOP                          ; F523
	NOP                          ; F524
	NOP                          ; F525
	STA    RESM0                 ; F526
	LDA    $D3                   ; F528
	LDA    $D3                   ; F52A
	LDA    $D3                   ; F52C
	ASL                          ; F52E
	STA    HMM0                  ; F52F
	BCC    LF535                 ; F531
	STA    RESM0                 ; F533
LF535
	STA    WSYNC                 ; F535
	STA    HMOVE                 ; F537
	LDA    $D3                   ; F539
	AND    #$07                  ; F53B
	ASL                          ; F53D
	STA    $E7                   ; F53E
	BEQ    LF567                 ; F540
	LDA    $E6                   ; F542
	EOR    #$01                  ; F544
	STA    $E6                   ; F546
	LSR                          ; F548
	BCS    LF55F                 ; F549
	AND    #$02                  ; F54B
	BEQ    LF557                 ; F54D
	LDA    $E6                   ; F54F
	AND    #$FB                  ; F551
	STA    $E6                   ; F553
	DEC    $D3                   ; F555
LF557
	SEC                          ; F557
	LDA    $D4                   ; F558
	SBC    $E7                   ; F55A
	JMP    LF572                 ; F55C
LF55F
	CLC                          ; F55F
	LDA    $D4                   ; F560
	ADC    $E7                   ; F562
	JMP    LF572                 ; F564
LF567
	LDA    $CF                   ; F567
	AND    #$F8                  ; F569
	STA    $D3                   ; F56B
	LDA    $BB                   ; F56D
	CLC                          ; F56F
	SBC    #$0B                  ; F570
LF572
	STA    $D4                   ; F572
	STA    WSYNC                 ; F574
	STA    HMOVE                 ; F576
	STA    WSYNC                 ; F578
	STA    HMOVE                 ; F57A
	JSR    LF5BB                 ; F57C
	JSR    LF5BB                 ; F57F
	JSR    LF5BB                 ; F582
	STA    WSYNC                 ; F585
	STA    HMOVE                 ; F587
	JSR    LF5BB                 ; F589
	JSR    LF5BB                 ; F58C
	JSR    LF5BB                 ; F58F
	LDA    #$50                  ; F592
	STA    HMM0                  ; F594
	LDA    #$00                  ; F596
	STA    HMP1                  ; F598
	STA    WSYNC                 ; F59A
	STA    HMOVE                 ; F59C
	JSR    LF5BB                 ; F59E
	JSR    LF5BB                 ; F5A1
	JSR    LF5BB                 ; F5A4
	LDA    #$00                  ; F5A7
	STA    HMM0                  ; F5A9
	LDA    #$47                  ; F5AB
	STA    $DF                   ; F5AD
	LDA    $DE                   ; F5AF
	STA    $E0                   ; F5B1
	JMP    LF09E                 ; F5B3
LF5B6
	LDA    $80                   ; F5B6
	LSR                          ; F5B8
	BCS    LF5BC                 ; F5B9
LF5BB
	RTS                          ; F5BB
LF5BC
	LDA    $91                   ; F5BC
	BMI    LF5C7                 ; F5BE
	AND    #$01                  ; F5C0
	TAX                          ; F5C2
	LDA    $3C,X                 ; F5C3
	BMI    LF620                 ; F5C5
LF5C7
	LDA    $BE                   ; F5C7
	BPL    LF5F4                 ; F5C9
	LDA    $BC                   ; F5CB
	CLC                          ; F5CD
	ADC    #$0D                  ; F5CE
	CMP    $BB                   ; F5D0
	BCS    LF5F4                 ; F5D2
	LDA    $BD                   ; F5D4
	STA    $BE                   ; F5D6
	LDA    $BC                   ; F5D8
	STA    $BD                   ; F5DA
	LDA    $D1                   ; F5DC
	STA    $D2                   ; F5DE
	LDA    $D0                   ; F5E0
	STA    $D1                   ; F5E2
	LDA    $CF                   ; F5E4
	STA    $D0                   ; F5E6
	LDA    $BB                   ; F5E8
	CLC                          ; F5EA
	SBC    #$04                  ; F5EB
	STA    $BC                   ; F5ED
	LDY    #$01                  ; F5EF
	JSR    $B018                 ; F5F1
LF5F4
	LDA    $91                   ; F5F4
	BMI    LF5FC                 ; F5F6
	AND    #$10                  ; F5F8
	BEQ    LF619                 ; F5FA
LF5FC
	LDA    $D3                   ; F5FC
	AND    #$07                  ; F5FE
	BNE    LF619                 ; F600
	LDA    $CF                   ; F602
	ORA    #$07                  ; F604
	STA    $D3                   ; F606
	LDA    $BB                   ; F608
	CLC                          ; F60A
	SBC    #$0B                  ; F60B
	STA    $D4                   ; F60D
	LDA    $E6                   ; F60F
	AND    #$FA                  ; F611
	STA    $E6                   ; F613
	LDA    #$E0                  ; F615
	STA    $9D                   ; F617
LF619
	LDA    $91                   ; F619
	AND    #$EF                  ; F61B
	STA    $91                   ; F61D
	RTS                          ; F61F
LF620
	LDA    $91                   ; F620
	ORA    #$10                  ; F622
	STA    $91                   ; F624
	RTS                          ; F626
LF627
	LDA    $97                   ; F627
	BEQ    LF6A4                 ; F629
	DEC    $97                   ; F62B
	BNE    LF6A4                 ; F62D
	LDA    $91                   ; F62F
	AND    #$20                  ; F631
	BEQ    LF6A4                 ; F633
	LDA    $91                   ; F635
	EOR    #$20                  ; F637
	AND    #$F5                  ; F639
	STA    $91                   ; F63B
	LDA    $91                   ; F63D
	BMI    LF6A1                 ; F63F
	DEC    $85                   ; F641
	LDA    $86                   ; F643
	CMP    #$06                  ; F645
	BCC    LF64D                 ; F647
	SBC    #$04                  ; F649
	STA    $86                   ; F64B
LF64D
	LDX    $87                   ; F64D
	LDA    DFA0D,X               ; F64F
	CMP    $9E                   ; F652
	BCS    LF659                 ; F654
	JSR    LF938                 ; F656
LF659
	LDA    $93                   ; F659
	AND    #$01                  ; F65B
	BEQ    LF679                 ; F65D
	LDX    #$05                  ; F65F
	LDA    $8B                   ; F661
	BMI    LF679                 ; F663
	LDA    $91                   ; F665
	EOR    #$01                  ; F667
	STA    $91                   ; F669
LF66B
	LDA    $85,X                 ; F66B
	LDY    $8B,X                 ; F66D
	STY    $85,X                 ; F66F
	STA    $8B,X                 ; F671
	DEX                          ; F673
	BPL    LF66B                 ; F674
	JMP    LF8F5                 ; F676
LF679
	LDA    $85                   ; F679
	BMI    LF680                 ; F67B
	JMP    LF8F5                 ; F67D
LF680
	LDA    $91                   ; F680
	AND    #$01                  ; F682
	BEQ    LF693                 ; F684
	LDX    #$05                  ; F686
LF688
	LDA    $85,X                 ; F688
	LDY    $8B,X                 ; F68A
	STY    $85,X                 ; F68C
	STA    $8B,X                 ; F68E
	DEX                          ; F690
	BPL    LF688                 ; F691
LF693
	LDA    $87                   ; F693
	STA    $A4                   ; F695
	LDA    #$00                  ; F697
	STA    $81                   ; F699
	LDA    #$80                  ; F69B
	STA    $80                   ; F69D
	STA    $91                   ; F69F
LF6A1
	JMP    LF8FA                 ; F6A1
LF6A4
	BIT    $30                   ; F6A4
	BPL    LF70B                 ; F6A6
	LDA    $D3                   ; F6A8
	AND    #$07                  ; F6AA
	CMP    #$01                  ; F6AC
	BNE    LF70B                 ; F6AE
	LDA    $91                   ; F6B0
	AND    #$02                  ; F6B2
	BEQ    LF6F1                 ; F6B4
	LDA    $D3                   ; F6B6
	AND    #$F8                  ; F6B8
	CMP    DFA3B                 ; F6BA
	BEQ    LF6CE                 ; F6BD
	CMP    DFA3C                 ; F6BF
	BEQ    LF6CE                 ; F6C2
	CMP    DFA3D                 ; F6C4
	BEQ    LF6CE                 ; F6C7
	CMP    DFA3E                 ; F6C9
	BNE    LF70B                 ; F6CC
LF6CE
	LDA    $B5                   ; F6CE
	CLC                          ; F6D0
	ADC    #$05                  ; F6D1
	CMP    $D4                   ; F6D3
	BCS    LF70B                 ; F6D5
	ADC    #$02                  ; F6D7
	CMP    $D4                   ; F6D9
	BCC    LF70B                 ; F6DB
	LDA    $B8                   ; F6DD
	BPL    LF6E5                 ; F6DF
	EOR    #$FF                  ; F6E1
	STA    $B8                   ; F6E3
LF6E5
	LDA    #$00                  ; F6E5
	STA    $B3                   ; F6E7
	LDY    #$0B                  ; F6E9
	JSR    LF964                 ; F6EB
	JMP    LF70B                 ; F6EE
LF6F1
	LDX    $E1                   ; F6F1
	LDA    $B3,X                 ; F6F3
	AND    #$3F                  ; F6F5
	TAY                          ; F6F7
	CMP    #$09                  ; F6F8
	BCC    LF70B                 ; F6FA
	LDA    #$01                  ; F6FC
	STA    $B3,X                 ; F6FE
	LDA    DFD14,Y               ; F700
	JSR    LF964                 ; F703
	LDY    #$03                  ; F706
	JSR    $B018                 ; F708
LF70B
	BIT    $31                   ; F70B
	BPL    LF770                 ; F70D
	LDX    $E2                   ; F70F
	LDA    $A7,X                 ; F711
	CMP    #$44                  ; F713
	BCS    LF770                 ; F715
	LDX    $E3                   ; F717
	BNE    LF73B                 ; F719
	LDA    $97                   ; F71B
	BNE    LF770                 ; F71D
	LDA    $91                   ; F71F
	BMI    LF770                 ; F721
	LDA    #$64                  ; F723
	LDY    $85                   ; F725
	BEQ    LF72B                 ; F727
	LDA    #$1E                  ; F729
LF72B
	STA    $97                   ; F72B
	LDA    #$20                  ; F72D
	ORA    $91                   ; F72F
	STA    $91                   ; F731
	LDY    #$08                  ; F733
	JSR    $B018                 ; F735
	JMP    LF770                 ; F738
LF73B
	LDY    $E2                   ; F73B
	LDA.w  $00A7,Y               ; F73D
	CMP    #$41                  ; F740
	BCS    LF770                 ; F742
LF744
	CPX    #$03                  ; F744
	BCS    LF754                 ; F746
	LDA    $D0,X                 ; F748
	STA    $CF,X                 ; F74A
	LDA    $BC,X                 ; F74C
	STA    $BB,X                 ; F74E
	INX                          ; F750
	JMP    LF744                 ; F751
LF754
	LDA    #$FF                  ; F754
	STA    $BE                   ; F756
	LDX    $E2                   ; F758
	LDA    $A7,X                 ; F75A
	TAY                          ; F75C
	CMP    #$31                  ; F75D
	BCS    LF770                 ; F75F
	LDA    #$44                  ; F761
	STA    $A7,X                 ; F763
	JSR    LF964                 ; F765
	LDA    DFB94,Y               ; F768
	LDY    #$02                  ; F76B
	JSR    $B018                 ; F76D
LF770
	JSR    LF5B6                 ; F770
	LDA    $80                   ; F773
	AND    #$0F                  ; F775
	CMP    #$07                  ; F777
	BNE    LF77E                 ; F779
	JSR    LF792                 ; F77B
LF77E
	JMP    LF03E                 ; F77E
LF781
	LDY    $D6                   ; F781
	LDX    $A7,Y                 ; F783
	LDA    #$04                  ; F785
	STA    $E7                   ; F787
	LDA    DFA8D,X               ; F789
	LSR                          ; F78C
	BCC    LF791                 ; F78D
	ASL    $E7                   ; F78F
LF791
	RTS                          ; F791
LF792
	LDA    $97                   ; F792
	BEQ    LF797                 ; F794
LF796
	RTS                          ; F796
LF797
	LDA    $82                   ; F797
	AND    #$02                  ; F799
	BEQ    LF7C2                 ; F79B
	DEC    $D8                   ; F79D
	BPL    LF7C1                 ; F79F
	LDY    $D6                   ; F7A1
	LDA.w  $00A7,Y               ; F7A3
	CMP    #$02                  ; F7A6
	BNE    LF7B0                 ; F7A8
	LDA    $82                   ; F7AA
	AND    #$FD                  ; F7AC
	STA    $82                   ; F7AE
LF7B0
	LDA    #$00                  ; F7B0
	STA.w  $00A7,Y               ; F7B2
	LDA    DFA71,Y               ; F7B5
	STA    $D6                   ; F7B8
	JSR    LF781                 ; F7BA
	LDA    $E7                   ; F7BD
	STA    $D8                   ; F7BF
LF7C1
	RTS                          ; F7C1
LF7C2
	JSR    LF781                 ; F7C2
	LDA    $E7                   ; F7C5
	INC    $D8                   ; F7C7
	INC    $D8                   ; F7C9
	CMP    $D8                   ; F7CB
	BCS    LF796                 ; F7CD
	LDA    #$FF                  ; F7CF
	STA    $D8                   ; F7D1
	LDX    DFA81,Y               ; F7D3
	STX    $D6                   ; F7D6
	LDA    $84                   ; F7D8
	STA    $BF,X                 ; F7DA
	LDA    $D6                   ; F7DC
	STA    $E9                   ; F7DE
	LDA    $93                   ; F7E0
	AND    #$04                  ; F7E2
	BEQ    LF7EF                 ; F7E4
	LSR    $E9                   ; F7E6
	BCC    LF7EF                 ; F7E8
	LDA    #$01                  ; F7EA
	STA    $A7,X                 ; F7EC
	RTS                          ; F7EE
LF7EF
	LDX    $95                   ; F7EF
	LDA    DFB67,X               ; F7F1
	STA    $E7                   ; F7F4
	AND    #$40                  ; F7F6
	BEQ    LF826                 ; F7F8
	LDA    $E9                   ; F7FA
	LSR                          ; F7FC
	BCS    LF814                 ; F7FD
	LSR                          ; F7FF
	BCS    LF808                 ; F800
	LDA    $E7                   ; F802
	AND    #$20                  ; F804
	BNE    LF82C                 ; F806
LF808
	LDA    $D6                   ; F808
	TAX                          ; F80A
	LDA    $84                   ; F80B
	AND    #$07                  ; F80D
	ADC    #$31                  ; F80F
	STA    $A7,X                 ; F811
	RTS                          ; F813
LF814
	LDA    #$00                  ; F814
	LDX    $D6                   ; F816
	STA    $A7,X                 ; F818
	RTS                          ; F81A
LF81B
	AND    #$7F                  ; F81B
	STA    $94                   ; F81D
	LDA    #$02                  ; F81F
	LDX    $D6                   ; F821
	STA    $A7,X                 ; F823
	RTS                          ; F825
LF826
	LDA    $E9                   ; F826
	AND    #$03                  ; F828
	BEQ    LF814                 ; F82A
LF82C
	LDA    $94                   ; F82C
	BEQ    LF814                 ; F82E
	BMI    LF81B                 ; F830
	AND    #$07                  ; F832
	STA    $E7                   ; F834
	LDA    $94                   ; F836
	LSR                          ; F838
	LSR                          ; F839
	AND    #$0E                  ; F83A
	TAY                          ; F83C
	DEC    $94                   ; F83D
	LDA    $E7                   ; F83F
	BNE    LF845                 ; F841
	STA    $94                   ; F843
LF845
	LDA    DF859,Y               ; F845
	LDX    $D6                   ; F848
	STA    $A7,X                 ; F84A
	LDA    DF869,Y               ; F84C
	STA    $DF                   ; F84F
	LDA    DF86A,Y               ; F851
	STA    $E0                   ; F854
	JMP    ($00DF)               ; F856
DF859
	.byte $22
DF85A
	.byte $22,$1A,$12,$06,$06,$2F,$2F,$0E
	.byte $0A,$03,$03,$00,$00,$31,$31
DF869
	.byte $AC
DF86A
	.byte $F8
	.word LF879                ; F86B
	.word LF8C1                ; F86D
	.word LF8AC                ; F86F
	.word LF879                ; F871
	.word LF8AC                ; F873
	.byte $C0,$F8,$C0,$F8
LF879
	LDA    #$00                  ; F879
	STA    $E7                   ; F87B
	LDA    $BF,X                 ; F87D
	ORA    #$40                  ; F87F
	STA    $E8                   ; F881
	AND    #$3F                  ; F883
	STA    $E9                   ; F885
	AND    #$20                  ; F887
	BEQ    LF898                 ; F889
	LDA    DF85A,Y               ; F88B
	STA    $A7,X                 ; F88E
	LDA    $E8                   ; F890
	EOR    #$40                  ; F892
	STA    $E8                   ; F894
	DEC    $E7                   ; F896
LF898
	LDA    $E7                   ; F898
	EOR    #$10                  ; F89A
	CLC                          ; F89C
	ADC    $E9                   ; F89D
	AND    #$3F                  ; F89F
	STA    $E9                   ; F8A1
	LDA    $E8                   ; F8A3
	AND    #$C0                  ; F8A5
	ORA    $E9                   ; F8A7
	STA    $BF,X                 ; F8A9
	RTS                          ; F8AB
LF8AC
	LDA    $BF,X                 ; F8AC
	AND    #$BF                  ; F8AE
	STA    $E7                   ; F8B0
	AND    #$20                  ; F8B2
	BEQ    LF8BC                 ; F8B4
	LDA    $E7                   ; F8B6
	ORA    #$40                  ; F8B8
	STA    $E7                   ; F8BA
LF8BC
	LDA    $E7                   ; F8BC
	STA    $BF,X                 ; F8BE
	RTS                          ; F8C0
LF8C1
	LDA    $94                   ; F8C1
	AND    #$03                  ; F8C3
	CLC                          ; F8C5
	ADC    $A7,X                 ; F8C6
	STA    $A7,X                 ; F8C8
	LDA    $BF,X                 ; F8CA
	AND    #$3F                  ; F8CC
	STA    $BF,X                 ; F8CE
	RTS                          ; F8D0
LF8D1
	LDA    #$00                  ; F8D1
	STA    $87                   ; F8D3
	STA    $8D                   ; F8D5
LF8D7
	LDA    #$00                  ; F8D7
	STA    $91                   ; F8D9
	STA    $94                   ; F8DB
	STA    $81                   ; F8DD
	STA    $86                   ; F8DF
	STA    $8C                   ; F8E1
	STA    $88                   ; F8E3
	STA    $89                   ; F8E5
	STA    $8A                   ; F8E7
	STA    $8E                   ; F8E9
	STA    $8F                   ; F8EB
	STA    $90                   ; F8ED
	LDA    #$04                  ; F8EF
	STA    $85                   ; F8F1
	STA    $8B                   ; F8F3
LF8F5
	LDY    #$09                  ; F8F5
	JSR    $B018                 ; F8F7
LF8FA
	LDA    #$00                  ; F8FA
	STA    $E6                   ; F8FC
	LDX    #$0F                  ; F8FE
	LDA    #$00                  ; F900
LF902
	STA    $A7,X                 ; F902
	DEX                          ; F904
	BPL    LF902                 ; F905
	LDA    $82                   ; F907
	AND    #$FD                  ; F909
	STA    $82                   ; F90B
	LDA    #$00                  ; F90D
	STA    $D7                   ; F90F
	STA    $D6                   ; F911
	STA    $A0                   ; F913
	STA    $F8                   ; F915
	STA    $94                   ; F917
	LDA    #$01                  ; F919
	STA    $9E                   ; F91B
	LDA    $80                   ; F91D
	ORA    #$07                  ; F91F
	STA    $80                   ; F921
	LDA    #$0F                  ; F923
	STA    $D5                   ; F925
	LDA    DFA3C                 ; F927
	STA    $D3                   ; F92A
	STA    $CF                   ; F92C
	LDA    #$1F                  ; F92E
	STA    $BB                   ; F930
	JSR    LF940                 ; F932
	JMP    LF03E                 ; F935
LF938
	INC    $87                   ; F938
	LDA    $87                   ; F93A
	AND    #$0F                  ; F93C
	STA    $87                   ; F93E
LF940
	LDY    $87                   ; F940
	LDA    DF9FD,Y               ; F942
	STA    $96                   ; F945
	LDA    DF9ED,Y               ; F947
	STA    $95                   ; F94A
	RTS                          ; F94C
DF94D
	.byte $10,$30,$50,$00,$50,$00,$00,$00
	.byte $00,$00,$00
DF958	; FIX: hundreds byte is BCD; prototype had decimal 10/20/75 typed as hex
	.byte $00,$00,$00,$01,$01,$02,$03,$07
	.byte $08,$10,$20,$75
LF964
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
LF98F
	LDA    $91                   ; F98F
	BPL    LF9A0                 ; F991
	LDA    $80                   ; F993
	LSR                          ; F995
	LSR                          ; F996
	LDX    $80                   ; F997
	BMI    LF99D                 ; F999
	EOR    #$FF                  ; F99B
LF99D
	JMP    LF9E0                 ; F99D
LF9A0
	LSR                          ; F9A0
	LDA    SWCHA                 ; F9A1
	BCC    LF9AA                 ; F9A4
	ASL                          ; F9A6
	ASL                          ; F9A7
	ASL                          ; F9A8
	ASL                          ; F9A9
LF9AA
	STA    $E7                   ; F9AA
	ASL                          ; F9AC
	ASL                          ; F9AD
	BMI    LF9BB                 ; F9AE
	LDA    $BB                   ; F9B0
	CMP    #$26                  ; F9B2
	BCS    LF9C6                 ; F9B4
	INC    $BB                   ; F9B6
	JMP    LF9C6                 ; F9B8
LF9BB
	ASL                          ; F9BB
	BMI    LF9C6                 ; F9BC
	LDA    $BB                   ; F9BE
	CMP    #$0E                  ; F9C0
	BCC    LF9C6                 ; F9C2
	DEC    $BB                   ; F9C4
LF9C6
	LDA    $E7                   ; F9C6
	BMI    LF9D5                 ; F9C8
	LDA    $D5                   ; F9CA
	CMP    #$1F                  ; F9CC
	BEQ    LF9DE                 ; F9CE
	INC    $D5                   ; F9D0
	JMP    LF9DE                 ; F9D2
LF9D5
	ASL                          ; F9D5
	BMI    LF9DE                 ; F9D6
	LDA    $D5                   ; F9D8
	BEQ    LF9DE                 ; F9DA
	DEC    $D5                   ; F9DC
LF9DE
	LDA    $D5                   ; F9DE
LF9E0
	AND    #$1F                  ; F9E0
	TAX                          ; F9E2
	LDA    $CF                   ; F9E3
	AND    #$07                  ; F9E5
	ORA    DFA2D,X               ; F9E7
	STA    $CF                   ; F9EA
	RTS                          ; F9EC
DF9ED
	.byte $19,$19,$19,$00,$1A,$1D,$00,$1D
	.byte $05,$1F,$1F,$0A,$23,$0E,$1F,$13
DF9FD
	.byte $02,$3C,$4E,$56,$68,$56,$56,$26
	.byte $14,$56,$68,$68,$68,$68,$56,$68
DFA0D
	.byte $10,$0F,$0E,$14,$11,$0E,$11,$12
	.byte $11,$13,$14,$13,$0D,$0D,$14,$10
DFA1D
	.byte $16,$16,$14,$1B,$17,$14,$18,$18
	.byte $17,$16,$1D,$15,$14,$10,$1C,$14
DFA2D
	.byte $38,$30,$28,$20,$18,$10,$08,$00
	.byte $78,$70,$68
DFA38
	.byte $60,$58,$50
DFA3B
	.byte $48
DFA3C
	.byte $B8
DFA3D
	.byte $B0
DFA3E
	.byte $A8,$A0,$98,$90,$88,$80,$F8,$F0
	.byte $E8,$E0,$D8,$D0,$C8,$C8,$C8
DFA4D
	.byte $07,$06,$05,$04,$03,$02,$01,$00
	.byte $0E,$0E,$0D,$0C,$0B,$0A,$09,$08
	.byte $16,$15,$14,$13,$12,$11,$10,$0F
	.byte $1D,$1D,$1C,$1B,$1A,$19,$18,$17
	.byte $03,$00,$01,$02
DFA71
	.byte $0B,$00,$01,$02,$03,$04,$05,$06
	.byte $07,$08,$09,$0A
DFA7D
	.byte $01,$02,$03,$00
DFA81
	.byte $01,$02,$03,$04,$05,$06,$07,$08
	.byte $09,$0A,$0B,$00
DFA8D
	.byte $00,$00,$00,$02,$02,$02,$08,$08
	.byte $08,$08,$02,$00,$00,$04,$02,$00
	.byte $00,$04,$04,$00,$00,$00,$00,$00
	.byte $00,$06,$04,$00,$00,$00,$00,$00
	.byte $00,$06,$02,$02,$02,$02,$02,$02
	.byte $02,$02,$02,$02,$02,$02,$02,$00
	.byte $02,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00
DFAD7
	.byte $00,$01,$02,$04,$05,$03,$07,$08
	.byte $09,$06,$0A,$0C,$0D,$0D,$0E,$10
	.byte $11,$11,$12,$14,$15,$16,$17,$18
	.byte $19,$19,$1A,$1C,$1D,$1E,$1F,$20
	.byte $21,$21,$22,$24,$25,$26,$27,$28
	.byte $29,$2A,$2B,$2C,$2D,$2E,$23,$2F
	.byte $30,$32,$33,$34,$35,$36,$37,$38
	.byte $39,$3A,$3B,$3C,$3D,$3E,$3F,$40
	.byte $31,$41,$41,$41,$45,$46,$47,$48
	.byte $49,$00,$0E,$0C,$0A,$08,$06,$04
	.byte $02,$00,$00,$1C,$1A,$18,$16,$14
	.byte $12,$10,$2C,$2A,$28,$26,$24,$22
	.byte $20,$1E,$00,$3A,$38,$36,$34,$32
	.byte $30,$2E
DFB41
	.byte $02,$03,$02,$03,$12,$04,$03,$12
	.byte $23,$06,$13,$2D,$0A,$23,$23,$2A
	.byte $16,$0A,$1C,$14,$14,$2A,$23,$14
	.byte $2D,$0A,$23,$1C,$0E,$1C,$1C,$12
	.byte $16,$17,$1C,$14,$2D,$03
DFB67
	.byte $00,$42,$42,$42,$00,$00,$43,$00
	.byte $44,$00,$00,$42,$62,$00,$00,$42
	.byte $44,$44,$00,$00,$62,$62,$62,$62
	.byte $00,$03,$00,$01,$02,$03,$06,$02
	.byte $03,$04,$05,$02,$03,$04,$05,$06
	.byte $07,$04,$05,$06,$07
DFB94
	.byte $02,$00,$04,$36,$36,$36,$38,$38
	.byte $38,$38,$65,$60,$60,$61,$65,$60
	.byte $60,$61,$75,$70,$70,$70,$70,$70
	.byte $70,$71,$75,$70,$70,$70,$70,$70
	.byte $70,$71,$15,$11,$11,$11,$11,$11
	.byte $11,$11,$11,$11,$11,$11,$11,$03
	.byte $59,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$01,$07,$00,$00,$00,$00,$00
	.byte $00,$00
LFBDE
	CPX    $D6                   ; FBDE
	BNE    LFBE3                 ; FBE0
	RTS                          ; FBE2
LFBE3
	LDA    $A7,X                 ; FBE3
	TAY                          ; FBE5
	LDA    DFB94,Y               ; FBE6
	AND    #$0F                  ; FBE9
	ASL                          ; FBEB
	TAY                          ; FBEC
	LDA    DFC03,Y               ; FBED
	STA    $DF                   ; FBF0
	LDA    DFC04,Y               ; FBF2
	STA    $E0                   ; FBF5
	LDA    #$00                  ; FBF7
	STA    $E8                   ; FBF9
	LDA    $A5                   ; FBFB
	LSR                          ; FBFD
	STA    $E7                   ; FBFE
	JMP    ($00DF)               ; FC00
DFC03
	.byte $59
DFC04
	.byte $FC,$1B,$FC
	.word LFC43                ; FC07
	.word LFCC0                ; FC09
	.byte $A0,$FC
	.word LFCAB                ; FC0D
	.word LFC17                ; FC0F
	.word LFCD1                ; FC11
	.word LFC1E                ; FC13
	.word LFCD4                ; FC15
LFC17
	AND    #$0F                  ; FC17
	BEQ    LFC30                 ; FC19
LFC1B
	JMP    LF286                 ; FC1B
LFC1E
	LDA    #$80                  ; FC1E
	STA    $E8                   ; FC20
	LDA    $BF,X                 ; FC22
	BMI    LFC1B                 ; FC24
	LDY    $D4                   ; FC26
	CPY    $E7                   ; FC28
	BCC    LFC1B                 ; FC2A
	ORA    $E8                   ; FC2C
	STA    $BF,X                 ; FC2E
LFC30
	JMP    LF21E                 ; FC30
DFC33
	.byte $10,$02,$20,$02,$40,$20,$60,$20
	.byte $80,$40,$A0,$80,$C0,$80,$F0,$A0
LFC43
	STA    $E7                   ; FC43
	LDA    $91                   ; FC45
	AND    #$02                  ; FC47
	BNE    LFC59                 ; FC49
	DEC    $E7                   ; FC4B
	LDY    #$03                  ; FC4D
LFC4F
	LDA.w  $00B7,Y               ; FC4F
	CMP    $E7                   ; FC52
	BEQ    LFC5A                 ; FC54
	DEY                          ; FC56
	BPL    LFC4F                 ; FC57
LFC59
	RTS                          ; FC59
LFC5A
	LDA.w  $00B7,Y               ; FC5A
	BMI    LFC59                 ; FC5D
	LDA.w  $00B3,Y               ; FC5F
	ASL                          ; FC62
	STY    $E8                   ; FC63
	LDY    $95                   ; FC65
	LDA    DFB67,Y               ; FC67
	ROL                          ; FC6A
	AND    #$0F                  ; FC6B
	TAY                          ; FC6D
	LDA    DFC33,Y               ; FC6E
	STA    $E7                   ; FC71
	LDA    $93                   ; FC73
	AND    #$02                  ; FC75
	BEQ    LFC7B                 ; FC77
	LSR    $E7                   ; FC79
LFC7B
	LDA    $E7                   ; FC7B
	CMP    $84                   ; FC7D
	BCC    LFC59                 ; FC7F
	LDY    $E8                   ; FC81
	LDA.w  $00B3,Y               ; FC83
	AND    #$3F                  ; FC86
	CMP    #$09                  ; FC88
	BCC    LFC59                 ; FC8A
	LDA    #$43                  ; FC8C
	STA    $A7,X                 ; FC8E
	LDA.w  $00CB,Y               ; FC90
	CLC                          ; FC93
	ADC    #$01                  ; FC94
	STA    $BF,X                 ; FC96
	JSR    LF21E                 ; FC98
	PLA                          ; FC9B
	PLA                          ; FC9C
	JMP    LF3E0                 ; FC9D
	.byte $C9,$1E,$90,$06,$A5,$82,$09,$02
	.byte $85,$82,$60
LFCAB
	LSR                          ; FCAB
	CMP    #$06                  ; FCAC
	BNE    LFCBD                 ; FCAE
	LDA    $BF,X                 ; FCB0
	EOR    #$40                  ; FCB2
	STA    $BF,X                 ; FCB4
LFCB6
	INC    $A7,X                 ; FCB6
	PLA                          ; FCB8
	PLA                          ; FCB9
	JMP    LF3E0                 ; FCBA
LFCBD
	JMP    LF286                 ; FCBD
LFCC0
	LDA    $84                   ; FCC0
	EOR    $80                   ; FCC2
	CMP    #$A0                  ; FCC4
	BCS    LFCC9                 ; FCC6
	RTS                          ; FCC8
LFCC9
	LDY    #$05                  ; FCC9
	JSR    $B018                 ; FCCB
	JMP    LFCB6                 ; FCCE
LFCD1
	JMP    LF21E                 ; FCD1
LFCD4
	LDA    $84                   ; FCD4
	CMP    #$C0                  ; FCD6
	BCC    LFCE3                 ; FCD8
	LDA    #$42                  ; FCDA
	STA    $A7,X                 ; FCDC
	LDY    #$04                  ; FCDE
	JSR    $B018                 ; FCE0
LFCE3
	JSR    LF286                 ; FCE3
	PLA                          ; FCE6
	PLA                          ; FCE7
	JMP    LF3E0                 ; FCE8
LFCEB
	LDA    $A7,X                 ; FCEB
	AND    #$3F                  ; FCED
	TAY                          ; FCEF
	LDA    DFD14,Y               ; FCF0
	AND    #$0F                  ; FCF3
	ASL                          ; FCF5
	TAY                          ; FCF6
	LDA    DFD08,Y               ; FCF7
	STA    $DF                   ; FCFA
	LDA    DFD09,Y               ; FCFC
	STA    $E0                   ; FCFF
	LDA    $80                   ; FD01
	AND    #$04                  ; FD03
	JMP    ($00DF)               ; FD05
DFD08
	.byte $68
DFD09
	.byte $FD,$58,$FD
	.word LFD4A                ; FD0C
	.word LFD69                ; FD0E
	.word LFD5B                ; FD10
	.word LFD68                ; FD12
DFD14
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $93,$90,$90,$90,$90,$91,$91,$92
	.byte $92,$94,$94,$92,$92,$30,$60,$30
	.byte $90,$90,$90
DFD2F
	.byte $00,$02,$03,$04,$05,$06,$07,$07
	.byte $08,$0A,$0B,$0C,$09,$0E,$0D,$10
	.byte $0F,$12,$11,$14,$13,$15,$16,$17
	.byte $19,$1A,$18
LFD4A
	BEQ    LFD58                 ; FD4A
	LDA    $AB,X                 ; FD4C
	AND    #$03                  ; FD4E
	BNE    LFD58                 ; FD50
	LDA    #$80                  ; FD52
LFD54
	EOR    $BF,X                 ; FD54
	STA    $BF,X                 ; FD56
LFD58
	JMP    LF2D0                 ; FD58
LFD5B
	BEQ    LFD58                 ; FD5B
	LDA    $AB,X                 ; FD5D
	AND    #$03                  ; FD5F
	BNE    LFD58                 ; FD61
	LDA    #$40                  ; FD63
	JMP    LFD54                 ; FD65
LFD68
	RTS                          ; FD68
LFD69
	LDA    $AB,X                 ; FD69
	CLC                          ; FD6B
	ADC    #$02                  ; FD6C
	LSR                          ; FD6E
	LSR                          ; FD6F
	STA    $E7                   ; FD70
	LDA    $D4                   ; FD72
	LSR                          ; FD74
	LSR                          ; FD75
	CMP    $E7                   ; FD76
	BNE    LFD92                 ; FD78
	LDA    $D3                   ; FD7A
	LSR                          ; FD7C
	LSR                          ; FD7D
	LSR                          ; FD7E
	TAY                          ; FD7F
	LDA    DFA4D,Y               ; FD80
	LSR                          ; FD83
	LSR                          ; FD84
	STA    $E7                   ; FD85
	LDA    $BF,X                 ; FD87
	LSR                          ; FD89
	LSR                          ; FD8A
	LSR                          ; FD8B
	CMP    $E7                   ; FD8C
	BNE    LFD92                 ; FD8E
	INC    $A7,X                 ; FD90
LFD92
	RTS                          ; FD92
LFD93
	LDA    INTIM                 ; FD93
	BNE    LFD93                 ; FD96
	STA    WSYNC                 ; FD98
	LDX    #$00                  ; FD9A
	STX    COLUBK                ; FD9C
	STX    COLUPF                ; FD9E
	DEX                          ; FDA0
	TXS                          ; FDA1
	LDA    #$28                  ; FDA2
	STA    TIM64T                ; FDA4
	JSR    LFE8B                 ; FDA7
	LDA    #$F8                  ; FDAA
	STA    COLUP0                ; FDAC
	STA    COLUP1                ; FDAE
	LDA    $91                   ; FDB0
	BMI    LFE1B                 ; FDB2
	LDA    #$02                  ; FDB4
	STA    $E7                   ; FDB6
	LDA    $91                   ; FDB8
LFDBA
	LDX    #$F6                  ; FDBA
	LSR                          ; FDBC
	BCC    LFDC1                 ; FDBD
LFDBF
	LDX    #$8C                  ; FDBF
LFDC1
	STX    COLUP0                ; FDC1
	STX    COLUP1                ; FDC3
	LDY    #$0B                  ; FDC5
LFDC7
	LDX    $E7                   ; FDC7
	LDA    #$FF                  ; FDC9
	STA.w  $00EB,Y               ; FDCB
	DEY                          ; FDCE
	LDA    $88,X                 ; FDCF
	AND    #$0F                  ; FDD1
	TAX                          ; FDD3
	LDA    DFF6A,X               ; FDD4
	STA.w  $00EB,Y               ; FDD7
	DEY                          ; FDDA
	LDA    #$FF                  ; FDDB
	STA.w  $00EB,Y               ; FDDD
	DEY                          ; FDE0
	LDX    $E7                   ; FDE1
	LDA    $88,X                 ; FDE3
	LSR                          ; FDE5
	LSR                          ; FDE6
	LSR                          ; FDE7
	LSR                          ; FDE8
	TAX                          ; FDE9
	LDA    DFF6A,X               ; FDEA
	STA.w  $00EB,Y               ; FDED
	DEC    $E7                   ; FDF0
	DEY                          ; FDF2
	BPL    LFDC7                 ; FDF3
	LDA    $85,X                 ; FDF5
	STA    $EA                   ; FDF7
	LDA    #$06                  ; FDF9
	JSR    LFEB5                 ; FDFB
	LDY    #$0A                  ; FDFE
	LDX    #$05                  ; FE00
LFE02
	LDA    DFF74                 ; FE02
	CPX    $EA                   ; FE05
	BPL    LFE0B                 ; FE07
	LDA    #$21                  ; FE09
LFE0B
	STA.w  $00EB,Y               ; FE0B
	DEX                          ; FE0E
	DEY                          ; FE0F
	DEY                          ; FE10
	BPL    LFE02                 ; FE11
	LDA    #$02                  ; FE13
	JSR    LFEB5                 ; FE15
	JMP    LFE88                 ; FE18
LFE1B
	LDA    $92                   ; FE1B
	BNE    LFE4C                 ; FE1D
	LDA    $81                   ; FE1F
	AND    #$01                  ; FE21
	BEQ    LFE62                 ; FE23
	LDA    $88                   ; FE25
	ORA    $89                   ; FE27
	ORA    $8A                   ; FE29
	BEQ    LFE38                 ; FE2B
	LDA    $80                   ; FE2D
	BMI    LFE38                 ; FE2F
	LDA    #$02                  ; FE31
	STA    $E7                   ; FE33
	JMP    LFDBA                 ; FE35
LFE38
	STA    WSYNC                 ; FE38
	LDX    #$0B                  ; FE3A
LFE3C
	LDA    DFF0D,X               ; FE3C
	STA    $EB,X                 ; FE3F
	DEX                          ; FE41
	BPL    LFE3C                 ; FE42
LFE44
	LDA    #$06                  ; FE44
	JSR    LFEB5                 ; FE46
	JMP    LFE88                 ; FE49
LFE4C
	STA    WSYNC                 ; FE4C
	LDX    #$0B                  ; FE4E
LFE50
	LDA    DFF75,X               ; FE50
	STA    $EB,X                 ; FE53
	DEX                          ; FE55
	BPL    LFE50                 ; FE56
	LDX    $93                   ; FE58
	LDA    DFF6B,X               ; FE5A
	STA    $F5                   ; FE5D
	JMP    LFE44                 ; FE5F
LFE62
	LDA    $80                   ; FE62
	BMI    LFE77                 ; FE64
	LDA    $8E                   ; FE66
	ORA    $8F                   ; FE68
	ORA    $90                   ; FE6A
	BEQ    LFE77                 ; FE6C
	LDA    #$08                  ; FE6E
	STA    $E7                   ; FE70
	LDA    $81                   ; FE72
	JMP    LFDBF                 ; FE74
LFE77
	STA    WSYNC                 ; FE77
	LDX    #$0B                  ; FE79
LFE7B
	LDA    DFF81,X               ; FE7B
	STA    $EB,X                 ; FE7E
	DEX                          ; FE80
	BPL    LFE7B                 ; FE81
	LDA    #$09                  ; FE83
	JSR    LFEB5                 ; FE85
LFE88
	JMP    LF0C4                 ; FE88
LFE8B
	STA    WSYNC                 ; FE8B
	LDA    #$03                  ; FE8D
	LDY    #$00                  ; FE8F
	STY    REFP1                 ; FE91
	STA    NUSIZ0                ; FE93
	STA    NUSIZ1                ; FE95
	STA    VDELP0                ; FE97
	STA    VDELP1                ; FE99
	STY    GRP0                  ; FE9B
	STY    GRP1                  ; FE9D
	STY    GRP0                  ; FE9F
	STY    GRP1                  ; FEA1
	STY    HMP1                  ; FEA3
	NOP                          ; FEA5
	STA    RESP0                 ; FEA6
	STA    RESP1                 ; FEA8
	LDA    #$F0                  ; FEAA
	STA    HMP0                  ; FEAC
	STY    REFP0                 ; FEAE
	STA    WSYNC                 ; FEB0
	STA    HMOVE                 ; FEB2
	RTS                          ; FEB4
LFEB5
	STA    $E7                   ; FEB5
LFEB7
	LDY    $E7                   ; FEB7
	LDA    ($EB),Y               ; FEB9
	STA    GRP0                  ; FEBB
	STA    WSYNC                 ; FEBD
	LDA    ($ED),Y               ; FEBF
	STA    GRP1                  ; FEC1
	LDA    ($EF),Y               ; FEC3
	STA    GRP0                  ; FEC5
	LDA    ($F1),Y               ; FEC7
	STA    $E8                   ; FEC9
	LDA    ($F3),Y               ; FECB
	TAX                          ; FECD
	LDA    ($F5),Y               ; FECE
	TAY                          ; FED0
	LDA    $E8                   ; FED1
	STA    GRP1                  ; FED3
	STX    GRP0                  ; FED5
	STY    GRP1                  ; FED7
	STY    GRP0                  ; FED9
	DEC    $E7                   ; FEDB
	BPL    LFEB7                 ; FEDD
	LDA    #$00                  ; FEDF
	STA    GRP0                  ; FEE1
	STA    GRP1                  ; FEE3
	STA    GRP0                  ; FEE5
	STA    GRP1                  ; FEE7
	RTS                          ; FEE9
	.byte $79,$85,$B5,$A5,$B5,$85,$79,$17
	.byte $15,$15,$77,$55,$55,$77,$71,$51
	.byte $11,$31,$11,$51,$70,$49,$49,$49
	.byte $C9,$49,$49,$BE,$55,$55,$55,$D9
	.byte $55,$55,$99
DFF0D
	.byte $EA,$FE,$F1,$FE,$F8,$FE,$FF,$FE
	.byte $06,$FF,$19,$FF,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$18,$24,$18,$3C
	.byte $66,$66,$66,$66,$66,$3C,$7E,$18
	.byte $18,$18,$18,$78,$38,$7E,$60,$60
	.byte $3C,$06,$46,$7C,$3C,$46,$06,$0C
	.byte $06,$46,$3C,$0C,$0C,$7E,$4C,$2C
	.byte $1C,$0C,$7C,$46,$06,$7C,$60,$60
	.byte $7E,$3C,$66,$66,$7C,$60,$62,$3C
	.byte $18,$18,$08,$04,$02,$62,$7E,$3C
	.byte $66,$66,$3C,$66,$66,$3C,$3C,$46
	.byte $06,$3E,$66,$66,$3C
DFF6A
	.byte $24
DFF6B
	.byte $2B,$32,$39,$40,$47,$4E,$55,$5C
	.byte $63
DFF74
	.byte $19
DFF75
	.byte $8D,$FF,$94,$FF,$9B,$FF,$A2,$FF
	.byte $19,$FF,$19,$FF
DFF81
	.byte $A9,$FF,$B3,$FF,$BD,$FF,$C7,$FF
	.byte $D1,$FF,$DB,$FF,$7D,$FD,$CD,$DD
	.byte $C1,$FD,$7C,$9B,$9B,$9B,$FB,$9B
	.byte $FB,$F1,$6C,$6D,$6D,$6D,$6D,$FD
	.byte $F8,$F0,$F0,$80,$E0,$80,$F0,$F0
	.byte $F7,$F7,$7F,$3E,$1C,$1C,$3E,$7F
	.byte $F7,$F7,$BC,$BC,$61,$E3,$FB,$FB
	.byte $E3,$63,$BD,$DB,$47,$E7,$B7,$BB
	.byte $BB,$BB,$BB,$BB,$BB,$BB,$9E,$BF
	.byte $B7,$B7,$B7,$B7,$B7,$B7,$BF,$9E
	.byte $7D,$7C,$6E,$6E,$6E,$6E,$6E,$6E
	.byte $6E,$EE,$F0,$F8,$38,$38,$F8,$F0
	.byte $C0,$C0,$F8,$F0
; ---- far-call slots into new bank 0 (see bank0.asm) ----
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
FAR_KERNEL
	STA    SEL1                  ; FFEF  -> bank 1 kernel (lands at $FFF2)
	.byte $00,$00,$00,$00,$00,$00 ; FFF2-FFF7 (FFF6/7 are F6 hotspots)
; end free FFE5
; bankswitch hotspots / vectors
	.byte $00,$00
	.byte $00,$00,$00,$F0,$00,$F0

