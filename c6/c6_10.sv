// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

//優先權綜合: case/if 並且條件"不"互斥
module mux_4pri(output reg y,
                input a,b,c,d,sel_a,sel_b,sel_c);
    always @(*) begin//等同a,b,...,sel_c
        if (sel_a==1)      y = a;
        else if (sel_b==0) y = b;
        else if (sel_c==1) y = c;
        else               y = d;
    end
endmodule