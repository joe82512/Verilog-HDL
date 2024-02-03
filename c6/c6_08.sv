// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

//組合邏輯綜合: 比較器
module comparator #(parameter size = 2) (
    output reg a_gt_b, a_lt_b, a_eq_b,
    input [size-1:0] a,b
);
    integer k;
    always @(a,b) begin:compare_loop
        for (k=size; k>0; k=k-1) begin
            if (a[k]!=b[k]) begin
                a_gt_b = a[k];        //a>b, a[k]=1
                a_lt_b = ~a[k];       //a<b, a[k]=0
                a_eq_b = 0;
                disable compare_loop; //比較差異最高位
            end
        end
        a_gt_b = 0;
        a_lt_b = 0;
        a_eq_b = 1;
    end
endmodule