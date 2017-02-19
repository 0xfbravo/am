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
	char* temp1; // temp1 = (char*) "abc";
	char* temp2; // a
	int temp3;// strlen(temp1);
	int temp4;// sizeof(char);
	int temp5;// temp3 * temp4;
	char* temp6; // temp6 = (char*) "123";
	char* temp7; // b
	int temp8;// strlen(temp6);
	int temp9;// sizeof(char);
	int temp10;// temp8 * temp9;
	int temp12; // strlen(temp2);
	int temp13; // strlen(temp7);
	int temp14; // temp12 + temp13;
	int temp15; // sizeof(char);
	int temp16; // temp14 * temp15;
	char* temp11; // temp2 . temp7
	char* temp17; // c
	int temp18;// strlen(temp11);
	int temp19;// sizeof(char);
	int temp20;// temp18 * temp19;
	
	/* Operations */
	temp1 = (char*) "abc";
	temp3 = strlen(temp1);
	temp4 = sizeof(char);
	temp5 = temp3 * temp4;
	temp2 = (char*) malloc(temp5);
	strcpy(temp2,temp1);
	temp6 = (char*) "123";
	temp8 = strlen(temp6);
	temp9 = sizeof(char);
	temp10 = temp8 * temp9;
	temp7 = (char*) malloc(temp10);
	strcpy(temp7,temp6);
	temp12 = strlen(temp2);
	temp13 = strlen(temp7);
	temp14 = temp12 + temp13;
	temp15 = sizeof(char);
	temp16 = temp14 * temp15;
	temp11 = (char*) malloc(temp16);
	strcat(temp11,temp2);
	strcat(temp11,temp7);
	temp18 = strlen(temp11);
	temp19 = sizeof(char);
	temp20 = temp18 * temp19;
	temp17 = (char*) malloc(temp20);
	strcpy(temp17,temp11);
	cout << temp17 << " ";
	cout << endl;
	
	/* Free memory */
	free(temp2);
	free(temp7);
	free(temp11);
	free(temp17);
	
	BLOCK_LABEL_0_END:
	return 0;

	/* Scopes Labels */
	
}
