# Documentation - Bread Board PBX (BB_PBX)

This simple telephone Private Branch Exchange (PBX) is using ready made modules:

* [Subscriber Line Interface Circuit (SLIC)](/docs/Ring_SLIC_Interface.pdf)
* [PSTN Interface circuit](/docs/Ag2130-datasheet-low-cost-PSTN-interface.pdf)
* [Audio WAV/MP3 players](/docs/KOOBOOK_SD_Audio_player.pdf)
* [DTMF decoder module](/docs/MT8870.jpg)
* [Relay Board](/docs/4DPDT_Relay_board.jpeg) & [Schematic Drawing](/docs/4DPDT_Relay_board_schem.jpeg)

The modules are connected to a Micromite PIC32 microcontroller that is running an embedded BASIC called MMBasic.

* [MMBASIC PIC32 Schematic](/docs/PIC32MX170F256B_drawing.jpeg)

Due to the amount of I/O pins needed to control the modules the Micromite PIC32 microcontroller can support just two extentions (SLICs) and one PSTN module


## Block Diagram

![Alt text](../images/BB-PBX.png?raw=true "Block Diagram")

## Basic Switch Fabric

![Alt text](/docs/BB-PBX-Relay-Fabric.png "Fabric")
