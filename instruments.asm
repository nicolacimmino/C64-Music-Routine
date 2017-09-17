
align 256

INSTTBL WORD INSTRNO
        WORD INSTRNO
        WORD INSTRNO
        WORD LEAD1
        WORD SHOT
        WORD SHOT

        ; Null instrument, used for voices where an instrument has not be set 
        ; yet.
INSTRNO BYTE $FF        ; END

LEAD1   BYTE $25, $09   ; WVR 5, $FF            AD
        BYTE $26, $84   ; SR
        BYTE $23, $4
        BYTE $22, $00                
        BYTE $29, $49
        BYTE $28, $00
        BYTE $2A, $F4   ; TODO:4 is the voice, filter needs a voice agnostic cmd
        BYTE $2B, $1F   ; F is the volume should be able to and/or+mask
        BYTE $24, $41   ; WVR 4, %10000001      triangle + GATE ON
        BYTE $22, $80
        BYTE $E0
        BYTE $22, $00
        BYTE $15
        BYTE $24, $40   ; WVR 4, 0              triangle + GATE OFF
        BYTE $E0
        BYTE $E0         
        BYTE $E0                 
        BYTE $2A, $00
        BYTE $FF        ; END

        ; GUNSHOT. THIS IS ACHIEVED WITH WHITE NOISE GATED FOR FOUR TICKS
        ; AND THEN FADING OUT WITH A RELEASE OF 750MS. NOTE HOW WE SET THE
        ; FREQUENCY AROUND 600HZ, SID WHITE NOISE IS ACTUALLY COLOURED SO 
        ; THIS MATTERS.

SHOT    BYTE $25, $02   ; WRI 5, $02            ATTACK 0MS, DECAY 16MS
        BYTE $26, $A9   ; WRI 6, $A9            SUSTAIN 10, RELEASE 750MS
        BYTE $21, $28   ; WRI 1, $28            FREQUENCY HI
        BYTE $20, $C8   ; WRI 0, $C8            FREQUENCY LO (622HZ)
        BYTE $24, $81   ; WRI 4, %10000001      WF NOISE, GATE ON        
        BYTE $02        ; WIN 2                 INIT WAIT, 4 TICKS
        BYTE $10        ; LWW 0                 LOOP WHILE WAITING OFFSET 0
        BYTE $24, $80   ; WRI 4, %10000000      NOISE, GATE OFF        
        BYTE $FF        ; END

