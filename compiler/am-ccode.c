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
	float temp1; // temp1 = 2.2;
	float temp2; // c
	
	char* temp3; // Pre-declaration
	
	
	
	/* Operations */
	temp1 = 2.2;
	temp2 = temp1;
	
	temp3 = malloc(100 * sizeof(char));
	scanf("%s",temp3);
	printf("%s ",temp3);
	
	printf("%f ",temp2);
	printf("\n");
	/* Free memory */
	
	
	free(temp3);
	return 0;
}
