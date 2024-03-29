// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

// 顯示狀態機綜合: 序列111檢測
module Seq_Rec_3_1s_Mealy (D_out, D_in, En, clk, reset);         
    output      D_out;
    input       D_in, En;
    input       clk, reset;
    // State assignment
    parameter   S_idle = 0; // Binary code
    parameter   S_0 = 1;
    parameter   S_1 = 2;
    parameter   S_2 = 3;
    reg [1: 0]  state, next_state;

    // 狀態轉移
    always @ (negedge clk) 
        if (reset == 1) state <= S_idle;
        else state <= next_state;

    // 轉移條件
    always @ (state or D_in) begin
        case (state) // Partially decoded
            S_idle:
                if ((En == 1) && (D_in == 1)) next_state = S_1;
                else if ((En  == 1) && (D_in == 0)) next_state = S_0;    
                else next_state = S_idle;

            S_0:
                if (D_in == 0) next_state = S_0;
                else if (D_in == 1) next_state = S_1; 
                else next_state = S_idle;

            S_1:
                if (D_in == 0) next_state = S_0;
                else if (D_in == 1) next_state = S_2;     
                else next_state = S_idle;

            S_2:
                if (D_in == 0) next_state = S_0;
                else if (D_in == 1) next_state = S_2;    
                else next_state = S_idle;

            default:
                next_state = S_idle;  
        endcase
    end

    // 輸出
    assign D_out = ((state == S_2) && (D_in == 1 )); // Mealy output
endmodule

module Seq_Rec_3_1s_Moore (D_out, D_in, En, clk, reset);         
    output      D_out;
    input       D_in, En;
    input       clk, reset;
    // State assignment
    parameter   S_idle = 0; // One-Hot
    parameter   S_0 = 1;
    parameter   S_1 = 2;
    parameter   S_2 = 3;
    parameter   S_3 = 4;
    reg [2:0]   state, next_state;
    
    // 狀態轉移
    always @ (negedge clk) 
        if (reset == 1) state <= S_idle; else state <= next_state;

    // 轉移條件
    always @ (state or D_in) begin
        case (state) 
            S_idle:
                if ((En == 1) && (D_in == 1)) next_state = S_1;
                else if ((En  == 1) && (D_in == 0)) next_state = S_0;    
                else next_state = S_idle;

            S_0:
                if (D_in == 0) next_state = S_0;
                else if (D_in == 1) next_state = S_1; 
                else next_state = S_idle;

            S_1:
                if (D_in == 0) next_state = S_0;
                else if (D_in == 1) next_state = S_2;     
                else next_state = S_idle;

            S_2, S_3:
                if (D_in == 0) next_state = S_0;
                else if (D_in == 1) next_state = S_3;    
                else next_state = S_idle;

            default:
                next_state = S_idle;  
        endcase
    end

    // 輸出
    assign D_out = (state == S_3); // Moore output
endmodule


module t_Seq_Rec_3_1s ();
    reg D_in_NRZ, D_in_RZ, En, clk, reset;  

    wire Mealy_NRZ;
    wire Mealy_RZ;
    wire Moore_NRZ;
    wire Moore_RZ;

    Seq_Rec_3_1s_Mealy M0 (Mealy_NRZ, D_in_NRZ, En, clk, reset);         
    Seq_Rec_3_1s_Mealy M1 (Mealy_RZ, D_in_RZ, En, clk, reset);         
    Seq_Rec_3_1s_Moore M2 (Moore_NRZ, D_in_NRZ, En, clk, reset);         
    Seq_Rec_3_1s_Moore M3 (Moore_RZ, D_in_RZ, En, clk, reset);         

    //EPWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        #275 $finish;
    end

    initial begin
        #5 reset = 1;
        #1 reset = 0;
    end

    initial begin
        clk = 0;
        forever #10 clk = ~clk;  
    end

    initial begin
        #5 En = 1;
        #50 En = 0;
    end

    initial fork 
        begin
            #10 D_in_NRZ = 0;
            #25 D_in_NRZ = 1;
            #80 D_in_NRZ = 0;
        end

        begin
            #135 D_in_NRZ = 1;
            #40 D_in_NRZ = 0;
        end
        
        begin
            #195 D_in_NRZ = 1'bx;
            #60 D_in_NRZ = 0;
        end
    join

    initial fork
        #10 D_in_RZ = 0;    
        #35 D_in_RZ = 1;    #45 D_in_RZ = 0; 
        #55 D_in_RZ = 1;    #65 D_in_RZ = 0;
        #75 D_in_RZ = 1;    #85 D_in_RZ = 0; 
        #95 D_in_RZ = 1;    #105 D_in_RZ = 0; 
        #135 D_in_RZ = 1;   #145 D_in_RZ = 0;
        #155 D_in_RZ = 1;   #165 D_in_RZ = 0; 
        #195 D_in_RZ = 1'bx;#250 D_in_RZ = 0; 
    join
endmodule