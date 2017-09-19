        ; TICK, NOTE, INSTR, DUR

align 4

PHRASE3 BYTE $48, 69, $04, $10
        BYTE $58, 71, $04, $10
        BYTE $68, 72, $04, $10
        BYTE $78, 74, $04, $10
        BYTE $88, 76, $04, $10
        BYTE $98, 69, $04, $10
        BYTE $A8, 71, $04, $10
        BYTE $B8, 72, $04, $10
        BYTE $C8, 74, $04, $10
        BYTE $D8, 76, $04, $10
        BYTE $FF, 0, <PHRASE3, >PHRASE3       
