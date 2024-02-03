// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

//帶反饋的敏感電平週期->MUX
module latch_if1 (
    output reg [3:0] data_out,
    input [3:0] data_in,
    input latch_enable
);
    always @(latch_enable,data_in)
        if (latch_enable) data_out = data_in;
        else              data_out = data_out; //帶反饋
    
endmodule

//帶反饋的assign或不完整的敏感電平會綜合出Latch
module latch_if2 (
    output reg [3:0] data_out,
    input [3:0] data_in,
    input latch_enable
);
    always @(latch_enable,data_in)
        if (latch_enable) data_out = data_in; //條件不完整

    // assign data_out[3:0] = (latch_enable) ? data_in[3:0] : data_out[3:0]; //帶反饋
endmodule

//考慮所有輸入值
module mux_latch (
    output reg y_out,
    input data_a, data_b, sel_a, sel_b
);
    always @(sel_a, sel_b, data_a, data_b)
        case({sel_a,sel_b})
            2'b10: y_out = data_a;
            2'b01: y_out = data_b;
        endcase
endmodule