YACC = bison

YFLAGS = -dvy
CFLAGS = -g -std=c99

SRC = grammar.y scanner.l main.c list.c symbol_table.c imdtcode.c
OBJ = grammar.o scanner.o main.o list.o symbol_table.o imdtcode.o

java2pic : $(OBJ)
	cc -o $@ $(OBJ)

clean :
	rm -f y.output y.tab.* *.o *.core java2pic test_suite

test_suite : list.o
	cc $(CFLAGS) -o $@ list.o test.c
