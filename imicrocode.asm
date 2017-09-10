; *****************************************************************************
; *                                                                           *
; * COPYRIGHT (C) 2017 NICOLA CIMMINO                                         *
; *                                                                           *
; * THIS IS THE INSTRUMENTS MICROCODE IMPLEMENTATION. HERE WE DEFINE A SET OF *
; * COMMANDS THAT ARE USED TO DEFINE THE INSTRUMENTS.                         *
; *                                                                           *
; *  THIS PROGRAM IS FREE SOFTWARE: YOU CAN REDISTRIBUTE IT AND/OR MODIFY     *
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

; *****************************************************************************
; *                                                                           *

CMDTBL  WORD CMD_WIN           ; 0X00   WAIT INIT
        WORD CMD_WAI           ; 0X10   WAIT
        WORD CMD_WRI           ; 0X30   WRITE REGISTER
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD CMD_END           ; 0XF0

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * WAIT INIT                                                                 *
; * INITIALISES THE WAIT COUNTER. TAKES THE NUMBER OF TICKS in P0.            *

CMD_WIN AND  #%00001111         ; INIT THE WAIT COUNTER WITH P0*2.
        ASL
        STA  MUWAIT             ; 
        LDA  #$01               ; RETURN TOAL CONSUMED 1 BYTE, Y BIT CLEAR.
        RTS

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * WAIT                                                                      *
; * DCREASES THE TICK COUNTER AND RETURNS 0 CONSUMED BYTES UNTIL THE WAIT     *
; * COUNTER REACHES ZERO. THIS CAUSES THE PLAYER TO RE-EXECUTE WAIT AT EVERY  *
; * TICK UNTIL WAIT EXPIRED.                                                  *

CMD_WAI LDA  #$80               ; ASSUME WE WILL RETURN ZERO, Y BIT SET.          
        DEC  MUWAIT             ; ONE LESS TICK TO WAIT.
        BNE  @DONE              ; NOT ZERO YET?
        LDA  #$81               ; WE REACHED ZERO, RETURN 1, Y BIT SET.
@DONE   RTS

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * WRITE REGISTER.                                                           *
; *                                                                           *
; * THE PLAYER PASSES US THE REGISTER NUMBER IN A (0-15), VOICE REIGSTER HAS  *
; * THE CURRENT VOICE (1-3). THESE ARE VIRTUALISED REGISTER NUMBERS AND HERE  *
; * WE CONVERT THOSE TO THE ACTUALY PHYSICAL SID REGISTER NUMBER.             *

CMD_WRI CMP  #$07       ; TEST REG NUMBER, IF <7 THIS IS A VOICE REGISTER, GO TO
        BMI  @VOICER    ; RELEVANT VOICE REGISTER SET.
        
        CLC             ; THIS IS A GLOBAL REGISTER, OFFSET BY 13 AS THE FIRST
        ADC  #13        ; VIRTUALISED GLOBAL IS 8 AND REAL IS 21.
        BNE  DOWR       ; BRANCH ALWAYS AS ADC #13 NEVER SETS Z.

@VOICER LDY  VOICE      
        CLC
@LOOP   DEY
        BEQ  DOWR
        ADC  #7
        BNE  @LOOP      ; BRANCH ALWAYS, ADC #7 NEVER SETS Z 

DOWR    TAX
        LDY  #1
        LDA  (INSTRP),Y
        STA  $D400,X

        LDA  #$02       ; WE CONSUMED 2 BYTES, Y BIT CLEAR.
        RTS

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * NO FURTHER ACTIONS FOR THIS INSTRUMENT. WE STAY ON THE SAME INSTRUCTION.  *

CMD_END LDA  #$80       ; WE CONSUMED 0 BYTES, Y BIT SET.
        RTS

; *                                                                           *
; *****************************************************************************
