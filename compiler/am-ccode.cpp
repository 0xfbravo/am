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
	char* temp3; // temp3 = (char*) "bibi";
	char* temp4; // b
	char* temp5; // temp2 . temp4
	char* temp6; // temp6 = (char*) "eu te amo";
	char* temp7; // temp5 . temp6
	char* temp8; // c
	
	/* Operations */
	temp1 = (char*) "abc123";
	temp2 = (char*) malloc(strlen(temp1) * sizeof(char));
	strcpy(temp2,temp1);
	temp3 = (char*) "bibi";
	temp4 = (char*) malloc(strlen(temp3) * sizeof(char));
	strcpy(temp4,temp3);
	temp5 = (char*) malloc((strlen(temp2) + strlen(temp4)) * sizeof(char));
	strcat(temp5,temp2);
	strcat(temp5,temp4);
	temp6 = (char*) "eu te amo";
	temp7 = (char*) malloc((strlen(temp5) + strlen(temp6)) * sizeof(char));
	strcat(temp7,temp5);
	strcat(temp7,temp6);
	temp8 = (char*) malloc(strlen(temp7) * sizeof(char));
	strcpy(temp8,temp7);
	// Output 
	cout << temp8 << " ";
	cout << endl;
	
	/* Free memory */
	free(temp2);
	free(temp4);
	free(temp5);
	free(temp7);
	free(temp8);
	
	return 0;

	/* Scopes Labels */
	
}
