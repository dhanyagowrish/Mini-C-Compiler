%{
int yylineno;
%}

alpha [A-Za-z]
digit [0-9]


%%
[ \t] ;
\n	{yylineno++;}
"{"	{scope_start(); return '{';}
"}"	{scope_end(); return '}';}
";"	     {   return(';'); }
","	     {   return(','); }
":"	     {   return(':'); }
"="	     {   return('='); }
"("	     {   return('('); }
")"	     {   return(')'); }
("[") 	     {   return('['); }
("]")        {   return(']'); }
"."	     {   return('.'); }
"&"	     {   return('&'); }
"!"	     {   return('!'); }
"~"	     {   return('~'); }
"-"	     {   return('-'); }
"+"	     {   return('+'); }
"*"	     {   return('*'); }
"/"	     {   return('/'); }
"%"	     {   return('%'); }
"<"	     {   return('<'); }
">"	     {   return('>'); }
"^"	     {   return('^'); }
"|"	     {   return('|'); }
"?"	     {   return('?'); }
int	{yylval.ival = INT; return INT;}
float	{yylval.ival = FLOAT; return FLOAT;}
void	{yylval.ival = VOID; return VOID;}
^"#include ".+	return PREPROC;
switch {return SWITCH;}
case	{return CASE;}
default {return DEFAULT;}
break {return BREAK;}
while	return WHILE;
return 	return RETURN;
printf	return PRINT;
{alpha}({alpha}|{digit})* {yylval.str=strdup(yytext); return ID;}
{digit}+	{yylval.str=strdup(yytext);return NUM;}
{digit}+\.{digit}+ 	{yylval.str=strdup(yytext); return REAL;}
"<="		return LE;
">="		return GE;
"=="		return EQ;
"!="		return NEQ;
"&&"		return AND;
"||"		return OR;
"++"            return INC;
"--"            return DEC;
\/\/.* ;
\/\*(.*\n)*.*\*\/ ;

\".*\"	return STRING;
.	return yytext[0];
%%

