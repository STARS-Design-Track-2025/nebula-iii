#!/bin/bash

FUNCTION_NAME="team_07_sram_init"
FILENAME="${FUNCTION_NAME}.c"
MEMORY_FILE="module_tests/instruction_ex.mem"

echo -e "$FUNCTION_NAME(volatile uint32_t * sram_space);\n\n" > $FILENAME
echo -e "$FUNCTION_NAME(volatile uint32_t * sram_space) {" >> $FILENAME

nl -ba $MEMORY_FILE | awk '
{
    # $1 = line number, $2 = hex opcode
    printf "\t*(sram_space + %d) = 0x%s;\n",
           ($1-1), tolower($2), $1
}
' >> $FILENAME

echo -e "}" >> $FILENAME
