// 5.12
module compare_2_CA1 (
    input  A1, A0, B1, B0,
    output A_lt_B, A_gt_B, A_eq_B
);
    // 單位元運算
    assign A_lt_B = ({A1,A0} < {B1,B0});
    assign A_gt_B = ({A1,A0} > {B1,B0});
    assign A_eq_B = ({A1,A0} == {B1,B0});
endmodule

// 5.13
module compare_2_CA2 (
    input	[1: 0] A, B,
    output A_lt_B, A_gt_B, A_eq_B
);
    // 多位元運算
    assign A_lt_B = (A < B);
    assign A_gt_B = (A > B);
    assign A_eq_B = (A == B);
endmodule

// 5.14
module compare_32_CA #(parameter word_size = 32)(
    input [word_size-1: 0] A, B,
    output A_gt_B, A_lt_B, A_eq_B
);
    // 自訂位元長度
    assign  A_gt_B = (A > B),		// Note: list of multiple assignments
            A_lt_B = (A < B),
            A_eq_B = (A == B);
endmodule

// 5.15
module compare_2_RTL (
    input  A1, A0, B1, B0,
    output reg A_lt_B, A_gt_B, A_eq_B
);
    // RTL模型 , 定義為 reg
    always @ (A0 or A1 or B0 or B1) begin
        A_lt_B = ({A1,A0} < {B1,B0});
        A_gt_B = ({A1,A0} > {B1,B0});
        A_eq_B = ({A1,A0} == {B1,B0});
  end
endmodule

// 5.18
module compare_2_algo (
    output reg A_lt_B, A_gt_B, A_eq_B,
    input [1: 0] A, B
);
    // 演算法模型不一定能綜合
    always @ (A, B) begin // Level-sensitive behavior
        A_lt_B = 0;
        A_gt_B = 0;
        A_eq_B = 0;
        if (A == B) A_eq_B = 1; // Note: parentheses are required
        else if (A > B) A_gt_B = 1;
        else A_lt_B = 1;
    end
endmodule