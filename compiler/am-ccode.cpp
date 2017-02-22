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
	int temp2; // acertou
	int temp3; // temp3 = 0;
	int temp4; // i
	int temp5; // temp5 = 10;
	int temp6; // temp4 < temp5
	int temp7; // temp4 + 1;
	int temp8; // temp2 + 1;
	
	/* Operations */
	temp1 = 10;
	temp2 = temp1;
	cout << temp2 << " ";
	cout << endl;
	temp3 = 0;
	temp4 = temp3;
	BLOCK_LABEL_1_BEGIN:
	temp5 = 10;
	temp6 = temp4 < temp5;
	if(temp6) goto BLOCK_LABEL_1;
	BLOCK_LABEL_1_END:
	cout << temp2 << " ";
	cout << endl;
	
	/* Free memory */
	
	BLOCK_LABEL_0_END:
	return 0;

	/* Scopes Labels */
	BLOCK_LABEL_1:
	temp8 = temp2 + 1;
	temp2 = temp8;
	cout << temp2 << " ";
	cout << endl;
	temp7 = temp4 + 1;
	temp4 = temp7;
	goto BLOCK_LABEL_1_BEGIN;
	
}
