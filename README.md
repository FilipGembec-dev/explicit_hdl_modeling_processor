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

INSTRUCTION SET:

    NOP -> skips 5 clock cycles 'h00   
    HLT -> sets halt flag to 1  'h01   
    
    LDA <address0> <address1> -> A <= M[{address1, address0}]  'h02   
    LDB <address0> <address1> -> B <= M[{address1, address0}]  'h03  
    ABTC -> C <= {B, A}    'h04
    ABTD -> D <= {B, A}    'h05
    CTAB -> {B, A} <= C    'h06
    DTAB -> {B, A} <= D    'h07

    STR <address0> <address1> -> M[{address1, address0}] <= A 'h08

    8ADD -> {B, A} <= A + B    'h09
    8SUB -> {B, A} <= A - B    'h0a
    8MLT -> {B, A} <= A * B    'h0b
    8DIV -> {B, A} <= A / B    'h0c
    -
    8AND -> A <= A & B         'h0d 
    8OR  -> A <= A | B         'h0e
    8XOR -> A <= A ^ B         'h0f
    8NOT -> A <= !A            'h10

    16ADD -> {D, C} <= C + D   'h11
    16SUB -> {D, C} <= C - D   'h12
    16MLT -> {D, C} <= C * D   'h13
    16DIV -> {D, C} <= C / D   'h14
    -
    16AND -> C <= C & D        'h15
    16OR  -> C <= C | D        'h16
    16XOR -> C <= C ^ D        'h17
    16NOT -> C <= !C           'h18
    
    in -> A <= in              'h19
    out -> OUT <= A            'h1a
    
    JMP <address0> <address1> -> memCNTR <= {<address0>, <address1>}   'h1b

    JCC <address0> <address1> -> if((A + B) > (2**8 - 1)) memCNTR <= {<address0>, <address1>}  'h1c
    JCZ <address0> <address1> -> if(A == 0) memCNTR <= {<address0>, <address1>}                'h1d
    JCE8 <address0> <address1> -> if(A == B) memCNTR <= {<address0>, <address1>}               'h1e
    JCE16 <address0> <address1> -> if(C == D) memCNTR <= {<address0>, <address1>}              'h1f
