// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

//有reg並不代表會綜合出register
module or4_behav #(parameter word_length = 4)(
    output reg y,
    input [word_length-1:0] x_in
);
    integer k;
    
    always @(x_in) begin: check_for_1
        y = 0;
        for (k=0; k<=word_length-1; k = k+1) begin
            if (x_in[k]==1) begin
                y = 1;
                disable check_for_1;
            end //if
        end //for-loop
    end
endmodule

//帶反饋的assign或不完整的敏感電平會綜合出Latch
module or4_behav_latch #(parameter word_length = 4)(
    output reg y,
    input [word_length-1:0] x_in
);
    integer k;
    
    always @(x_in[3:1]) begin: check_for_1 //不完整, 沒有x_in[0]
        y = 0;
        for (k=0; k<=word_length-1; k = k+1) begin
            if (x_in[k]==1) begin
                y = 1;
                disable check_for_1;
            end //if
        end //for-loop
    end
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