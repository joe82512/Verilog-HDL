// 5.22
module encoder (Code, Data);
    output [2: 0] Code;
    input  [7: 0] Data;
    reg    [2: 0] Code;
    // 編碼器 8->3
    always @  (Data) begin
        if (Data == 8'b00000001) Code = 0; else
        if (Data == 8'b00000010) Code = 1; else
        if (Data == 8'b00000100) Code = 2; else
        if (Data == 8'b00001000) Code = 3; else
        if (Data == 8'b00010000) Code = 4; else
        if (Data == 8'b00100000) Code = 5; else
        if (Data == 8'b01000000) Code = 6; else
        if (Data == 8'b10000000) Code = 7; else Code = 3'bx;
    end

/* Alternative description is given below
always @  (Data)
    case (Data)
        8'b00000001 : Code = 0;  
        8'b00000010 : Code = 1;  
        8'b00000100 : Code = 2;  
        8'b00001000 : Code = 3;  
        8'b00010000 : Code = 4;  
        8'b00100000 : Code = 5;  
        8'b01000000 : Code = 6;  
        8'b10000000 : Code = 7;  
        default     : Code = 3'bx;
    endcase
*/
endmodule

// 5.23
module priority (Code, valid_data, Data);
    output [2: 0] Code;
    output valid_data;
    input  [7: 0] Data;
    reg    [2: 0] Code;
 
    assign valid_data = |Data; // "reduction or" operator
    //優先編碼器 , 最高位優先
    always @  (Data) begin
        if (Data[7]) Code = 7; else
        if (Data[6]) Code = 6; else
        if (Data[5]) Code = 5; else
        if (Data[4]) Code = 4; else
        if (Data[3]) Code = 3; else
        if (Data[2]) Code = 2; else
        if (Data[1]) Code = 1; else
        if (Data[0]) Code = 0; else
                     Code = 3'bx;
    end

/*// Alternative description is given below

always @  (Data)
  casex (Data)
       8'b1xxxxxxx 	: Code = 7;  
       8'b01xxxxxx 	: Code = 6;  
       8'b001xxxxx 	: Code = 5;  
       8'b0001xxxx 	: Code = 4;  
       8'b00001xxx 	: Code = 3;  
       8'b000001xx  : Code = 2;  
       8'b0000001x 	: Code = 1;  
       8'b00000001	: Code = 0;  
       default 	: Code = 3'bx;
  endcase
*/
endmodule

// 5.24
module decoder (Data, Code);
    output [7: 0] Data;
    input  [2: 0] Code;
    reg    [7: 0] Data;
    // 解碼器 3->8
    always @  (Code) begin
        if (Code == 0) Data = 8'b00000001; else
        if (Code == 1) Data = 8'b00000010; else
        if (Code == 2) Data = 8'b00000100; else
        if (Code == 3) Data = 8'b00001000; else
        if (Code == 4) Data = 8'b00010000; else
        if (Code == 5) Data = 8'b00100000; else
        if (Code == 6) Data = 8'b01000000; else
        if (Code == 7) Data = 8'b10000000; else
                       Data = 8'bx;
    end
/* Alternative description is given below
always @  (Code)
  case (Code)
    0		: Data = 8'b00000001;  
    1		: Data = 8'b00000010;  
    2		: Data = 8'b00000100;  
    3		: Data = 8'b00001000;  
    4		: Data = 8'b00010000;  
    5		: Data = 8'b00100000;  
    6		: Data = 8'b01000000;  
    7		: Data = 8'b10000000;  
    default	: Data = 8'bx;
  endcase
*/
endmodule

// 5.25
module Seven_Seg_Display (Display, BCD, Blanking);
    output [6: 0]	Display;
    input  [3: 0] BCD;
    reg    [6: 0]	Display;
    //七段顯示器          abc_defg
    parameter BLANK = 7'b111_1111;
    parameter ZERO  = 7'b000_0001; // h01
    parameter ONE   = 7'b100_1111; // h4f
    parameter TWO   = 7'b001_0010; // h12
    parameter THREE = 7'b000_0110; // h06
    parameter FOUR  = 7'b100_1100; // h4c
    parameter FIVE  = 7'b010_0100; // h24
    parameter SIX   = 7'b010_0000; // h20
    parameter SEVEN = 7'b000_1111; // h0f
    parameter EIGHT = 7'b000_0000; // h00
    parameter NINE  = 7'b000_0100; // h04

    always @ (BCD or Blanking)
        if (Blanking) Display = BLANK;
        else
            case (BCD)
                0:      Display = ZERO;
                1:      Display = ONE;
                2:      Display = TWO;
                3:      Display = THREE;
                4:      Display = FOUR;
                5:      Display = FIVE;
                6:      Display = SIX;
                7:      Display = SEVEN;
                8:      Display = EIGHT;
                9:      Display = NINE;
                default:Display = BLANK;
    endcase
endmodule

