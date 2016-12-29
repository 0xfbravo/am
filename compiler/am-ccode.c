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
	// Scope
	int temp1; // temp1 = 3;
	int temp2; // b
	// Scope
	int temp3; // temp3 = 3;
	int temp4; // a
	// Scope
	int temp5; // temp5 = 4;
	int temp6; // c

	/* Operations */
	// Scope
	temp1 = 3;
	temp2 = temp1;
	// Scope
	temp3 = 3;
	temp4 = temp3;
	// Scope
	temp5 = 4;
	temp6 = temp5;

	return 0;
}
