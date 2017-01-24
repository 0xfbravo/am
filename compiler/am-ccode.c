/*
     _
    /_\    /\/\
   //_\\  /    \
  /  _  \/ /\/\ \
  \_/ \_/\/    \/
*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#define TRUE 1
#define FALSE 0

int main() {
	/* Declarations */
	int temp1; // temp1 = TRUE;
	int temp2; // temp2 = FALSE;
	int temp3; // temp1 && temp2
	int temp4; // c
	int temp5; // temp5 = 5;
	float temp6; // temp6 = 2.3;
	char* temp7; // temp7 = "hello";
	
	int temp8; // temp8 = FALSE;
	
	/* Operations */
	temp1 = TRUE;
	temp2 = FALSE;
	temp3 = temp1 && temp2;
	temp4 = temp3;
	temp5 = 5;
	printf("%d ",temp5);
	temp6 = 2.3;
	printf("%f ",temp6);
	temp7 = "hello";
	printf("%s ",temp7);
	
	printf("%d ",temp4);
	temp8 = FALSE;
	printf("%d ",temp8);
	printf("\n");
	return 0;
}
