YACC = bison

YFLAGS = -dvy
CFLAGS = -g

SRC = grammar.y scanner.l main.c list.c
OBJ = grammar.o scanner.o main.o list.o

java2pic : $(OBJ)
	cc -o $@ $(OBJ)

clean :
	rm -f y.output y.tab.* *.o *.core java2pic test_suite

test_suite : list.o
	cc $(CFLAGS) -o $@ list.o test.c
