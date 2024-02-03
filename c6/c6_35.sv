// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

// 括號造成綜合結果不同
module operator_group (sum1, sum2, a, b, c, d);
    output [4: 0]   sum1, sum2;
    input [3: 0]    a, b, c, d;
    
    assign sum1 = a + b + c + d;
    assign sum2 = (a + b) + (c + d); //更快
endmodule