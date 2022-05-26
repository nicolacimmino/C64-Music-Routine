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

align 256

INSTTBL WORD INSTRNO
        WORD DRUM1
        WORD BASS1
        
        ; Null instrument, used for voices where an instrument has not be set 
        ; yet.
INSTRNO BYTE $FF        ; END

DRUM1   BYTE $41, $8F, $0E, $00, $08, $10, $00, $F7
                        ; VIN FREQ=220Hz, PW=50%,TRIANGLE, GATE ON,
                        ; A=2mS D=6mS S=15  R=240ms                    

        BYTE $21, $2E   ; WVR 1, $2E            FREQ=700Hz
        BYTE $24, $81   ; WRI 4, %10000001      NOISE, GATE ON        
        BYTE $E0        ; YLD

        BYTE $21, $0E   ; WVR 1, $0E            FREQ=220Hz
        BYTE $24, $11   ; WRI 4, %00010001      TRIANGLE, GATE ON        
        BYTE $E0        ; YLD

        BYTE $24, $41   ; WRI 4, %01000001      PULSE, GATE ON        
        BYTE $E0        ; YLD
        
        BYTE $21, $2E   ; WVR 1, $2E            FREQ=700Hz
        BYTE $24, $80   ; WRI 4, %10000000      NOISE, GATE OFF

        BYTE $02        ; WIN 2                 INIT WAIT, 4 TICKS (P0*2)
        BYTE $10        ; LWW 0                 LOOP WHILE WAITING OFFSET 0
        
        BYTE $21, $0E   ; WVR 1, $0E            FREQ=220Hz
        BYTE $24, $40   ; WRI 4, %01000000      PULSE, GATE OFF
        
        BYTE $FF        ; END


BASS1   BYTE $31, $82
        BYTE $41, $6F, $03, $00, $04, $40, $00, $F0
                        ; VIN FREQ=51Hz, PW=75%,PULSE, GATE ON,
                        ; A=2mS D=6mS S=15  R=6ms            

        BYTE $0A        ; WIN 10                 INIT WAIT, 2 LOOPS                        
        BYTE $10        ; LWW 0                 LOOP WHILE WAITING OFFSET 0
        
        BYTE $31, $81

        BYTE $0A        ; WIN 10                 INIT WAIT, 2 LOOPS                        
        BYTE $10        ; LWW 0                 LOOP WHILE WAITING OFFSET 0

        ;BYTE $31, $81 ; filt
        
        BYTE $0A        ; WIN 10                 INIT WAIT, 2 LOOPS                        
        BYTE $10        ; LWW 0                 LOOP WHILE WAITING OFFSET 0

        BYTE $24, $00   ; WRI 4, %01000000      PULSE, GATE OFF
        BYTE $FF        ; END

