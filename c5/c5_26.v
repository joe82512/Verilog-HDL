// 5.26
module Auto_LFSR_RTL (Y, Clock, Reset);
    parameter Length = 8;
    parameter initial_state = 8'b1001_0001;	// 91h
    parameter [1: Length] Tap_Coefficient = 8'b1100_1111; 

    input  Clock, Reset;
    output [1: Length] Y;
    reg    [1: Length] Y;

    // LSFR , 常用於CRC校驗
    always @ (posedge Clock)
    if (!Reset) Y <= initial_state;	// Active-low reset to initial state
    else begin
        Y[1] <= Y[8];
        Y[2] <= Tap_Coefficient[7] ? Y[1] ^ Y[8] : Y[1];
        Y[3] <= Tap_Coefficient[6] ? Y[2] ^ Y[8] : Y[2];
        Y[4] <= Tap_Coefficient[5] ? Y[3] ^ Y[8] : Y[3];
        Y[5] <= Tap_Coefficient[4] ? Y[4] ^ Y[8] : Y[4];
        Y[6] <= Tap_Coefficient[3] ? Y[5] ^ Y[8] : Y[5];
        Y[7] <= Tap_Coefficient[2] ? Y[6] ^ Y[8] : Y[6];
        Y[8] <= Tap_Coefficient[1] ? Y[7] ^ Y[8] : Y[7];  
    end
endmodule

// 5.27
module Auto_LFSR_ALGO (Y, Clock, Reset);
    parameter   Length = 8;
    parameter   initial_state = 8'b1001_0001;
    parameter   [1: Length] Tap_Coefficient = 8'b1100_1111;
    input       Clock, Reset;
    output      [1: Length] Y;
    integer     Cell_ptr;
    reg         [1: Length] Y;	// 5-10-2004

    // LOOP 寫法
    always @  (posedge Clock) begin
        if (!Reset) Y <= initial_state;		// Arbitrary initial state, 91h
        else begin
            for (Cell_ptr = 2; Cell_ptr <= Length; Cell_ptr = Cell_ptr +1)
                if (Tap_Coefficient [Length - Cell_ptr + 1] == 1)
                    Y[Cell_ptr] <= Y[Cell_ptr -1]^ Y [Length];
                else
                    Y[Cell_ptr] <= Y[Cell_ptr -1];
            
            Y[1] <= Y[Length];
        end
    end
endmodule

// 5.31
module Auto_LFSR_Param (Y, Clock, Reset);
    parameter   Length = 8;
    parameter   initial_state = 8'b1001_0001;	// Arbitrary initial state
    parameter   [1: Length] Tap_Coefficient = 8'b1100_1111; 

    input       Clock, Reset;
    output      [1: Length] Y;
    reg         [1: Length] Y;
    integer     k;
    
    // 可輸入引數
    always @  (posedge Clock)
        if (!Reset) Y <= initial_state;	 
        else begin
            for (k = 2; k <= Length; k = k + 1)
                Y[k] <= Tap_Coefficient[Length-k+1] ? Y[k-1] ^ Y[Length] : Y[k-1];	 
            Y[1] <= Y[Length];
        end
endmodule

// 5.30
module Majority_4b (Y, A, B, C, D);
    input   A, B, C, D;
    output  Y;
    reg     Y;
    // 輸入限制 4-bits
    always @ (A or B or C or D) begin
        case ({A, B, C, D})
            7, 11, 13, 14, 15: Y = 1;
            default Y = 0;
        endcase
    end
endmodule

module Majority (Y, Data);
    parameter   size = 8; //預設引數
    parameter   max = 3;		
    parameter   majority = 5;
    input       [size-1: 0]	Data;
    output      Y;
    reg         Y;
    reg         [max-1: 0] count;
    integer     k;

    always @ (Data) begin
        count = 0;
        for (k = 0; k < size; k = k + 1) begin
            if (Data[k] == 1) count = count + 1;
        end
        Y = (count >= majority);
    end
endmodule

// 5.34
module find_first_one (index_value, A_word, trigger);
    output  [3: 0] index_value;
    input   [15: 0]	A_word;
    input   trigger;
    reg     [3: 0] index_value;
    // disable label
    always @ (trigger) begin: search_for_1
        index_value = 0;
        for (index_value = 0; index_value <= 15; index_value = index_value + 1)
            if (A_word[index_value] == 1) disable search_for_1; //停止迴圈
    end
endmodule

// 5.35
module add_4cycle (sum, data, clk, reset);
    output [5: 0]   sum;
    input  [3: 0]   data;
    input           clk, reset;
    reg             sum;
    // 隱式狀態機
    always @ (posedge clk) begin:  add_loop
        if (reset) disable add_loop;                    else sum <= data;
         @ (posedge clk) if (reset) disable add_loop;   else sum <= sum + data;
          @ (posedge clk) if (reset) disable add_loop;  else sum <= sum + data;
           @ (posedge clk) if (reset) disable add_loop; else sum <= sum + data;
   end
endmodule