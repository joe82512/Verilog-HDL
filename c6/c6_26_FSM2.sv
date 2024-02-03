// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

// 顯示狀態機綜合: 訊號轉換
module NRZ_2_Manchester_Mealy (B_out, B_in, clock, reset_b);
    output      B_out;
    input       B_in;
    input       clock, reset_b;
    reg [1:0]   state, next_state;
    reg         B_out;

    // State assignment
    parameter   S_0 = 0,
                S_1 = 1,
                S_2 = 2,
                dont_care_state = 2'bx,
                dont_care_out = 1'bx;

    // 狀態轉移
    always @ (negedge clock or negedge reset_b)
        if (reset_b == 0) state <= S_0;
        else state <= next_state;

    // 轉移條件 + 輸出
    always @ (state or B_in ) begin
        B_out = 0;
        case (state) // Partially decoded
            S_0:
                if (B_in == 0) next_state = S_1;  
                else if (B_in == 1) begin next_state = S_2; B_out = 1; end
            S_1:
                begin next_state = S_0; B_out = 1; end
            S_2:
                begin next_state = S_0; end
            default:
                begin next_state = dont_care_state; B_out = dont_care_out; end
        endcase
    end 
endmodule

module Clock_1_2 (clock_1, clock_2);
    output    clock_1, clock_2;
    reg       clock_1, clock_2;
    parameter half_cycle_1 = 10;
    parameter half_cycle_2 = 5;
    parameter period_1 = 2*half_cycle_1;
    parameter period_2 = 2*half_cycle_2;

    initial begin
        clock_1 = 0;
        forever begin
        #half_cycle_1 clock_1 = ~ clock_1;
        end
    end
    
    initial begin
        clock_2 = 0;
        forever begin
            #half_cycle_2 clock_2 = ~ clock_2;
        end
    end
endmodule

module test_NRZ_2_Manchester_Mealy ();
    reg B_in, reset_b;
    wire B_out, clock;

    NRZ_2_Manchester_Mealy M1 (B_out, B_in, clock_2, reset_b);
    Clock_1_2 M2 (clock_1, clock_2);

    //EPWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        #200 $finish;
    end

    initial begin
        #1 reset_b = 0;
        #2 reset_b = 1;
    end

    initial fork
        B_in = 0;
        #(M2.period_1) B_in = 1;
        #(4*M2.period_1) B_in = 0;
        #(6*M2.period_1) B_in = 1;
        #(7*M2.period_1) B_in = 0;
    join
endmodule