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
	float temp1; // temp1 = 1.0;
	float temp2; // i
	int temp3; // temp3 = 10;
	float temp4; // (float) temp3;
	int temp5; // temp2 < temp4
	float temp6; // temp6 = 0.1;
	float temp7; // temp2 + temp6
	
	/* Operations */
	temp1 = 1.0;
	temp2 = temp1;
	BLOCK_LABEL_1_BEGIN:
	temp3 = 10;
	temp4 = (float) temp3;;
	temp5 = temp2 < temp4;
	if(temp5) goto BLOCK_LABEL_1;
	BLOCK_LABEL_1_END:
	
	/* Free memory */
	
	BLOCK_LABEL_0_END:
	return 0;

	/* Scopes Labels */
	BLOCK_LABEL_1:
	cout << temp2 << " ";
	cout << endl;
	temp6 = 0.1;
	temp7 = temp2 + temp6;
	temp2 = temp7;
	goto BLOCK_LABEL_1_BEGIN;
	
}
