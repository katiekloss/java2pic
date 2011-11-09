YACC = bison

YFLAGS = -dvy
CFLAGS = -g

SRC = grammar.y main.c scanner.l
OBJ = grammar.o main.o scanner.o

java2pic : $(OBJ)
	cc -o $@ $(OBJ)

clean :
	rm -f y.output y.tab.* *.o java2pic
