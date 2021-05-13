# Mini C Compiler  
A mini C compiler developed using Lex and Yacc for:  
* Structures  
* Switch  
* While
  
## Phases implemented:  
1. Lexical Analysis  
2. Syntax Analysis  
3. Semantic Analysis  
4. Intermediate Code Generation (ICG) in Three Address Code form
  
## Features:  
* Symbol Table generation
* Intermediate code is stored in Quadruples format  
  
## Errors handled:  
* Undeclared variables  
* Re-declaration of variables within the same scope  
* Type mismatch  
  
## Optimizations:  
* Constant folding  
* Constant propogation  
* Loop invariant code identification  
* Dead code identification
