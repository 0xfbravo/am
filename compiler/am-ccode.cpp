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
	char* temp1; // Pre-declaration
	int temp2; // sizeof(char);
	int temp3; // MAX_BUFFER_SIZE * temp2;
	char* temp4; // String Input Buffer
	int temp5; // strlen(temp4);
	int temp6; // sizeof(char);
	int temp7; // temp5 * temp6;
	char* temp8; // temp8 = (char*) "fellipe";
	char* temp9; // temp9 = (char*) "acertou";
	int temp10; // strcmp(temp8,tempSwitch0) == 0;
	char* temp11; // temp11 = (char*) "errou";
	char* tempSwitch0; // tempSwitch = 1
	
	/* Operations */
	temp2 = sizeof(char);
	temp3 = MAX_BUFFER_SIZE * temp2;
	temp4 = (char*) malloc(temp3);
	temp5 = strlen(temp4);
	temp6 = sizeof(char);
	temp7 = temp5 * temp6;
	fgets(temp4,MAX_BUFFER_SIZE,stdin);
	temp4[strlen(temp4)-1] = 0;
	temp1 = (char*) malloc(temp7);
	strcpy(temp1,temp4);
	tempSwitch0 = temp1;
	temp8 = (char*) "fellipe";
	temp10 = strcmp(temp8,tempSwitch0) == 0;
	if(temp10) goto BLOCK_LABEL_1;
	BLOCK_LABEL_1_END:
	goto BLOCK_LABEL_2;
	BLOCK_LABEL_2_END:
	BLOCK_LABEL_3_END:
	
	/* Free memory */
	free(temp4);
	free(temp1);
	
	BLOCK_LABEL_0_END:
	return 0;

	/* Scopes Labels */
	BLOCK_LABEL_1:
	temp9 = (char*) "acertou";
	cout << temp9 << " ";
	cout << endl;
	goto BLOCK_LABEL_0_END;
	BLOCK_LABEL_2:
	temp11 = (char*) "errou";
	cout << temp11 << " ";
	cout << endl;
	
}
