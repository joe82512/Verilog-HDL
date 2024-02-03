// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

module Par_load_reg4 #(parameter word_size = 4) (
    output reg [word_size-1:0] Data_out,
    input      [word_size-1:0] Data_in,
    input load, clock, reset
);
    // 移位暫存器: parallel
    always @(posedge clock, posedge reset) begin
        if (reset==1'b1)     Data_out <= { word_size{1'b0} };
        else if (load==1'b1) Data_out <= Data_in;
    end
endmodule