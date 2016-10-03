all:
	flex number.l
	bison -d number.y
	gcc number.tab.c lex.yy.c -o number -lfl
