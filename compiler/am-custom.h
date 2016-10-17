/*
     _
    /_\    /\/\
   //_\\  /    \
  /  _  \/ /\/\ \
  \_/ \_/\/    \/
      Compiler

  Bianca Albuquerque, Fellipe Pimentel
  UFRRJ 2016.2
*/
#include <iostream>
#include <string>
#include <regex>
using namespace std;

/* Default Colors - Material Shell Colors - https://github.com/carloscuesta/materialshell/blob/master/colors.md */
#define BLACK "#252525"
#define RED "#FF5252"
#define GREEN "#C3D82C"
#define YELLOW "#FFD740"
#define BLUE "#40C4FF"
#define MAGENTA "#FF4081"
#define CYAN "#18FFFF"
#define WHITE "#F5F5F5"
#define TEXT "#A1B0B8"
#define BACKGROUND "#263238"

struct COLOR {
  int r;
  int g;
  int b;
};

/* Color Text for Terminal */
string colorText(string txt, COLOR c){
  if(c.r < 0 || c.g < 0 || c.b < 0 || c.r > 255 || c.g > 255 || c.b > 255){ return txt; }
  return "\033[1;38;2;" + to_string(c.r) + ";" + to_string(c.g) + ";" + to_string(c.b) + "m" + txt + "\033[21;39;49m";
}

/* Hex Color to RGB */
COLOR hexToRGB(string hex){
  hex.erase(0,1);

  string r = regex_match(hex, regex("[a-fA-F0-9]{3}")) ? hex.substr(0,1) : hex.substr(0,2);
  string g = regex_match(hex, regex("[a-fA-F0-9]{3}")) ? hex.substr(1,1) : hex.substr(2,2);
  string b = regex_match(hex, regex("[a-fA-F0-9]{3}")) ? hex.substr(2,1) : hex.substr(4,2);

  COLOR c;
  c.r = stoi(r,nullptr,16);
  c.g = stoi(g,nullptr,16);
  c.b = stoi(b,nullptr,16);

  //cout << r << " " << g << " " << b << endl;
  //cout << c.r << " " << c.g << " " << c.b << endl;
  return c;
}
