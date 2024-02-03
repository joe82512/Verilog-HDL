// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

module Shift_reg4 #(parameter word_size = 4) (
    output Data_out,
    input Data_in, clock, reset
);
    // 移位暫存器: Sequencial
    reg [word_size-1:0] Data_reg;
    assign Data_out = Data_reg[0];
    always @(posedge clock, negedge reset) begin
        if (reset==1'b0) Data_reg <= { word_size{1'b0} };
        else             Data_reg <= { Data_in, Data_reg[word_size-1:1] };
    end
endmodule