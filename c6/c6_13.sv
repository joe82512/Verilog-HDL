// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

//用 { } 分組縮減電路面積
module badd_4 (
    output [3:0] Sum,
    output C_out,
    input [3:0] A,B,C_in
);
    assign {Cout, Sum} = A + B + C_in;
endmodule

//mux比加法器占用更少電路面積
module res_share (
    output [4:0] y_out,
    input [3:0] data_a, data_b, accum,
    input sel
);
    assign y_out = data_a + (sel ? accum : data_b);
endmodule