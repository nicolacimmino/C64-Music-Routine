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
        ; VOICE TABLE ENDS AT $2F.

MAXRST  =$31
; *                                                                           *
; *****************************************************************************

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
      
        LDA  #0
        STA  MAXRST

        CLI             ; LET INTERRUPTS COME.

        ; THIS IS OUR MAIN LOOP. NOTHING  USEFUL THE PLAYER RUNS ONLY ONCE PER
        ; FRAME WHEN THE INTERRUPT HAPPENS.
        
        JMP  *

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * THIS IS THE RASTER INTERRUPT  SERVICE ROUTINE. IN A FULL APP THIS WOULD DO* 
; * SEVERAL THINGS, WE HERE ONLY CALL THE MUSIC PLAYER.                       *

ISR     LDA  #1         ; SET BODER TO WHITE, SO WE SEE HOW MANY SCAN LINES THE
        STA  $D020      ; PLAYER TAKES.

        JSR  MUPLAY

        LDA  #0         ; BORDER BACK TO BLACK.
        STA  $D020

        LDA  $D012
        CMP  MAXRST
        BMI  *+4
        STA  MAXRST

        LSR  $D019      ; ACKNOWELEDGE VIDEO INTERRUPTS.

        RTI

; *                                                                           *
; *****************************************************************************

incasm "muplayer.asm"
incasm "imicrocode.asm"
incasm "instruments.asm"
incasm "track.asm"
incasm "trackcmds.asm"
