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
        WORD LEAD1
        WORD LEAD2
        WORD SHOT
        WORD TEST1
        WORD TEST2
        WORD DRUM1

        ; Null instrument, used for voices where an instrument has not be set 
        ; yet.
INSTRNO BYTE $FF        ; END

DRUM1   BYTE $40, $8F, $0E, $00, $08, $10, $00, $F7
                        ; VIN FREQ=220Hz, PW=50%,TRIANGLE, GATE ON,
                        ; A=2mS D=6mS S=15  R=240ms            
        BYTE $24, $11   ; WRI 4, %00010001      TRIANGLE, GATE ON        
        BYTE $E0        ; YLD

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


        ; GUNSHOT. THIS IS ACHIEVED WITH WHITE NOISE GATED FOR TWO TICKS
        ; AND THEN FADING OUT WITH A RELEASE OF 750MS. NOTE HOW WE SET THE
        ; FREQUENCY AROUND 600HZ, SID WHITE NOISE IS ACTUALLY COLOURED SO 
        ; THIS MATTERS.

SHOT    BYTE $25, $02   ; WRI 5, $02            ATTACK 0MS, DECAY 16MS
        BYTE $26, $A9   ; WRI 6, $A9            SUSTAIN 10, RELEASE 750MS
        BYTE $21, $28   ; WRI 1, $28            FREQUENCY HI
        BYTE $20, $C8   ; WRI 0, $C8            FREQUENCY LO (622HZ)
        BYTE $24, $81   ; WRI 4, %10000001      WF NOISE, GATE ON        
        BYTE $02        ; WIN 2                 INIT WAIT, 2 TICKS                        
        BYTE $10        ; LWW 0                 LOOP WHILE WAITING OFFSET 0
        BYTE $24, $80   ; WRI 4, %10000000      NOISE, GATE OFF        
        BYTE $FF        ; END

  
LEAD1   BYTE $25, $02   ; WVR 5, $FF            AD
        BYTE $26, $84   ; SR
        BYTE $23, $4
        BYTE $22, $00                

        ;BYTE $31, $F2   ; FLT $1, $F4            FILTER LP, RES $F, FOSC MUL 1
        
        BYTE $24, $41   ; WVR 4, %10000001      triangle + GATE ON
        BYTE $22, $80
        BYTE $E0
        BYTE $22, $00
        BYTE $15
        BYTE $24, $40   ; WVR 4, 0              triangle + GATE OFF
        BYTE $E0
        BYTE $E0         
        BYTE $E0                 
        ;BYTE $30        ; FLT 0                 FILTER OFF
        BYTE $FF        ; END

LEAD2   BYTE $25, $02   ; WVR 5, $FF            AD
        BYTE $26, $F4   ; SR
        BYTE $24, $11   ; WVR 4, %10000001      triangle + GATE ON
        BYTE $10
        BYTE $24, $10   ; WVR 4, %10000001      triangle + GATE ON
        BYTE $FF

TEST1   BYTE $25, $02   ; WVR 5, $FF            AD
        BYTE $26, $F2   ; SR
        BYTE $23, $04   ; PULSE WIDTH
        BYTE $22, $00                
        BYTE $31, $F0   ; FLT $1, $F4           FILTER LP, RES $F, FOSC MUL 1
        BYTE $24, $41   ; WVR 4, %10000001      PULSE + GATE ON
        BYTE $10
        BYTE $24, $40   ; WVR 4, %10000001      PULSE + GATE OFF
        BYTE $E0
        BYTE $E0         
        BYTE $E0                 
        BYTE $30        ; FLT 0                 FILTER OFF       
        BYTE $FF

TEST2   BYTE $25, $02   ; WVR 5, $FF            AD
        BYTE $26, $84   ; SR
        BYTE $23, $04   ; PULSE WIDTH
        BYTE $22, $00                
        BYTE $31, $F2   ; FLT $1, $F4           FILTER LP, RES $F, FOSC MUL 1
        BYTE $24, $41   ; WVR 4, %10000001      PULSE + GATE ON
        BYTE $10
        BYTE $24, $40   ; WVR 4, %10000001      PULSE + GATE OFF
        BYTE $E0
        BYTE $E0         
        BYTE $E0                 
        BYTE $30        ; FLT 0                 FILTER OFF       
        BYTE $FF
