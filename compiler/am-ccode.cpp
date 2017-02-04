/*
     _
    /_\    /\/\
   //_\\  /    \
  /  _  \/ /\/\ \
  \_/ \_/\/    \/
*/
#include <iostream>
#include <string.h>
using namespace std;

#define TRUE 1
#define FALSE 0
#define MAX_BUFFER_SIZE 300

int main() {
	/* Declarations */
	int temp1; // temp1 = 10;
	int temp2; // a
	char* temp6; // temp6 = (char*) "string";
	char* temp7; // b
	
	/* Operations */
	temp1 = 10;
	temp2 = temp1;
	// Scope 1
	int temp3; // temp3 = 20;
	temp3 = 20;
	temp2 = temp3;
	// -- End Scope
	// Scope 2
	int temp4; // temp4 = 30;
	int temp5; // b
	temp4 = 30;
	temp5 = temp4;
	// -- End Scope
	temp6 = (char*) "string";
	temp7 = (char*) malloc(strlen(temp6) * sizeof(char));
	strcpy(temp7,temp6);
	
	/* Free memory */
	free(temp7);
	
	return 0;
}
