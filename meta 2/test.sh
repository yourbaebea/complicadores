#!/bin/bash

# Compiler Tester
# @version 4.0
# @author Pedro Miguel Duque Rodrigues
# @author Ana Beatriz Marques
# adaptation from uccompiler to gocompiler

# simple use explanation
# in the folder metaX add this file
# inside the folder create the following
#   metaX/tests/input                       this is where your .dgo and .out files from the git go to
#   metaX/tests/output                      this is where your new generated files go after running the tests
#
# to run: open terminal of folder metaX and run
#   bash test.sh uccompiler -(flag)         (flag) is the flag of the current meta = -l;
#
# files are generated and compared, if there is any error there will be ❌ {file that doesnt pass the test} in the terminal
# 
# done :D


# Terminal Escape Colors
RED="\x1B[31m"
GREEN="\x1B[32m"
RESET="\x1B[0m"
BLUE="\x1B[34m"

# Default Directory Search Path and Compiler Output Paths
INPUT_DIR="tests/input"
OUTPUT_DIR="tests/output"

# Default Configurations
LEXER="gocompiler.l"
GRAMMAR="gocompiler.y"
SHOW_DIFF="false"
VALGRIND_MEMCHECK="false"

# ProgramFlags
UCCOMPILER_FLAGS=""
VALGRIND_FLAGS="--leak-check=full --show-leak-kinds=all"
DIFF_FLAGS="--strip-trailing-cr"   # Might be helpufl: "--suppress-common-lines"""

function run_tests() {
    for file_path in $1/*.dgo; do
        gofile=$(basename "$file_path")
        outfile=${gofile%.*}.out

        ./$GO_COMPILER $UCCOMPILER_FLAGS <$file_path >$2/$outfile

        (diff -y $DIFF_FLAGS $1/$outfile $2/$outfile) &>DIFFOUT

        if [ $? -eq 0 ]; then
            echo -e ✅ "${GREEN}TEST PASSED!!${RESET}" $gofile
        else
            echo -e ❌ "${RED}TEST FAILED!!${RESET}" $gofile
            [[ $SHOW_DIFF == "true" ]] && echo && cat -n DIFFOUT && echo
        fi
        if [[ $VALGRIND_MEMCHECK == "true" ]]; then
            valgrind $VALGRIND_FLAGS ./$GO_COMPILER <$file_path
        fi
    done
    rm DIFFOUT
}


    GO_COMPILER=$1
    for option in "$@"; do
        case $option in
        -l)
            UCCOMPILER_FLAGS="$UCCOMPILER_FLAGS -l"
            shift
            ;;
        -e1)
            UCCOMPILER_FLAGS="$UCCOMPILER_FLAGS -e1"
            shift
            ;;
        -e2)
            UCCOMPILER_FLAGS="$UCCOMPILER_FLAGS -e2"
            shift
            ;;
        -t)
            UCCOMPILER_FLAGS="$UCCOMPILER_FLAGS -t"
            shift
            ;;
        
        esac
    done
    
    run_tests $INPUT_DIR $OUTPUT_DIR
fi
done
