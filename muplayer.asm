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

MUINIT  LDA  #<PHRASE
        STA  PHRASP+8   ; PHRASE POINTER, WILL COME FROM LOOP
        LDA  #>PHRASE
        STA  PHRASP+9

        LDA  #<PHRASE2
        STA  PHRASP+16  ; PHRASE POINTER, WILL COME FROM LOOP
        LDA  #>PHRASE2
        STA  PHRASP+17

        LDA  #<PHRASE3
        STA  PHRASP+24  ; PHRASE POINTER, WILL COME FROM LOOP
        LDA  #>PHRASE3
        STA  PHRASP+25

        LDX  #24        ; CLEAR ALL SID REGISTERS
        LDA  #0
        STA  $D400,X
        DEX
        BNE  *-4

        LDA  #0
        STA  TICK
        STA  TICK+1

                        ;;LDX #0          ; INITIALISE TO INSTRNO
        LDA  INSTTBL    ; INSTRUMENT LSB
        STA  INSTRP+8
        STA  INSTRP+16
        STA  INSTRP+24

        LDA  INSTTBL+1  ; INSTRUMENT MSB
        STA  INSTRP+9
        STA  INSTRP+17
        STA  INSTRP+25

        LDA  #%00001111 ; VOLUME MAX
        STA  $D418

        RTS

; *****************************************************************************
; * THIS IS THE ACTUAL PLAYER ROUTINE ENTRY POINT. NEEDS TO BE CALLED ONCE PER*
; * SCREEN.                                                                   *

MUPLAY  INC  TICK       ; NEXT TICK (16 BIT INCREMENT)
        BNE  *+4
        INC  TICK+1

        LDA  #3
        STA  VOICE

NEXTV   LDA  VOICE      ; CALCULATE OFFSET OF THE CURRENT VOICE INTO THE VTABLE
        ASL             ; (VOICE*8) AND STORE IT FOR LATER USE. 
        ASL             ; 
        ASL             ;
        STA  VTOFF      ; 
        TAX             ;

                        
        LDY  #7         ; COPY VOICE VTABLE FOR THE CURRENT VOICE TO THE CURRENT
@COPY   LDA  VTBL+7,X   ; VTABLE
        STA  VTBL,Y     ;
        DEX             ;
        DEY             ;
        BPL  @COPY      ;

        LDY  #0         ; PHRASP IS POINTING TO THE CURRENT PHRASE ENTRY AND THE
        LDA  TICK       ; FIRST TWO BYTES ARE THE TICK OF THE NEXT EVENT KEEP 
        CMP  (PHRASP),Y ; PLAYING THE CURRENT INSTRUMENT IF WE HAVE NOT REACHED
        BNE  PLAY       ; THE WANTED TICK YET.
        INY             ;
        LDA  TICK+1     ;
        CMP  (PHRASP),Y ;
        BNE  PLAY       ;

        LDA  #0         ; CALCULATE OFFSET INTO THE VIC REGISTERS FOR THE VOIICE
        LDX  VOICE      ; CURRENTLY PLAYING ((VOICE-1)*7). WE NEED THIS TO STORE
        CLC             ; FREQUENCY IN THE CORRECT REGISTER BELOW.
@LOOP   DEX             ;
        BEQ  @DOWR      ;
        ADC  #7         ;
        BNE  @LOOP      ; BRANCH ALWAYS, ADC #7 NEVER SETS Z

@DOWR   TAX             ; BYTES 2 AND 3 OF THE PHRASE ENTRY CONTAIN THE NOTE
        LDY  #2         ; FREQUENCY. SET IT IN THE RELEVANT SID REGISTER.
        LDA  (PHRASP),Y ;
        STA  $D400,X    ;
        INY             ; 
        LDA  (PHRASP),Y ;
        STA  $D401,X    ;

        LDY  #4         ; BYTE 4 CONTAINS THE INSTRUMENT NUMBER, LOOKUP IN THE
        LDA  (PHRASP),Y ; INSTRTBL THE ADDRESS OF THE FIRST IMICROCODE FOR IT
        ASL             ; AND SET IT IN INSTRP POINTER.
        TAX             ;
        LDA  INSTTBL,X  ;
        STA  INSTRP     ;
        LDA  INSTTBL+1,X;
        STA  INSTRP+1   ;

        LDY  #5         ; BYTE 5 CONTAINS THE DURATION OF THE NOTE.
        LDA  (PHRASP),Y ; 
        STA  MUWAIT     ;

        CLC             ; MOVE THE PHRASP TO THE NEXT ENTRY.
        LDA  #8         ; 
        ADC  PHRASP     ; 
        STA  PHRASP     ; 
        BCC  *+4        ;
        INC  PHRASP+1   ;

PLAY    LDY  #0         ; LOAD CURRRENT INSTRUMENT COMMAND, WHICH IS POINTED BY
        LDA  (INSTRP),Y ; INSTRP.

        ROR             ; THE HIGH NIBBLE IS THE ACTAL COMMAND, SO THE OFFSET
        ROR             ; INTO THE COMMAND TABLE IS THAT*2.
        ROR             ;
        AND  #%00011110 ;
        TAX             ;

        LDA  CMDTBL,X   ; A BIT OF SELF MODIFYING CODE. MODIFY THE JSR BELOW TO
        STA  @JSRINS+1  ; POINT TO THE RELEVANT IMICROCODE INSTRUCTION ROUTINE.
        LDA  CMDTBL+1,X ;
        STA  @JSRINS+2  ;

        LDA  (INSTRP),Y ; PASS LOW NIBBLE OF COMMAND TO THE CALLED ROUTINE, THIS
        AND  #%00001111 ; IS THE ARGUMENT.

@JSRINS JSR  *          ; EXECUTE THE ACTUAL IMICROCODE INSTRUCTION.

        CLC             ; ROUTINE RETURNS IN A THE AMOUNT OF CMD MEMORY BYTES
        ADC  INSTRP     ; CONSUMED. MOVE INSTRP ACCORDINGLY.
        STA  INSTRP     ; 
        BCC  *+4        ;
        INC  INSTRP+1   ;
        
        LDX  VTOFF      ; COPY THE CURRENT VTABLE BACK TO THE RELEVANT VOICE 
        LDY  #7         ; VTABLE.
@COPY   LDA  VTBL,Y     ;
        STA  VTBL+7,X   ;
        DEX             ;
        DEY             ;
        BPL  @COPY      ;

        DEC  VOICE      ; NEXT VOICE OR LEAVE IF WE HAVE GONE THROUGH THEM ALL.
        BEQ  *+5        ;
        JMP  NEXTV      ;

        RTS
; *                                                                           *
; *****************************************************************************
