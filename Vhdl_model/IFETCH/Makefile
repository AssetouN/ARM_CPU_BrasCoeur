#GHDL=/home/jeanlou/Outils/ghdl/bin/ghdl
GHDL=/usr/bin/ghdl
all : ifetch.o

fifo_generic.o : ../FIFO/fifo_generic.vhdl
	${GHDL} -a -v ../FIFO/fifo_generic.vhdl

ifetch.o : ifetch.vhdl fifo_generic.o
	${GHDL} -a -v ifetch.vhdl

clean :
	rm *.o work-obj93.cf
