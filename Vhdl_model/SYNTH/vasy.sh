rm -f *.v

cd ../CORE/

rm -f *.v
vasy -v -V arm_core.vhdl
mv arm_core.v ../SYNTH

cd ../DECOD

rm -f *.v

vasy -v -V decod.vhdl
vasy -v -V registre.vhdl
vasy -v -V fifo_129b.vhdl

mv decod.v ../SYNTH
mv registre.v ../SYNTH
mv fifo_129b.v ../SYNTH

cd ../FIFO

rm -f *.v

vasy -v -V fifo_32b.vhdl
vasy -v -V fifo_72b.vhdl

mv fifo_32b.v ../SYNTH
mv fifo_72b.v ../SYNTH

cd ../EXEC

rm -f *.v

vasy -v -V exec.vhdl
vasy -v -V alu.vhdl 
vasy -v -V shifter.vhdl
vasy -v -V multiplier.vhdl
vasy -v -V multiplier32c.vhdl

mv exec.v ../SYNTH
mv alu.v ../SYNTH
mv shifter.v ../SYNTH
mv multiplier.v ../SYNTH
mv multiplier32c.v ../SYNTH

cd ../IFETCH

rm -f *.v
vasy -v -V ifetch.vhdl
mv ifetch.v ../SYNTH

cd ../MEM/

rm -f *.v
vasy -v -V mem.vhdl
mv mem.v ../SYNTH
