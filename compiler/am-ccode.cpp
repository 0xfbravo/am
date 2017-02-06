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
	
	/* Operations */
	BLOCK_LABEL_1_DO:
	int temp1; // temp1 = 1;
	int temp2; // temp2 = 1;
	int temp3; // temp1 + temp2
	// Output 
	temp1 = 1;
	temp2 = 1;
	temp3 = temp1 + temp2;
	cout << temp3 << " ";
	cout << endl;
	goto BLOCK_LABEL_1_WHILE;
	BLOCK_LABEL_1_DO_WHILE_EXIT:
	
	/* Free memory */
	
	return 0;

	/* Scopes Labels */
	BLOCK_LABEL_1_WHILE:
	int temp4; // temp4 = TRUE;
	temp4 = TRUE;
	if(temp4) { goto BLOCK_LABEL_1_DO; } 
	goto BLOCK_LABEL_1_DO_WHILE_EXIT;
	
}
