module Processing_Unit (instruction, Zflag, address, Bus_1, mem_word, Load_R0, Load_R1, Load_R2, 
    Load_R3, Load_PC, Inc_PC, Sel_Bus_1_Mux, Load_IR, Load_Add_R, Load_Reg_Y, Load_Reg_Z, 
    Sel_Bus_2_Mux, clk, rst);

    parameter word_size = 8;
    parameter op_size = 4;
    parameter Sel1_size = 3;
    parameter Sel2_size = 2;

    // 走線定義
    output [word_size-1: 0] instruction, address, Bus_1;
    output                  Zflag;

    input [word_size-1: 0]  mem_word;
    input                   Load_R0, Load_R1, Load_R2, Load_R3, Load_PC, Inc_PC;
    input [Sel1_size-1: 0] 	Sel_Bus_1_Mux;
    input [Sel2_size-1: 0] 	Sel_Bus_2_Mux;
    input                   Load_IR, Load_Add_R, Load_Reg_Y, Load_Reg_Z;
    input                   clk, rst;

    wire                    Load_R0, Load_R1, Load_R2, Load_R3;
    wire [word_size-1: 0]   Bus_2;
    wire [word_size-1: 0]   R0_out, R1_out, R2_out, R3_out;
    wire [word_size-1: 0]   PC_count, Y_value, alu_out;
    wire                    alu_zero_flag;
    wire [op_size-1 : 0]    opcode = instruction [word_size-1: word_size-op_size];

    // 元件定義
    Register_Unit   R0      (R0_out, Bus_2, Load_R0, clk, rst);
    Register_Unit 	R1      (R1_out, Bus_2, Load_R1, clk, rst);
    Register_Unit 	R2   	(R2_out, Bus_2, Load_R2, clk, rst);
    Register_Unit 	R3   	(R3_out, Bus_2, Load_R3, clk, rst);
    Register_Unit 	Reg_Y 	(Y_value, Bus_2, Load_Reg_Y, clk, rst);
    D_flop 			Reg_Z 	(Zflag, alu_zero_flag, Load_Reg_Z, clk, rst);
    Address_Register Add_R	(address, Bus_2, Load_Add_R, clk, rst);
    Instruction_Register IR	(instruction, Bus_2, Load_IR, clk, rst);
    Program_Counter PC      (PC_count, Bus_2, Load_PC, Inc_PC, clk, rst);
    Multiplexer_5ch Mux_1   (Bus_1, R0_out, R1_out, R2_out, R3_out, PC_count, Sel_Bus_1_Mux);
    Multiplexer_3ch Mux_2   (Bus_2, alu_out, Bus_1, mem_word, Sel_Bus_2_Mux);
    Alu_RISC        ALU     (alu_zero_flag, alu_out, Y_value, Bus_1, opcode);
endmodule



/* ------------ 子元件 ------------ */
module Register_Unit (data_out, data_in, load, clk, rst);
    parameter word_size = 8;

    output [word_size-1: 0] data_out; //to   Mux_1
    input  [word_size-1: 0] data_in;  //from Bus_2
    input                   load;     //Load_R by Control_Unit
    input                   clk, rst;
    reg    [word_size-1: 0] data_out;

    // load reg with async reset
    always @ (posedge clk or negedge rst)
        if (rst == 0) data_out <= 0; else if (load) data_out <= data_in;
endmodule

// 1-bit Register
module D_flop (data_out, data_in, load, clk, rst);
    output  data_out; //Zflag (zero) , 判斷 alu_out 是否為 0
    input   data_in;  //alu_zero flag
    input   load;     //Load_Reg_Z by Control_Unit
    input   clk, rst;
    reg     data_out;

    // load reg with async reset
    always @ (posedge clk or negedge rst)
        if (rst == 0) data_out <= 0; else if (load == 1)data_out <= data_in;
endmodule

// same as Register_Unit
module Address_Register (data_out, data_in, load, clk, rst);
    parameter word_size = 8;
    output [word_size-1: 0] data_out;
    input  [word_size-1: 0] data_in;
    input                   load, clk, rst;
    reg    [word_size-1: 0] data_out;

    // load reg with async reset
    always @ (posedge clk or negedge rst)
        if (rst == 0) data_out <= 0; else if (load) data_out <= data_in;
endmodule

// same as Register_Unit
module Instruction_Register (data_out, data_in, load, clk, rst);
    parameter word_size = 8;
    output [word_size-1: 0] data_out; //address to memory
    input  [word_size-1: 0] data_in;  //from Bus_2
    input                   load;
    input                   clk, rst;
    reg    [word_size-1: 0] data_out;

    // load reg with async reset
    always @ (posedge clk or negedge rst)
        if (rst == 0) data_out <= 0; else if (load) data_out <= data_in; 
endmodule

// PC = PC+1
module Program_Counter (count, data_in, Load_PC, Inc_PC, clk, rst);
    parameter word_size = 8;
    output [word_size-1: 0] count;
    input  [word_size-1: 0] data_in;
    input                   Load_PC, Inc_PC;
    input                   clk, rst;
    reg    [word_size-1: 0] count;

    // load reg with async reset
    always @ (posedge clk or negedge rst)
        if (rst == 0) count <= 0; else if (Load_PC) count <= data_in; else if  (Inc_PC) count <= count +1;
endmodule

// 5-MUX: Mux_1
module Multiplexer_5ch (mux_out, data_a, data_b, data_c, data_d, data_e, sel);
    parameter word_size = 8;
    output [word_size-1: 0] mux_out; //Bus_1
    input  [word_size-1: 0] data_a, data_b, data_c, data_d, data_e; //R[0-3], PC
    input  [2: 0]           sel;
    
    assign  mux_out = (sel==0)  ? data_a : (sel==1) 
                                ? data_b : (sel==2) 
                                ? data_c : (sel==3) 
                                ? data_d : (sel==4) 
                                ? data_e : 'bx;
endmodule

// 3-MUX: Mux_2
module Multiplexer_3ch (mux_out, data_a, data_b, data_c, sel);
    parameter  word_size = 8;
    output [word_size-1: 0] mux_out; //Bus_2
    input  [word_size-1: 0] data_a, data_b, data_c; //alu, mux1, mem
    input  [1: 0]           sel;

    assign  mux_out = (sel==0)  ? data_a : (sel==1) 
                                ? data_b : (sel==2) 
                                ? data_c : 'bx; 
endmodule

/*  ALU Instruction		Action
    ADD			Adds the datapaths to form data_1 + data_2.
    SUB			Subtracts the datapaths to form data_1 - data_2.
    AND			Takes the bitwise-and of the datapaths, data_1 & data_2.
    NOT			Takes the bitwise Boolean complement of data_1.
*/
// Note: the carries are ignored in this model. 
module Alu_RISC (alu_zero_flag, alu_out, data_1, data_2, sel);
    parameter word_size = 8;
    parameter op_size = 4;
    // Opcodes: 1-word
    parameter NOP   = 4'b0000;
    parameter ADD   = 4'b0001;
    parameter SUB 	= 4'b0010;
    parameter AND 	= 4'b0011;
    parameter NOT 	= 4'b0100;
    // Opcodes: 2-word
    parameter RD  	= 4'b0101;
    parameter WR	= 4'b0110;
    parameter BR	= 4'b0111; //Jump
    parameter BRZ 	= 4'b1000; //Branch if zero

    // 走線
    output                  alu_zero_flag;
    output [word_size-1: 0] alu_out;
    input  [word_size-1: 0] data_1, data_2;
    input  [op_size-1: 0]   sel;
    reg    [word_size-1: 0] alu_out;

    // 計算結果
    assign  alu_zero_flag = ~|alu_out; //alu_out全0 則 alu_zero_flag = 1
    always @ (sel or data_1 or data_2)  
        case  (sel)
            NOP:        alu_out = 0;
            ADD:        alu_out = data_1 + data_2;  // Reg_Y + Bus_1
            SUB:        alu_out = data_2 - data_1;
            AND:        alu_out = data_1 & data_2;
            NOT:        alu_out = ~ data_2;         // Gets data from Bus_1
            default:    alu_out = 0;
        endcase 
endmodule