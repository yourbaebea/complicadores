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
LEX_FLAGS=""
YACC_FLAGS="-d"
CLANG_FLAGS=""
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

function compile() {
    flex $1 $LEX_FLAGS && yacc $2 $YACC_FLAGS -d && cc -g -Wall -Wno-unused-function *.c -o $3
}

function need_recompile() {
    for f in $LEXER $GRAMMAR *.{c,h}; do
        if [[ $f -nt $GO_COMPILER ]]; then
            return 1
        fi
    done
    return 0
}

if [ $# -eq 0 ]; then
    echo "
    Usage: ./test.sh [compiler] [-l|-e1|-e2|-t] [-diff] [-compile] [-lex="lex_file"] [-yacc="lex_file"] [-i="input_dir"] [-o="output_dir"]
    Description:
        [compiler] -> REQUIRED
            The nam e / path of the compiler executable. 
            If the name suplied for the executable does not correspond to a existing executable
            the script will atempt to generate one for you using the default .l file (uccompiler.l)
            or the one that you specify using the -lex flag.
            NOTE: Everytime that the changes are made to the .l file the script will attempt to recompile
        [-l|-e1|-e2|-t] -> OPTIONAL
            Multiple compiler flags that may be passed to the compiler to see more check the UC compiler
            specification document.
            NOTE: There is the option to always provide a bunch of flags by default. To achive this
            edit the UCCOMPILER_FLAGS
        [-lex="PATH"| --lexer=] -> OPTIONAL
            A string with the name / path of the lex file used to produce the compiler
            NOTE: You may change the default name / path by editing the LEXER variable in the script.
        [-yacc="PATH"| --grammar=] -> OPTIONAL
            A string with the name / path of the yacc file used to produce the compiler
            NOTE: You may change the default name / path by editing the GRAMMAR variable in the script.
        [-i="PATH"| --input-dir=] -> OPTIONAL
            A string with the name / path of the directory that contains the source code files (.uc, .c)
            and the files containing the expected output (.out)
            NOTE: You may change the default name / path by editing the INPUT_DIR variavle in the script
        [-o="PATH"| --output-dir=] -> OPTIONAL
            A string with the name / path of the directory that will contain the output obtained from
            running your compiler on the source code file (.uc, .c) provided.
            NOTE: You may change the default name / path by editing the OUTPUT_DIR variable in the script
        [-d | -diff] -> OPTIONAL
            On the test cases where there are errors it shows a numerated list of lines where there are differences
            between the expected compiler output and yours. If this flag is not specified it will not show the diff
            by default but this behaviour can be changed by edition the SHOW_DIFF variable and setting it to "true"
            
    Example Usage: 
        user@computer$ ./test.sh ucc -l 
        user@computer$ ./test.sh ucc -e1 
        user@computer$ ./test.sh ucc -l -diff
        user@computer$ ./test.sh my_compiler -e1 -l
        user@computer$ ./test.sh ucc -l -lex=\"compiler.l\" -i=tests/input_folder -o=tests/my_output_folder
    "

    exit 1

else
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
        -i=* | --input-dir=*)
            INPUT_DIR="${option#*=}"
            shift
            ;;

        -o=* | --output-dir=*)
            OUTPUT_DIR="${option#*=}"
            shift
            ;;
        -lex=* | --lexer=*)
            LEXER="${option#*=}"
            shift
            ;;
        -yacc=*)
            GRAMMAR="${option#*=}"
            shift
            ;;
        -d | --diff)
            SHOW_DIFF="true"
            shift
            ;;
        -m | --memcheck)
            VALGRIND_MEMCHECK="true"
            shift
            ;;
        esac
    done

    [[ ! -f $LEXER ]] && (echo -e "${RED}ERROR:${RESET} ${LEXER} file does not exist!" && exit 1)
    [[ ! -f $GRAMMAR ]] && (echo -e "${RED}ERROR:${RESET} ${GRAMMAR} file does not exist!" && exit 1)
    
    need_recompile # checks if there is a more recent version of the program dependencies
    if [[ $? -eq 1 ]]; then
        echo -e "${BLUE} INFO:${RESET} Compiling... "

        compile $LEXER $GRAMMAR $GO_COMPILER

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}COMPILATION SUCCESSFUL!!${RESET}"
        else
            echo -e "${RED}COMPILATION FAILED!!${RESET}"
            exit 1
        fi
    fi
    run_tests $INPUT_DIR $OUTPUT_DIR
fi