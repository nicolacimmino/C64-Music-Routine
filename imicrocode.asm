; *****************************************************************************
; *                                                                           *
; * COPYRIGHT (C) 2017 NICOLA CIMMINO                                         *
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

*=$F000

; *****************************************************************************
; *                                                                           *

CMDTBL  WORD @WIN
        WORD WAI
        WORD WVR
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
        WORD END

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * WAIT INIT                                                                 *
; * INITIALISES THE WAIT COUNTER. TAKES A ONE BYTE OPERAND WITH THE NUMBER OF *
; * OF TICKS TO WAIT.                                                         *

@WIN    LDY  #1                 ; INIT THE WAIT COUNTER WITH THE OPERAND.
        LDA  (INSTRP),Y         ;
        STA  MUWAIT             ; 
        LDA  #2                 ; RETURN TOAL CONSUMED 2 BYTES.
        RTS

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * WAIT                                                                      *
; * DESCREASES THE TICK COUNTER AND RETURNS 0 CONSUMED BYTES UNTIL THE WAIT   *
; * COUNTER REACHES ZERO. THIS CAUSES THE PLAYER TO RE-EXECUTE WAIT AT EVERY  *
; * TICK UNTIL WAIT EXPIRED.                                                  *

WAI     LDA  #0                 ; ASSUME WE WILL RETURN ZERO.          
        DEC  MUWAIT             ; ONE LESS TICK TO WAIT.
        BNE  @DONE              ; NOT ZERO YET?
        LDA  #1                 ; WE REACHED ZERO, RETURN 1.
@DONE   RTS

; *                                                                           *
; *****************************************************************************

WVR     TAX
        LDY  #1
        LDA  (INSTRP),Y
        STA  $D400,X

        LDA  #2         ; WE CONSUMED 2 BYTES
        RTS


END     LDA  #0         ; WE STAY ON THE SAME INSTRUCTION FOREVER
        RTS
