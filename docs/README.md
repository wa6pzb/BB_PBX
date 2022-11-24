# Documentation - Bread Board PBX (BB_PBX)

This simple telephone Private Branch Exchange (PBX) uses ready made modules:

* [Subscriber Line Interface Circuit (SLIC)](/docs/Ring_SLIC_Interface.pdf)
* [PSTN Interface circuit](/docs/Ag2130-datasheet-low-cost-PSTN-interface.pdf)
* [Audio WAV/MP3 players](/docs/KOOBOOK_SD_Audio_player.pdf)
* [DTMF decoder module](/docs/MT8870.jpg)
* [Relay Board](/docs/4DPDT_Relay_board.jpeg) & [Schematic Drawing](/docs/4DPDT_Relay_board_schem.jpeg)


The modules are connected to a Micromite PIC32 microcontroller that is running an embedded BASIC called MMBasic.

* Micromite - https://geoffg.net/micromite.html
* [MMBASIC PIC32 Schematic](/docs/PIC32MX170F256B_drawing.jpeg)
* PICAXE 8 pin microcontroller ring generator

Due to the amount of I/O pins needed to control the modules the Micromite PIC32 microcontroller can support just two extentions (SLICs) and one PSTN module.
An I/O extender could be used in the future.

## Features

* Pulse rotary dialing
* Two Extensions
* One Public Switch Telephone Network port (to connect to the world)
* Progress Tones presented to the two extensions (dialtone, ringing, etc.)
* Extension can dial and ring each other by using an assigned extension number
* Simple ring generator using a PICAXE 8 pin microcontroller dedicated to each SLIC using only a single I/O pin and no software on the PIC32

## Block Diagram

![Alt text](../images/BB-PBX.png?raw=true "Block Diagram")

## Basic Switch Fabric

![Alt text](/docs/BB-PBX-Relay-Fabric.png "Fabric")
