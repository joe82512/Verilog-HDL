// 5.1
module AOI_5_CA0 (
    input 	x_in1, x_in2, x_in3, x_in4, x_in5,
    output	y_out
);
    // 1-bit 用邏輯運算(! && ||)或位元運算(~ & |)皆可
    assign y_out = ~((x_in1 & x_in2) | (x_in3 & x_in4 & x_in5));
endmodule

// 5.2
module AOI_5_CA1 (
    input 	x_in1, x_in2, x_in3, x_in4, x_in5, enable,
    output	y_out
);
    // 三態輸出門, enable控制
    assign y_out = enable ? ~((x_in1 & x_in2) | (x_in3 & x_in4 & x_in5)) : 1'bz;
endmodule

// 5.3
module AOI_5_CA2 (
    input 	x_in1, x_in2, x_in3, x_in4, x_in5, enable,
    output	y_out
);
    // 明確定義 wire
    wire y_out = enable ? ~((x_in1 & x_in2) | (x_in3 & x_in4 & x_in5)): 1'bz;
endmodule

// 5.4
module Mux_2_32_CA #(parameter word_size = 32)(
    output 	[word_size-1: 0] mux_out,
    input 	[word_size-1: 0] data_1, data_0,
    input                    select
);
    // parameter 仿真期間不變
    assign mux_out = enable ? data_1 : data_0;
endmodule

// 5.5
module AOI_5_CA2 (
    input 	x_in1, x_in2, x_in3, x_in4, x_in5, enable,
    output	y_out
);
    // 傳輸延時 
    wire #1 y1 = x_in1 & x_in2;
    wire #1 y2 = x_in3 & x_in4;
    wire #1 y_out = ~(y1 | y2); 
endmodule