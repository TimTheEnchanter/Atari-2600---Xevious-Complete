;----------------------------------------------------------------------
; M4b: air-enemy loop (replaces Tod's $F3D0-$F401), reached via FAR_2.
; Processes 4 lanes per call like the original: X = lane slot (0-11),
; $A5 = running lane position (x2), $EB = loop count, $A6 = resume slot.
; Lane Y = $A5>>1 and ship Y $BB grow downward; air X/2 compares with
; ship X $D5. $BF,X: bits 0-5 X, bit6 = moving left, bit7 = fast/state.
; Scratch during logic: $DF, $E7, $E8 (dx), $E9 (dv), $EA (|dx|), $EC (phase).
; $E0 holds the handler page for JMP ($00DF) and must survive the loop.
; Stack: entered at SP=$FD; at most two nested JSRs (lowest byte $FA).
;
; Tod's handlers for non-family types are copied unchanged in effect.
; Families get arcade-style behaviour within the lane model:
;   $03-$05 Zoshi   chases the ship's column, fires (area 4+)
;   $06-$09 Torkan  slides over the ship, stops, fires, then leaves
;   $0A-$11 Toroid  homes in, turns away near the ship (fires area 3+)
;   $12-$21 Kapi    fast swoop, U-turn and fire; Terrazi zig-zag in area 10+
;   $22-$2E Jara    fast weave back and forth across the ship
;----------------------------------------------------------------------
	MAC GEO			; $E9 dv = ship Y - lane Y (>0 above ship), $E8 dx = air X/2 - ship X, $EA = |dx|
	LDA    $A5
	LSR
	STA    $E9
	LDA    $BB
	SEC
	SBC    $E9
	STA    $E9
	LDA    $BF,X
	AND    #$3F
	LSR
	SEC
	SBC    $D5
	STA    $E8
	BPL    .gp
	EOR    #$FF
	ADC    #1                    ; C=0 here (from SBC borrow)
.gp	STA    $EA
	ENDM
	MAC FACESHIP		; head toward the ship's column
	LDA    $BF,X
	AND    #$BF
	LDY    $E8
	BMI    .fs
	ORA    #$40
.fs	STA    $BF,X
	ENDM
	MAC AWAY		; C=1 if moving away from the ship's column
	LDA    $BF,X
	ASL
	ASL                          ; C = bit6 (moving left)
	LDA    $E8
	BCC    .aw1
	ASL                          ; left: away if dx < 0
	BCC    .aw3
	BCS    .aw3
.aw1	CMP    #1                    ; right: away if dx >= 1 (signed)
	BMI    .aw2
	SEC
	BCS    .aw3
.aw2	CLC
.aw3
	ENDM
	MAC RND			; A = per-slot pseudo-random byte
	LDA    RndMix,X
	EOR    $84
	EOR    $80
	ENDM

AirLoop SUBROUTINE
	LDA    #>HJmp
	STA    $E0
	LDA    $80                   ; speed-table phase for this tick
	AND    #$0C
	LSR
	LSR
	STA    $EC
	LDA    #3
	STA    $EB
	LDX    $A6
AirObj	CPX    $D6                   ; top (spawn) lane: animate only
	BEQ    Anim
	LDY    $A7,X
	LDA    HndLo,Y
	STA    $DF
	JMP    ($00DF)
Anim	LDY    $A7,X
	LDA    AnimNext,Y
	STA    $A7,X
Skip	LDA    Below,X               ; next lane down
	TAX
	LDY    $A7,X
	LDA    LaneAdd,Y
	CLC
	ADC    $A5
	STA    $A5
	DEC    $EB
	BPL    AirObj
	STX    $A6
	JMP    FARRET0

;---- Tod's handlers (types 0, 2, $2F, $30, $41, $42) ----
; type 0 (empty lane): a ground launcher level with this lane may fire a Spario ($FC43)
H_Launch SUBROUTINE
	LDA    $91
	AND    #$02
	BNE    .a
	LDA    $A5
	LSR
	SEC
	SBC    #1
	STA    $E7
	LDY    #3
.l	LDA.w  $00B7,Y
	CMP    $E7
	BEQ    .f
	DEY
	BPL    .l
.a	JMP    Anim
.f	LDA.w  $00B3,Y
	ASL
	STY    $E8
	LDY    $95
	LDA    WaveF,Y
	ROL
	AND    #$0F
	TAY
	LDA    LThr,Y
	STA    $E7
	LDA    $93
	AND    #$02
	BEQ    .t
	LSR    $E7
.t	LDA    $E7
	CMP    $84
	BCC    .a
	LDY    $E8
	LDA.w  $00B3,Y
	AND    #$3F
	CMP    #$09
	BCC    .a
	LDA    #$43
	STA    $A7,X
	LDA.w  $00CB,Y
	CLC
	ADC    #1
	STA    $BF,X
	JSR    Aim
	LDY    #4                    ; M5: launchers' Sparios get the launch sound too
	JSR    Sound
	JMP    Skip

; type 2: lane marker that flips the lane scroll direction ($FCA0)
H_Mark	SUBROUTINE
	LDA    $A5
	LSR
	CMP    #$1E
	BCC    .a
	LDA    $82
	ORA    #$02
	STA    $82
.a	JMP    Anim

; type $2F: waits, then opens with a sound ($FCC0)
H_2F	SUBROUTINE
	LDA    $84
	EOR    $80
	CMP    #$A0
	BCC    .a
	LDY    #5
	JSR    Sound
	INC    $A7,X
	JMP    Skip
.a	JMP    Anim

; type $30: drifts; may turn into an aimed Spario ($FCD4)
H_30	SUBROUTINE
	LDA    $84
	CMP    #$C0
	BCC    .m
	LDA    #$42
	STA    $A7,X
	LDY    #4
	JSR    Sound
.m	JSR    MoveTod
	JMP    Skip

; type $41: Spario in flight ($F286)
H_Move	JSR    MoveTod
	JMP    Anim

; type $42: aim at the ship ($FCD1)
H_Aim	JSR    Aim
	JMP    Anim

;---- families (each update: state check first, geometry only where needed) ----
H_Zoshi SUBROUTINE
	GEO
	LDA    $87
	CMP    #3
	BCC    .mv
	LDA    $E9
	SEC
	SBC    #6
	CMP    #18                   ; 6 <= dv < 24
	BCS    .mv
	LDA    $EA
	CMP    #3
	BCS    .mv
	RND
	CMP    #$40
	BCS    .mv
	JSR    Fire
.mv	LDA    $E9
	BMI    .go                   ; past the ship: keep going
	LDA    $EA
	CMP    #2
	BCC    .x                    ; over the ship's column: hold
	FACESHIP
.go	LDA    #4
	JSR    MoveLv
.x	JMP    Anim

H_Tork SUBROUTINE
	LDA    $BF,X
	BMI    .lv                   ; bit7 = fired, leaving
	GEO
	LDA    $E9
	BMI    .go
	CMP    #6
	BCC    .go                   ; too close: give up and leave
	LDA    $EA
	CMP    #2
	BCS    .ap
	RND                          ; stopped over the ship: fire when ready
	AND    #$03
	BNE    .x
	JSR    Fire
	BCC    .x
.go	LDA    $BF,X
	ORA    #$80
	STA    $BF,X
	JSR    FaceAway
.lv	LDA    #6
	JSR    MoveLv
.x	JMP    Anim
.ap	FACESHIP
	LDA    #3
	JSR    MoveLv
	JMP    Anim

H_Toroid SUBROUTINE
	LDA    $A7,X
	AND    #$03
	CMP    #2
	BEQ    .ap                   ; $0A/$0E approach
	CMP    #1
	BEQ    .fl                   ; $0D/$11 flee
	LDA    #1                    ; turning frames: slow drift away
	JSR    MoveLv
	JMP    Anim
.fl	LDA    #5
	JSR    MoveLv
	JMP    Anim
.ap	GEO
	LDA    $E9
	BMI    .turn
	CMP    #12
	BCC    .turn
	CMP    #20
	BCS    .home
	LDA    $EA
	CMP    #2
	BCC    .turn                 ; lined up and fairly close
.home	LDA    $EA
	CMP    #2
	BCC    .m
	FACESHIP
.m	LDA    #3
	JSR    MoveLv
	JMP    Anim
.turn	JSR    FaceAway
	LDA    $87
	CMP    #2
	BCC    .nf
	RND
	CMP    #$60
	BCS    .nf
	JSR    Fire
.nf	INC    $A7,X                 ; -> turning frames
	JMP    Skip

H_Kapi SUBROUTINE
	LDA    $A7,X
	AND    #$07
	CMP    #2
	BEQ    .ap                   ; $12/$1A approach
	CMP    #1
	BEQ    .fl                   ; $19/$21 flee
	LDA    #2                    ; U-turn frames
	JSR    MoveLv
	JMP    Anim
.fl	LDA    #6
	JSR    MoveLv
	JMP    Anim
.ap	GEO
	LDA    $87
	CMP    #9
	BCS    .terr
	LDA    $E9                   ; Kapi: swoop at the ship
	BMI    .turn
	CMP    #11
	BCC    .turn
	LDA    $EA
	CMP    #2
	BCC    .m
	FACESHIP
.m	LDA    #5
	JSR    MoveLv
	JMP    Anim
.terr	LDA    $E9                   ; Terrazi: tight zig-zag across the ship
	BMI    .turn
	CMP    #7
	BCC    .turn
	AWAY
	BCC    .tm
	LDA    $EA
	CMP    #5
	BCC    .tm
	LDA    $BF,X
	EOR    #$40
	STA    $BF,X
.tm	LDA    #6
	JSR    MoveLv
	JMP    Anim
.turn	JSR    FaceAway
	RND
	CMP    #$A0
	BCS    .nf
	JSR    Fire
.nf	LDA    $A7,X
	CLC
	ADC    #4                    ; $12->$16, $1A->$1E: short turn
	STA    $A7,X
	JMP    Skip

H_Jara SUBROUTINE
	GEO
	LDA    $E9
	BMI    .st
	AWAY
	BCC    .st
	LDA    $EA
	CMP    #12
	BCC    .st
	LDA    $BF,X                 ; swung far enough past: sweep back
	EOR    #$40
	STA    $BF,X
.st	LDA    #5
	JSR    MoveLv
	LDA    $A7,X
	CMP    #$22
	BNE    .a
	INC    $A7,X                 ; first update: start the spin cycle
	JMP    Skip
.a	JMP    Anim

 IF TODAI
;---- verification build: Tod's own family handlers ($FCAB/$FC17/$FC1E/$F286) ----
T_Turn	SUBROUTINE              ; handler 5: flip and advance at lane Y/2 == 6
	LDA    $A5
	LSR
	LSR
	CMP    #6
	BNE    T_Mv
	LDA    $BF,X
	EOR    #$40
	STA    $BF,X
	INC    $A7,X
	JMP    Skip
T_Mv	JSR    MoveTod              ; handler 1
	JMP    Anim
T_Spin	SUBROUTINE              ; handler 6
	LDA    $A5
	LSR
	AND    #$0F
	BNE    T_Mv
	JSR    Aim
	JMP    Anim
T_Bomb	SUBROUTINE              ; handler 8
	LDA    $BF,X
	BMI    T_Mv
	LDA    $A5
	LSR
	STA    $E7
	LDY    $D4
	CPY    $E7
	BCC    T_Mv
	LDA    $BF,X
	ORA    #$80
	STA    $BF,X
	JSR    Aim
	JMP    Anim
 ENDIF

;---- helpers (leaf routines; only Fire calls Sound) ----
FaceAway SUBROUTINE
	LDA    $EA
	CMP    #2
	BCS    .d
	LDA    $BF,X                 ; lined up: head for the nearer edge
	AND    #$3F
	CMP    #30
	LDA    $BF,X
	AND    #$BF
	BCS    .s
	ORA    #$40
	BNE    .s
.d	LDA    $BF,X
	AND    #$BF
	LDY    $E8
	BPL    .s
	ORA    #$40                  ; left of the ship: go left
.s	STA    $BF,X
	RTS

; MoveLv: A = speed level 0-7 (Steps4 rows 12-19). MoveTod: Tod's class
; speeds ($F286). Steps are pre-scaled x4 so X<<2 +/- step gives the range
; check from the carry and one compare. Leaving X 0..$3B frees the slot.
MoveTod	SUBROUTINE
	LDY    $A7,X
	LDA    Cls,Y
	AND    #$0E
	ASL
	ASL
	LDY    $BF,X
	BPL    .s
	ORA    #$04
.s	ORA    $EC
	TAY
	JMP    MoveY
MoveLv	ASL
	ASL
	ADC    #48
	ORA    $EC
	TAY
MoveY	SUBROUTINE
	LDA    Steps4,Y
	STA    $DF
	LDA    $BF,X
	ASL
	ASL                          ; C = bit6 (left), A = X<<2
	BCS    .l
	ADC    $DF
	BCS    .gone
	BCC    .ck
.l	SBC    $DF
	BCC    .gone
.ck	CMP    #$F0                  ; $3C<<2
	BCS    .gone
	LSR
	LSR
	STA    $DF
	LDA    $BF,X
	AND    #$C0
	ORA    $DF
	STA    $BF,X
	RTS
.gone	LDA    #0
	STA    $A7,X
	RTS

; Aim: Tod's $F21E (direction toward the ship; slow if closer across than down)
Aim	SUBROUTINE
	LDY    #$C0
	LDA    $BF,X
	AND    #$3F
	STA    $E7
	LSR
	CMP    $D5
	BCS    .a
	LDY    #$80
.a	TYA
	ORA    $E7
	STA    $BF,X
	LDA    $A5
	LSR
	SEC
	SBC    $BB
	BPL    .b
	EOR    #$FF
.b	LSR
	STA    $E7
	LDA    $BF,X
	AND    #$3F
	LSR
	SEC
	SBC    $D5
	BPL    .c
	EOR    #$FF
.c	CMP    $E7
	BCS    .r
	LDA    $BF,X
	AND    #$7F
	STA    $BF,X
.r	RTS

; Fire: put an aimed Spario (type $43) in the lane just below slot X, if that
; lane is empty and on screen (the lanes themselves cap how many are up).
; Needs GEO ($E8,$E9,$EA). Out: C=1 fired (also starts sound 4).
Fire	SUBROUTINE
	LDY    Below,X
	CPY    $D6                   ; X is the bottom lane
	BEQ    .no
	LDA.w  $00A7,Y
	BNE    .no
	STY    $DF
	LDY    $DF
	LDA    #$43
	STA.w  $00A7,Y
	LDA    $BF,X
	AND    #$3F
	LDY    $E8
	BMI    .r
	ORA    #$40                  ; enemy right of the ship: Spario goes left
.r	ORA    #$80
	STA    $E7
	LDA    $E9
	BPL    .v
	EOR    #$FF
.v	LSR                          ; |dv|/2 vs |dx| as in Tod's aim
	CMP    $EA
	BCC    .f
	BEQ    .f
	LDA    $E7
	AND    #$7F
	STA    $E7
.f	LDA    $E7
	LDY    $DF
	STA.w  $00BF,Y
	LDY    #4
	JSR    Sound
	SEC
	RTS
.no	CLC
	RTS

; Sound: the bank 3 engine's request (snd.asm SndReq), Y = sound number
Sound	SUBROUTINE
	CPY    $98
	BCC    .r
	STY    $98
	LDA    B0S0Start,Y
	STA    $9C
	LDA    B0S1Start,Y
	STA    $99
	LDA    #0
	STA    $9A
.r	RTS

;---- tables ----
RndMix	.byte  $00,$5B,$B6,$11,$6C,$C7,$22,$7D,$D8,$33,$8E,$E9
	include sndstart.inc		; = bank 3 S0Start/S1Start (tools/sndgen.py)
	include tabs.inc		; ends with SpdAll (Tod's 6 classes, 48 bytes)
	; SpdAll rows 12-19 must follow directly (offset 48): speed levels 0-7, per tick phase
	.byte  0,0,0,0, 1,1,1,1, 1,2,1,2, 2,2,2,2
	.byte  2,3,2,3, 3,3,3,3, 3,4,3,4, 4,4,4,4

; handler entry for each air type (low bytes into page HJmp)
HndLo
 IF TODAI
	.byte  <J_Launch,<J_None,<J_Mark,<J_TSpin,<J_TSpin,<J_TSpin,<J_TBomb,<J_TBomb,<J_TBomb,<J_TBomb
	.byte  <J_TTurn,<J_None,<J_None,<J_TMv,<J_TTurn,<J_None,<J_None,<J_TMv          ; 0A-11
	.byte  <J_TTurn,<J_None,<J_None,<J_None,<J_None,<J_None,<J_None,<J_TMv          ; 12-19
	.byte  <J_TTurn,<J_None,<J_None,<J_None,<J_None,<J_None,<J_None,<J_TMv          ; 1A-21
	.byte  <J_TTurn
	REPEAT 12
	.byte  <J_TMv                                                                   ; 23-2E
	REPEND
 ELSE
	.byte  <J_Launch,<J_None,<J_Mark                        ; 00-02
	.byte  <J_Zoshi,<J_Zoshi,<J_Zoshi                       ; 03-05
	.byte  <J_Tork,<J_Tork,<J_Tork,<J_Tork                  ; 06-09
	REPEAT 8
	.byte  <J_Toroid                                        ; 0A-11
	REPEND
	REPEAT 16
	.byte  <J_Kapi                                          ; 12-21
	REPEND
	REPEAT 13
	.byte  <J_Jara                                          ; 22-2E
	REPEND
 ENDIF
	.byte  <J_2F,<J_30                                      ; 2F-30
	REPEAT 16
	.byte  <J_None                                          ; 31-40 Bacura
	REPEND
	.byte  <J_Move,<J_Aim                                   ; 41-42
	REPEAT 13
	.byte  <J_None                                          ; 43-4F
	REPEND
