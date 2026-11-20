;======================================================================
; BANK 3  (original bank 1, runs at $B000)
;======================================================================
	SEG bank3
	ORG $3000
	RORG $B000
	STA    $FFF8                 ; B000
	.byte $4C,$1C,$F0
LB006
	STA    $FFF8                 ; B006
LB009
	JMP    LB01E                 ; B009
LB00C
	STA    $FFF8                 ; B00C
LB00F
	JMP    SndUpd                ; B00F  M5 sound engine
LB012
	STA    $FFF8                 ; B012
LB015
	JMP    LBF17                 ; B015
LB018
	STA    $FFF8                 ; B018
LB01B
	JMP    SndReq                ; B01B  M5 sound engine
LB01E	; (dead: Tod's kernel copy, now in bank 1)
	include snd.asm
	DS.B $BCE0-., $FF
DBCE0
	.byte $00,$00,$02,$06,$00,$00,$06,$00
	.byte $05,$05
DBCEA
	.byte $00,$0D,$17,$00,$00,$00,$00,$E2
	.byte $26,$6C,$00
DBCF5
	.byte $00,$08,$12,$30,$A1,$A8,$0F,$AF
	.byte $1C,$37
DBCFF
	.byte $00,$84,$84,$88,$88,$85,$8D,$8D
	.byte $88,$8D,$01
LBD0A
	CPY    $98                   ; BD0A
	BCC    LBD1E                 ; BD0C
	STY    $98                   ; BD0E
	LDA    DBCF5,Y               ; BD10
	STA    $9C                   ; BD13
	LDA    DBCEA,Y               ; BD15
	STA    $99                   ; BD18
	LDA    #$00                  ; BD1A
	STA    $9A                   ; BD1C
LBD1E
	JMP    $F018                 ; BD1E
LBD21
	LDX    $98                   ; BD21
	LDA    DBCFF,X               ; BD23
	BMI    LBD3B                 ; BD26
	STA    AUDC0                 ; BD28
	LDA    DBCF5,X               ; BD2A
	STA    AUDV0                 ; BD2D
	LDA    DBCE0,X               ; BD2F
	STA    AUDF0                 ; BD32
	LDA    #$00                  ; BD34
	STA    $98                   ; BD36
	JMP    LBD58                 ; BD38
LBD3B
	LDX    $98                   ; BD3B
	DEC    $9A                   ; BD3D
	BPL    LBD51                 ; BD3F
	INC    $99                   ; BD41
	INC    $9C                   ; BD43
	LDA    DBCE0,X               ; BD45
	STA    $9A                   ; BD48
	LDA    DBCFF,X               ; BD4A
	STA    AUDC0                 ; BD4D
	STA    AUDC1                 ; BD4F
LBD51
	LDY    $9C                   ; BD51
	LDA    DBDD2,Y               ; BD53
	BNE    LBD70                 ; BD56
LBD58
	STA    $9C                   ; BD58
	STA    $98                   ; BD5A
	LDA    #$04                  ; BD5C
	STA    AUDC0                 ; BD5E
	LDA    $9D                   ; BD60
	BNE    LBD70                 ; BD62
	LDA    $91                   ; BD64
	AND    #$06                  ; BD66
	BEQ    LBD70                 ; BD68
	LDA    #$09                  ; BD6A
	STA    AUDC0                 ; BD6C
	LDA    #$8F                  ; BD6E
LBD70
	STA    AUDF0                 ; BD70
	LSR                          ; BD72
	LSR                          ; BD73
	LSR                          ; BD74
	LSR                          ; BD75
	ORA    #$01                  ; BD76
	STA    AUDV0                 ; BD78
	LDY    $99                   ; BD7A
	LDA    DBDD2,Y               ; BD7C
	BNE    LBD8F                 ; BD7F
	STA    $99                   ; BD81
	LDA    $9B                   ; BD83
	AND    #$1F                  ; BD85
	TAX                          ; BD87
	LDA    #$04                  ; BD88
	STA    AUDC1                 ; BD8A
	LDA    DBDB1,X               ; BD8C
LBD8F
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
	BCC    LBDA6                 ; BD9E
	ADC    #$00                  ; BDA0
	AND    #$1F                  ; BDA2
	ORA    #$60                  ; BDA4
LBDA6
	STA    $9B                   ; BDA6
	LDA    $9D                   ; BDA8
	BEQ    LBDAE                 ; BDAA
	INC    $9D                   ; BDAC
LBDAE
	JMP    $F00C                 ; BDAE
DBDB1
	.byte $3D,$4E,$4F,$4E,$4B,$4E,$4F,$4E
	.byte $3D,$4E,$50,$4E,$4B,$4E,$50,$4E
	.byte $3D,$4E,$51,$4E,$4B,$4E,$51,$4E
	.byte $3D,$4E,$52,$4E,$4B,$4E,$52,$4E
	.byte $00
DBDD2
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
LBF17
	LDY    $96                   ; BF17
	LDA    $F7                   ; BF19
	AND    #$1F                  ; BF1B
	CMP    #$16                  ; BF1D
	BNE    LBF25                 ; BF1F
	LDA    #$08                  ; BF21
	BNE    LBF2C                 ; BF23
LBF25
	LDA    $F7                   ; BF25
	AND    #$80                  ; BF27
	ORA    DBF44,Y               ; BF29
LBF2C
	STA    $B3,X                 ; BF2C
	LDA    DBF45,Y               ; BF2E
	STA    $CB,X                 ; BF31
	LDA    #$FF                  ; BF33
	STA    $F6                   ; BF35
	LDA    #$00                  ; BF37
	STA    $B7,X                 ; BF39
	LDA    $91                   ; BF3B
	ORA    #$08                  ; BF3D
	STA    $91                   ; BF3F
	JMP    $F012                 ; BF41
DBF44
	.byte $0D
DBF45
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
FREE_BFB4	; ---- unused space (68 bytes) ----
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00
; end free BFB4
; bankswitch hotspots / vectors
	.byte $00,$00
	.byte $00,$00,$00,$F0,$00,$F0
