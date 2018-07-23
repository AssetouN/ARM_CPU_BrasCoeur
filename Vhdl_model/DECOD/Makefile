#GHDL=/home/jeanlou/Outils/ghdl/bin/ghdl
GHDL=/usr/bin/ghdl
all : decod.o

registre.o : registre.vhdl
	${GHDL} -a -v registre.vhdl

fifo_129b.o : fifo_129b.vhdl
	${GHDL} -a -v fifo_129b.vhdl

fifo_32b.o : fifo_32b.vhdl
	${GHDL} -a -v fifo_32b.vhdl

decod.o : decod.vhdl registre.o fifo_129b.o fifo_32b.o
	${GHDL} -a -v decod.vhdl

#exec_tb.o : exec_tb.vhdl exec.o
#	${GHDL} -a -v exec_tb.vhdl
#
#exec_tb : exec_tb.o
#	${GHDL} -e -v exec_tb

clean :
	rm *.o work-obj93.cf
