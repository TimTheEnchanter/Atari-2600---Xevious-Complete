;----------------------------------------------------------------------
; M5 sound engine (bank 3, in the space of Tod's old kernel copy, which has
; been dead since the kernel moved to bank 1). Replaces $BD0A / $BD21;
; reached through the same trampolines ($B018 request, $B00C frame update).
; Request semantics are Tod's: Y = sound, a higher number may interrupt a
; lower one. Each sound has a ch0 and a ch1 note sequence (Seq0 / Seq1).
; RAM (Tod's): $98 sound, $99 ch1 pos, $9A step timer, $9B idle counter,
; $9C ch0 pos, $9D bomb whistle (1..$7F) / landing thump ($F0..$FF);
; $82 bits 2-4: Andor alarm timer (free bits of Tod's frame counter byte).
;----------------------------------------------------------------------
TODBGM	= 0		; 1 = Tod's bass ostinato instead of the drone on idle ch1

SndReq	SUBROUTINE              ; Y = sound
	CPY    $98
	BCC    .x
	STY    $98
	LDA    S0Start,Y
	STA    $9C
	LDA    S1Start,Y
	STA    $99
	LDA    #0
	STA    $9A
.x	JMP    $F018                 ; back to bank 2

SndUpd	SUBROUTINE              ; once per game frame
	INC    $9B
	LDA    $9C
	ORA    $99
	BEQ    .c0                   ; both channels idle
	DEC    $9A
	BPL    .c0
	LDX    $98                   ; next step
	LDA    SRate,X
	STA    $9A
	LDA    SCtl,X
	STA    AUDC0
	STA    AUDC1
	LDA    $9C
	BEQ    .a1
	INC    $9C
.a1	LDA    $99
	BEQ    .c0
	INC    $99
;-- channel 0: effect, else Andor alarm / hum, else silence
.c0	LDY    $9C
	BEQ    .i0
	LDA    Seq0,Y
	BNE    .p0
	STA    $9C                   ; ch0 sequence done
	STA    $98
.i0	LDA    $91
	AND    #$06
	BNE    .andor
	LDA    $82                   ; no Andor: reset the alarm timer
	AND    #$E3
	STA    $82
	LDA    #0
	STA    AUDV0
	BEQ    .c1
.andor	LDA    $82
	AND    #$1C
	CMP    #$1C
	BEQ    .hum
	LDA    $9B                   ; siren for ~4 s: two tones, 8 frames each
	AND    #$1F
	BNE    .sir
	LDA    $82
	CLC
	ADC    #$04
	STA    $82
.sir	LDA    #$04
	STA    AUDC0
	LDA    $9B
	AND    #$08
	BEQ    .s1
	LDA    #$86                  ; note: vol 9, freq 6
	BNE    .p0
.s1	LDA    #$89                  ; vol 9, freq 9
	BNE    .p0
.hum	LDA    #$09                  ; then Tod's Andor hum (quieter)
	STA    AUDC0
	LDA    #$6F
.p0	STA    AUDF0
	LSR
	LSR
	LSR
	LSR
	ORA    #$01
	STA    AUDV0
;-- bomb state, every frame: $9D 1..$7F whistle while the bomb falls,
;   $F0..$FF landing thump, 0 idle (Tod's drop code sets $E0: restarts here)
.c1	LDA    $D3
	AND    #$07
	BEQ    .nob
	LDA    $9D
	BMI    .ws
	BNE    .wg
.ws	LDA    #$01                  ; new whistle
	STA    $9D
.wg	LDA    $82                   ; slow scroll: bombs fall half as fast
	LSR
	BCC    .wi
	LDA    $9B
	LSR
	BCC    .bs
.wi	LDA    $9D
	CMP    #$7F
	BCS    .bs
	INC    $9D
	BNE    .bs
.nob	LDA    $9D
	BEQ    .bs
	BMI    .ti
	LDA    #$F0                  ; bomb has landed: start the thump
	STA    $9D
	BNE    .bs
.ti	INC    $9D                   ; thump runs out at 0
;-- channel 1: effect part, else bomb whistle / thump, else drone
.bs	LDY    $99
	BEQ    .i1
	LDA    Seq1,Y
	BNE    .p1
	STA    $99                   ; ch1 sequence done
.i1	LDA    $9D
	BEQ    .drone
	BMI    .th
	LDA    #$04                  ; whistle: falling pitch
	STA    AUDC1
	LDA    $9D
	LSR
	CMP    #$12
	BCC    .wc
	LDA    #$12
.wc	ADC    #$06                  ; freq 6..25
	ORA    #$E0                  ; vol 15
	BNE    .p1
.th	LDA    #$08                  ; thump: low noise, fading
	STA    AUDC1
	LDA    $9D
	EOR    #$0F                  ; $F0..$FF -> volume 15..0
	ASL
	ASL
	ASL
	ASL
	ORA    #$1E
	BNE    .p1
.drone
 IF TODBGM
	LDA    $9B                   ; Tod's ostinato: one note per 8 frames
	LSR
	LSR
	LSR
	AND    #$1F
	TAX
	LDA    #$04
	STA    AUDC1
	LDA    TodBass,X
 ELSE
	LDA    #$06                  ; low pulsing hum (div-31 tone)
	STA    AUDC1
	LDA    $9B
	LSR
	LSR
	LSR
	AND    #$07
	TAX
	LDA    DroneV,X
 ENDIF
.p1	STA    AUDF1
	LSR
	LSR
	LSR
	LSR
	ORA    #$01
	STA    AUDV1
	JMP    $F00C                 ; back to bank 2

DroneV	.byte  $0D,$2D,$2D,$4D,$4D,$2D,$2D,$0D   ; vol 1,3,3,5,5,3,3,1 at freq 13
 IF TODBGM
TodBass	.byte $3D,$4E,$4F,$4E,$4B,$4E,$4F,$4E,$3D,$4E,$50,$4E,$4B,$4E,$50,$4E
	.byte $3D,$4E,$51,$4E,$4B,$4E,$51,$4E,$3D,$4E,$52,$4E,$4B,$4E,$52,$4E
 ENDIF
	include sndtab.inc
