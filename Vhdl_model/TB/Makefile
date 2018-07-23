#GHDL=/home/jeanlou/Outils/ghdl/bin/ghdl
GHDL=/usr/bin/ghdl
GHDL_OP = -v
C_MOD_DIR = ../../C_model/
all : main_tb

ram.o : ram.vhdl
	${GHDL} -a ${GHDL_OP} ram.vhdl

icache.o : icache.vhdl ram.o
	${GHDL} -a ${GHDL_OP} icache.vhdl

dcache.o : dcache.vhdl ram.o
	${GHDL} -a ${GHDL_OP} dcache.vhdl

main_tb.o : main_tb.vhdl icache.o dcache.o ram.o 
	${GHDL} -a ${GHDL_OP} main_tb.vhdl

arm_core.o : ../CORE/arm_core.vhdl ifetch.o decod.o exec.o mem.o
	${GHDL} -a ${GHDL_OP} ../CORE/arm_core.vhdl
	
ifetch.o : ../IFETCH/ifetch.vhdl fifo_generic.o
	${GHDL} -a ${GHDL_OP} ../IFETCH/ifetch.vhdl

decod.o : ../DECOD/decod.vhdl fifo_32b.o fifo_127b.o fifo_131b.o registre.o
	${GHDL} -a ${GHDL_OP} ../DECOD/decod.vhdl

registre.o : ../DECOD/registre.vhdl 
	${GHDL} -a ${GHDL_OP} ../DECOD/registre.vhdl

exec.o : ../EXEC/exec.vhdl fifo_74b.o alu.o shifter.o multiplier.o
	${GHDL} -a ${GHDL_OP} ../EXEC/exec.vhdl

fifo_72b.o : ../FIFO/fifo_72b.vhdl
	${GHDL} -a ${GHDL_OP} ../FIFO/fifo_72b.vhdl
	
fifo_74b.o : ../FIFO/fifo_74b.vhdl
	${GHDL} -a ${GHDL_OP} ../FIFO/fifo_74b.vhdl

fifo_32b.o : ../FIFO/fifo_32b.vhdl
	${GHDL} -a ${GHDL_OP} ../FIFO/fifo_32b.vhdl

fifo_127b.o : ../FIFO/fifo_127b.vhdl
	${GHDL} -a ${GHDL_OP} ../FIFO/fifo_127b.vhdl

fifo_129b.o : ../FIFO/fifo_129b.vhdl
	${GHDL} -a ${GHDL_OP} ../FIFO/fifo_129b.vhdl
	
fifo_131b.o : ../FIFO/fifo_131b.vhdl
	${GHDL} -a ${GHDL_OP} ../FIFO/fifo_131b.vhdl

alu.o : ../EXEC/alu.vhdl
	${GHDL} -a ${GHDL_OP} ../EXEC/alu.vhdl

shifter.o : ../EXEC/shifter.vhdl
	${GHDL} -a ${GHDL_OP} ../EXEC/shifter.vhdl

multiplier.o : ../EXEC/multiplier.vhdl
	${GHDL} -a ${GHDL_OP} ../EXEC/multiplier.vhdl

mem.o : ../MEM/mem.vhdl
	${GHDL} -a ${GHDL_OP} ../MEM/mem.vhdl

fifo_generic.o : ../FIFO/fifo_generic.vhdl
	${GHDL} -a ${GHDL_OP} ../FIFO/fifo_generic.vhdl

main_tb : main_tb.o ram.o icache.o dcache.o arm_core.o 
	${GHDL} -e ${GHDL_OP} -Wl,${C_MOD_DIR}/lib/mem.o -Wl,${C_MOD_DIR}/lib/arm_ghdl.o -Wl,${C_MOD_DIR}/ReadElf/lib/ElfObj.o main_tb

clean :
	rm *.o main_tb work-obj93.cf *.vcd
