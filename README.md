# 68hc11-lightshow

This was a fun school project I did in 2011 to become familiar with assembly language. The objective was to create a program that toggled between showing the current temperature in BCD and showing dancing light shows on an LED array. A user could then access these features using a simple 16 button keypad.

## Components
 - 68HC11 processor + cable + software
 - 16 button keypad
 - LM34 temperature sensor
 - LM385Z zener diode
 - 40 pin DIP header
 - Breadboard
 - 8 LEDs
 - ZIF socket
 - Misc. resistors + wires

## Design
The design of the main routine is outlined in the flow chart below. Loop names are labeled to the side: LIGHTS, LIGHT2, LIGHT3, LIGHT4, LIGHTGO, and LOOP2 (originally called HAVE_A). To keep track of things, a checkmark was inscribed in each box as its function was implemented in the program. Also, a sketch of the stack can be found in the bottom left corner, starting with the rate value in memory location $37, and ending with the higher order byte of the return address in memory location $34.

![Flow chart](http://i.imgur.com/m4fhQjE.png)

## Implementation
The implementation consists of 3 files:
 - `main.asm` - Main Routine
 - `subroutines1.asm` - TEMPS, SHOW
 - `subroutines2.asm` - UPDATE, DELAY, GETKEY, BOUNCE

Designs were implemented using a PC running the THRSim11 development environment. The PC was connected to the 68HC11 through an RS232 cable. Code was tested with THRSim11's simulation capabilities before assembling and downloading to the board.

I encountered some difficulties with the wiring of the circuit on my particular breadboard setup. If the wiring was incorrect, then some key values would not be correctly reported to the processor. In such cases I reverted back to a standard keypad test program and addressed any wiring issues before continuing.

Another difficulty was the limitation of space in the 68HC11’s memory. The start addresses for my instructions and data had to be carefully set so that they would not write over each other. ORG statements were examined closely to avoid unexpected executions that did not go with what I programmed. To overcome the difficulty of limitations in RAM space, all of the subroutines had to be moved to the EEPROM. This meant dividing the asm file into separate files that maintained constant address calls (so that jumps and branches would work properly), and that could be downloaded into the $100-$1FF range.

Once a subroutine file was loaded into the $100-$1FF range, BUFFALO monitor/HyperTerminal was used to copy the instructions into the EEPROM ($B600-B6FF) range with the command:  “MOVE 100 xxx B600” where xxx is the ending address of the subroutine instructions.  A second file of subroutines was loaded into the EEPROM following the same procedure, since not all subroutine instructions could fit in the $100-1FF range. In this case, the MOVE command was changed slightly to have a different ending address in the RAM and a different starting address in the EEPROM, so as not to incorrectly overwrite existing code.

After the EEPROM held all of the subroutines, the main routine was loaded into the RAM and executed normally.  One additional problem that proved to have a very simple solution was that the program initially used a “BRA” instruction where there should have been a “BEQ,” resulting in an infinite loop before the light show could be reached.

In designing the subroutines, there was some initial difficulty regarding stack usage.  Specifically, it was difficult to determine how the main program would take the key inputs and pass them to the light show subroutine.  Once the fact that the JSR instruction pushes the return address onto the stack was accounted for, it was possible to use push and pull commands in conjunction with the index registers to develop a solution that would work in every loop of the program.
