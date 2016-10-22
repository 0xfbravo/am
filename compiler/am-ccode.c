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

// User Consts

int main() {
	// Declare
	int temp1; // temp1 = FALSE;
	int temp2; // temp2 = TRUE;
	int temp3; // temp1 || temp2
	int temp4; // temp4 = TRUE;
	int temp5; // temp3 && temp4
	int temp6; // a

	// Operations
	temp1 = FALSE;
	temp2 = TRUE;
	temp3 = temp1 || temp2;
	temp4 = TRUE;
	temp5 = temp3 && temp4;
	temp6 = temp5;

	return 0;
}
