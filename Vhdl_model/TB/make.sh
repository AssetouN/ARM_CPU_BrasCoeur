#!/bin/bash
cd ../../C_model/ReadElf/src
make clean
make
cd ../../src
make clean
make 
cd ../../Test_prog/C
make clean
make 
cd ../S
make clean 
make
cd ../../Vhdl_model/TB