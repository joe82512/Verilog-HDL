// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

// 不同的加法器表達式
module multiple_reg_assign (data_out1, data_out2, data_a, data_b, data_c, data_d, sel, clk);
    output [4: 0]   data_out1, data_out2;
    input [3: 0]    data_a, data_b, data_c, data_d;
    input           clk;
    reg [4: 0]      data_out1, data_out2;
  
    always @ (posedge clk) begin
        data_out1 = data_a + data_b ;
        data_out2 = data_out1 + data_c;
        if (sel == 1'b0)
            data_out1 = data_out2 + data_d;
    end
endmodule 

// 與上個等校但電路不同
module expression_sub (data_out1, data_out2, data_a, data_b, data_c, data_d, sel, clk);
    output [4: 0]   data_out1, data_out2;
    input [3: 0]    data_a, data_b, data_c, data_d;
    input           sel, clk;
    reg [4: 0]      data_out1, data_out2;
    
    always @ (posedge clk) begin
        data_out2 = data_a + data_b + data_c;
        if (sel == 1'b0) 
            data_out1 = data_a + data_b + data_c + data_d;
        else
            data_out1 = data_a + data_b;
    end
endmodule

// 更好的寫法 : <=
module expression_sub_nb (data_out1nb, data_out2nb, data_a, data_b, data_c, data_d, sel, clk);
    output [4: 0]   data_out1nb, data_out2nb;
    input [3: 0]    data_a, data_b, data_c, data_d;
    input           sel, clk;
    reg [4: 0]      data_out1nb, data_out2nb;
    
    always @ (posedge clk) begin
        data_out2nb <= data_a + data_b + data_c;
        if (sel == 1'b0) 
            data_out1nb <= data_a + data_b + data_c + data_d;
        else
            data_out1nb <= data_a + data_b;
    end
endmodule