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
	int temp3; // temp3 = 10;
	int temp4; // b
	float temp5; // temp5 = 20.2;
	float temp6; // c
	int temp7; // temp7 = TRUE;
	int temp8; // d
	int temp9; // temp9 = TRUE;
	int temp10; // temp10 = FALSE;
	int temp11; // temp9 || temp10
	int temp12; // e
	int temp13; // temp13 = TRUE;
	int temp14; // temp13 || temp12
	int temp15; // f
	int temp16; // temp15 && temp12
	int temp17; // g
	int temp18; // temp18 = 2;
	int temp19; // temp4 > temp18
	int temp20; // h
	float temp21; // (float) temp4
	int temp22; // temp21 <= temp6
	int temp23; // i
	int temp24; // temp24 = 1;
	int temp25; // temp25 = 2;
	int temp26; // temp24 == temp25
	int temp27; // j
	float temp28; // temp28 = 2.0;
	int temp29; // (int) temp28
	int temp30; // temp30 = 2;
	int temp31; // temp29 == temp30
	int temp32; // temp32 = 40;
	int temp33; // k
	char* temp34; // String Input Buffer
	char* temp35; // Pre-declaration
	int temp36; // Pre-declaration
	char* temp37; // temp37 = (char*) "teste";
	int temp38; // temp38 = 1;
	float temp39; // temp39 = 22.3;
	int temp40; // temp40 = TRUE;
	int temp41; // temp41 = FALSE;
	int temp42; // temp40 && temp41
	int temp43; // !temp8
	int temp44; // temp44 = 10;
	int temp45; // constante
	char* temp46; // temp46 = (char*) "abc123";
	char* temp47; // temp47 = (char*) "a";
	int temp48; // TRUE
	
	/* Operations */
	temp1 = (char*) "abc123";
	temp2 = (char*) malloc(strlen(temp1) * sizeof(char));
	strcpy(temp2,temp1);
	temp3 = 10;
	temp4 = temp3;
	temp5 = 20.2;
	temp6 = temp5;
	temp7 = TRUE;
	temp8 = temp7;
	temp9 = TRUE;
	temp10 = FALSE;
	temp11 = temp9 || temp10;
	temp12 = temp11;
	temp13 = TRUE;
	temp14 = temp13 || temp12;
	temp15 = temp14;
	temp16 = temp15 && temp12;
	temp17 = temp16;
	temp18 = 2;
	temp19 = temp4 > temp18;
	temp20 = temp19;
	temp21 = (float) temp4;
	temp22 = temp21 <= temp6;
	temp23 = temp22;
	temp24 = 1;
	temp25 = 2;
	temp26 = temp24 == temp25;
	temp27 = temp26;
	temp28 = 2.0;
	temp29 = (int) temp28;
	temp30 = 2;
	temp31 = temp29 == temp30;
	temp27 = temp31;
	temp32 = 40;
	temp33 = temp32;
	// String Buffer Init
	temp34 = (char*) malloc(MAX_BUFFER_SIZE * sizeof(char));
	// Input: a
	free(temp2);
	fgets(temp34,MAX_BUFFER_SIZE,stdin);
	temp34[strlen(temp34)-1] = 0;
	temp2 = (char*) malloc(strlen(temp34) * sizeof(char));
	strcpy(temp2,temp34);
	// Output 
	cout << temp2 << " ";
	cout << endl;
	cin >> temp36;
	// Output 
	temp37 = (char*) "teste";
	cout << temp37 << " ";
	temp38 = 1;
	cout << temp38 << " ";temp39 = 22.3;
	cout << temp39 << " ";temp40 = TRUE;
	temp41 = FALSE;
	temp42 = temp40 && temp41;
	cout << temp42 << " ";cout << endl;
	// Output 
	temp43 = !temp8;
	cout << temp43 << " ";
	cout << endl;
	temp44 = 10;
	temp45 = temp44;
	// Output 
	cout << temp45 << " ";
	cout << endl;
	// Output 
	temp46 = (char*) "abc123";
	temp47 = (char*) "a";
	temp48 = TRUE;
	cout << temp48 << " ";
	cout << endl;
	
	/* Free memory */
	free(temp2);
	free(temp34);
	
	return 0;
}
