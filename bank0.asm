;======================================================================
; BANK 0 (new code)
;======================================================================
TODAI	= 0		; 1 = Tod's family AI (port check)
	SEG bank0
	ORG $0000
	RORG $F000
	BANKHEADER

;----------------------------------------------------------------------
; Score add (replaces Tod's $F964). In: A = points code in bits 4-7.
; Out: C=1 if an extra ship was awarded (bank 2 plays the jingle).
; Extra ships at 20,000 then every 60,000 (arcade default): awarded when
; the ten-thousands count (BCD $88) changes to a value v with (v-2) mod 6 == 0.
ScoreAdd SUBROUTINE
	LSR
	LSR
	LSR
	LSR
	TAY
	LDA    $91
	BMI    .none                 ; attract mode scores nothing
	LDX    $88                   ; old ten-thousands
	SED
	CLC
	LDA    $8A
	ADC    PtsLo,Y
	STA    $8A
	LDA    $89
	ADC    PtsHi,Y
	STA    $89
	LDA    $88
	ADC    #0
	STA    $88
	CLD
	CPX    $88
	BEQ    .none
	LSR                          ; BCD -> binary: tens*10 + units
	LSR
	LSR
	LSR
	TAX
	LDA    $88
	AND    #$0F
	CLC
	ADC    Times10,X
	SEC
	SBC    #2
	BCC    .none                 ; below 20,000
.mod	CMP    #6
	BCC    .r
	SBC    #6
	BCS    .mod
.r	CMP    #0
	BNE    .none
	INC    $85                   ; extra ship
	SEC
	JMP    FARRET0
.none	CLC
	JMP    FARRET0
PtsLo	.byte  $10,$30,$50,$00,$50,$00,$00,$00,$00,$00,$00,$00
PtsHi	.byte  $00,$00,$00,$01,$01,$02,$03,$07,$08,$10,$20,$75
Times10	.byte  0,10,20,30,40,50,60,70,80,90

;----------------------------------------------------------------------
; Ship pre-kernel: P1 ship position ($E8 fine HM, $E9 coarse 0-4 / bit7 = skip).
; Andor (P1 is the quad-width core) -> fall back to Tod's missile ship.
CALIB	= 0
ShipPre SUBROUTINE
	LDA    #$47
	STA    $DF
	LDA    $91
	AND    #$02
	BEQ    .p1
	LDX    #$BE                  ; Andor core frame table holds low bytes in page $BE,
	LDA    $EF                   ; but the last frame lives at $BF0B (prototype read $BE0B)
	CMP    #$20
	BCS    .pg
	INX
.pg	STX    $F0
	LDA    #$B0                  ; SHIPDET skip path -> Tod's M1 ship
	STA    $E8
	LDA    #$80
	STA    $E9
	JMP    FARRET0
.p1
 IF CALIB
	LDA    $92                   ; calibration: coarse from $92 (0-3), fine from $93
	AND    #3
	ORA    $93
	STA    $E8
	LDA    #3
	STA    $E9
 ELSE
	LDA    $CF                   ; Tod's missile X coding -> fine (bits 4-7) | coarse (bits 0-1)
	LSR
	LSR
	LSR
	TAY
	LDA    ShipPos,Y
	STA    $E8
	LDY    #3                    ; frame 0 = Solvalou (row index frame*4+3)
	LDA    $91
	AND    #$20
	BEQ    .fr
	LDA    $97                   ; dying: explosion frames from Tod's death timer
	CMP    #31
	BCC    .t
	LDA    #30
.t	EOR    #$FF
	CLC
	ADC    #31                   ; elapsed 0..30
	LSR
	LSR
	LSR                          ; 0..3
	TAY
	LDA    ExplIdx,Y
	TAY
.fr	STY    $E9
 ENDIF
	; ground objects whose start row falls in the ship band
	LDA    #0
	STA    $EA
	LDX    #3
.c	LDA    $B7,X
	BMI    .nx                   ; offscreen/unused
	SEC
	SBC    $BB
	CLC
	ADC    #3
	CMP    #11                   ; start within BB-3 .. BB+7 (rows/positioning meet the span)
	BCS    .nx
	LDA    ObjBit,X
	ORA    $EA
	STA    $EA
.nx	DEX
	BPL    .c
	LDA    $EA
	BEQ    .done
	LDA    $80                   ; overlap: alternate ship / ground objects
	LSR
	BCC    .hideg
	LDA    #$8A                  ; odd: no ship this frame (SHIPDET skip path)
	STA    $E8
	LDA    #$80
	STA    $E9
	LDA    #0
	STA    $EA
	JMP    FARRET0
.hideg	LDX    #3                    ; even: hide those objects for this frame
.h	LDA    ObjBit,X
	AND    $EA
	BEQ    .hn
	LDA    $B7,X
	ORA    #$80
	STA    $B7,X
.hn	DEX
	BPL    .h
.done	JMP    FARRET0
ObjBit	.byte  $08,$04,$02,$01       ; X=3 -> bit0 (POSTK shifts from X=3 down)
;ShipCoarse (unused)
	.byte 0,0,0,0,0,0,0,0,3,2,2,2,2,2,0,0,4,4,1,1,1,1,1,1,4,4,4,4,4,4,4,4
ShipFine
	.byte $E0,$F0,$00,$10,$20,$30,$40,$50,$70,$30,$40,$50,$60,$70,$C0,$D0,$60,$70,$80,$90,$A0,$B0,$C0,$D0,$E0,$F0,$00,$10,$20,$30,$40,$50

ShipPos
	.byte $D0,$E0,$F0,$00,$10,$20,$30,$40,$E1,$F1,$01,$80,$90,$A0,$B0,$C0,$81,$91,$A1,$B1,$C1,$D1,$E1,$F1,$A3,$B3,$C3,$82,$92,$A2,$B2,$C2
ExplIdx
	.byte 7,11,15,19              ; burst 1, burst 2, sparks, gone

;----------------------------------------------------------------------
; Collision decision (replaces $F70B..$F71A). Out: C=1 nothing; C=0 and
; X=0 ship destroyed, X>0 shot index that hit enemy $E2.
Coll SUBROUTINE
	LDA    $E3
	BPL    .m1
	AND    #$0F                  ; P1 ship hit: enemy lane recorded by the kernel
	TAX
	LDA    $A7,X
	CMP    #$44
	BCS    .m1                   ; explosion/non-lethal
	LDX    #0
	CLC
	JMP    FARRET0
.m1	BIT    $31                   ; missile 1 vs P0 (shots, or Tod's ship during Andor)
	BPL    .none
	LDX    $E2
	LDA    $A7,X
	CMP    #$44
	BCS    .none
	LDA    $91
	AND    #$02
	BNE    .tod
	LDA    $E3
	AND    #$3F
	BEQ    .none                 ; index 0 = ship, but the ship isn't M1 now
	TAX
	CLC
	JMP    FARRET0
.tod	LDX    $E3
	CLC
	JMP    FARRET0
.none	SEC
	JMP    FARRET0

	include air.asm
	include title.asm

;----------------------------------------------------------------------
; FAR_2 is shared: the caller is told apart by the low byte of its return
; address on the stack (JSR pushes ret-1; $01xx mirrors RAM on the 2600).
;   $F5AB JSR FAR_2 (pre-kernel) -> ShipPre;  $F3D0 JSR FAR_2 -> AirLoop;
;   TitleGo ($F3D6) JSR FAR_2 -> Title
Far2	TSX
	LDA    $0101,X
	CMP    #$AD                  ; <($F5AB+2)
	BNE    .t
	JMP    ShipPre
.t	CMP    #<(TitleGo+2)         ; bank 2 TitleGo -> Title (whole frames)
	BNE    .air
	JMP    Title
.air	JMP    AirLoop

;----------------------------------------------------------------------
; air handler entry page (HndLo holds the low bytes)
	ORG $0F00
	RORG $FF00
HJmp
J_None	JMP    Anim
J_Launch JMP   H_Launch
J_Mark	JMP    H_Mark
J_2F	JMP    H_2F
J_30	JMP    H_30
J_Move	JMP    H_Move
J_Aim	JMP    H_Aim
J_Zoshi	JMP    H_Zoshi
J_Tork	JMP    H_Tork
J_Toroid JMP   H_Toroid
J_Kapi	JMP    H_Kapi
J_Jara	JMP    H_Jara
 IF TODAI
J_TTurn	JMP    T_Turn
J_TMv	JMP    T_Mv
J_TSpin	JMP    T_Spin
J_TBomb	JMP    T_Bomb
 ENDIF

;----------------------------------------------------------------------
; far-call landing pads (must line up with bank 2's slots at $FFE5..)
	ORG $0FE2
	RORG $FFE2
FARRET0	STA    SEL2                  ; -> bank 2 continues at $FFE5 (RTS)
	.byte  $00                   ; FFE5 (bank 2's RTS)
	.byte  $00,$00,$00           ; FFE6 (bank 2's STA SEL0)
	JMP    ScoreAdd              ; FFE9 = FAR_SCORE+3
	JMP    Coll                  ; FFEC = FAR_1+3
	JMP    Far2                  ; FFEF = FAR_2+3 (ShipPre / AirLoop)
	.byte  0,0,0                 ; FFF2 (bank 1 landing, not bank 0)
	ORG $0FFC
	RORG $FFFC
	.word $F000,$F000
