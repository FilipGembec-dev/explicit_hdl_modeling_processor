`timescale 1ns / 1ps

//instantiating the processor and other peripherals for only procesor upload
module top(input CLK100MHZ, input [7:0] IN, output [7:0] OUT);
    
    //instantiating the processor
    processor#("BOOT_ROM.mem") CPUT0 (CLK100MHZ, IN, OUT, rst);
    
    assign rst = 0;
    
endmodule


module processor#(memmoryFile = "BOOT_ROM.mem")(
    input CLK100MHZ, [7:0] IN, output reg [7:0] OUT, input rst
    );
    
    reg hltreg = 0; //halt register
    wire sys_clock; //system clock register
    assign sys_clock = CLK100MHZ &! hltreg; //anding the input clock and the inverse of the halt register
    
    //defining workign memmory
    reg [7:0] M [2**15:0]; //8 bit data buss with 16 bit address buss

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
    //16 bit register for keeping the value of memCNTR
    reg [15:0] addressKeep = 'h0000;
    

    
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
                        'h04: begin addressKeep <= memCNTR; memCNTR <= memJMP; end
                        'h05: begin A <= M[memCNTR]; memCNTR <= addressKeep; memJMP <= 'h0000; end
                    endcase
                end
                'h03: begin //LDB
                    case(T)
                        'h01: memCNTR <= memCNTR + 1;
                        'h02: begin memJMP[7:0] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                        'h03: begin memJMP[15:8] <= M[memCNTR]; memCNTR <= memCNTR + 1; end
                        'h04: begin addressKeep <= memCNTR; memCNTR <= memJMP; end
                        'h05: begin B <= M[memCNTR]; memCNTR <= addressKeep; memJMP <= 'h0000; end            
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
                        'h04: begin addressKeep <= memCNTR; memCNTR <= memJMP; end
                        'h05: begin M[memCNTR] <= A; memCNTR <= addressKeep; memJMP <= 'h0000; end
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
              'h22: begin // incrementing register
                    case(T)
                        'h01: memCNTR <= memCNTR + 1;
                        'h02: begin
                            case(M[memCNTR])
                                'h0a: A <= A + 1;
                                'h0b: B <= B + 1;
                                'h0c: C <= C + 1;
                                'h0d: D <= D + 1;
                                default: A <= A + 1;
                            endcase
                            memCNTR <= memCNTR + 1;
                        end
                    endcase
              end
              'h23: begin // reseting register
                    case(T)
                        'h01: memCNTR <= memCNTR + 1;
                        'h02: begin
                            case(M[memCNTR])
                                'h0a: A <= 0;
                                'h0b: B <= 0;
                                'h0c: C <= 0;
                                'h0d: D <= 0;
                                default: A <= 0;
                            endcase
                            memCNTR <= memCNTR + 1;
                        end
                    endcase
              end              
              default: //NOP
                    case(T)
                        'h01: memCNTR <= memCNTR + 1;
                    endcase 
                                                                 
            endcase
        end
        
        if(rst) begin   //if reset line is high redset all values in processor to 0
            OUT <= 'h0;
            hltreg <= 'h0;
            A <= 'h0;
            B <= 'h0;
            C <= 'h0;
            D <= 'h0;
            inst <= 'h0;
            memCNTR <= 'h0;
            memJMP <= 'h0;
            addressKeep <= 'h0;
        end
        

    end
    

    
endmodule
