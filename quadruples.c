#include<stdio.h>
#include<string.h>
struct quad
{
	char op[100];
	char arg1[100];
	char arg2[100];
	char result[100];
	int no;
}q[100];		// array of structures
int record=0;		// TOTAL number of records 


void enter_in_quad(char *op,char *arg1,char *arg2,char *result)
{
	strcpy(q[record].op,op);
	strcpy(q[record].arg1,arg1);
	strcpy(q[record].arg2,arg2);
	strcpy(q[record].result,result);
	q[record].no=record;
	
	
	//for(int i=0;i<=q[record].no;i++)
		//printf("\n%s %s %s %s\n",q[record].op,q[record].arg1,q[record].arg2,q[record].result);
		//printf("\n%s %s %s %s\n",q[i].op,q[i].arg1,q[i].arg2,q[i].result);
	
	++record;
}


void display_quad()
{
	printf("\n\n OP\t\tARG1\t\tARG2\t\tRESULT\n\n");
	
	for(int i=0;i<=record;i++)
	{
		
		printf("%s\t\t%s\t\t%s\t\t%s\n",q[i].op,q[i].arg1,q[i].arg2,q[i].result);
	}
}






