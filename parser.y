%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbolTable.c"
#include "quadruples.c"

int g_addr = 100;
int i=1;				// latest SCOPE
int lnum1=0;
int stack[100];
int index1=0;				// index of SCOPE ARRAY
int end[100];
int arr[10];
int ct;
int c;
int b;
int fl;
int top=0;				// index of ST1 STACK 
int label[20];
int label_num=0;			// the label suffix i.e L's suffix
int ltop=0;
char st1[100][10];			// - it is the stack used for generating 3AC in terms of STACK OPERATIONS - holds the different values and operands in expressions
char temp_count[2]="0";		// holds the latest TEMPORARY SUFFIX i.e t's suffix	
int plist[100],flist[100];
int k=-1;
int errc=0;
int j=0;
char temp[2]="t";
char null[2]=" ";
char switch_variable[100];
int next_num = 1;
int is_default = 0;
int is_break = 3;
int prev_case = 3;
char prev_case_break[20];
char buffer[20];
int is_array=0;
char dummy_concat[10];

char op_1[100];
char arg1_1[100];
char arg2_1[100];
char result_1[100];

int is_cond_while = 0;
int is_body_while = 0;
int while_scope = 0; 
char loop_variant_id[10][10];
int id_indicator=1; 
int num_loop_variant_ids=0;
int is_return = 0;
int is_not_lambda = 1;

int return_deadcode_statements_count=0;
char expr_eval_res[20];

void yyerror(char *s);
int printline();

int is_void=0;
int is_print=0;

extern int yylineno;




void dummy_quad(char *op,char *arg1,char *arg2,char *result)
{
	strcpy(op_1,op);
	strcpy(arg1_1,arg1);
	strcpy(arg2_1,arg2);
	strcpy(result_1,result);
}



void check_after_return()
{
	if(is_return>0)
	{	
		++return_deadcode_statements_count;
	}
}
		


char *my_itoa(float num, char *str)
{
        if(str == NULL)
        {
                return NULL;
        }
        sprintf(str, "%f", num);
        
        return str;
}


void my_concat(char num,char *str)
{
	char dummy[20];
	strcpy(dummy_concat,str);
	//my_itoa(num,dummy);
	sprintf(dummy, "%d", num);
	strcat(dummy_concat,dummy);
}

// when new scope seen - add to scope stack
void scope_start()
{
	stack[index1]=i;
	i++;
	index1++;
	return;
}

// when scope ends - mark it as '1' in END and '0' in STACK
void scope_end()
{
	index1--;
	end[stack[index1]]=1;
	stack[index1]=0;
	return;
}



void while1()
{
	label_num++;
	label[++ltop]=label_num;
	printf("\nL%d:\n",label_num);
	
	my_concat(label_num,"L");
	enter_in_quad("Label","NULL","NULL",dummy_concat);
}

void while2()
{
	label_num++;						// increment the label's suffix
	printf("iffalse %s goto L%d",st1[top],label_num);
	
	
	char dummy[20];
	strcpy(dummy,"L");
	//my_itoa(label_num,buffer);
	sprintf(buffer, "%d", label_num);
	strcat(dummy,buffer);
	enter_in_quad("iffalse",st1[top],"NULL",dummy);
	
	--top;
 	label[++ltop]=label_num;				
}

void while3()
{
	int y=label[ltop];
	--ltop;
	printf("\ngoto L%d\n",label[ltop]);

	my_concat(label[ltop],"L");
	--ltop;
	
	enter_in_quad("goto","NULL","NULL",dummy_concat);
	printf("\nL%d:\n",y);
}

// push a string into ST1 STACK
void push(char *a)
{
	strcpy(st1[++top],a);
}

void array1()
{
	strcpy(temp,"t");
	strcat(temp,temp_count);
	printf("\n%s = %s\n",temp,st1[top]);		// temporary = index	
	strcpy(st1[top],temp);
	temp_count[0]++;
	strcpy(temp,"t");
	strcat(temp,temp_count);
	printf("%s = %s [ %s ] \n",temp,st1[top-1],st1[top]);		
	top--;
	strcpy(st1[top],temp);
	temp_count[0]++;
}


// // generate 3AC for expressions in terms of STACK OPERATIONS
void codegen()
{
	strcpy(temp,"t");
	strcat(temp,temp_count);
	printf("\n%s = %s %s %s\n",temp,st1[top-2],st1[top-1],st1[top]);	// print the instruction in 3AC as stack operations	
	
	enter_in_quad(st1[top-1],st1[top-2],st1[top],temp);
	
	top-=2;
	strcpy(st1[top],temp);							// make the TOP element of the ST1 stack the most recent temp i.e t0 etc
	temp_count[0]++;							// increment the latest temp suffix
}



void codegen_assign()
{
	printf("\n%s = %s\n",st1[top-2],st1[top]);			// print id = value i.e assignment
	
	enter_in_quad("=",st1[top],"NULL",st1[top-2]);
	
	top-=2;							// decrement top of ST1..
}


void switch1(char *switch_var)
{
	strcpy(switch_variable,switch_var);
}

// display label AND condition for the case 
void case1(char *case_value)
{	
	if(is_break==0)
	{
		case2(case_value);
	}
	
	else{
		
		++label_num;
		printf("\n\nL%d:",label_num);
		strcpy(temp,"t");
		strcat(temp,temp_count);
		temp_count[0]++;
		printf("\n%s = %s == %s",temp,switch_variable,case_value);
		printf("\niffalse %s goto L%d",temp,label_num+1);
		
		char dummy[20];
		strcpy(dummy,"L");
		//my_itoa(label_num+1,buffer);
		
		sprintf(buffer, "%d", label_num+1);
		strcat(dummy,buffer);
		enter_in_quad("iffalse",temp,"NULL",dummy);
		
	}
		
}


void case2(char *case_value)
{	
	
	++label_num;
	printf("\n\nL%d:",label_num);
	strcpy(temp,"t");
	strcat(temp,temp_count);
	temp_count[0]++;
	printf("\n%s = %s == %s",temp,switch_variable,case_value);
	printf("\niffalse %s goto L%d",temp,label_num+2);
	
	char dummy[20];
	strcpy(dummy,"L");
	//my_itoa(label_num+2,buffer);
	sprintf(buffer, "%d", label_num+2);
	strcat(dummy,buffer);
	enter_in_quad("iffalse",temp,"NULL",dummy);
	
	printf("\nL%d:",label_num+1);
	++label_num;
}


void break1()
{
	
	if(is_default==0)
	{
		//printf("goto next%d\n",next_num);
		strcpy(prev_case_break,"goto next");
		
		//my_itoa(next_num,buffer);
		sprintf(buffer, "%d", next_num);
		
		
		char dummy[20];
		strcpy(dummy,"next");
		strcat(dummy,buffer);
		dummy_quad("goto","NULL","NULL",dummy);
		
		strcat(prev_case_break,buffer);
		
		
		
		
	}
}

void break2()
{
	if(is_default==0)
	{
		//printf("goto L%d\n",label_num+2);
		strcpy(prev_case_break,"goto L");
		//my_itoa((label_num+2),buffer);
		sprintf(buffer, "%d", label_num+2);
		
		char dummy[20];
		strcpy(dummy,"L");
		strcat(dummy,buffer);
		
		dummy_quad("goto","NULL","NULL",dummy);
		
		strcat(prev_case_break,buffer);
	}
}
	

void print_prev_break()
{
	//printf("\nIS BREAK:%d",is_break);
	//printf("PREV BREAK%s",prev_case_break);
	if(prev_case == 1)
	{
	
		if(is_default==1)
		{
			//printf("\nIN DEFAULT");
			printf("goto L%d",label_num+1);
			
			//my_itoa(label_num+1,buffer);
			sprintf(buffer, "%d", label_num+1);
			char dummy[20];
			strcpy(dummy,"L");
			strcat(dummy,buffer);
			enter_in_quad("goto","NULL","NULL",dummy);
		}
		
		else
		{	
			//printf("\nIN ELSE");
			printf("%s",prev_case_break);
			
			enter_in_quad(op_1,arg1_1,arg2_1,result_1);
		}
	}
}


void end_switch()
{
	printf("\nnext%d:\n",next_num);
	++next_num;
}


void default1()
{
	++label_num;
	printf("\n\nL%d:",label_num);
}

void loop_variant_ids(char id[10])
{
	if(is_cond_while)
	{
		strcpy(loop_variant_id[num_loop_variant_ids],id);
		//printf("loop variant identifier - %s \n", loop_variant_id[num_loop_variant_ids]);
		num_loop_variant_ids++;
		
	}
}

int check_invariant(char id[10])
{
				 
				int i =0; 
				while(i < num_loop_variant_ids) 
				{ 
					if(strcmp(id,loop_variant_id[i]) != 0)
					{
				 		//printf("\n\nINVARIANT: %d \n\n",yylineno);
						
					}
					else if(strcmp(id,loop_variant_id[i]) == 0)
						return 0;
					++i; 
					
				}
				return 1; 

				
				
				
}

void myprint(int result)
{
	if(result==1) printf("\nLOOP INVARIANT: %d",yylineno);
	
		
}



void expression_evaluation(char *a,char op,char *b)
{
	float a_val = atof(a);
	float b_val = atof(b);
	
	float res;
	
	switch(op)
	{
		case '+': res=a_val+b_val;
			break;
			
		case '-': res=a_val-b_val;
			  break;
			  
		case '*': res = a_val*b_val;
				break;
		case '/': res = a_val/b_val;
			break;
			
	}
	
	
	my_itoa(res,expr_eval_res);
	
	//printf("\nEXPR EVAL RESULT %s a %f b %f res %f",expr_eval_res,a_val,b_val,res);
	
	
}


%}

%token<ival> INT FLOAT VOID
%token<str> ID NUM REAL
%token WHILE RETURN PREPROC LE STRING PRINT FUNCTION ARRAY FOR GE EQ NE INC DEC SWITCH CASE DEFAULT BREAK
%left LE GE EQ NEQ AND OR '<' '>'
%right '='
%left '+' '-'
%left '*' '/'
%type<str> assignment1 consttype E T F
%type<ival> Type

%union {
		int ival;
		char *str;
	}
%%

// PROGRAM STARTS
start : Function start
	| PREPROC start
	| Declaration start
	|
	;

// MAIN FUNCTION
Function : Type ID '('')' compound_statement {
	// if return type value is not matched with type specified
	if ($1!=returntype_func())
	{
		printf("\nError : Return Type mismatch : Line %d\n",printline()); errc++;
	}
	
	// check if MAIN function is named 'main'	
	if(strcmp($2,"main")!=0)
		{printf("Error : Cannot name main function this! %s : Line %d\n",$2,printline()); errc++;}
	
	else
	{
		insert($2,FUNCTION);				// create entry in symbol table
		insert($2,$1);
		g_addr+=4;
	}
	}
	;


Type : INT
	| FLOAT
	| VOID
	;

compound_statement : '{' stmt '}'
	;
	
stmt : Declaration stmt {check_after_return();}
	| while stmt	{check_after_return();}
	| RETURN consttype ';' {is_return = yylineno;} stmt {	

						if(!(strspn($2,"0123456789")==strlen($2)))		// check if the return value is float or int 
							storereturn(FLOAT);				// store the function return type
						else
							storereturn(INT);
							
					// check for statements after RETURN
						if(return_deadcode_statements_count>0)
						{
							printf("\nStatements after line number %d is DEAD CODE\n",is_return);
						}	
				}
	| RETURN ';' {is_return = yylineno; is_void=1;} stmt 
					{storereturn(VOID);
						if(return_deadcode_statements_count>0)
						{
							printf("\nStatements after line number %d is DEAD CODE\n",is_return);
						} 
					}
						
	| ';'		
	| PRINT '(' STRING ')' ';' stmt	{ is_print=1; check_after_return();}
	| ID INC';' stmt {push($1); loop_variant_ids($1); if(is_body_while) myprint(check_invariant($1)); 	check_after_return();}
	| ID DEC';' stmt {push($1); loop_variant_ids($1); if(is_body_while) myprint(check_invariant($1));	check_after_return();}
	| INC ID';' stmt {push($2); loop_variant_ids($2); if(is_body_while) myprint(check_invariant($2));	check_after_return();}
	| DEC ID';' stmt {push($2); loop_variant_ids($2); if(is_body_while) myprint(check_invariant($2));	check_after_return();}
	| switch stmt												{check_after_return();}
	| compound_statement stmt										{check_after_return();}
	|				
	;
//SWITCH'('ID')''{'case'}' stmt

switch : SWITCH'('ID')'{switch1($3);} '{'case'}' {end_switch(); is_break=3; is_default=0; prev_case=3;}
	;


case : CASE consttype ':'{ print_prev_break(); prev_case=1; case1($2); }stmt break case 
	| default
        ;


break : BREAK';' {is_break=1; break1();}
       |{is_break=0; break2();}
       ;
       
default : DEFAULT {is_default=1;print_prev_break(); default1();}':'stmt break
	| {	default1(); 
		printf("goto next%d\n",next_num); 		
		char dummy[20];
		strcpy(dummy,"next");
		my_itoa(next_num,buffer);
		strcat(dummy,buffer);
		enter_in_quad("goto","-","-",dummy);
	}
	;

//____________________________________________________________________________________________________________________

while : WHILE {while1();is_cond_while = 1;}'(' E ')' {while2();is_cond_while = 0; is_body_while = 1;} compound_statement {while3(); is_body_while = 0;}
	;

/*assignment : ID '=' consttype
	| ID '+' assignment
	| ID ',' assignment
	| consttype ',' assignment
	| ID
	| consttype
	;
*/

assignment1 : ID {push($1);} '=' {strcpy(st1[++top],"=");} E {codegen_assign();}
	{
		
		int sct=returnscope($1,stack[index1-1]);
		int type=returntype($1,sct);
		if((!(strspn($5,"0123456789")==strlen($5))) && type==258 && fl==0 && strlen($5)==1)
			printf("\nError: Type Mismatch : Line %d\n",printline());
		
		if(!lookup($1))
		{
			int currscope=stack[index1-1];
			int scope=returnscope($1,currscope);
			if((scope<=currscope && end[scope]==0) && !(scope==0))
			{
				check_scope_update($1,$5,currscope);
			}
		}
		
		if(is_body_while == 1)
	
		{
			
			int check = check_invariant($1); 
			if(check && id_indicator) printf("\nLOOP INVARIANT: %d", yylineno);
			id_indicator = 1;
				
		
		} 
	}

	| ID ',' assignment1    
	{
			if(is_body_while) 
			{
				push($1);
				myprint(check_invariant($1));
				id_indicator = 1;
			}

			if(lookup($1))
				printf("\nUndeclared Variable %s : Line %d\n",$1,printline());
	}
	| consttype ',' assignment1
	| ID  
	{
		if(is_body_while) 
			{
				push($1);
				myprint(check_invariant($1));
			}
		if(lookup($1))
			printf("\nUndeclared Variable %s : Line %d\n",$1,printline());
	}
//	| function_call
	| consttype
	;



consttype : NUM
	| REAL
	;

Declaration : Type ID {push($2);} '=' {strcpy(st1[++top],"=");} E {codegen_assign();} ';'
	{
		if( (!(strspn($6,"0123456789")==strlen($6))) && $1==258 && (fl==0) && strlen($6)==1)
		{
			printf("\nError : Type Mismatch : Line %d\n",printline());
			//fl=1;
		}
		if(!lookup($2))
		{
			int currscope=stack[index1-1];
			int previous_scope=returnscope($2,currscope);
			if(currscope==previous_scope)
				printf("\nError : Redeclaration of %s : Line %d\n",$2,printline());
			else
			{
				insert_dup($2,$1,currscope);
				check_scope_update($2,$6,stack[index1-1]);
				int sg=returnscope($2,stack[index1-1]);
				g_addr+=4;
			}
		}
		else
		{
			int scope=stack[index1-1];
			insert($2,$1);
			insertscope($2,scope);
			check_scope_update($2,$6,stack[index1-1]);
			g_addr+=4;
		}
		if(is_body_while == 1)
	
		{
			
			int check = check_invariant($2); 
			if(check && id_indicator) printf("\nLOOP INVARIANT: %d", yylineno);
			id_indicator = 1;
				
		
		} 
	}

	| assignment1 ';'  {
				if(!lookup($1))
				{
					int currscope=stack[index1-1];
					int scope=returnscope($1,currscope);
					if(!(scope<=currscope && end[scope]==0) || scope==0)
						printf("\nError : Variable %s out of scope : Line %d\n",$1,printline());
				}
				else
					printf("\nError : Undeclared Variable %s : Line %d\n",$1,printline());
				}
				
	| Type ID ';'
        {
        	if(!lookup($2))		// if identifier is in in symbol table
		{
			int currscope=stack[index1-1];
			int previous_scope=returnscope($2,currscope);
			if(currscope==previous_scope)				// check if redeclaration of identifier
				{printf("\nError : Redeclaration of %s : Line %d\n",$2,printline());errc++;}
			else							// if no redeclaration..create entry according to scope
			{
				insert_dup($2,$1,currscope);
			
			}
			

		}
		else		// if identifier is NOT in symbol table
		{
			int scope=stack[index1-1];
			
			insert($2,$1);				// create entry - incl scope
			insertscope($2,scope);
			
		}
		if(is_body_while) myprint(check_invariant($2));
	}

	| Type ID '[' consttype ']' ';' {
			int itype;
			if(!(strspn($4,"0123456789")==strlen($4))) { itype=259; } else itype = 258;
			if(itype!=258)
			{ printf("\nError : Array index must be of type int : Line %d\n",printline());errc++;}
			if(atoi($4)<=0)
			{ printf("\nError : Array index must be of type int > 0 : Line %d\n",printline());errc++;}
			if(!lookup($2))
			{
				int currscope=stack[top-1];
				int previous_scope=returnscope($2,currscope);
				if(currscope==previous_scope)
				{printf("\nError : Redeclaration of %s : Line %d\n",$2,printline());errc++;}
				else
				{
					insert_dup($2,ARRAY,currscope);
					insert_by_scope($2,$1,currscope);	//to insert type to the correct identifier in case of multiple entries of the identifier by using scope
					if (itype==258) {insert_index($2,$4);}
					update_array_size($2,currscope,atoi($4));
				}
			}
			else
			{
				int scope=stack[top-1];
				insert($2,ARRAY);
				insert($2,$1);
				insertscope($2,scope);
				if (itype==258) {insert_index($2,$4);}
				update_array_size($2,scope,atoi($4));
			}
		}

	| ID '[' assignment1 ']' ';'
	| error
	;

array : ID {push($1);}'[' E ']'
	;

E : E '+'{strcpy(st1[++top],"+");} T{codegen();}			{expression_evaluation($1,'+',$4); strcpy($$,expr_eval_res);}
   | E '-'{strcpy(st1[++top],"-");} T{codegen();}			{expression_evaluation($1,'-',$4); strcpy($$,expr_eval_res);}
   | T
   | ID {push($1);loop_variant_ids(st1[top]);if(is_body_while) myprint(check_invariant($1));} LE {strcpy(st1[++top],"<=");} E {codegen();}
   | ID {push($1);loop_variant_ids(st1[top]);if(is_body_while) myprint(check_invariant($1));} GE {strcpy(st1[++top],">=");} E {codegen();}
   | ID {push($1);loop_variant_ids(st1[top]);if(is_body_while) myprint(check_invariant($1));} EQ {strcpy(st1[++top],"==");} E {codegen();}
   | ID {push($1);loop_variant_ids(st1[top]);if(is_body_while) myprint(check_invariant($1));} NEQ {strcpy(st1[++top],"!=");} E {codegen();}
   | ID {push($1);loop_variant_ids(st1[top]);if(is_body_while) myprint(check_invariant($1));} AND {strcpy(st1[++top],"&&");} E {codegen();}
   | ID {push($1);loop_variant_ids(st1[top]);if(is_body_while) myprint(check_invariant($1));} OR {strcpy(st1[++top],"||");} E {codegen();}
   | ID {push($1);loop_variant_ids(st1[top]);if(is_body_while) myprint(check_invariant($1));} '<' {strcpy(st1[++top],"<");} E {codegen();}
   | ID {push($1);loop_variant_ids(st1[top]);if(is_body_while) myprint(check_invariant($1));} '>' {strcpy(st1[++top],">");} E {codegen();}
   | ID {push($1);} '=' {strcpy(st1[++top],"=");} E {codegen_assign();}
   | array {array1();fl=1; is_array=1;}
   ;
T : T '*'{strcpy(st1[++top],"*");} F{codegen();}			{expression_evaluation($1,'*',$4); strcpy($$,expr_eval_res);}
   | T '/'{strcpy(st1[++top],"/");} F{codegen();}			{expression_evaluation($1,'/',$4); strcpy($$,expr_eval_res);}
   | F
   ;
F : '(' E ')' {$$=$2;}
   | ID { 
   
   			// for original 3AC code START COMMENT HERE
   		int currscope=stack[index1-1];
   		char id_value[10];
   		
   		int ret_type = returntype($1,currscope);
   		
   		float id_res = find_identifier_value($1,currscope);
   		
   		if(ret_type==258)
   		{
   			int id_res_1 = (int)id_res;
   			sprintf($1, "%d", id_res_1);
   			
   		}
   		
   		else
   		{
   			sprintf($1,"%f",id_res);
   		}		// end comment here

   		push($1);fl=1;if(is_cond_while) {loop_variant_ids($1);} if(is_body_while) {if(!check_invariant($1)) id_indicator = 0;}
   		 
   		
   		}
   | consttype { push($1); $$=$1; fl=0;}	
   ;

%%

#include "lex.yy.c"
#include<ctype.h>


int main(int argc, char *argv[])
{
	yyin =fopen(argv[1],"r");
	yyparse();
	if(!yyparse())
	{
		printf("Parsing done\n");
		
		
		/*if(is_print==0 && is_void==1)
		{
			printf("\nThe entire program is dead code!\n");
		}*/
		
		display();
		display_quad();
	}
	else
	{
		printf("Error\n");
	}
	fclose(yyin);
	return 0;
}

void yyerror(char *s)
{
	printf("\nLine %d : %s %s\n",yylineno,s,yytext);
}
int printline()
{
	return yylineno;
}

