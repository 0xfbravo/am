all:
	clear
	flex am.l
	bison -v -t -d -y am.y
	g++ -std=c++11 y.tab.c -o am -lfl
	rm -rf y.tab.c lex.yy.c
	./am < hello.am
