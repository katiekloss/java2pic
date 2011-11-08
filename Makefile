#-----------------------------------------------------------------------------
#	Makefile
#	EECS 337 Compilers Fall 2011
#	by ajk108
#
# REVISION HISTORY
#
# ajk108: Updated to work properly on FreeBSD
#
#-----------------------------------------------------------------------------

YFLAGS	= -dv
LFLAGS	=
CFLAGS	= -g

SRC	= java11.y java.l main.c
OBJ	= java11.o java.o main.o

java2pic :	$(OBJ)

java.o	: y.tab.h

clean	:
	rm -f java.c java11.c y.tab.h y.output *.o java2pic

fromtar	:
	tar xvf project_caseid.tar 

totar	:
	tar cvf project_caseid.tar Makefile java11.y java.l main.c
