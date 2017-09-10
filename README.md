
[Instruments](#instruments)

# Instruments #

Instruments are defined by making use of a microcode that executes intructions on a virtualised SID. These instructions allow to create intruments that are more complex than it would be possible by just defyning a waveform and an ADSR envelope. Microcoded instruments can evolve all the sound parameters over time, giving access to a more rich sound palette. We will refer to the Instrument MicroCode as IMC throughout this text and, where needed, in the source code.

## The virtualised SID ##

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



# Units #

## Tick (T) ##

The smallest time unit, a tick is equivalent to 1 frame interrupt call.

## Beat (BT) ##

One beat is 16 TICKS. 

# Tune Elements #

## Instrument Table (IT) ##

Each instrument is a sequence of commands, each command is made of 1 byte, except some that require a full 8 bits operand. The high nibble is the command, the lower nibble the operand, where required the second byte the second operand.

| 7 | 6 | 5 | 4  | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|
| CMD2 | CMD1 | CMD0 | OP4  | OP3 | OP2 | OP1 | OP0 |

### Write Voice Register (WVR) ###

| 7 | 6 | 5 | 4  | 3 | 2 | 1 | 0 | 7 | 6 | 5 | 4  | 3 | 2 | 1 | 0 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|   0    |   0   |   1  |   0  | REG3 | REG2 | REG1 | REG0 | OP7 | OP6 | OP5 | OP4 | OP3 | OP2 | OP1 | OP0 |


### Write Register (WRR) ###

| 7 | 6 | 5 | 4  | 3 | 2 | 1 | 0 | 7 | 6 | 5 | 4  | 3 | 2 | 1 | 0 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|   0    |   0   |   1  |   1  | REG3 | REG2 | REG1 | REG0 | OP7 | OP6 | OP5 | OP4 | OP3 | OP2 | OP1 | OP0 |


WAIT        WA 0 \<TICKS>

  0 1 0 TICKS4-0
  
WAIT_NOTE_OFF WA 1 

  0 1 1 NA4-0

BITSET

BITCLR

## Instruments Pointers Table (IPT) ##

This is a pointers table to the beginning of the instrument, two bytes per instrument, little endian.

```
IPT BYTE IT0_LO IT0_HI 
    BYTE IT1_LO IT1_HI 
    .....
```

## Track (TRK) ##

Each track is made up of one entry per beat. The entry conntains:

```
TRK BYTE BEAT_NUMBER, FREQ_HI, FREQ_LO, INSTR_NUM, DURATION
    BYTE BEAT_NUMBER, FREQ_HI, FREQ_LO, INSTR_NUM, DURATION
    .....
```
