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
	char* temp1; // temp1 = (char*) "abc123";
	char* temp2; // a
	char* temp3; // String Input Buffer
	
	/* Operations */
	temp1 = (char*) "abc123";
	temp2 = (char*) malloc(strlen(temp1) * sizeof(char));
	strcpy(temp2,temp1);
	// Output 
	cout << temp2 << " ";
	cout << endl;
	// String Buffer Init
	temp3 = (char*) malloc(MAX_BUFFER_SIZE * sizeof(char));
	// Input: a
	free(temp2);
	fgets(temp3,MAX_BUFFER_SIZE,stdin);
	temp3[strlen(temp3)-1] = 0;
	temp2 = (char*) malloc(strlen(temp3) * sizeof(char));
	strcpy(temp2,temp3);
	// Output 
	cout << temp2 << " ";
	cout << endl;
	
	/* Free memory */
	free(temp2);
	free(temp3);
	
	return 0;
}
