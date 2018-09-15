; *****************************************************************************
; *                                                                           *
; * COPYRIGHT (C) 2018 NICOLA CIMMINO                                         *
; *                                                                           *
; * THIS IS THE INSTRUMENTS MICROCODE IMPLEMENTATION. HERE WE DEFINE A SET OF *
; * COMMANDS THAT ARE USED TO DEFINE THE INSTRUMENTS.                         *
; *                                                                           *
; *  THIS PROGRAM IS FREE SOFTWARE: YOU CAN REDISTRIBUTE IT AND/OR MODIFY     *
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
; * INVOKED ONCE PER TICK PER VOICE EXECUTES THE NEXT IMC INSTRUCTIONS UNTIL  *
; * THE Y (YIELD) FLAG IS SET.                                                *

IMCPLAY LDY  #0         ; LOAD CURRRENT INSTRUMENT COMMAND, WHICH IS POINTED BY
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
        BEQ  IMCPLAY
                
        RTS

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; *                                                                           *

CMDTBL  WORD CMD_WIN           ; 0X00   WAIT INIT
        WORD CMD_LWW           ; 0X10   LOOP WHILE WAITING
        WORD CMD_WRI           ; 0X20   WRITE REGISTER
        WORD CMD_FIL           ; 0x30   SET FILTER ON/OFF FOR THE INSTRUMENT
        WORD CMD_VIN           ; 0x40   VOICE INIT
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD $0000
        WORD CMD_YLD           ; 0XE0
        WORD CMD_END           ; 0XF0

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * WAIT INIT                                                                 *
; * INITIALISES THE WAIT COUNTER. TAKES THE NUMBER OF LOOPS in P0.            *

CMD_WIN AND  #%00001111         ; INIT THE WAIT COUNTER WITH P0.
        STA  MUWAIT             ; 
        LDA  #$01               ; RETURN TOTAL CONSUMED 1 BYTE, Y BIT CLEAR.
        RTS

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * LOOP WHILE WAITING.                                                       *
; * LOOP P0 INSTRUCTIONS BACK UNLESS WAIT END. YIELDS AFTER EACH LOOP.        *

CMD_LWW DEC  MUWAIT             ; ONE LESS LOOP TO WAIT.
        BNE  @LOOP              ; NOT ZERO YET?
        LDA  #$81               ; WE REACHED ZERO, 1 BYTE CONSUMED, Y BIT SET.
        RTS
@LOOP   CLC             
        EOR  #$FF        
        ADC  #1
        CLC
        ADC  INSTRP
        STA  INSTRP
        BPL  @DONE
        DEC  INSTRP+1
@DONE   LDA  #$80               ; ZERO BYTES CONSUMED FOR NOW, Y BIT SET.                  
        RTS

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * WRITE REGISTER.                                                           *
; *                                                                           *
; * THE PLAYER PASSES US THE REGISTER NUMBER IN A (0-15), VOICE REIGSTER HAS  *
; * THE CURRENT VOICE (1-3). THESE ARE VIRTUALISED REGISTER NUMBERS AND HERE  *
; * WE CONVERT THOSE TO THE ACTUALY PHYSICAL SID REGISTER NUMBER.             *

CMD_WRI CMP  #$07       ; TEST REG NUMBER, IF <7 THIS IS A VOICE REGISTER, GO TO
        BMI  @VOICER    ; RELEVANT VOICE REGISTER SET.
        
        CLC             ; THIS IS A GLOBAL REGISTER, OFFSET BY 13 AS THE FIRST
        ADC  #13        ; VIRTUALISED GLOBAL IS 8 AND REAL IS 21.
        BNE  DOWR       ; BRANCH ALWAYS AS ADC #13 NEVER SETS Z.

@VOICER CLC             ; OFFSET THE REGISTER NUMBER BY THE VOICE SID REGISTER
        ADC  SROFF      ; OFFSET FOUND IN THE VTABLE.

DOWR    TAX
        LDY  #1
        LDA  (INSTRP),Y
        STA  $D400,X

        LDA  #$02       ; WE CONSUMED 2 BYTES, Y BIT CLEAR.
        RTS

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * VOICE INIT.                                                               *
; *                                                                           *
; * BULK INITIALISE ALL 7 VOICE REGISTERS.                                    *
; * P0:0 IF SET, VOICE GATE WILL BE OPEN AFTER SETTING UP ALL REGISTERS.      *
; *                                                                           *
; * THIS COMMAND ALWAYS YEALDS.                                               *

CMD_VIN PHA             ; STORE P0 FOR LATER.
        LDA  SROFF      ; FIRST VOICE OFFSET IN THE VOICE REGISTERS.
        CLC
        ADC  #6
        TAX
        
        LDY  #7
@LOOP   LDA  (INSTRP),Y
        STA  $D400,X        
        DEX        
        DEY
        BNE  @LOOP

        PLA             ; RETRIEVE P0
        BEQ  @DONE      ; DO NOTHING IF ZERO.

        LDX  SROFF      ; GATE THE VOICE. SINCE THE VOICE CONTROL REGISTER
        LDY  #5         ; IS WRITE ONLY WE CANNOT JUST SET THE BIT, WE NEED
        LDA  (INSTRP),Y ; TO REWRITE THE ALL VALUE AS IT WAS IN P5 PLUS SET
        ORA  #1         ; THE GATE BIT.
        STA  $D404,X    ;

@DONE   LDA  #$88       ; WE CONSUMED 8 BYTES, Y BIT SET.
        RTS

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * SET FILTER. P0 CONTAINS THE FILTER TYPE VALUE. IF P0 IS > 0 WE SET THE    *
; * INSTRUMENT VOICE TO BE ROUTED THROUGH THE FILTER.                         *                                                                *

CMD_FIL CMP  #0
        BEQ  FILTOFF

        ASL             ; MOVE FILTER TYPE IN HIGER 4 BITS.
        ASL             ;
        ASL             ;
        ASL             ;
        ORA  #%00001111 ; GLOBAL VOLUME IS ALWAYS MAX,
        STA  $D418
        
        LDY  #1         ; P1 HIGHER NIBBLE CONTAINS THE FILTER RESONANCE.
        LDA  (INSTRP),Y ;
        TAX             ; PRESERVE P1 FOR LATER USE.
        AND  #%11110000 ;
        LDY  VOICE      ; USE A LOOKUP TABLE TO CONVERT VOICE NUMBER TO THE
        ORA  FCTBL-1,Y  ; RIGHT BIT TO SET.
        STA  $D417      ; 

        TXA             ; RECOVER P1.
        AND  #%00000011 ; LOWER BITS ARE THE FOSC FACTOR.
        TAX             ; FOSC FACTOR IN X.

        LDY  SROFF      ; SID VOICE REGISTERS OFFSET FROM VATABLE.
        LDA  $D401,Y    ; GET VOICE FREQUENCY HI.

@LOOP2  DEX             ; SHIFT THE HIGH FREQUENCY BYTE BY FACTOR TIMES
        BEQ  @DONE      ; FACTOR 0 FFILT=FOSC*1.5, FACTOR 2 = *3, FACTOR 3 = *6
        ASL             ;
        BNE  @LOOP2     ;

@DONE   STA  $D416

        LDA  #$02       ; WE CONSUMED 2 BYTES, Y BIT CLEAR.
        RTS

FILTOFF LDA  #$FF       ; ONCE THE FILTER IS ON A VOICE WE CANNOT SWITCH THE
        STA  $D416      ; VOICE ENABLE BIT AS IT GENERATES A CLICK. WE SET THE
        LDA  #$1F       ; FILTER TO A LP WITH THE CUTOFF FREQUENCY TO MAX.
        STA  $D418      ; 

        LDA  #$01       ; WE CONSUMED 1 BYTE, Y BIT CLEAR.
        RTS             

FCTBL   BYTE %00000001, %00000010, %00000100
 
; *                                                                           *
; *****************************************************************************
        
; *****************************************************************************
; * YIELD                                                                     *
; * YIELD EXECUTION FOR 1 TICK.                                               *

CMD_YLD LDA  #$81
        RTS

; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; * NO FURTHER ACTIONS FOR THIS INSTRUMENT. WE STAY ON THE SAME INSTRUCTION.  *

CMD_END LDA  #$80       ; WE CONSUMED 0 BYTES, Y BIT SET.
        RTS

; *                                                                           *
; *****************************************************************************

