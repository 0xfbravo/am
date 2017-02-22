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

/* Functions */


int main() {
	/* Declarations */
	int temp1; // temp1 = 10;
	int temp2; // a
	char* temp3; // temp3 = (char*) "string";
	char* temp4; // a
	int temp5;// strlen(temp3);
	int temp6;// sizeof(char);
	int temp7;// temp5 * temp6;
	
	/* Operations */
	temp1 = 10;
	temp2 = temp1;
	cout << temp2 << " ";
	cout << endl;
	temp3 = (char*) "string";
	temp5 = strlen(temp3);
	temp6 = sizeof(char);
	temp7 = temp5 * temp6;
	temp4 = (char*) malloc(temp7);
	strcpy(temp4,temp3);
	cout << temp4 << " ";
	cout << endl;
	
	/* Free memory */
	free(temp4);
	
	BLOCK_LABEL_0_END:
	return 0;

	/* Scopes Labels */
	
}
