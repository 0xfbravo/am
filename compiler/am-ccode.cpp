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

int main() {
	/* Declarations */
	char* temp1; // Pre-declaration
	char* temp2; // Pre-declaration
	char* temp3; // String Input Buffer
	
	/* Operations */
	temp3 = (char*) malloc(300 * sizeof(char));
	fgets(temp3,300,stdin);
	temp3[strlen(temp3)-1] = 0;
	strcpy(temp1,temp3);
	cout << strlen(temp1) << endl;
	cout << temp1 << " ";
	cout << endl;
	fgets(temp3,300,stdin);
	temp3[strlen(temp3)-1] = 0;
	strcpy(temp2,temp3);
	cout << strlen(temp2) << endl;
	cout << temp2 << " ";
	cout << endl;
	/* Free memory */
	free(temp3);
	
	return 0;
}
