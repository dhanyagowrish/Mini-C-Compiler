lex lexer.l
yacc parser.y 
gcc y.tab.c -ll -w
./a.out testcase.c
