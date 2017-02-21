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
	int temp1; // temp1 = 2;
	int temp2; // temp2 = 2;
	int temp3; // sizeof(float);
	int temp4; // temp1 * temp2;
	int temp5; // temp4 * temp3;
	float* temp6; // [temp1][temp2];
	float* temp7; // a
	int temp8; // temp8 = 1;
	int temp9; // temp9 = 1;
	int temp10; // temp10 = 100;
	float temp11; // temp11 = 3.2;
	
	float temp12; // (float) temp10;
	float temp13; // temp12 + temp11
	int temp14; // 2 * 1;
	int temp15; // 1 + temp14;
	float temp16; // temp7[temp15]
	
	/* Operations */
	temp1 = 2;
	temp2 = 2;
	temp3 = sizeof(float);
	temp4 = temp1 * temp2;
	temp5 = temp4 * temp3;
	temp6 = (float*) malloc(temp5);
	memset(temp6,0,temp5);
	temp7 = temp6;
	temp8 = 1;
	temp9 = 1;
	temp10 = 100;
	temp11 = 3.2;
	
	temp12 = (float) temp10;
	temp13 = temp12 + temp11;
	temp14 = 2 * 1;
	temp15 = 1 + temp14;
	temp7[temp15] = temp13;
	cout << temp7[ 0 + 2 * 0 ] << " ";
	cout << temp7[ 1 + 2 * 0 ] << " ";
	cout << endl;
	cout << temp7[ 0 + 2 * 1 ] << " ";
	cout << temp7[ 1 + 2 * 1 ] << " ";
	cout << endl;
	cout << endl;
	
	/* Free memory */
	free(temp6);
	
	BLOCK_LABEL_0_END:
	return 0;

	/* Scopes Labels */
	
}
