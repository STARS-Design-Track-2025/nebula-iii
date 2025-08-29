#!/bin/bash

nl -ba finalTest.memh | awk '
{
    # $1 = line number, $2 = hex opcode
    printf "*(&sram_space + %d) = 0x%s;\n",
           ($1-1), tolower($2), $1
}
' > sram_init_output.c
