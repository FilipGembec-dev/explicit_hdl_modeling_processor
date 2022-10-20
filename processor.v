`timescale 1ns / 1ps

/********************Instruction set*********************
{auxilery operations}
    NOP -> skips 5 clock cycles 'h00;   *
    HLT -> sets halt flag to 1  'h01;   *
    
{Working register operations}
    LDA <address0> <address1> -> A <= M[{address1, address0}];  'h02;   *
    LDB <address0> <address1> -> B <= M[{address1, address0}];  'h03;   *
    ABTC -> C <= {B, A};    'h04;
    ABTD -> D <= {B, A};    'h05;
    CTAB -> {B, A} <= C;    'h06;
    DTAB -> {B, A} <= D;    'h07;

{Storing data to memmory}
    STR <address0> <address1> -> M[{address1, address0}] <= A; 'h08;

{8bit arithemtic and logic operation}
    8ADD -> {B, A} <= A + B;    'h09;
    8SUB -> {B, A} <= A - B;    'h0a;
    8MLT -> {B, A} <= A * B;    'h0b;
    8DIV -> {B, A} <= A / B;    'h0c;
    -
    8AND -> A <= A & B;         'h0d; 
    8OR  -> A <= A | B;         'h0e;
    8XOR -> A <= A ^ B;         'h0f;
    8NOT -> A <= !A;            'h10;

{16 bit arithmetic and logic operations}
    16ADD -> {D, C} <= C + D;   'h11;
    16SUB -> {D, C} <= C - D;   'h12;
    16MLT -> {D, C} <= C * D;   'h13;
    16DIV -> {D, C} <= C / D;   'h14;
    -
    16AND -> C <= C & D;        'h15;
    16OR  -> C <= C | D;        'h16;
    16XOR -> C <= C ^ D;        'h17;
    16NOT -> C <= !C;           'h18;
    
{input / output opearions}
    in -> A <= in;              'h19;
    out -> OUT <= A;            'h1a; *
    
{memmory navigation operations}
    JMP <address0> <address1> -> memCNTR <= {<address0>, <address1>};   'h1b;

{conditional memmory navigation operations}
    JCC <address0> <address1> -> if((A + B) > (2**8 - 1)) memCNTR <= {<address0>, <address1>};  'h1c;
    JCZ <address0> <address1> -> if(A == 0) memCNTR <= {<address0>, <address1>};                'h1d;
    JCE8 <address0> <address1> -> if(A == B) memCNTR <= {<address0>, <address1>};               'h1e;
    JCE16 <address0> <address1> -> if(C == D) memCNTR <= {<address0>, <address1>};              'h1f;
    
******************************************************************************************/

module processor#(memmoryFile = "BOOT_ROM.mem")(
    input clock, [7:0] IN, output reg [7:0] OUT, input rst
    );
    
    reg hltreg = 0; //halt register
    wire sys_clock; //system clock register
    assign sys_clock = clock &! hltreg; //anding the input clock and the inverse of the halt register
    
    //defining workign memmory
    reg [7:0] M [((15**2)- 1):0]; //8 bit data buss with 16 bit address buss

    initial begin //pasting the values from a premade memmory file to the working memmory
        $readmemh(memmoryFile, M, 1, 2**16 - 1);
        OUT <= 'h00;    //making the initial value of the output port
    end
    //defining working registers
    reg [7:0] A = 'h00;  //memmory interfacing accumulator
    reg [7:0] B = 'h00;  //second opperand for 8 bit logicArithmetic operations
    reg [15:0] C = 'h0000; //16 bit register for 16 bit arithmetics and floating point arithemtics -> can be writen to by operation c <= {b, a}
    reg [15:0] D = 'h0000; //second opperand for accomodating 16 bit arithmetics -> can be write to by D <= C
    
    //intruction register
    reg [7:0] inst = 'h00;
    
    //memmory counter
    reg [15:0] memCNTR = 'h0000;
    //16 bit register for storing the memmory to jump to
    reg [15:0] memJMP = 'h0000;
    

    
    //state machine for adding function and time domain to processor elements
    reg [3:0] T = 'h00; //register for keeping the time domain of state machine
    always@(posedge (sys_clock ^ rst))begin
        if(!rst) begin  //if reset line is low execute processor operations
            T <= T + 1;
            case(T) //instruction fetch
                'h00: inst = M[memCNTR];
            endcase;
            
            case(inst)
                'h00:begin //NOP
                    case(T)
                        'h01: memCNTR <= memCNTR + 1;
                    endcase
                end
                'h01: begin //HLT
                    case(T)
                        'h01: hltreg <= 1;
                    endcase
                end
                /**************************************************************************/
                'h02: begin //LDA
                    case(T)
                        'h01: memCNTR <= memCNTR + 1;
                        'h02: begin memJMP[7:0] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                        'h03: begin memJMP[15:8] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                        'h04: begin A <= M[memJMP]; memJMP <= 'h0000; end
                    endcase
                end
                'h03: begin //LDB
                    case(T)
                        'h01: memCNTR <= memCNTR + 1;
                        'h02: begin memJMP[7:0] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                        'h03: begin memJMP[15:8] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                        'h04: begin B <= M[memJMP]; memJMP <= 'h0000; end                    
                    endcase
                end
                'h04: begin //ABTC
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; C <= {B, A}; end
                    endcase
                end
                'h05: begin //ABTD
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; D <= {B, A}; end
                    endcase
                end    
                'h06: begin //CTAB
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; {B, A} <= C; end
                    endcase
                 end
                'h07: begin //DTAB
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; {B, A} <= D; end
                    endcase
                end
                'h08: begin //STR
                    case(T)
                        'h01: memCNTR <= memCNTR + 1;
                        'h02: begin memJMP[7:0] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                        'h03: begin memJMP[15:8] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                        'h04: begin M[memJMP] <= A; memJMP <= 'h0000; end
                    endcase
                end      
                /**************************************************************************/      
                'h09: begin //8ADD
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; {B, A} <= A + B; end
                    endcase
                end
                'h0a: begin //8SUB
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; {B, A} <= A - B; end
                    endcase
                end
                'h0b: begin //8MLT
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; {B, A} <= A * B; end
                    endcase
                end
                'h0c: begin //8DIV
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; {B, A} <= A / B; end
                    endcase
                end  
               'h0d: begin //8and     
                   case(T)
                        'h01: begin memCNTR <= memCNTR + 1; A <= A & B; end
                   endcase   
               end
               'h0e: begin //8or
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; A <= A | B; end
                    endcase
               end        
               'h0f: begin //8xor
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; A <= A ^ B; end
                    endcase
               end    
               'h10: begin //8not
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; A <= !A; end
                    endcase
               end   
               /*--------------------------------------------------------------------------*/
                'h11: begin //16ADD
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; {D, C} <= C + D; end
                    endcase
                end
                'h12: begin //16SUB
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; {D, C} <= C - D; end
                    endcase
                end
                'h13: begin //16MLT
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; {D, C} <= C * D; end
                    endcase
                end
                'h14: begin //16DIV
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; {D, C} <= C / D; end
                    endcase
                end  
               'h15: begin //16and     
                   case(T)
                        'h01: begin memCNTR <= memCNTR + 1; C <= C & D; end
                   endcase   
               end
               'h16: begin //16or
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; C <= C | D; end
                    endcase
               end        
               'h17: begin //16xor
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; C <= C ^ D; end
                    endcase
               end    
               'h18: begin //16not
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; C <= !C; end
                    endcase
               end   
               /***************************************************************************/
               'h19: begin //in
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; A <= IN; end
                    endcase
               end        
               'h1a: begin //out
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; OUT <= A; end
                    endcase
               end    
               /***************************************************************************/
               'h1b: begin //JMP
                    case(T)
                        'h01: memCNTR <= memCNTR + 1;
                        'h02: begin memJMP[7:0] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                        'h03: begin memJMP[15:8] <= M[memCNTR]; end
                        'h04: begin memCNTR <= memJMP; memJMP <= 'h0000; end
                    endcase
               end  
              /****************************************************************************/
              'h1c: begin // JCC
                        if((A + B) > (2**8 - 1)) begin
                            case(T)
                                'h01: memCNTR <= memCNTR + 1;
                                'h02: begin memJMP[7:0] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                                'h03: begin memJMP[15:8] <= M[memCNTR]; end
                                'h04: begin memCNTR <= memJMP; memJMP <= 'h0000; end         
                            endcase           
                        end
                        else begin
                            case(T)
                                'h01: memCNTR <= memCNTR + 1;
                                'h02: memCNTR <= memCNTR + 1;
                                'h03: memCNTR <= memCNTR + 1; 
                            endcase
                        end
              end
              'h1d: begin // JCZ
                        if(A == 0) begin
                            case(T)
                                'h01: memCNTR <= memCNTR + 1;
                                'h02: begin memJMP[7:0] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                                'h03: begin memJMP[15:8] <= M[memCNTR]; end
                                'h04: begin memCNTR <= memJMP; memJMP <= 'h0000; end         
                            endcase           
                        end
                        else begin
                            case(T)
                                'h01: memCNTR <= memCNTR + 1;
                                'h02: memCNTR <= memCNTR + 1;
                                'h03: memCNTR <= memCNTR + 1; 
                            endcase
                        end
              end          
              'h1e: begin // JCE8
                        if(A == B) begin
                            case(T)
                                'h01: memCNTR <= memCNTR + 1;
                                'h02: begin memJMP[7:0] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                                'h03: begin memJMP[15:8] <= M[memCNTR]; end
                                'h04: begin memCNTR <= memJMP; memJMP <= 'h0000; end         
                            endcase           
                        end
                        else begin
                            case(T)
                                'h01: memCNTR <= memCNTR + 1;
                                'h02: memCNTR <= memCNTR + 1;
                                'h03: memCNTR <= memCNTR + 1; 
                            endcase
                        end
              end          
              'h1f: begin // JCE16
                        if(C == D) begin
                            case(T)
                                'h01: memCNTR <= memCNTR + 1;
                                'h02: begin memJMP[7:0] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                                'h03: begin memJMP[15:8] <= M[memCNTR]; end
                                'h04: begin memCNTR <= memJMP; memJMP <= 'h0000; end         
                            endcase           
                        end
                        else begin
                            case(T)
                                'h01: memCNTR <= memCNTR + 1;
                                'h02: memCNTR <= memCNTR + 1;
                                'h03: memCNTR <= memCNTR + 1; 
                            endcase
                        end
              end   
              'h20: begin // 8 bit register switch
                    case(T)
                        'h01: begin memCNTR <= memCNTR + 1; A <= B; B <= A; end
                    endcase
              end
              'h21: begin // 16 bit register switch
                    case(T) 
                        'h01: begin memCNTR <= memCNTR + 1; C <= D; D <= C; end
                    endcase       
              end
    
              default: //NOP
                    case(T)
                        'h01: memCNTR <= memCNTR + 1;
                    endcase 
                                                                 
            endcase
        end
        
        if(rst) begin   //if reset line is high redset all values in processor to 0
            hltreg <= 'h0;
            A <= 'h0;
            B <= 'h0;
            C <= 'h0;
            D <= 'h0;
            inst <= 'h0;
            memCNTR <= 'h0;
            memJMP <= 'h0;
        end
        

    end
    
    
endmodule
