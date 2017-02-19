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
	char* temp1; // temp1 = (char*) "abc123";
	char* temp2; // a
	int temp3;// strlen(temp1);
	int temp4;// sizeof(char);
	int temp5;// temp3 * temp4;
	
	/* Operations */
	temp1 = (char*) "abc123";
	temp3 = strlen(temp1);
	temp4 = sizeof(char);
	temp5 = temp3 * temp4;
	temp2 = (char*) malloc(temp5);
	strcpy(temp2,temp1);
	cout << temp2 << " ";
	cout << endl;
	
	/* Free memory */
	free(temp2);
	
	BLOCK_LABEL_0_END:
	return 0;

	/* Scopes Labels */
	
}
