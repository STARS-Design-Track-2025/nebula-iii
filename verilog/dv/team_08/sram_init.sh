#!/bin/bash

FILENAME="team_08_sram_init.c"

echo -e "void team_08_sram_init(volatile uint32_t* sram_space);\n\n" > $FILENAME
echo -e "void team_08_sram_init(volatile uint32_t* sram_space) {" >> $FILENAME

nl -ba module_tests/t08_sample_memory.mem | awk '
{
    # $1 = line number, $2 = hex opcode
    printf "\t*(sram_space + %d) = 0x%s;\n",
           ($1-1), tolower($2), $1
}
' >> $FILENAME

echo -e "}" >> $FILENAME
