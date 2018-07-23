#GHDL=/home/jeanlou/Outils/ghdl/bin/ghdl
GHDL=/usr/bin/ghdl
all : mem.o

mem.o : mem.vhdl
	${GHDL} -a -v mem.vhdl

clean :
	rm *.o work-obj93.cf
