#!/bin/bash
cd ../../C_model/ReadElf/src
make clean
cd ../../src
make clean
cd ../../Test_prog/C
make clean
cd ../S
make clean -
cd ../../Vhdl_model/CHIP
make clean
cd ../CORE
make clean
cd ../DECOD
make clean
cd ../EXEC
make clean
cd ../FIFO
make clean
cd ../IFETCH
make clean
cd ../MEM
make clean
cd ../TB
