
# Method #

In order to verify the code works as expected a series the tests defined in `test.asm` can be run. These are not fully automated tests. The general method is to define a test instrument, with certain characteristics that exercise a particular feature of the player and use that instrument, in isolation, on a voice. The sound output needs then to be sampled and visually analyzed, for instance in Octave,  to match the expected signal.

## TEST 1 ##

````ASM
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
````        
![test1](tests/test1.png)


### VIN Test ###

Verify that the VIN command correctly initialises a voice. The triangle wave is expected to have a frequency of 220Hz in the first part of the sequence, ie 4 periods in the 20mS duration.

### VWR Test ###

Verify that the VWR command correctly writes to the desired voice registester. The waveform is expected to change through the sequence triangle/noise/triangle/pulse.

### YLD Test ###

Verify that the the YLD command yields for 1 tick. Each step of the triangle/noise/triangle/pulse sequence is expected to last 20mS (one tick).

### END Test ###

Verify that the END command correctly terminates the execution of the IMC sequence. The change from noise to pulse at the end should not happen.

Sampled output:

![drum1](images/validation_drum_1.png)

## TEST 2 ##

The following instrument is applied to all voices.

```ASM
TEST1   BYTE $40, $8F, $0E, $00, $08, $11, $00, $F7
        BYTE $FF
```

### VOI Test ###

The VOI command works as expected on all voices.  A monitor is used to inspect the SID registers, all 3 voices are expected to be setup with the values as in the dump below.

```
>M D400 D41F
C:d400  8f 0e 00 08  11 00 f7 8f  0e 00 08 11  00 f7 8f 0e  00 08 11 00  f7 00 00 00  0f 00 00 00  00 00 00 00
```
