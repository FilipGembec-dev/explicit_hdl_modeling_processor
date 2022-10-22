# Explicit_hdl_modeling_processor
This project displays designing a processor using explicit verilog expressions in the state machine.

The processor is designed to be used with the vivado deisgn suite, the assembly copiler compiles the code to vivado prendly memory file syntax.

This processor is a 8 bit machine with 16 bit arithmetic opeartions.
It has instructions for switchin data from 8 bit registers to the 16 bit registers and back.

It can do all 4 basic logic operations and all basic mathematical operations utilising a DSP block in an Artix7 FPGA for single cycle division.
The overflow of addition and multiplication is stored in the B register when writin the result to A.
The CPU is reseted trough an rst pin on the input, it is active high.
The program is loaded trough a mem file whose name(name with path if not in the same folder as the verilog file) is pased in trough a parameter 
when instatiating the processor module in a higher module.
The instructions should be writen as two digit HEX value.

It has a single 8 bit output port and single 8 bit input poer for inputing and outputing data.

Compiling the ASM.cpp will return an executable file that compiles a simple assembler for the processor. The compiler is run by passing the file name of the
assembly code file as a comand line argument. -> ./ASM tode.txt



Instruction set

    NOP -> 'h00; 
    HLT -> 'h01; 
    
    LDA 'h02;
    LDB 'h03; 
    ABTC 'h04; 
    ABTD 'h05; 
    CTAB 'h06; 
    DTAB 'h07; 

    STR 'h08;  //3 byte operation

    8ADD  'h09; 
    8SUB  'h0a; 
    8MLT  'h0b; 
    8DIV  'h0c; 
    -
    8AND  'h0d; 
    8OR   'h0e; 
    8XOR  'h0f; 
    8NOT  'h10; 

    16ADD  'h11;
    16SUB  'h12;
    16MLT  'h13;
    16DIV  'h14;
    -
    16AND  'h15;
    16OR   'h16;
    16XOR  'h17;
    16NOT  'h18;
    
    in     'h19;
    out    'h1a; 
    
    JMP    'h1b; // 3 byte operation

    JCC      'h1c; //3 byte operation
    JCZ      'h1d; //3 byte operation
    JCE8     'h1e; //3 byte operation
    JCE16    'h1f; //3 byte operation

	SW8      'h20; 
    SW16     'h21; 

    INC      'h22;
    RST      'h23;
