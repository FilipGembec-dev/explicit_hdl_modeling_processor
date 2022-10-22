#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <string>
#include <algorithm>

using namespace std;

string dec_to_hex(int decimal) {
  int remainder, product = 1;
  string hex_dec = "";
  while (decimal != 0) {
    remainder = decimal % 16;
    char ch;
    if (remainder >= 10)
      ch = remainder + 55;
    else
      ch = remainder + 48;
    hex_dec += ch;
  
    decimal = decimal / 16;
    product *= 10;
  }
  reverse(hex_dec.begin(), hex_dec.end());

  return hex_dec;
}


int main(int argc, char *argv[]){

    if(argc > 2){
        cout << "Too many arguments" << endl;
        return 0;
    }

    //instantiating an output file object
    fstream mem_file;
    mem_file.open("mem.mem", ios::out); // creating the memory file
    
    fstream code_file; 


    code_file.open(argv[1],ios::in);   
    if(!code_file) {
        cout<<"No such file: " << argv[1] << endl;
        goto exit; 
    } 
    else { 
        unsigned int memmory_index = 0;
        string ch = ""; 
        string number = "";
        int int_number;

        while (!code_file.eof()) {
            code_file >> ch;
            if(ch == "@"){
                string where, what;
                code_file >> where;
                code_file >> what;

                what = dec_to_hex(stoi(what));
                    if( what.size() == 1)
                        what = "0" + what;  
                    if( what.size() > 2){
                        cout << "Number too big " << what << endl;
                        goto exit;
                    }  
                mem_file << "@"; mem_file << where << " "; mem_file << what << endl;
            }
            else if(ch == "LDA"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++;
                mem_file << "02" << endl;
                code_file >> number;
                int_number = stoi(number);
                string output_hex = "0000";
                output_hex = dec_to_hex(int_number);
                    if( output_hex.size() == 1)
                        output_hex = "000" + output_hex;
                    if( output_hex.size() == 2)
                        output_hex = "00" + output_hex;
                    if( output_hex.size() == 3)
                        output_hex = "0" + output_hex;   
                    if( output_hex.size() > 4){
                        cout << "Number too big " << int_number << endl;
                        goto exit;
                    }     
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++;    
                mem_file << output_hex[2] << output_hex[3] << endl;
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++;
                mem_file << output_hex[0] << output_hex[1] << endl;
            }   
            else if(ch == "LDB"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "03" << endl;
                code_file >> number;
                int_number = stoi(number);
                string output_hex = "0000";
                output_hex = dec_to_hex(int_number);
                    if( output_hex.size() == 1)
                        output_hex = "000" + output_hex;
                    if( output_hex.size() == 2)
                        output_hex = "00" + output_hex;
                    if( output_hex.size() == 3)
                        output_hex = "0" + output_hex;   
                    if( output_hex.size() > 4){
                        cout << "Number too big " << int_number << endl;
                        goto exit;
                    }     
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << output_hex[2] << output_hex[3] << endl;
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << output_hex[0] << output_hex[1] << endl;
            }   
            else if(ch == "NOP"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "00" << endl;
            }   
            else if(ch == "HLT"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "01" << endl;
            }
            else if(ch == "ABTC"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "04" << endl;
            }
            else if(ch == "ABTD"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "05" << endl;
            }
            else if(ch == "CTAB"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "06" << endl;
            }
            else if(ch == "DTAB"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "07" << endl;
            }
            else if(ch == "STR"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "08" << endl;
                code_file >> number;
                int_number = stoi(number);
                string output_hex = "0000";
                output_hex = dec_to_hex(int_number);
                    if( output_hex.size() == 1)
                        output_hex = "000" + output_hex;
                    if( output_hex.size() == 2)
                        output_hex = "00" + output_hex;
                    if( output_hex.size() == 3)
                        output_hex = "0" + output_hex;   
                    if( output_hex.size() > 4){
                        cout << "Number too big " << int_number << endl;
                        goto exit;
                    }     
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << output_hex[2] << output_hex[3] << endl;
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << output_hex[0] << output_hex[1] << endl;
            }  
            else if(ch == "8ADD"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "09" << endl;
            }
            else if(ch == "8SUB"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "0a" << endl;
            }
            else if(ch == "8MLT"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "0b" << endl;
            }
            else if(ch == "8DIV"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "0c" << endl;
            }
            else if(ch == "8AND"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "0d" << endl;
            }
            else if(ch == "8OR"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "0e" << endl;
            }
            else if(ch == "8XOR"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "0f" << endl;
            }
            else if(ch == "8NOT"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "10" << endl;
            }
            else if(ch == "16ADD"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "11" << endl;
            }
            else if(ch == "16SUB"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "12" << endl;
            }
            else if(ch == "16MLT"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "13" << endl;
            }
            else if(ch == "16DIV"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "14" << endl;
            }
            else if(ch == "16AND"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "15" << endl;
            }
            else if(ch == "16OR"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "16" << endl;
            }
            else if(ch == "16XOR"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "17" << endl;
            }
            else if(ch == "16NOT"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "18" << endl; 
            }
            else if(ch == "IN"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "19" << endl;
            }
            else if(ch == "OUT"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "1a" << endl;
            }
            else if(ch == "JMP"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "1b" << endl;
                code_file >> number;
                int_number = stoi(number);
                string output_hex = "0000";
                output_hex = dec_to_hex(int_number);
                    if( output_hex.size() == 1)
                        output_hex = "000" + output_hex;
                    if( output_hex.size() == 2)
                        output_hex = "00" + output_hex;
                    if( output_hex.size() == 3)
                        output_hex = "0" + output_hex;   
                    if( output_hex.size() > 4){
                        cout << "Number too big " << int_number << endl;
                        goto exit;
                    }     
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << output_hex[2] << output_hex[3] << endl;
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << output_hex[0] << output_hex[1] << endl;
            }  
            else if(ch == "JCC"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "1c" << endl;
                code_file >> number;
                int_number = stoi(number);
                string output_hex = "0000";
                output_hex = dec_to_hex(int_number);
                    if( output_hex.size() == 1)
                        output_hex = "000" + output_hex;
                    if( output_hex.size() == 2)
                        output_hex = "00" + output_hex;
                    if( output_hex.size() == 3)
                        output_hex = "0" + output_hex;   
                    if( output_hex.size() > 4){
                        cout << "Number too big " << int_number << endl;
                        goto exit;
                    }     
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++;     
                mem_file << output_hex[2] << output_hex[3] << endl;
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << output_hex[0] << output_hex[1] << endl;
            }  
            else if(ch == "JCZ"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "1d" << endl;
                code_file >> number;
                int_number = stoi(number);
                string output_hex = "0000";
                output_hex = dec_to_hex(int_number);
                    if( output_hex.size() == 1)
                        output_hex = "000" + output_hex;
                    if( output_hex.size() == 2)
                        output_hex = "00" + output_hex;
                    if( output_hex.size() == 3)
                        output_hex = "0" + output_hex;   
                    if( output_hex.size() > 4){
                        cout << "Number too big " << int_number << endl;
                        goto exit;
                    }     
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << output_hex[2] << output_hex[3] << endl;
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << output_hex[0] << output_hex[1] << endl;
            }  
            else if(ch == "JCE8"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "1e" << endl;
                code_file >> number;
                int_number = stoi(number);
                string output_hex = "0000";
                output_hex = dec_to_hex(int_number);
                    if( output_hex.size() == 1)
                        output_hex = "000" + output_hex;
                    if( output_hex.size() == 2)
                        output_hex = "00" + output_hex;
                    if( output_hex.size() == 3)
                        output_hex = "0" + output_hex;   
                    if( output_hex.size() > 4){
                        cout << "Number too big " << int_number << endl;
                        goto exit;
                    }
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++;          
                mem_file << output_hex[2] << output_hex[3] << endl;
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << output_hex[0] << output_hex[1] << endl;
            } 
            else if(ch == "JCE16"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "1f" << endl;
                code_file >> number;
                int_number = stoi(number);
                string output_hex = "0000";
                output_hex = dec_to_hex(int_number);
                    if( output_hex.size() == 1)
                        output_hex = "000" + output_hex;
                    if( output_hex.size() == 2)
                        output_hex = "00" + output_hex;
                    if( output_hex.size() == 3)
                        output_hex = "0" + output_hex;   
                    if( output_hex.size() > 4){
                        cout << "Number too big " << int_number << endl;
                        goto exit;
                    } 
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++;         
                mem_file << output_hex[2] << output_hex[3] << endl;
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << output_hex[0] << output_hex[1] << endl;
            }  
            else if(ch == "SW8"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "20" << endl;
            }
            else if(ch == "SW16"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "21" << endl;
            }
            else if(ch == "INC"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "22" << endl;
                code_file >> number;
                    if( number.size() == 1)
                        number = "0" + number; 
                    if( number.size() > 2){
                        cout << "Number too big " << int_number << endl;
                        goto exit;
                    }
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++;         
                mem_file << number[0] << number[1] << endl;
            }   
            else if(ch == "RST"){
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++; 
                mem_file << "23" << endl;
                code_file >> number;
                    if( number.size() == 1)
                        number = "0" + number; 
                    if( number.size() > 2){
                        cout << "Number too big " << int_number << endl;
                        goto exit;
                    }
                mem_file << "@"; mem_file << memmory_index << " "; memmory_index++;         
                mem_file << number[0] << number[1] << endl;
            }             
        }
    }

    exit:
    code_file.close(); 
    mem_file.close();
    return 0;
}   

/*
menonics:
 
    NOP -> 'h00; 
    HLT -> 'h01; 
    
    LDA 'h02; //3 byte operation
    LDB 'h03; //3 byte operation
    ABTC 'h04; 
    ABTD 'h05; 
    CTAB 'h06; 
    DTAB 'h07; 

    STR 'h08;  //3 byte operation

    8ADD -> 'h09; 
    8SUB -> 'h0a; 
    8MLT -> 'h0b; 
    8DIV -> 'h0c; 
    -
    8AND -> 'h0d; 
    8OR  -> 'h0e; 
    8XOR -> 'h0f; 
    8NOT -> 'h10; 

    16ADD -> 'h11;
    16SUB -> 'h12;
    16MLT -> 'h13;
    16DIV -> 'h14;
    -
    16AND -> 'h15;
    16OR  -> 'h16;
    16XOR -> 'h17;
    16NOT -> 'h18;
    
    in ->    'h19;
    out ->   'h1a; 
    
    JMP      'h1b; // 3 byte operation

    JCC      'h1c; //3 byte operation
    JCZ      'h1d; //3 byte operation
    JCE8     'h1e; //3 byte operation
    JCE16    'h1f; //3 byte operation

	SW8      'h20; 
    SW16     'h21; 

    INC      'h22;
    RST      'h23;
*/