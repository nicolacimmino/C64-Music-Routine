
# Method #

In order to verify that the code works as expected a series of tests have been run. The general method is to define a test intrument, with certain characteristics that exercise a particular feature of the player and use that instrument, in isolation, on a voice. The sound output has then been sampled and visually analyzed in Audacity to match the expected signal.

## YLD Test ##

Verify that the the YLD command yealds for 1 tick. Each step of the triangle/noise/triangle/pulse sequence is expected to last 20mS (one tick).

````ASM
DRUM1   BYTE $25, $00   ; WVR 5, $00            A=2mS D=6mS
        BYTE $26, $F7   ; WVR 6, $F7            S=15  R=240ms
        BYTE $22, $00   ; WVR 2, $00            PW: 50%
        BYTE $23, $08   ; WVR 3, $08                            
        BYTE $20, $8F   ; WVR 0, $8F            FREQ=220Hz
        BYTE $21, $0E   ; WVR 1, $0E        
        BYTE $24, $11   ; WRI 4, %00010001      TRIANGLE, GATE ON        
        BYTE $E0        ; YLD

        BYTE $21, $2E   ; WVR 1, $2E            FREQ=700Hz
        BYTE $24, $81   ; WRI 4, %10000001      NOISE, GATE ON        
        BYTE $E0        ; YLD

        BYTE $21, $0E   ; WVR 1, $0E            FREQ=220Hz
        BYTE $24, $11   ; WRI 4, %00010001      TRIANGLE, GATE ON        
        BYTE $E0        ; YLD

        BYTE $24, $41   ; WRI 4, %01000001      PULSE, GATE ON        
        BYTE $E0        ; YLD
        
        BYTE $21, $2E   ; WVR 1, $2E            FREQ=700Hz
        BYTE $24, $80   ; WRI 4, %10000001      NOISE, GATE OFF
                
        BYTE $FF        ; END
````        

Sampled output:

![drum1](images/validation_drum_1.png)
