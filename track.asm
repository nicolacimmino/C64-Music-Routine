        ; TICK, NOTE, INSTR, DUR

align 4

PHRASE1 BYTE $00, 69, $02, $05
        BYTE $0F, 0, <PHRASE1, >PHRASE1       

PHRASE2 BYTE $00, 69, $02, $05
        BYTE $10, 71, $02, $05
        BYTE $1F, 0, <PHRASE2, >PHRASE2       

PHRASE3 BYTE $00, 80, $02, $05
        BYTE $0F, 0, <PHRASE3, >PHRASE3       
        