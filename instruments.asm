
INSTTBL WORD INSTRNO
        WORD INSTR1
        WORD INSTR2
        WORD PIANO

        ; Null instrument, used for voices where an instrument has not be set 
        ; yet.
INSTRNO BYTE $FF        ; END

        ; This is is an example of an instrumet such, for instance, a flute or
        ; a piano doing legato, where the length of the note is set in the phrase
INSTR1  BYTE $25, $11   ; WVR 5, $52            AD
        BYTE $26, $F1   ; SR
        BYTE $24, $11   ; WVR 4, %10000001      triangle + GATE ON
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
PHRASE  BYTE $41, $00, $D6, $1C, $03, $05
        BYTE $81, $00, $D6, $2C, $03, $20
        BYTE $F1, $00, $D6, $1C, $03, $30
        BYTE $41, $01, $D6, $2C, $03, $40
