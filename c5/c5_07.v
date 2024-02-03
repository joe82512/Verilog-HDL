// 5.07
module Latch_CA (
    output q_out,
    input  data_in, enable
);
    // Latch
    assign q_out = enable ? data_in : q_out;
endmodule

// 5.08
module Latch_Rbar_CA (
    output q_out;
    input  data_in, enable, reset;
);
    // 增加 reset(優先) 與 enable(次序)
    assign q_out = !reset ? 0 : enable ? data_in : q_out;
endmodule

// 5.09
module df_behav (
    output reg q,
    output q_bar,
    input data, set, clk, reset
);
    // q 定義為 reg , Flip Flop
    assign q_bar = ~ q;
    always @  (posedge clk) begin // Flip-flop with synchronous set/reset
        if (reset == 0) q <= 0; 
        else if (set ==0) q <= 1;
        else q <= data; 
    end
endmodule

// 5.10
module asynch_df_behav (
    output reg q,
    output q_bar,
    input data, set, clk, reset
);
    // 單行可省略 begin...end / or可以用,取代
    assign q_bar = ~q;
    always @  (negedge set or negedge reset or posedge clk) // synchronized activity
        if (reset == 0) q <= 0; 
        else if (set == 0) q <= 1; 
        else q <= data;
endmodule 

