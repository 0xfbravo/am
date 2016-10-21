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

/* Default Colors - Brogrammer */
#define WHITE "#ffffff"
#define OFF_WHITE "#ecf0f1"
#define DARK_GREY "#1a1a1a"
#define LIGHT_GREY "#555555"
#define MEDIUM_LIGHT_GREY "#2a2a2a"
#define MEDIUM_DARK_GREY "#222222"
#define GREEN "#2ecc71"
#define AQUA "#1abc9c"
#define RED "#e74c3c"
#define BLUE "#3498db"
#define YELLOW "#f1c40f"
#define ORANGE_RED "#e67e22"
#define PERIWINKLE "#6c71c4"

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
