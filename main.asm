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

; *****************************************************************************
; * BELOW ARE TBE BASIC TOKENS FOR 10 SYS49152                                *
; * WE STORE THEM AT THE BEGINNING OF THE BASIC RAM SO WHEN WE CAN LOAD       *
; * THE PROGRAM WITH AUTORUN (LOAD "*",8,1) AND SAVE TO TYPE THE SYS.         *

*=$801

        BYTE $0E, $08, $0A, $00, $9E, $34, $39, $31, $35, $32, $00, $00, $00
; *                                                                           *
; *****************************************************************************

MUWAIT=$02 ; 1 byte amount of ticks for the current wait
TICK=$03   ; 2 bytes current TICK

PHRASP=$10   ; 2 bytes pointer into the current PHRASE (abosulte address)
INSTRP=$12 ; 2 bytes pointer into the instrumet table commands


incasm "imicrocode.asm"
incasm "instruments.asm"

; *****************************************************************************
; * THIS IS THE ENTRY POINT INTO OUR PROGRAM. WE DO SOME SETUP AND THEN LET   *
; * THINGS ROLL FROM HERE.                                                    *

*=$C000

START   SEI             ; PREVENT INTERRUPTS WHILE WE SET THINGS UP.
        JSR  $FF81      ; RESET VIC, CLEAR SCREEN, THIS IS A KERNAL FUNCTION.

        LDA  #%00110101 ; DISABLE KERNAL AND BASIC ROMS WE GO BARE METAL.
        STA  $01        ; 

        LDA  #%01111111 ; DISABLE CIA-1/2 INTERRUPTS.
        STA  $DC0D      ;
        STA  $DD0D      ;
      
        LDA  #1         ; SET RASTER INTERRUPT FOR LINE 1. POSITION IS ACTUALLY
        STA  $D012      ; IRRELEVANT WE NEED A TIME BASE ONE CALL PER FRAME.
        LDA  #%01111111 ; CLEAR RST8 BIT, THE INTERRUPT LINE IS
        AND  $D011      ; ABOVE RASTER LINE 255.
        STA  $D011
       
        LDA  #<ISR      ; SET THE INTERRUPT VECTOR TO THE ISR ROUTINE.
        STA  $FFFE      ;
        LDA  #>ISR
        STA  $FFFF

        LSR  $D019      ; ACKNOWELEDGE VIDEO INTERRUPTS.
        LDA  #%00000001 ; ENABLE RASTER INTERRUPT.
        STA  $D01A      ;
        
        JSR MUINIT

        LDA  $DC0D      ; ACKNOWLEDGE CIA INTERRUPTS.
        
        CLI             ; LET INTERRUPTS COME.

        ; THIS IS OUR MAIN LOOP. NOTHING  USEFUL THE PLAYER RUNS ONLY ONCE PER
        ; FRAME WHEN THE INTERRUPT HAPPENS.
        
        JMP  *

; *                                                                           *
; *****************************************************************************

MUINIT  LDA #<PHRASE
        STA PHRASP        ; Phrase pointer, will come from loop
        LDA #>PHRASE
        STA PHRASP+1

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
        STA  INSTRP
        INX
        LDA  INSTTBL,X ; Instrument MSB
        STA  INSTRP+1

        LDA #%00001111  ; Volume max
        STA $D418
        
        RTS
 
; *****************************************************************************
; * THIS IS THE RASTER INTERRUPT  SERVICE ROUTINE. IN A FULL APP THIS WOULD DO* 
; * SEVERAL THINGS, WE HERE ONLY PROCESS THE MUSIC STUFF.                     *

ISR     INC TICK        ; NEXT TICK (16 BIT INCREMENT)
        BNE *+4
        INC TICK+1

        LDY #0          ; PHRASP IS POINTING TO THE CURRENT PHRASE ENTRY AND
        LDA TICK        ; THE FIRST TWO BYTES ARE THE TICK OF THE NEXT EVENT
        CMP (PHRASP),Y    ; KEEP PLAYING THE CURRENT INSTRUMENT IF WE HAVE NOT
        BNE @PLAY       ; REACHED THE TICK YET
        INY 
        LDA TICK+1
        CMP (PHRASP),Y
        BNE @PLAY

        LDY #2          ; Freq LO from track
        LDA (PHRASP),Y
        STA $D400
        LDY #3          ; Freq HI from track
        LDA (PHRASP),Y
        STA $D401
        
        LDY #4          ; Instrument
        LDA (PHRASP),Y
        ASL             ; Instrument*2
        TAX
        LDA  INSTTBL,X ; Instrument LSB
        STA  INSTRP
        INX
        LDA  INSTTBL,X ; Instrument MSB
        STA  INSTRP+1

        LDY #5
        LDA (PHRASP),Y    ; Duration
        STA MUWAIT
        
        CLC
        LDA #6          ; On to next entry in the phrase
        ADC PHRASP
        STA PHRASP
        BNE @PLAY
        INC PHRASP+1

@PLAY   LDY  #0         ; LOAD CURRRENT INSTRUMENT COMMAND
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
        ADC INSTRP      ; CONSUMED. MOVE INSTRP
        STA INSTRP      ; TODO needs to be a 16bit addition

MUDONE  LSR  $D019      ; ACKNOWELEDGE VIDEO INTERRUPTS.

        RTI

; *                                                                           *
; *****************************************************************************

