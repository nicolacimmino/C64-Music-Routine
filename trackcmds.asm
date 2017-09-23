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

TRKCMD  TAY             ; PRESERVE THE CALL ARGUMENT FOR LATER.
        CLC             ; THE COMMAND IS IN BITS 6 AND 5 OF A, WE ROTATE RIGHT
        ROR             ; 4 TIMES SO, AND KEEP ONLY THE LOWER 3 BITS TO GET 
        ROR             ; COMMAND*2.
        ROR             ;
        ROR             ;
        AND  #%00000111 ;
        TAX             ;

        LDA  TCTABLE,X  ; A BIT OF SELF MODIFYING CODE. MODIFY THE JMP BELOW TO
        STA  @JMPINS+1  ; POINT TO THE RELEVANT TRACK COMMAND ROUTINE.
        LDA  TCTABLE+1,X;
        STA  @JMPINS+2  ;

        TYA             ; GET P0 (LOWER 5 BITS) FROM THE CALL ARGUMENT.
        AND  #%00011111 ; 

@JMPINS JMP  *          ; EXECUTE THE ACTUAL TRACK COMMAND ROUTINE.

TCTABLE WORD TC_NOP
        WORD TC_REP
        WORD TC_NOP
        WORD TC_NOP

TC_REP  CMP  #0         ; P0 IS IN A, IF IT'S ZERO THIS IS AN INFINITE LOOP
        BEQ  DOREP  

        INC  PHLOOP     ; INCREMENT LOOP COUNTER
        CMP  PHLOOP     ; P0 IS IN A, SEE IF WE REACHED WANTED LOOP COUNT
        BEQ  NEXTPH     ; ON TO THE NEXT PHRASE.

DOREP   LDY  #2         ; MOVE PHRASE POINTER TO THE VALUE POINTED BY 
        LDA  (PHRASP),Y
        TAX
        INY
        LDA  (PHRASP),Y
        STA  PHRASP+1
        TXA
        STA  PHRASP
        LDA  #$FF
        STA  TICK

        RTS

NEXTPH  LDA  #0
        STA  PHLOOP
        LDA  #$FF
        STA  TICK
TC_NOP  CLC
        LDA  #4
        ADC  PHRASP
        STA  PHRASP
        BNE  @DONE
        INC  PHRASP+1

@DONE   RTS
