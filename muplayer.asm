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
; * SCREEN.                                                                   *

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
        
        TAX             ; KEEP A COPY OF THE RETURN VALUE.
        AND  #%00001111 ; ROUTINE RETURNS IN A LOWER NIBBLE THE AMOUNT OF CMD
        CLC             ; MEMORY BYTES CONSUMED. MOVE INSTRP ACCORDINGLY.
        ADC  INSTRP     ; 
        STA  INSTRP     ; 
        BCC  *+4        ;
        INC  INSTRP+1   ;
        
        TXA             ; RETRIEVE THE RETURN VALUE AND GET BIT 7 (YEALD FLAG)
        AND  #%10000000 ; WE SHOULD END HERE THE SEQUENCE EXECUTION IF SET.
        BEQ  PLAY
       
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

; *****************************************************************************
; * LOOKUP TABLE FOR MIDI NOTES NUMBERS TO FREQUENCY HI/LO SETTINGS.          *

MIDITBL BYTE $D4,$01    ; MIDI #21 - A0
        BYTE $F0,$01
        BYTE $0E,$02
        BYTE $2D,$02
        BYTE $4E,$02
        BYTE $71,$02
        BYTE $96,$02
        BYTE $BE,$02
        BYTE $E7,$02
        BYTE $14,$03
        BYTE $42,$03
        BYTE $74,$03
        BYTE $A9,$03
        BYTE $E0,$03
        BYTE $1B,$04
        BYTE $5A,$04
        BYTE $9C,$04
        BYTE $E2,$04
        BYTE $2D,$05
        BYTE $7B,$05
        BYTE $CF,$05
        BYTE $27,$06
        BYTE $85,$06
        BYTE $E8,$06
        BYTE $51,$07
        BYTE $C1,$07
        BYTE $37,$08
        BYTE $B4,$08
        BYTE $38,$09
        BYTE $C4,$09
        BYTE $59,$0A
        BYTE $F7,$0A
        BYTE $9D,$0B
        BYTE $4E,$0C
        BYTE $0A,$0D
        BYTE $D0,$0D
        BYTE $A2,$0E
        BYTE $81,$0F
        BYTE $6D,$10
        BYTE $67,$11
        BYTE $70,$12
        BYTE $89,$13
        BYTE $B2,$14
        BYTE $ED,$15
        BYTE $3B,$17
        BYTE $9C,$18
        BYTE $13,$1A
        BYTE $A0,$1B
        BYTE $45,$1D
        BYTE $02,$1F
        BYTE $DA,$20
        BYTE $CE,$22
        BYTE $E0,$24
        BYTE $11,$27
        BYTE $64,$29
        BYTE $DA,$2B
        BYTE $76,$2E
        BYTE $39,$31
        BYTE $26,$34
        BYTE $40,$37
        BYTE $89,$3A
        BYTE $04,$3E
        BYTE $B4,$41
        BYTE $9C,$45
        BYTE $C0,$49
        BYTE $23,$4E
        BYTE $C8,$52
        BYTE $B4,$57
        BYTE $EB,$5C
        BYTE $72,$62
        BYTE $4C,$68
        BYTE $80,$6E
        BYTE $12,$75
        BYTE $08,$7C
        BYTE $68,$83
        BYTE $39,$8B
        BYTE $80,$93
        BYTE $45,$9C
        BYTE $90,$A5
        BYTE $68,$AF
        BYTE $D6,$B9
        BYTE $E3,$C4
        BYTE $99,$D0
        BYTE $00,$DD
        BYTE $24,$EA    ; MIDI #105 - A7

; *                                                                           *
; *****************************************************************************
