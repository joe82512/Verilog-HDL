// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

// 隱式狀態機綜合 : shift register
module shifter_1 (sig_d, new_signal, Data_in, clock, reset);
    output  sig_d, new_signal;
    input   Data_in, clock, reset;
    reg     sig_a, sig_b, sig_c, sig_d, new_signal;

    always @ (posedge reset or posedge clock)
        begin if (reset == 1'b1)
        begin
            sig_a <= 0;
            sig_b <= 0;
            sig_c <= 0;
            sig_d <= 0;
            new_signal <= 0;
        end
        else
        begin 
            sig_a <= Data_in;
            sig_b <= sig_a;
            sig_c <= sig_b;
            sig_d <= sig_c;
            new_signal <= (~ sig_a) & sig_b; //綜合成flip-flop
        end
    end  
endmodule

module shifter_2 (sig_d, new_signal, Data_in, clock, reset);
    output  sig_d, new_signal;
    input   Data_in, clock, reset;
    reg     sig_a, sig_b, sig_c, sig_d, new_signal;

    always @ (posedge reset or posedge clock)
        begin
        if (reset == 1'b1)
            begin
            sig_a <= 0;
            sig_b <= 0;
            sig_c <= 0;
            sig_d <= 0;
            end
        else  
            begin
            sig_a <= shift_input;
            sig_b <= sig_a;
            sig_c <= sig_b;
            sig_d <= sig_c;
            end
        end
        assign new_signal = (~ sig_a) & sig_b; //沒有被綜合成flip-flop
endmodule