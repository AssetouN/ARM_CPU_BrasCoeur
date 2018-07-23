#GHDL=/home/jeanlou/Outils/ghdl/bin/ghdl
GHDL=/usr/bin/ghdl
all : exec_tb

alu.o : alu.vhdl
	${GHDL} -a -v alu.vhdl

shifter.o : shifter.vhdl
	${GHDL} -a -v shifter.vhdl

fifo_72b.o : ../FIFO/fifo_72b.vhdl
	${GHDL} -a -v ../FIFO/fifo_72b.vhdl

multiplier.o : multiplier.vhdl
	${GHDL} -a -v multiplier.vhdl

exec.o : exec.vhdl alu.o shifter.o fifo_72b.o multiplier.o
	${GHDL} -a -v exec.vhdl

exec_tb.o : exec_tb.vhdl exec.o
	${GHDL} -a -v exec_tb.vhdl

exec_tb : exec_tb.o
	${GHDL} -e -v exec_tb

clean :
	rm *.o work-obj93.cf exec_tb exec_tb.vcd
