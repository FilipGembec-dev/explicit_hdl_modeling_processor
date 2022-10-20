# explicit_hdl_modeling_processor
This project displays designing a processor using explicit verilog expressions in the state machine.

This processor is a 8 bit machine with 16 bit arithmetic opeartions.
It has instructions for switchin data from 8 bit registers to the 16 bit registers and back.

It can do all 4 basic logic operations and all basic mathematical operations utilising a DSP block in an Artix7 FPGA for single cycle division.
The overflow of addition and multiplication is stored in the B register when writin the result to A.
The program is loaded trough a mem file whose name(name with path if not in the same folder as the verilog file) is pased in trough a parameter 
when instatiating the processor module in a higher module.
The instructions should be writen as two digit HEX value.

It has a single 8 bit output port and single 8 bit input poer for inputing and outputing data.

Future versions will include an UART for comunicating and reprograming the processor, universal GPIOs, and also instructions for single bit data manipulation.
