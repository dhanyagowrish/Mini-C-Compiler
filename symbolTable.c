#include<stdio.h>
#include<string.h>
struct sym
{
	int sno;			// s.no of identifier in table
	char token[100];		// identifier Name 
	int type[100];			// Type of a Identifier in every scope
	int tn;			// number of tokens		
	float fvalue;	
	int index;			// insert INDEX for array
	int scope;			// keeps track of SCOPE
	int storage;			//keeps track of STORAGE
}st[100];		// array of structures
int n=0;		// TOTAL number of identifier names
int arr[10];	
int tnp;
int ret_type;	// return type of MAIN function


// return RETURN TYPE of function
int returntype_func()
{
	return ret_type;
}

// add return type of main function to ret_type variable
void storereturn(int return_type)
{
	ret_type = return_type;
	return;
}

void insertscope(char *a,int s)
{
	int i;
	for(i=0;i<n;i++)
	{
		if(!strcmp(a,st[i].token))
		{
			st[i].scope=s;
			st[i].storage=4;
			break;
		}
		
		
	}
}

/* a = Identifier Name
   cs = current scope 
*/

// returns PREVIOUS SCOPE of Identifier
int returnscope(char *a,int cs)
{
	int i;
	int max = 0;
	for(i=0;i<=n;i++)
	{
		if(!strcmp(a,st[i].token) && cs>=st[i].scope)	// when we find the Identifier in symbol table.. check if scope of Identifier is GREATER than current_scope(cs)
		{
			if(st[i].scope>=max)			// max stores the most previous/most recent scope 	
				max = st[i].scope;
		}
	}
	return max;
}


int lookup(char *a)
{
	int i;
	for(i=0;i<n;i++)
	{
		if( !strcmp( a, st[i].token) )	// FOUND in symbol table
			return 0;
	}
	return 1;		// not in symbol table
}

/*
	a = Identifier name
	sc = current scope 
*/

// return the TYPE of the identifier given the scope of the identifier
int returntype(char *a,int sct)
{
	int i;
	for(i=0;i<n;i++)
	{
		if(!strcmp(a,st[i].token) && st[i].scope==sct)
			return st[i].type[0];
	}
}





/* a= Identifier name
   b= Value of identifier
   sc=current scope
 */
 // find identifier of the current scope and update the value associated with it
void check_scope_update(char *a,char *b,int sc)
{
	int i,j,k;
	int max=0;
	
	for(i=0;i<=n;i++)			// find most recent scope of the identifier
	{
		if(!strcmp(a,st[i].token)   && sc>=st[i].scope)
		{
			if(st[i].scope>=max)
				max=st[i].scope;
		}
	}
	
	for(i=0;i<=n;i++)
	{
		if(!strcmp(a,st[i].token)   && max==st[i].scope)	// find identifier and update the value
		{
			float temp=atof(b);
			for(k=0;k<st[i].tn;k++)
			{
				if(st[i].type[k]==258)
					st[i].fvalue=(int)temp;	// type cast to int if the identifier is of type INT 
				else
					st[i].fvalue=temp;
			}
		}
	}
}


void storevalue(char *a,char *b,int s_c)
{
	int i;
	for(i=0;i<=n;i++)
	{
		if(!strcmp(a,st[i].token) && s_c==st[i].scope)
		{
			st[i].fvalue=atof(b);
		}
	}
}



/* name = Identifier
   type = token_name 
*/
void insert(char *name, int type)
{
	int i;
	if(lookup(name))	// if the identifier is NOT in the symbol table
	{
		strcpy(st[n].token,name);	// adds identifier name
		st[n].tn=1;
		st[n].type[st[n].tn-1]=type;
		st[n].sno=n+1;
		st[n].storage=4;
		n++;
	}
	else		// identifier is found in symbol table..search the table
	{
		for(i=0;i<n;i++)
		{
			if(!strcmp(name,st[i].token))
			{
				st[i].tn++;
				st[i].type[st[i].tn-1]=type; 	// add the (identifier type) token_name of the identifier
				break;
			}
		}
	}

	return;
}

/* name = Identifier name
   type = Type of identifier
   s_c = current scope
 */
 
void insert_dup(char *name, int type, int s_c)
{
	strcpy(st[n].token,name);
	st[n].tn=1;
	st[n].type[st[n].tn-1]=type;
	st[n].sno=n+1;
	st[n].scope=s_c;
	st[n].storage=4;
	n++;
	return;
}

void insert_by_scope(char *name, int type, int s_c)
{
 	int i;
	for(i=0;i<n;i++)
 	{
  		if(!strcmp(name,st[i].token) && st[i].scope==s_c)
  		{
   			st[i].tn++;
   			st[i].type[st[i].tn-1]=type;
   			st[n].storage=4;
  		}
 	}
}


void insert_index(char *name,char* ind)
{
 	int i;
 	for(i=0;i<n;i++)
 	{
  		if(!strcmp(name,st[i].token) && st[i].type[0]==271)
  		{
   			st[i].index = atoi(ind);
   			st[n].storage=4;
  		}
	}
}



/* a= Identifier name
   sc=current scope
 */
 // return the relevant IDENTIFIER VALUE associated with the passed IDENTIFIERE
 
float find_identifier_value(char *a,int sc)
{
	int i,j,k;
	int max=0;
	
	for(i=0;i<=n;i++)			// find most recent scope of the identifier
	{
		if(!strcmp(a,st[i].token)   && st[i].scope<=sc)
		{
		
			if(st[i].scope>=max)
			{
				max=st[i].scope;
				
			}
		}
	}
	
	
	
	
	
	for(i=0;i<=n;i++)
	{
		if(!strcmp(a,st[i].token)   && max==st[i].scope)	// find identifier and update the value
		{
			
			//for(k=0;k<st[i].tn;k++)
			//{
					
					return st[i].fvalue;
				
			//}
		}
	}
}



void update_array_size(char *a, int sc,int arr_size)
{
	for(int i=0;i<=n;i++)
	{
		if(!strcmp(a,st[i].token)   && sc==st[i].scope)	// find identifier and update the value
		{
			st[i].storage=4*arr_size;
			//printf("\nOMG STORAGE %d",st[i].storage);
		}
	}
}	





void display()
{
	int i,j;
	printf("\n");
	printf("-------------------------------------------------------Symbol Table-----------------------------------------------------------\n");
	printf("\nSl.No\tIdentifier\tScope\t\tValue\t\tType\t\tStorage\n");
	printf("------------------------------------------------------------------------------------------------------------------------------\n\n");
	for(i=0;i<n;i++)
	{
		if(st[i].type[0]==258 || st[i].type[1]==258 || st[i].type[1]==260)
			printf("%d\t%s\t\t%d\t\t%d\t",st[i].sno,st[i].token,st[i].scope,(int)st[i].fvalue);
		else
			printf("%d\t%s\t\t%d\t\t%.2f\t",st[i].sno,st[i].token,st[i].scope,st[i].fvalue);
                printf("\t");
		for(j=0;j<st[i].tn;j++)
		{
			if(st[i].type[j]==258)
				printf("INT");
			else if(st[i].type[j]==259)
				printf("FLOAT");
			else if(st[i].type[j]==270)
				{printf("MAIN FUNCTION");
				st[i].storage=0;}
			else if(st[i].type[j]==271)
				printf("ARRAY");
			else if(st[i].type[j]==260)
				printf("VOID");
                       if(st[i].tn>1 && j<(st[i].tn-1))printf(" - ");
		}
                printf("\t\t%d",st[i].storage);
		printf("\n");
	}
	//printf(n);
	printf("------------------------------------------------------------------------------------------------------------------------------\n\n");
	return;
}

