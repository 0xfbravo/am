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
	int temp1; // temp1 = 0;
	int temp2; // i
	int temp3; // temp3 = 10;
	int temp4; // temp2 < temp3
	int temp5; // temp5 = 1;
	int temp6; // temp2 + temp5
	int temp7; // temp7 = 5;
	int temp8; // temp2 > temp7
	
	/* Operations */
	temp1 = 0;
	temp2 = temp1;
	BLOCK_LABEL_2_BEGIN:
	temp3 = 10;
	temp4 = temp2 < temp3;
	if(temp4) { goto BLOCK_LABEL_2;}
	BLOCK_LABEL_2_END:
	
	/* Free memory */
	
	BLOCK_LABEL_0_END:
	return 0;

	/* Scopes Labels */
	BLOCK_LABEL_1:
	goto BLOCK_LABEL_2_BEGIN;
	goto BLOCK_LABEL_1_END;
	BLOCK_LABEL_2:
	cout << temp2 << " ";
	cout << endl;
	temp7 = 5;
	temp8 = temp2 > temp7;
	if (temp8) { goto BLOCK_LABEL_1; }
	BLOCK_LABEL_1_END:
	temp5 = 1;
	temp6 = temp2 + temp5;
	temp2 = temp6;
	goto BLOCK_LABEL_2_BEGIN;
	
}
