// 5.19
module Mux_4_32_case (mux_out, data_3, data_2, data_1, data_0, select, enable);
    output  [31: 0] mux_out;
    input   [31: 0] data_3, data_2, data_1, data_0;
    input   [1:0]   select;
    input           enable;
    reg     [31:0]  mux_int;

    assign mux_out = enable ? mux_int : 32'bz;

    // case綜合成mux
    always @ ( data_3 or data_2 or data_1 or data_0 or select)
        case (select)
            0: mux_int = data_0;
            1: mux_int = data_1;
            2: mux_int = data_2;
            3: mux_int = data_3;
            default: mux_int = 32'bx; //不設可能會latch
        endcase
endmodule

// 5.20
module Mux_4_32_if (mux_out, data_3, data_2, data_1, data_0, select, enable);
    output  [31: 0] mux_out;
    input   [31: 0] data_3, data_2, data_1, data_0;
    input   [1:0]   select;
    input           enable;
    reg     [31:0]  mux_int;

    assign mux_out = enable ? mux_int : 32'bz;
    // if-else
    always @ ( data_3 or data_2 or data_1 or data_0 or select)
        if (select == 0)       mux_int = data_0;
        else if (select == 1)  mux_int = data_1;
        else if (select == 2)  mux_int = data_2; 
        else if (select == 3)  mux_int = data_3;
        else                   mux_int = 32'bx;
endmodule

// 5.21
module Mux_4_32_CA (mux_out, data_3, data_2, data_1, data_0, select, enable);
    output  [31: 0] mux_out;
    input   [31: 0] data_3, data_2, data_1, data_0;
    input   [1:0]   select;
    input           enable;
    reg     [31:0]  mux_int;

    assign mux_out = enable ? mux_int : 32'bz;
    // 用?取代if-else , 單行表達
	assign mux_int =    (select == 0) ? data_0 : 
                        (select == 1) ? data_1 :
                        (select == 2) ? data_2 :
                        (select == 3) ? data_3 : 32'bx;
endmodule