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

; *****************************************************************************
; * PAGE ZERO MEMORY MAP                                                      *

VOICE   =$04            ; 1 BYTE, CURRENT VOICE (1-3).
VTOFF   =$05            ; 1 BYTE, CURRENT VOICE OFFSET IN VTBL (VOICE*8).

        ; VOICE  TABLE  CONTAINS  4  SETS  OF  REGISTERS THAT KEEP TRACK OF THE 
        ; CURRENT STATUS OF THE PHRASE AND  INSTRUMENT FOR EACH VOICE, EACH SET
        ; IS 8 BYTES LONG. THE FIRST SET  REPRESENTS THE VOICE CURRENTLY PLAYNG
        ; THE FOLLOWING 3 SETS ARE THE COPIES REPRESENTING  THE LAST STATUS FOR
        ; FOR VOICES 1-3.

VTBL    =$10            ; 32 BYTES, VOICE TABLE.
PHRASP  =$10            ; 2 BYTES, POINTER INTO THE PHRASE.
INSTRP  =$12            ; 2 BYTES, POINTER INTO THE INSTRUMENT MICROCODE.
MUWAIT  =$14            ; 1 BYTE, TICKS LEFT FOR IMC WAIT COMMAND.
TICK    =$15            ; 1 BYTE, CURRENT TICK.
PHLOOP  =$16            ; 1 BYTE, PHRASE LOOP COUNTER.
SROFF   =$17            ; 1 BYTE, SID VOICE REGISTERS OFFSET FROM SID BASE ADDR. 
        ; VOICE TABLE ENDS AT $2F.

; *                                                                           *
; *****************************************************************************

align 256

incasm "midi_scale.asm"
incasm "imicrocode.asm"
incasm "trackcmds.asm"

MUINIT  LDX  #24        ; CLEAR ALL SID REGISTERS AND VOICE TABLE
        LDA  #0
@LOOP   STA  $D400,X
        STA  VTBL+8,X 
        DEX
        BPL  @LOOP
        
        STA  SROFF+8
        LDA  #7
        STA  SROFF+16
        LDA  #14
        STA  SROFF+24
        
        LDA  TRACK      ; VOICE 1 INITIAL PHRASE POINTER
        STA  PHRASP+8   
        LDA  TRACK+1
        STA  PHRASP+9

        LDA  TRACK+2
        STA  PHRASP+16  ; VOICE 2 INITIAL PHRASE POINTER
        LDA  TRACK+3
        STA  PHRASP+17

        LDA  TRACK+4
        STA  PHRASP+24  ; VOICE 3 INITIAL PHRASE POINTER
        LDA  TRACK+5
        STA  PHRASP+25

                        ; INITIALISE TO INSTRNO
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

@PLAYV  LDY  #1         ; BYTE 1 CONTAINS THE MIDI NOTE NUMBER
        LDA  (PHRASP),Y ; 
        CMP  #%01111111 ; IF BIT7 IS SET THIS IS A TRACK COMMAND.
        BMI  @PLAYN
        JSR  TRKCMD     ; EXECUTE TRACK COMMAD, UPON RETURN PHRASEP WILL HAVE
        JMP  VEND       ; UPDATED, END THIS VOICE

@PLAYN  LDX  SROFF      ; GET SID VOICE REGISTERS OFFSET FROM VTABLE.
        CLC             ; PLAY THE NOTE.
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
