
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

        ; GUNSHOT. THIS IS ACHIEVED WITH WHITE NOISE GATED FOR FOUR TICKS
        ; AND THEN FADING OUT WITH A RELEASE OF 750MS. NOTE HOW WE SET THE
        ; FREQUENCY AROUND 600HZ, SID WHITE NOISE IS ACTUALLY COLOURED SO 
        ; THIS MATTERS.

SHOT    BYTE $25, $00   ; WRI 5, $00            ATTACK 0MS, DECAY 0MS
        BYTE $26, $F9   ; WRI 6, $F9            SUSTAIN 16, RELEASE 750MS
        BYTE $21, $28   ; WRI 1, $28            FREQUENCY HI
        BYTE $20, $C8   ; WRI 0, $C8            FREQUENCY LO (622HZ)
        BYTE $24, $81   ; WRI 4, %10000001      WF NOISE, GATE ON        
        BYTE $00, $02   ; WIN 2                 INIT WAIT, 2 TICKS
        BYTE $10        ; WAI                   WAIT
        BYTE $24, $80   ; WRI 4, %10000000      NOISE, GATE OFF        
        BYTE $FF        ; END

