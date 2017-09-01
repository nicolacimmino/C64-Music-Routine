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
incasm "instruments.asm"

MUINIT  LDA #<PHRASE
        STA PHRASP+8        ; Phrase pointer, will come from loop
        LDA #>PHRASE
        STA PHRASP+9

        LDA #<PHRASE
        STA PHRASP+16        ; Phrase pointer, will come from loop
        LDA #>PHRASE
        STA PHRASP+17

        LDA #<PHRASE
        STA PHRASP+24       ; Phrase pointer, will come from loop
        LDA #>PHRASE
        STA PHRASP+25

        LDX  #24        ; CLEAR ALL SID REGISTERS
        LDA  #0
        STA  $D400,X
        DEX
        BNE  *-4

        LDA  #0
        STA  TICK
        STA  TICK+1

        LDX #0          ; Initialise to INSTRNO 
        LDA  INSTTBL,X ; Instrument LSB
        STA  INSTRP+8
        STA  INSTRP+16
        STA  INSTRP+24
        INX
        LDA  INSTTBL,X ; Instrument MSB
        STA  INSTRP+9
        STA  INSTRP+17
        STA  INSTRP+25

        LDA #%00001111  ; Volume max
        STA $D418
        
        RTS
 
; *****************************************************************************
; * THIS IS THE ACTUAL PLAYER ROUTINE ENTRY POINT. NEEDS TO BE CALLED ONCE PER* 
; * SCREEN.                                                                   *

MUPLAY  INC TICK        ; NEXT TICK (16 BIT INCREMENT)
        BNE *+4
        INC TICK+1

        LDA #3
        STA VOICE

NEXTV   ASL             ; A contains voice number
        ASL
        ASL
        STA VTABLEOFF
        TAX

        ; copy voice vtable to current vtable
        LDY #7
@COPY   LDA VOICETABLE+7,X
        STA VOICETABLE,Y
        DEX
        DEY
        BPL @COPY
                        ; PHRASP IS POINTING TO THE CURRENT PHRASE ENTRY AND
        LDA TICK        ; THE FIRST TWO BYTES ARE THE TICK OF THE NEXT EVENT
        CMP (PHRASP,X)  ; KEEP PLAYING THE CURRENT INSTRUMENT IF WE HAVE NOT
        BNE PLAY       ; REACHED THE TICK YET
        LDA TICK+1
        CMP (PHRASP+1,X)
        BNE PLAY

        LDY #2          ; Freq LO from track
        LDA (PHRASP),Y
        STA $D400
        LDY #3          ; Freq HI from track
        LDA (PHRASP),Y
        STA $D401
        
        ; load instrument address to instrp
        LDY #4          ; Instrument
        LDA (PHRASP),Y
        ASL             ; Instrument*2
        TAX
        LDA  INSTTBL,X ; Instrument LSB
        STA  INSTRP
        LDA  INSTTBL+1,X ; Instrument MSB
        STA  INSTRP+1
        
        LDY #5
        LDA (PHRASP),Y    ; Duration
        STA MUWAIT
        
        LDX VOICE
        ASL
        CLC
        LDA #6          ; On to next entry in the phrase
        ADC PHRASP,X
        STA PHRASP,X
        BNE PLAY
        INC PHRASP+1,X

PLAY   LDY  #0         ; LOAD CURRRENT INSTRUMENT COMMAND
        LDA  (INSTRP),Y

        ROR             ; GET HIGH NIBBLE*2 IN X
        ROR             ;
        ROR             ;
        AND  #%00011110 ;
        TAX             ;

        LDA CMDTBL,X    ; TRANSFER MSB OF CMD ADDRESS
        STA @JSRINS+1

        LDA CMDTBL+1,X
        STA @JSRINS+2

        LDA  (INSTRP),Y ; PASS LOW NIBBLE OF COMMAND TO THE CALLED ROUTINE
        AND  #%00001111

@JSRINS JSR  *
        
        CLC             ; ROUTINE RETURNS IN A THE AMOUNT OF CMD MEMORY BYTES
        ADC INSTRP   ; CONSUMED. MOVE INSTRP
        STA INSTRP    ; TODO needs to be a 16bit addition
        BCC @DONEADD
        LDA #0
        ADC INSTRP
        STA INSTRP
@DONEADD

        ; copy current voice vtable to voice table (mirrored)
        LDX VTABLEOFF
        LDY #7
@COPY   LDA VOICETABLE,Y
        STA VOICETABLE+7,X
        DEX
        DEY
        BPL @COPY

        DEC VOICE
        BEQ @DONE
        LDA VOICE
        JMP NEXTV

@DONE   RTS
; *                                                                           *
; *****************************************************************************
