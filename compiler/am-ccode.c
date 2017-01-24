/*
     _
    /_\    /\/\
   //_\\  /    \
  /  _  \/ /\/\ \
  \_/ \_/\/    \/
*/
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define TRUE 1
#define FALSE 0

int main() {
	/* Declarations */
	char* temp1; // strcpy(temp1,"abc123");
	char* temp2; // a
	char* temp3; // strcpy(temp3,"bac");
	
	/* Operations */
	strcpy(temp1,"abc123");
	temp2 = temp1;
	strcpy(temp3,"bac");
	temp2 = temp3;
	
	return 0;
}
