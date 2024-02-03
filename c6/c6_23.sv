// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

// 綜合成 flip-flop
module swap_synch (set1, set2, clk, data_a, data_b); 
    output  data_a, data_b;
    input   clk, set1, set2, swap;
    reg     data_a, data_b; 

always @(posedge clk) begin
    if (set1) begin
        data_a <= 1; data_b <= 0;
    end
    else if (set2) begin
        data_a <= 0; data_b <= 1;
    end
    else begin
        data_b <= data_a; data_a <= data_b;
    end
end
endmodule 

module D_reg4_a (Data_out, clock, reset, Data_in);
    output  [3: 0]  Data_out;
    input   [3: 0]  Data_in;
    input           clock, reset;
    reg     [3: 0]  Data_out;

    always @(posedge clock or posedge reset) begin 
        if (reset == 1'b1) Data_out <= 4'b0;
        else Data_out <= Data_in;
    end
endmodule

// D_out 為內部過程, 不會被綜合出來
module empty_circuit (D_in, clk);
    input   D_in;
    reg     D_out;

    always @(posedge clk) begin 
        D_out <= D_in;
    end
endmodule