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
	int temp3; // temp3 = 10;
	int temp4; // temp2 <= temp3
	char* temp7; // temp7 = (char*) "abc123";
	char* temp8; // temp8 = (char*) "aa";
	char* temp9; // temp9 = (char*) "123";
	float temp10; // temp10 = 123.34;
	int temp5; // temp5 = 1;
	
	/* Operations */
	temp1 = 1;
	temp2 = temp1;
	BLOCK_LABEL_1_EXIT:
	temp3 = 10;
	temp4 = temp2 <= temp3;
	if(temp4) { goto BLOCK_LABEL_1; } 
	// Output 
	temp7 = (char*) "abc123";
	cout << temp7 << " ";
	temp8 = (char*) "aa";
	cout << temp8 << " ";
	temp9 = (char*) "123";
	cout << temp9 << " ";
	temp10 = 123.34;
	cout << temp10 << " ";
	temp5 = 1;
	cout << endl;
	
	/* Free memory */
	
	return 0;

	/* Scopes Labels */
	BLOCK_LABEL_1:
	int temp5; // temp5 = 1;
	int temp6; // temp2 + temp5
	// Output 
	cout << temp2 << " ";
	cout << endl;
	temp5 = 1;
	temp6 = temp2 + temp5;
	temp2 = temp6;
	goto BLOCK_LABEL_1_EXIT;
	
}
