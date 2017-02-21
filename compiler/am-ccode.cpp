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
	int temp2; // temp2 = 2;
	int temp3; // sizeof(int);
	int temp4; // temp1 * temp2;
	int temp5; // temp4 * temp3;
	int* temp6; // [temp1][temp2];
	int* temp7; // a
	int temp8; // temp8 = 1;
	int temp9; // temp9 = 2;
	int temp10; // temp10 = 10;
	int temp11; // 2 * 1;
	int temp12; // 2 + temp11;
	int temp13; // temp7[temp12]
	int temp14; // temp14 = 1;
	int temp15; // temp15 = 2;
	int temp16; // 2 * 1;
	int temp17; // 2 + temp16;
	int temp18; // temp7[temp17];
	int temp19; // c
	
	/* Operations */
	temp1 = 10;
	temp2 = 2;
	temp3 = sizeof(int);
	temp4 = temp1 * temp2;
	temp5 = temp4 * temp3;
	temp6 = (int*) malloc(temp5);
	memset(temp6,0,temp5);
	temp7 = temp6;
	temp8 = 1;
	temp9 = 2;
	temp10 = 10;
	temp11 = 2 * 1;
	temp12 = 2 + temp11;
	temp7[temp12] = temp10;
	temp14 = 1;
	temp15 = 2;
	temp16 = 2 * 1;
	temp17 = 2 + temp16;
	temp18 = temp7[temp17];
	temp19 = temp18;
	cout << temp19 << endl;
	
	/* Free memory */
	free(temp6);
	
	BLOCK_LABEL_0_END:
	return 0;

	/* Scopes Labels */
	
}
