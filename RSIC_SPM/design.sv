// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

`include "processing_unit.v"
`include "control_unit.v"
`include "memory_unit.v"

module RISC_SPM(clk, rst);
    //參數定義
    parameter word_size = 8;
    parameter Sel1_size = 3;
    parameter Sel2_size = 2;
    wire [Sel1_size-1: 0] Sel_Bus_1_Mux;
    wire [Sel2_size-1: 0] Sel_Bus_2_Mux;

    input clk, rst;

    /* ------------ 數據與控制訊號傳輸 ------------ */
    // Data Nets
    wire zero;
    wire [word_size-1: 0] instruction, address, Bus_1, mem_word;
    
    // Control Nets
    wire Load_R0, Load_R1, Load_R2, Load_R3, Load_PC, Inc_PC, Load_IR;   
    wire Load_Add_R, Load_Reg_Y, Load_Reg_Z;
    wire write;
    
    
    /* ------------ 硬體元件: 處理器/控制器/儲存器 ------------ */
    //控制mem,reg的R/W & 控制MUX,BUS
    Processing_Unit M0_Processor (
        instruction, zero, address, Bus_1, mem_word, Load_R0, Load_R1,
        Load_R2, Load_R3, Load_PC, Inc_PC, Sel_Bus_1_Mux, Load_IR, Load_Add_R, Load_Reg_Y,
        Load_Reg_Z,  Sel_Bus_2_Mux, clk, rst
    );
    
    //取address -> 解opcode -> 執行
    Control_Unit M1_Controller (
        Load_R0, Load_R1, Load_R2, Load_R3, Load_PC, Inc_PC, 
        Sel_Bus_1_Mux, Sel_Bus_2_Mux , Load_IR, Load_Add_R, Load_Reg_Y, Load_Reg_Z, 
        write, instruction, zero, clk, rst
    );

    //memory
    Memory_Unit M2_SRAM (
        .data_out(mem_word), 
        .data_in(Bus_1), 
        .address(address), 
        .clk(clk),
        .write(write)
    );
endmodule