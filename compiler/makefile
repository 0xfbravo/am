all:
	clear
	flex am.l
	yacc -v -t -d -y am.y
	g++ -std=c++11 -x c++ y.tab.c -o am -ll
	rm -rf y.tab.c lex.yy.c
	./am < hello.am
	g++ -std=c++11 am-ccode.cpp
	./a.out
