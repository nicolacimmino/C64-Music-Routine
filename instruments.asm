
align 256

INSTTBL WORD INSTRNO
        WORD INSTR1
        WORD INSTR2
        WORD PIANO

        ; Null instrument, used for voices where an instrument has not be set 
        ; yet.
INSTRNO BYTE $FF        ; END

        ; This is is an example of an instrumet such, for instance, a flute or
        ; a piano where the length of the note is set in the phrase
INSTR1  BYTE $25, $11   ; WVR 5, $52            AD
        BYTE $26, $F1   ; SR
        BYTE $24, $21   ; WVR 4, %10000001      triangle + GATE ON
        BYTE $10        ; WAI (note off)
        BYTE $24, $00   ; WVR 4, 0              triangle + GATE OFF
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

        ; ticklo tickhi  FRELO FREHI INSTR, DUR

align 8

PHRASE  BYTE $41, $00, $D6, $1C, $02, $00, $00, $00
        BYTE $51, $00, $D6, $2C, $02, $00, $00, $00
        BYTE $61, $00, $D6, $1C, $02, $00, $00, $00
        BYTE $71, $00, $D6, $2C, $02, $00, $00, $00
        BYTE $81, $00, $D6, $1C, $02, $00, $00, $00
        BYTE $91, $00, $D6, $2C, $02, $00, $00, $00
        BYTE $A1, $00, $D6, $1C, $02, $00, $00, $00
        BYTE $B1, $00, $D6, $2C, $02, $00, $00, $00
        BYTE $C1, $00, $D6, $1C, $02, $00, $00, $00
        BYTE $D1, $00, $D6, $2C, $02, $00, $00, $00
        BYTE $E1, $00, $D6, $1C, $02, $00, $00, $00
        BYTE $F1, $00, $D6, $2C, $02, $00, $00, $00
        BYTE $01, $01, $D6, $1C, $02, $00, $00, $00
        BYTE $11, $01, $D6, $2C, $02, $00, $00, $00
        BYTE $21, $01, $D6, $1C, $02, $00, $00, $00
        BYTE $31, $01, $D6, $2C, $02, $00, $00, $00

PHRASE2 BYTE $41, $00, $D6, $1C, $03, $05, $00, $00
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
        
PHRASE3 BYTE $41, $00, $D6, $1C, $01, $05, $00, $00
        BYTE $51, $00, $D6, $2C, $01, $02, $00, $00
        BYTE $61, $00, $D6, $1C, $01, $05, $00, $00
        BYTE $71, $00, $D6, $2C, $01, $02, $00, $00
        BYTE $81, $00, $D6, $1C, $01, $05, $00, $00
        BYTE $91, $00, $D6, $2C, $01, $02, $00, $00
        BYTE $A1, $00, $D6, $1C, $01, $05, $00, $00
        BYTE $B1, $00, $D6, $2C, $01, $02, $00, $00
        BYTE $C1, $00, $D6, $1C, $01, $05, $00, $00
        BYTE $D1, $00, $D6, $2C, $01, $02, $00, $00
        BYTE $E1, $00, $D6, $1C, $01, $05, $00, $00
        BYTE $F1, $00, $D6, $2C, $01, $02, $00, $00
        BYTE $01, $01, $D6, $1C, $01, $05, $00, $00
        BYTE $11, $01, $D6, $2C, $01, $02, $00, $00
        BYTE $21, $01, $D6, $1C, $01, $05, $00, $00
        BYTE $31, $01, $D6, $2C, $01, $02, $00, $00
