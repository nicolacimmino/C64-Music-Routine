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

incasm "imicrocode.asm"
incasm "trackcmds.asm"

MUINIT  LDX  #24        ; CLEAR ALL SID REGISTERS AND VOICE TABLE
        LDA  #0
@LOOP   STA  $D400,X
        STA  VTBL+8,X 
        DEX
        BPL  @LOOP
        
        LDA  #<PHRASE1
        STA  PHRASP+8   ; PHRASE POINTER, WILL COME FROM LOOP
        LDA  #>PHRASE1
        STA  PHRASP+9

        LDA  #<PHRASE2
        STA  PHRASP+16  ; PHRASE POINTER, WILL COME FROM LOOP
        LDA  #>PHRASE2
        STA  PHRASP+17

        LDA  #<PHRASE3
        STA  PHRASP+24  ; PHRASE POINTER, WILL COME FROM LOOP
        LDA  #>PHRASE3
        STA  PHRASP+25

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
; * FRAME.                                                                    *

MUPLAY  LDA  #3         ; START TO PLAY FROM VOICE 3
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
        LDA  TICK       ; FIRST BYTES IS THE TICK OF THE NEXT EVENT KEEP 
        CMP  (PHRASP),Y ; PLAYING THE CURRENT INSTRUMENT IF WE HAVE NOT REACHED
        BNE  PLAY       ; THE WANTED TICK YET.

        LDA  #0         ; CALCULATE OFFSET INTO THE VIC REGISTERS FOR THE VOIICE
        LDX  VOICE      ; CURRENTLY PLAYING ((VOICE-1)*7). WE NEED THIS TO STORE
        CLC             ; FREQUENCY IN THE CORRECT REGISTER BELOW.
@LOOP   DEX             ;
        BEQ  @DOWR      ;
        ADC  #7         ;
        BNE  @LOOP      ; BRANCH ALWAYS, ADC #7 NEVER SETS Z

@DOWR   TAX             ; PRESERVE THE VOICE REGISTER OFFSET IN X
@PLAYV  LDY  #1         ; BYTE 1 CONTAINS THE MIDI NOTE NUMBER
        LDA  (PHRASP),Y ; 
        CMP  #%01111111 ; IF BIT7 IS SET THIS IS A TRACK COMMAND.
        BMI  @PLAYN
        JSR  TRKCMD     ; EXECUTE TRACK COMMAD, UPON RETURN PHRASEP WILL HAVE
        JMP  VEND       ; UPDATED, END THIS VOICE

@PLAYN  CLC             ; PLAY THE NOTE.
        SBC  #21        ; LOOKUP TABLE STARTS FROM MIDI NOTE #21
        ASL             ; OFFSET IN THE MIDI NOTES TABLE * 2
        TAY
        LDA  MIDITBL,Y  ; GET FREQUENCY LO
        STA  $D400,X    ;
        LDA  MIDITBL+1,Y; GET FREQUENCY LO
        STA  $D401,X    ;
        
        LDY  #2         ; BYTE 2 CONTAINS THE INSTRUMENT NUMBER, LOOKUP IN THE
        LDA  (PHRASP),Y ; INSTRTBL THE ADDRESS OF THE FIRST IMICROCODE FOR IT
        ASL             ; AND SET IT IN INSTRP POINTER.
        TAX             ;
        LDA  INSTTBL,X  ;
        STA  INSTRP     ;
        LDA  INSTTBL+1,X;
        STA  INSTRP+1   ;

        LDY  #3         ; BYTE 3 CONTAINS THE DURATION OF THE NOTE.
        LDA  (PHRASP),Y ; 
        STA  MUWAIT     ;

        CLC             ; MOVE THE PHRASP TO THE NEXT ENTRY.
        LDA  #4         ; 
        ADC  PHRASP     ; 
        STA  PHRASP     ; 
        BCC  *+4        ;
        INC  PHRASP+1   ;

PLAY    JSR  IMCPLAY
       
VEND    INC  TICK       ; NEXT TICK

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
