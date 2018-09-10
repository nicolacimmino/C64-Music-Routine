; *****************************************************************************
; *                                                                           *
; * COPYRIGHT (C) 2018 NICOLA CIMMINO                                         *
; *                                                                           *
; *   THIS PROGRAM IS FREE SOFTWARE: YOU CAN REDISTRIBUTE IT AND/OR MODIFY    *
; *   IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY    *
; *   THE FREE SOFTWARE FOUNDATION, EITHER VERSION 3 OF THE LICENSE, OR       *
; *   (AT YOUR OPTION) ANY LATER VERSION.                                     *
; *                                                                           *
; *  THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL,          *
; *   BUT WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF          *
; *   MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  SEE THE           *
; *   GNU GENERAL PUBLIC LICENSE FOR MORE DETAILS.                            *
; *                                                                           *
; *   YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE       *
; *   ALONG WITH THIS PROGRAM.  IF NOT, SEE HTTP://WWW.GNU.ORG/LICENSES/.     *
; *                                                                           *
; *                                                                           *
; *****************************************************************************

incasm "instruments.asm"
incasm "scale.asm"

        ; TICK, NOTE, INSTR, DUR

TRACK   BYTE <PHRASE1, >PHRASE1
        BYTE <PHRASE0, >PHRASE0
        BYTE <PHRASE0, >PHRASE0
        BYTE $00, $00

        align 4

PHRASE0 BYTE $FF, $A0, <PHRASE0, >PHRASE0       

PHRASE1 BYTE $00, 00, $06, $00
        BYTE $5F, $A0, <PHRASE1, >PHRASE1       

PHRASE2 BYTE $00, 00, $06, $00        
        BYTE $5F, $A0, <PHRASE2, >PHRASE2       

PHRASE3 BYTE $00, 00, $06, $00
        BYTE $5f, $A0, <PHRASE3, >PHRASE3

        BYTE $01, $80, $00, $00
PHRASE4 BYTE $00, 50, $01, $05
        BYTE $0F, $A5, <PHRASE4, >PHRASE4       
PHRASE5 BYTE $00, 90, $01, $05
        BYTE $0F, $A0, <PHRASE5, >PHRASE5       
        