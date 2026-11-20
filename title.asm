;----------------------------------------------------------------------
; M5: title screen (bank 0). Runs whole frames until the player chooses:
;   Reset -> new game (area 1);  Fire -> start from the last area reached
;   (Tod's continue: $A4);  Select -> game number 1-8;  ~10 s idle -> demo.
; Entered through bank 2 TitleGo (JSR FAR_2) from power-on, game over and the
; demo. Returns A=0 (Z) for the demo, A=1 for a game; RAM is set up here.
; Scratch: $A7-$B6 (object slots, cleared by Tod's $F8FA init) and $E7-$E9.
; The stack holds TitleGo's return address at $FE/$FF; at most two JSR levels.
;----------------------------------------------------------------------
T_PTR	= $A7		; 6 cell pointers (lo,hi) for the 48-px text kernel
T_TLO	= $B3		; idle timeout (frames, counts down)
T_THI	= $B4
T_FLG	= $B5		; bit7 fire armed (released since entry), bit6 select held
T_SRP	= $B6		; select auto-repeat timer
T_LN	= $E7		; 48-px kernel line counter
T_TMP	= $E8
T_ROW	= $E9		; logo / ship row repeat
IDLE	= 600		; frames on the title before the demo
TBOT	= 1		; bottom margin lines (title frame = 257 lines, as Tod's game)
TDEMO	= 0		; 1 = preset score/area on entry (screenshots only)

	MAC WAITTIM	; robust INTIM wait (also stops on an expired timer)
.wt	LDA    INTIM
	BEQ    .wd
	BPL    .wt
.wd
	ENDM

	MAC CPYSTR	; copy a 6-cell string's pointers to T_PTR (fixed time)
	LDX    #5
	LDY    #10
.ss	LDA    {1}Lo,X
	STA.w  T_PTR,Y
	LDA    {1}Hi,X
	STA.w  T_PTR+1,Y
	DEY
	DEY
	DEX
	BPL    .ss
	ENDM

Title	SUBROUTINE
 IF TDEMO
	LDA    #4
	STA    $A4
	LDA    #$01
	STA    $88
	LDA    #$23
	STA    $89
	LDA    #$40
	STA    $8A
 ENDIF
	LDA    #0
	STA    AUDV0
	STA    AUDV1
	STA    T_SRP
	STA    T_FLG
	LDA    #<IDLE
	STA    T_TLO
	LDA    #>IDLE
	STA    T_THI
	LDA    SWCHB
	AND    #$02
	BNE    TFrame
	LDA    #$40                  ; Select still held from the demo: no repeat yet
	STA    T_FLG

TFrame	WAITTIM                      ; end of the previous frame (overscan timer)
	LDA    #2
	STA    WSYNC
	STA    VSYNC
	STA    VBLANK
	STA    WSYNC
	STA    WSYNC
	LDA    #0
	STA    WSYNC
	STA    VSYNC
	LDA    #44                   ; 37 lines of vertical blank
	STA    TIM64T
	INC    $80                   ; frame counter (Tod's $F8FA reseeds it)
	LDA    $83                   ; keep Tod's RNG ($F049) turning
	ASL
	EOR    $83
	ASL
	ASL
	ROL    $83
	ROL    $84
	LDA    #0
	STA    GRP0
	STA    GRP1
	STA    PF0
	STA    PF1
	STA    PF2
	STA    CTRLPF
	STA    COLUBK
	STA    VDELP0
	STA    VDELP1
	STA    REFP0
	STA    REFP1
	STA    HMCLR
	WAITTIM
	STA    WSYNC
	LDA    #0
	STA    VBLANK

;---- kernel: 192 lines ----
	LDX    #13                   ; 14 lines top margin
.top	STA    WSYNC
	DEX
	BNE    .top
	LDA    $80                   ; logo shimmer phase
	LSR
	AND    #$3F
	TAX
	LDY    #6
	LDA    #6
	STA    T_ROW
.lg	STA    WSYNC                 ; 7 rows x 6 lines, asymmetric playfield
	LDA    LgCol,X
	STA    COLUPF                ; @7
	LDA    LgL0,Y
	STA    PF0                   ; @14
	LDA    LgL1,Y
	STA    PF1                   ; @21
	LDA    LgL2,Y
	STA    PF2                   ; @28
	NOP
	LDA    LgR0,Y
	STA    PF0                   ; @37  (28-49)
	LDA    LgR1,Y
	STA    PF1                   ; @44  (39-54)
	LDA    LgR2,Y
	STA    PF2                   ; @51  (50-65)
	INX
	DEC    T_ROW
	BNE    .lg
	LDA    #6
	STA    T_ROW
	DEY
	BPL    .lg
	STA    WSYNC
	LDA    #0
	STA    PF0
	STA    PF1
	STA    PF2
	LDA    #7                    ; Solvalou: quad width, centred
	STA    NUSIZ0
	LDA    #$0C
	STA    COLUP0
	STA    WSYNC
	LDX    #8
.rd	DEX
	BNE    .rd                   ; @41
	STA    RESP0                 ; @44 -> centred quad-width ship
	LDA    #$00
	STA    HMP0
	STA    WSYNC
	STA    HMOVE
	LDX    #4                    ; spacer lines
.sp1	STA    WSYNC
	DEX
	BNE    .sp1
	LDY    #5
.sv	LDA    #4
	STA    T_ROW
.svl	STA    WSYNC
	LDA    SolG,Y
	STA    GRP0
	DEC    T_ROW
	BNE    .svl
	DEY
	BPL    .sv
	STA    WSYNC
	LDA    #0
	STA    GRP0
	STA    WSYNC
	; -- "GAME n   pUP" --
	CPYSTR SGame
	LDA    $93
	AND    #$07
	TAX
	LDA    PNumLo,X
	STA    T_PTR+4
	LDA    PNumHi,X
	STA    T_PTR+5
	LDA    $93
	AND    #$01
	TAX
	LDA    PNumLo,X
	STA    T_PTR+8
	LDA    PNumHi,X
	STA    T_PTR+9
	LDA    #$0E
	JSR    T48Pos                ; 2 lines
	LDA    #9
	JSR    T48Draw               ; 10 lines
	STA    WSYNC
	STA    WSYNC
	STA    WSYNC
	; -- last score (Tod's digits) --
	LDX    #2
	LDY    #10
.sc	LDA    $88,X
	AND    #$0F
	STX    T_TMP
	TAX
	LDA    PDigLo,X
	STA.w  T_PTR,Y
	LDA    PDigHi,X
	STA.w  T_PTR+1,Y
	LDX    T_TMP
	LDA    $88,X
	LSR
	LSR
	LSR
	LSR
	TAX
	LDA    PDigLo,X
	STA.w  T_PTR-2,Y
	LDA    PDigHi,X
	STA.w  T_PTR-1,Y
	LDX    T_TMP
	DEY
	DEY
	DEY
	DEY
	DEX
	BPL    .sc
	LDA    #$1C
	JSR    T48Pos
	LDA    #13
	JSR    T48Draw               ; 14 lines
	STA    WSYNC
	STA    WSYNC
	STA    WSYNC
	STA    WSYNC
	; -- PRESS FIRE (flashing) --
	CPYSTR SPress
	LDA    $80
	AND    #$20
	BEQ    .pf
	LDA    #$00                  ; off phase: black text, same timing
	BEQ    .pc
.pf	LDA    #$0E
.pc	JSR    T48Pos
	LDA    #9
	JSR    T48Draw
	STA    WSYNC
	; -- FROM AREA nn (only after a game) --
	CPYSTR SArea
	LDX    $A4
	LDA    PAreaLo,X
	STA    T_PTR+10
	LDA    PAreaHi,X
	STA    T_PTR+11
	LDA    $A4
	BEQ    .na
	LDA    #$9C
	BNE    .ac
.na	LDA    #$00
.ac	JSR    T48Pos
	LDA    #9
	JSR    T48Draw
	LDX    #4
.sp2	STA    WSYNC
	DEX
	BNE    .sp2
	; -- (c)1983 ATARI (Tod's copyright) --
	CPYSTR SCopy
	LDA    #$F6
	JSR    T48Pos
	LDA    #13
	JSR    T48Draw
	LDX    #TBOT                 ; bottom margin (makes 192)
.bt	STA    WSYNC
	DEX
	BNE    .bt

;---- overscan ----
	LDA    #2
	STA    WSYNC
	STA    VBLANK
	LDA    #35                   ; 30 lines
	STA    TIM64T
	LDA    T_TLO                 ; idle timeout
	SEC
	SBC    #1
	STA    T_TLO
	LDA    T_THI
	SBC    #0
	STA    T_THI
	BCC    .demo
	LDA    SWCHB
	LSR
	BCC    .new                  ; Reset
	AND    #$01                  ; (Select, shifted)
	BNE    .sup
	JSR    T_Idle                ; Select held
	BIT    T_FLG
	BVS    .held
	LDA    T_FLG
	ORA    #$40
	STA    T_FLG
	LDA    #30
	BNE    .inc
.held	DEC    T_SRP
	BNE    .fire
	LDA    #15
.inc	STA    T_SRP
	LDA    $93
	CLC
	ADC    #1
	AND    #$07
	STA    $93
	JMP    .fire
.sup	LDA    T_FLG
	AND    #$BF
	STA    T_FLG
.fire	LDA    INPT4
	BMI    .rel
	BIT    T_FLG
	BMI    .cont                 ; pressed after a release: start
	JMP    TFrame
.rel	LDA    T_FLG
	ORA    #$80
	STA    T_FLG
	JMP    TFrame
.new	LDA    #0
	STA    $87
	STA    $8D
	BEQ    .go
.cont	LDA    $A4
	STA    $87
.go	LDA    #1                    ; game (Tod's $F8D7 init follows)
	JMP    FARRET0
.demo	LDA    #$80                  ; demo (as after Tod's game over)
	STA    $91
	STA    $80
	LDA    #0
	STA    $81
	JMP    FARRET0

T_Idle	LDA    #<IDLE                ; any input restarts the idle timeout
	STA    T_TLO
	LDA    #>IDLE
	STA    T_THI
	RTS

; 48-px text: position (Tod's $FE8B, 2 lines). In: A = colour.
T48Pos	SUBROUTINE
	STA    COLUP0
	STA    COLUP1
	STA    WSYNC
	LDA    #$03
	LDY    #$00
	STY    REFP1
	STA    NUSIZ0
	STA    NUSIZ1
	STA    VDELP0
	STA    VDELP1
	STY    GRP0
	STY    GRP1
	STY    GRP0
	STY    GRP1
	STY    HMP1
	NOP
	STA    RESP0
	STA    RESP1
	LDA    #$F0
	STA    HMP0
	STY    REFP0
	STA    WSYNC
	STA    HMOVE
	RTS

; 48-px text: draw (Tod's $FEB5). In: A = lines-1. Cells via T_PTR.
T48Draw	SUBROUTINE
	STA    T_LN
.l	LDY    T_LN
	LDA    (T_PTR),Y
	STA    GRP0
	STA    WSYNC
	LDA    (T_PTR+2),Y
	STA    GRP1
	LDA    (T_PTR+4),Y
	STA    GRP0
	LDA    (T_PTR+6),Y
	STA    T_TMP
	LDA    (T_PTR+8),Y
	TAX
	LDA    (T_PTR+10),Y
	TAY
	LDA    T_TMP
	STA    GRP1
	STX    GRP0
	STY    GRP1
	STY    GRP0
	DEC    T_LN
	BPL    .l
	LDA    #$00
	STA    GRP0
	STA    GRP1
	STA    GRP0
	STA    GRP1
	RTS

SolG	.byte  $24,$BD,$FF,$5A,$3C,$18   ; Solvalou, bottom row first
	include titledata.inc
