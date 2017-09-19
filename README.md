
[Instruments](#instruments)

# Instruments #

Instruments are defined by making use of a microcode that executes intructions on a virtualised SID. These instructions allow to create intruments that are more complex than it would be possible by just defyning a waveform and an ADSR envelope. Microcoded instruments can evolve all the sound parameters over time, giving access to a more rich sound palette. We will refer to the Instrument MicroCode as IMC throughout this text and, where needed, in the source code.

## The virtualised SID Registers ##

IMC operates on a virtualised SID that exposes the SID 29 registers in just 16 registers: 7 voice registers and 8 global registers (there's an unused register between the two blocks to align things nicely). The 7 voice registers, as opposed to the 7 registers per voice of the SID, allow to write instruments in IMC that can be played on any voice. The global 8 registers are the voice independent registers as found in the SID. Below is the registers map as seen by IMC intructions.

| REG | Direction | Purpose |
|---|---|---|
| 0 | W | Voice Frequency Low |
| 1 | W | Voice Frequency Hi |
| 2 | W | Voice Pulse Width Low |
| 3 | W | Voice Pulse Width Hi |
| 4 | W | Voice Control Register |
| 5 | W | Voice Attack/Decay |
| 6 | W | Voice Sustain/Release |
| 7 | W | Not in use |
| 8 | W | Filter Cutoff Low |
| 9 | W | Filter Cutoff Hi |
| 10 | W | Filter Resonance and Voice Selectors |
| 11 | W | Mode and Volume |
| 12 | R | Potentiometer X |
| 13 | R | Potentiometer Y |
| 14 | R | Oscillator 3 Sample |
| 15 | R | Envelope 3 Sample |

## IMC Instructions ##

The following instructions are available in IMC. Most intructions, once executed, cause the execution of the following instruction to take place immediately, except for those intructions that return a status register with the Yield (Y) flags set. Instructions returning with the Y bit set will cause the player to give up execution for that voice until the next frame triggers a call to the routine.

Each instruction is encoded in the high nibble of the command value. The lower nibble of the same byte is the first, 4 bits, parameter of the instructions, this is referred as P0. Some commands require an other byte to encode an other parameter, this is referred to as P1.

```
0          8         16
| CMD Byte | Operator |
| CMD | P0 |    P1    |
```

### WIN - Wait Init ###

Initialises the wait counter to the desired amount of ticks a following wait instruction will have to wait. The amount of ticks to wait is encoded in P0 as the amount of ticks/2, this allows waits ranging from 33mS to to 528mS in steps of 33mS. Note that while MUWAIT is an 8 bit register, and can be set for a delay up to 256 ticks (roughly 4 seconds), the WIN instruction allows to set it only up to 32 because of the limited size of P0. This was considered enough for intra-instruction durations, longer durations can be set for the whole note in the track note length byte.

```
LENGTH:1        STATUS Y---
                       0---
AFFECTS:       
P0         => MUWAIT
INSTRP + 1 => INSTRP
```

### LWW - Loop While Waiting ###

Waits the amount of ticks in MUWAIT. This is not an idle wait, the command will set the Y flag so it will cause the virtualised SID to yield and the other voices will be executed as well. Additionally INSTRP will be decremented by P0 unless MUWAIT has reached zero in which case the command will let the flow progress to the next instruction.

```
LENGTH:1        STATUS Y---
                       1---
AFFECTS:       
MUWAIT - 1  => MUWAIT
INSTRP - P0 => INSTRP IF MUWAIT>0
INSTRP + 1  => INSTRP IF MUWAIT=0
```

### WRI - Write Register ###

Writes a value into the specified register. This command takes the virtualised SID register in P0 and the value to write in P1. See "Virtualised SID registers" section above for the actual registers map. 

```
LENGTH:2        STATUS Y---
                       0---
AFFECTS:       
P1         => REG[P0] 
INSTRP + 2 => INSTRP
```
### YLD - Yield execution ###

Yields exection, other voices will be processed and this instruments next instruction will not be executed until the next tick.

```
LENGTH:1        STATUS Y---
                       1---
AFFECTS:       
INSTRP + 1 => INSTRP
```

### END - End sequence ###

Ends an instrument commands sequence and yield. No more code for this instrument will be executed until a new note on it is played.

```
LENGTH:1        STATUS Y---
                       0---
AFFECTS:       
---
```

## Examples ##

### Gunshot ### 

The gunshot effect is obtained by gating quickly on and off some white noise with an envelope decaying slowly. This gives the initial bang followed by a tail of fading noise. We set the voice frequency to 622Hz, noise in the SID is colored, so setting a frequency actually has an effect.

```
        BYTE $25, $02   ; WRI 5, $02            ATTACK 0MS, DECAY 16MS
        BYTE $26, $A9   ; WRI 6, $A9            SUSTAIN 10, RELEASE 750MS
        BYTE $21, $28   ; WRI 1, $28            FREQUENCY HI
        BYTE $20, $C8   ; WRI 0, $C8            FREQUENCY LO (622HZ)
        BYTE $24, $81   ; WRI 4, %10000001      WF NOISE, GATE ON        
        BYTE $02        ; WIN 2                 INIT WAIT, 4 TICKS
        BYTE $10        ; WAI                   WAIT
        BYTE $24, $80   ; WRI 4, %10000000      NOISE, GATE OFF        
        BYTE $FF        ; END

```
