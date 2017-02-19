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
	int temp1; // temp1 = 1;
	int temp2; // a
	int temp3; // temp2 + 1;
	int temp4; // temp4 = 2;
	
	int temp5; // temp2 * temp4
	int temp6; // b
	
	/* Operations */
	temp1 = 1;
	temp2 = temp1;
	temp3 = temp2 + 1;
	temp2 = temp3;
	temp4 = 2;
	
	temp5 = temp2 * temp4;
	temp6 = temp5;
	cout << temp2 << " ";
	cout << temp6 << " ";
	cout << endl;
	
	/* Free memory */
	
	BLOCK_LABEL_0_END:
	return 0;

	/* Scopes Labels */
	
}
