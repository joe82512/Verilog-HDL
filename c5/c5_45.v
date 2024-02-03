// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

module barrel_shift #(parameter word_size = 4) (
    output reg [word_size-1:0] Data_out,
    input      [word_size-1:0] Data_in,
    input load, clock, reset
);
    // 桶型移位暫存器: left shift+環形
    always @(posedge clock, posedge reset) begin
        if (reset==1'b1)     Data_out <= { word_size{1'b0} };
        else if (load==1'b1) Data_out <= Data_in;
        else                 Data_out <= { Data_out[word_size-2:0], Data_out[word_size-1] };
    end
endmodule