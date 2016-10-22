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
	int temp2; // !temp1
	int temp3; // !temp2
	int temp4; // a

	// Operations
	temp1 = FALSE;
	temp2 = !temp1;
	temp3 = !temp2;
	temp4 = temp3;

	return 0;
}
