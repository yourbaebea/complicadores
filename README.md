# compiladores 2021/22

Ana Beatriz Marques, 2018274233

Bárbara Gonçalves, 2018295452

### meta 1: 190/190
### meta 2: 19-11-2021 246/250
### meta 3: 03-12-2021 167/250
### meta 4: 17-12-2021 0/250


# links importantes
- tokens da linguagem https://golang.org/ref/spec#Lexical_elements
- repositorio do stor https://git.dei.uc.pt/rbarbosa/Comp2021/tree/master
      user: email do dei sem o @student.dei.uc.pt
      passe: passe do email do dei


### makefile:
"
gocompiler:
	flex gocompiler.l
	yacc -dy gocompiler.y
	clang -o gocompiler -Wall -Wno-unused-function *.c
	
.SILENT:
"

to run:
-  make -B


### bash for tests
in the folder metaX add this file
inside the folder create the following
| files | function of the files |
| --- | --- |
| metaX/tests/input | this is where your .dgo and .out files from the git go to |
| metaX/tests/output | this is where your new generated files go after running the tests |

first time:
chmod +x test.sh
dos2unix test.sh

 to run:
 ./test.sh gocompiler -(flag)
 
 files are generated and compared, if there is any error there will be ❌ {file that doesnt pass the test} in the terminal

# other stuff
      
- https://github.com/ruilinhares/Compiladores/blob/master/meta2/uccompiler.y
- https://github.com/jllopes/uccompiler/blob/master/uccompiler.y
- https://github.com/FranciscoJRSantos/Compiladores-UC
- https://github.com/AntoniossLopes/Compiladores
- https://github.com/lenacgs/comp
      

