// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

module Register_File #(parameter word_size = 32, addr_size = 5) (
    output [word_size-1:0] Data_Out_1, Data_Out_2,
    input  [word_size-1:0] Data_In,
    input  [addr_size-1:0] Read_Addr_1, Read_Addr_2, Write_Addr,
    input                  Write_Enable, Clock
);
    // 暫存器組 , for ALU
    reg [word_size-1:0] Reg_File[31:0]; //32-bits*32
    // 雙輸出
    assign Data_Out_1 = Reg_File[Read_Addr_1];
    assign Data_Out_2 = Reg_File[Read_Addr_2];
    // 單輸入
    always @(posedge Clock) begin
        if (Write_Enable==1'b1) Reg_File[Write_Addr] <= Data_In; //32*32-bits [5-bits] <= 32-bits
    end
endmodule