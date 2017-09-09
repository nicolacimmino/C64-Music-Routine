
align 256

INSTTBL WORD INSTRNO
        WORD INSTR1
        WORD INSTR2
        WORD PIANO
        WORD SHOT
        WORD SHOT

        ; Null instrument, used for voices where an instrument has not be set 
        ; yet.
INSTRNO BYTE $FF        ; END

        ; This is is an example of an instrumet such, for instance, a flute or
        ; a piano where the length of the note is set in the phrase
INSTR1  BYTE $25, $03   ; WVR 5, $52            AD
        BYTE $26, $00   ; SR
        BYTE $24, $11   ; WVR 4, %10000001      triangle + GATE ON
        BYTE $10        ; WAI (note off)
        BYTE $24, $10   ; WVR 4, 0              triangle + GATE OFF
        BYTE $FF        ; END

        ; This is an example of an instument such as a percussion
        ; that has its own duration regardless of what is set in the phrase
INSTR2  BYTE $25, $11   ; WVR 5, $52            AD
        BYTE $26, $F1   ; SR
        BYTE $24, $81   ; WVR 4, %10000001      NOISE + GATE ON
        BYTE $00, $01   ; WIN 1                 Init wait to 1 tick
        BYTE $10        ; WAI (duration set)
        BYTE $24, $00   ; WVR 4, 0              NOISE + GATE OFF
        BYTE $FF        ; END

PIANO   BYTE $25, $4F   ; WVR 5, $FF            AD
        BYTE $26, $00   ; SR
        BYTE $24, $11   ; WVR 4, %10000001      triangle + GATE ON
        BYTE $10        ; WAI (note off)
        BYTE $24, $00   ; WVR 4, 0              triangle + GATE OFF
        BYTE $FF        ; END

        ; GUNSHOT. THIS IS ACHIEVED WITH WHITE NOISE GATED FOR TWO TICKS
        ; AND THEN FADING OUT WITH A RELEASE OF 750MS. NOTE HOW WE SET THE
        ; FREQUENCY AROUND 600HZ, SID WHITE NOISE IS ACTUALLY COLOURED SO 
        ; THIS MATTERS.

SHOT    BYTE $25, $00   ; WVR 5, $52            AD
        BYTE $26, $F9   ; SR
        BYTE $21, $28   ; FH
        BYTE $20, $C8   ; FL
        BYTE $24, $81   ; WVR 4, %10000001      noise-gate        
        BYTE $00, $02   ; WIN 1                 Init wait to 1 tick
        BYTE $10        ; WAI (duration set)        
        BYTE $24, $80   ; WVR 4, %10000001      noise-gate        
        BYTE $FF        ; END

        ; ticklo tickhi  FRELO FREHI INSTR, DUR

align 8


PHRASE  BYTE $44, $0F, $D6, $1C, $02, $00, $00, $00
        BYTE $54, $00, $D6, $2C, $02, $00, $00, $00
        BYTE $64, $00, $D6, $1C, $02, $00, $00, $00
        BYTE $74, $00, $D6, $2C, $02, $00, $00, $00
        BYTE $84, $00, $D6, $1C, $02, $00, $00, $00
        BYTE $94, $00, $D6, $2C, $02, $00, $00, $00
        BYTE $A4, $00, $D6, $1C, $02, $00, $00, $00
        BYTE $B4, $00, $D6, $2C, $02, $00, $00, $00
        BYTE $C4, $00, $D6, $1C, $02, $00, $00, $00
        BYTE $D4, $00, $D6, $2C, $02, $00, $00, $00
        BYTE $E4, $00, $D6, $1C, $02, $00, $00, $00
        BYTE $F4, $00, $D6, $2C, $02, $00, $00, $00
        BYTE $04, $01, $D6, $1C, $02, $00, $00, $00
        BYTE $14, $01, $D6, $2C, $02, $00, $00, $00
        BYTE $24, $01, $D6, $1C, $02, $00, $00, $00
        BYTE $34, $01, $D6, $2C, $02, $00, $00, $00

PHRASE2 BYTE $41, $0F, $D6, $1C, $03, $05, $00, $00
        BYTE $51, $00, $D6, $2C, $03, $02, $00, $00
        BYTE $61, $00, $D6, $1C, $03, $05, $00, $00
        BYTE $71, $00, $D6, $2C, $03, $02, $00, $00
        BYTE $81, $00, $D6, $1C, $03, $05, $00, $00
        BYTE $91, $00, $D6, $2C, $03, $02, $00, $00
        BYTE $A1, $00, $D6, $1C, $03, $05, $00, $00
        BYTE $B1, $00, $D6, $2C, $03, $02, $00, $00
        BYTE $C1, $00, $D6, $1C, $03, $05, $00, $00
        BYTE $D1, $00, $D6, $2C, $03, $02, $00, $00
        BYTE $E1, $00, $D6, $1C, $03, $05, $00, $00
        BYTE $F1, $00, $D6, $2C, $03, $02, $00, $00
        BYTE $01, $01, $D6, $1C, $03, $05, $00, $00
        BYTE $11, $01, $D6, $2C, $03, $02, $00, $00
        BYTE $21, $01, $D6, $1C, $03, $05, $00, $00
        BYTE $31, $01, $D6, $2C, $03, $02, $00, $00
        BYTE $41, $01, $D6, $1C, $03, $05, $00, $00
        BYTE $51, $01, $D6, $2C, $03, $02, $00, $00
        BYTE $61, $01, $D6, $1C, $03, $05, $00, $00
        BYTE $71, $01, $D6, $2C, $03, $02, $00, $00
        BYTE $81, $01, $D6, $1C, $03, $05, $00, $00
        BYTE $91, $01, $D6, $2C, $03, $02, $00, $00
        BYTE $A1, $01, $D6, $1C, $03, $05, $00, $00
        BYTE $B1, $01, $D6, $2C, $03, $02, $00, $00
        BYTE $C1, $01, $D6, $1C, $03, $05, $00, $00
        BYTE $D1, $01, $D6, $2C, $03, $02, $00, $00
        BYTE $E1, $01, $D6, $1C, $03, $05, $00, $00
        BYTE $F1, $01, $D6, $2C, $03, $02, $00, $00
        BYTE $01, $02, $D6, $1C, $03, $05, $00, $00
        BYTE $11, $02, $D6, $2C, $03, $02, $00, $00
        BYTE $21, $02, $D6, $1C, $03, $05, $00, $00
        BYTE $31, $02, $D6, $2C, $03, $02, $00, $00
        BYTE $41, $02, $D6, $1C, $03, $05, $00, $00
        BYTE $51, $02, $D6, $2C, $03, $02, $00, $00
        BYTE $61, $02, $D6, $1C, $03, $05, $00, $00
        BYTE $71, $02, $D6, $2C, $03, $02, $00, $00
        BYTE $81, $02, $D6, $1C, $03, $05, $00, $00
        BYTE $91, $02, $D6, $2C, $03, $02, $00, $00
        BYTE $A1, $02, $D6, $1C, $03, $05, $00, $00
        BYTE $B1, $02, $D6, $2C, $03, $02, $00, $00
        BYTE $C1, $02, $D6, $1C, $03, $05, $00, $00
        BYTE $D1, $02, $D6, $2C, $03, $02, $00, $00
        BYTE $E1, $02, $D6, $1C, $03, $05, $00, $00
        BYTE $F1, $02, $D6, $2C, $03, $02, $00, $00
        BYTE $01, $03, $D6, $1C, $03, $05, $00, $00
        BYTE $11, $03, $D6, $2C, $03, $02, $00, $00
        BYTE $21, $03, $D6, $1C, $03, $05, $00, $00
        BYTE $31, $03, $D6, $2C, $03, $02, $00, $00
        BYTE $41, $03, $D6, $1C, $03, $05, $00, $00
        BYTE $51, $03, $D6, $2C, $03, $02, $00, $00
        BYTE $61, $03, $D6, $1C, $03, $05, $00, $00
        BYTE $71, $03, $D6, $2C, $03, $02, $00, $00
        BYTE $81, $03, $D6, $1C, $03, $05, $00, $00
        BYTE $91, $03, $D6, $2C, $03, $02, $00, $00
        BYTE $A1, $03, $D6, $1C, $03, $05, $00, $00
        BYTE $B1, $03, $D6, $2C, $03, $02, $00, $00
        BYTE $C1, $03, $D6, $1C, $03, $05, $00, $00
        BYTE $D1, $03, $D6, $2C, $03, $02, $00, $00
        BYTE $E1, $03, $D6, $1C, $03, $05, $00, $00
        BYTE $F1, $03, $D6, $2C, $03, $02, $00, $00
        
PHRASE3 BYTE $48, $00, $D6, $1C, $05, $01, $00, $00
        BYTE $58, $00, $D6, $2C, $04, $02, $00, $00
        BYTE $68, $00, $D6, $1C, $05, $03, $00, $00
        BYTE $78, $00, $D6, $2C, $04, $04, $00, $00
        BYTE $88, $00, $D6, $1C, $05, $05, $00, $00
        BYTE $98, $00, $D6, $2C, $04, $06, $00, $00
        BYTE $A8, $00, $D6, $1C, $05, $07, $00, $00
        BYTE $B8, $00, $D6, $2C, $04, $08, $00, $00
        BYTE $C8, $00, $D6, $1C, $05, $09, $00, $00
        BYTE $D8, $00, $D6, $2C, $04, $0A, $00, $00
        BYTE $E8, $0F, $D6, $1C, $01, $05, $00, $00
        BYTE $F8, $00, $D6, $2C, $01, $02, $00, $00
        BYTE $08, $01, $D6, $1C, $01, $05, $00, $00
        BYTE $18, $01, $D6, $2C, $01, $02, $00, $00
        BYTE $28, $01, $D6, $1C, $01, $05, $00, $00
        BYTE $38, $01, $D6, $2C, $01, $02, $00, $00
