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
	int temp1; // temp1 = 2;
	int temp2; // a
	int temp3; // temp3 = 2;
	int temp4; // temp2 == temp3
	int temp6; // temp6 = TRUE;
	
	/* Operations */
	temp1 = 2;
	temp2 = temp1;
	temp3 = 2;
	temp4 = temp2 == temp3;
	if (temp4) { goto BLOCK_LABEL_3; }
	temp6 = TRUE;
	if (temp6) { goto BLOCK_LABEL_2; }
	else { goto BLOCK_LABEL_1; }
	BLOCK_LABEL_1_EXIT:
	BLOCK_LABEL_2_EXIT:
	BLOCK_LABEL_3_EXIT:
	
	/* Free memory */
	free(temp8);
	
	return 0;

	/* Scopes Labels */
	BLOCK_LABEL_1:
	int temp9; // temp9 = 990;
	int temp10; // b
	temp9 = 990;
	temp10 = temp9;
	goto BLOCK_LABEL_1_EXIT;
	BLOCK_LABEL_2:
	char* temp7; // temp7 = (char*) "string";
	char* temp8; // c
	temp7 = (char*) "string";
	temp8 = (char*) malloc(strlen(temp7) * sizeof(char));
	strcpy(temp8,temp7);
	goto BLOCK_LABEL_2_EXIT;
	BLOCK_LABEL_3:
	int temp5; // temp5 = 30;
	temp5 = 30;
	temp2 = temp5;
	goto BLOCK_LABEL_3_EXIT;
	
}
