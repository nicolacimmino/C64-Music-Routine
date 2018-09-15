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
; * BELOW ARE TBE BASIC TOKENS FOR 10 SYS49152                                *
; * WE STORE THEM AT THE BEGINNING OF BASIC RAM SO WHEN WE LOAD THE PROGRAM   *
; * WITH AUTORUN (LOAD "*",8,1) IT WILL START AUTOMATICALLY.                  *

*=$801

        BYTE $0E, $08, $0A, $00, $9E, $34, $39, $31, $35, $32, $00, $00, $00
; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; *                                                                           *

MAXRST=$31

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * THIS IS THE ENTRY POINT INTO OUR PROGRAM. WE DO SOME SETUP AND THEN LET   *
; * THINGS ROLL FROM HERE.                                                    *

*=$C000

START   SEI             ; PREVENT INTERRUPTS WHILE WE SET THINGS UP.
        JSR  $FF81      ; RESET VIC, CLEAR SCREEN, THIS IS A KERNAL FUNCTION.

        LDA  #%01111111 ; DISABLE CIA-1/2 INTERRUPTS.
        STA  $DC0D      ;
        STA  $DD0D      ;
      
        LDA  #1         ; SET RASTER INTERRUPT FOR LINE 1. POSITION IS ACTUALLY
        STA  $D012      ; IRRELEVANT WE NEED A TIME BASE ONE CALL PER FRAME.
        LDA  #%01111111 ; CLEAR RST8 BIT, THE INTERRUPT LINE IS
        AND  $D011      ; ABOVE RASTER LINE 255.
        STA  $D011
       
        LDA  #<ISR      ; SET THE INTERRUPT VECTOR TO THE ISR ROUTINE.
        STA  $0314      ;
        LDA  #>ISR
        STA  $0315

        LSR  $D019      ; ACKNOWELEDGE VIDEO INTERRUPTS.
        LDA  #%00000001 ; ENABLE RASTER INTERRUPT.
        STA  $D01A      ;
        
        JSR  MUINIT

        LDA  $DC0D      ; ACKNOWLEDGE CIA INTERRUPTS.
      
        LDA  #0
        STA  MAXRST        

        CLI             ; LET INTERRUPTS COME.

        ; PRINT THE "LINES:" LABEL AND THEN KEEP LOOPING PRINTING
        ; ON SCREEN THE MAXIMUM NUMER RASTER LINES THE PLAYER TOOK.
        
        LDY #$FF
        LDA #$93
@LOOP   JSR $FFD2
        INY
        LDA T_LINES,Y
        BNE @LOOP

@LOOP1  LDA  MAXRST     ; PRINT MAXRST IN HEX ON THE SCREEN.
        CLC
        ROR
        ROR
        ROR
        ROR
        JSR  DEC2HEX        
        STA  $406
        LDA  MAXRST
        JSR  DEC2HEX
        STA  $407        
        JMP  @LOOP1

DEC2HEX AND  #$0F       ; SIMPLE HELPER TO PRINT A NIBBLE AS HEX.
        CMP  #$09
        BPL  PRINTL
        CLC
        ADC  #$30
        RTS
PRINTL  SEC
        SBC  #9
        RTS

T_LINES TEXT "lines:"
        BYTE 0
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

        JMP $EA31       ; BACK TO KERNAL ISR

; *                                                                           *
; *****************************************************************************

align 256

        ; TICK, NOTE, INSTR, DUR

TRACK   BYTE <PHRASE0, >PHRASE0
        BYTE <PHRASEN, >PHRASEN
        BYTE <PHRASEN, >PHRASEN
        BYTE $00, $00

align 4

PHRASE0 BYTE $00, 00, $01, $00
        BYTE $2F, 00, $02, $00
        BYTE $5F, $A0, <PHRASE0, >PHRASE0       

PHRASEN BYTE $FF, $A0, <PHRASEN, >PHRASEN       

      
INSTTBL WORD INSTRNO    ; 0
        WORD TEST1      ; 1
        WORD TEST2      ; 2
        
        ; Null instrument, used for voices where an instrument has not be set 
        ; yet.
INSTRNO BYTE $FF        ; END

        ; INSTRUMENT:   TEST1
        ; TESTS:        IMC WIN/LWW
        ; EXPECTED:     TRIANGLE    3 TICKS
        ;               NOISE       1 TICK
        ;               SAWTOOTH    1 TICK
        ;               NOISE       1 TICK
        ;               SAWTOOTH    1 TICK
        ;               NOISE       1 TICK      
        ;               END

TEST1   BYTE $41, $80, $0E, $00, $00, $10, $00, $F7
                        ; VIN                   FREQ=220Hz, 
                        ;                       TRIANGLE, GATE ON 
                        ;                       A=2mS D=6mS S=15  R=240ms 
                   
        BYTE $02        ; WIN 2                 INIT WAIT, 2 LOOPS                        
        BYTE $10        ; LWW 0                 LOOP WHILE WAITING OFFSET 0
        
        BYTE $24, $81   ; WRI 4, %10000001      NOISE, GATE ON        
        BYTE $E0        ; YLD

        BYTE $02        ; WIN 2                 INIT WAIT, 2 LOOPS                        
        BYTE $24, $21   ; WRI 4, %00100001      SAWTOOTH, GATE ON        
        BYTE $E0        ; YLD
        BYTE $24, $81   ; WRI 4, %10000001      NOISE, GATE ON        
        BYTE $15        ; LWW 5                 LOOP WHILE WAITING OFFSET -5

        BYTE $24, $00   ; WRI 4, %00010001      NO WAVEFORM, GATE OFF
        BYTE $FF        ; END

        ; INSTRUMENT:   TEST2
        ; TESTS:        IMC WRI/VIN
        ; EXPECTED:     TRIANGLE    3 TICKS
        ;               NOISE       1 TICK
        ;               SAWTOOTH    1 TICK
        ;               NOISE       1 TICK
        ;               SAWTOOTH    1 TICK
        ;               NOISE       1 TICK      
        ;               END

TEST2   BYTE $41, $8F, $FE, $00, $00, $80, $11, $A1
                        ; VIN                   FREQ=220Hz, 
                        ;                       NOISE, GATE ON,
                        ;                       A=2mS D=24mS S=10  R=24ms
                   
        BYTE $02        ; WIN 2                 INIT WAIT, 2 LOOPS                        
        BYTE $10        ; LWW 0                 LOOP WHILE WAITING OFFSET 0
                
        BYTE $24, $80   ; WRI 4, %10000000      NOISE, GATE OFF
        BYTE $FF        ; END



incasm "muplayer.asm"

