// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

// 隱式狀態機綜合: 序列111檢測 shift register
module Seq_Rec_3_1s_Mealy_Shft_Reg (D_out, D_in, En, clk, reset);         
    output      D_out;
    input       D_in, En;
    input       clk, reset;
    parameter   Empty = 2'b00;
    reg [1:0]   Data;
                        
    always @ (negedge clk) 
        if (reset == 1) Data <= Empty;
        else if (En  == 1) Data <= {D_in, Data[1]}; 

    assign D_out = ((Data == 2'b11) && (D_in == 1 )); // Mealy output
endmodule

module Seq_Rec_3_1s_Moore_Shft_Reg (D_out, D_in, En, clk, reset);         
    output      D_out;
    input       D_in, En;
    input       clk, reset;
    parameter   Empty = 2'b00;
    reg [2:0]   Data;
                        
    always @ (negedge clk) 
        if (reset == 1) Data <= Empty;
        else if (En == 1) Data <= {D_in, Data[2:1]}; 

    assign D_out = (Data == 3'b111); // Moore output
endmodule

module t_Seq_Rec_3_1s ();
    reg D_in, En, clk, reset;  

    wire D_out_Mealy;
    wire D_out_Moore;
    
    Seq_Rec_3_1s_Mealy_Shft_Reg M0 (D_out_Mealy, D_in, En, clk, reset);         
    Seq_Rec_3_1s_Moore_Shft_Reg M1 (D_out_Moore, D_in, En, clk, reset);         

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
        En = 1;
        // #5 En = 1;
        // #50 En = 0;
    end

    initial fork
        #10 D_in = 0;
        #35 D_in = 1;       #45 D_in = 0; 
        #55 D_in = 1;       #65 D_in = 0;
        #75 D_in = 1;       #85 D_in = 0; 
        #95 D_in = 1;       #105 D_in = 0; 
        #135 D_in = 1;      #145 D_in = 0;
        #155 D_in = 1;      #165 D_in = 0; 
        #195 D_in = 1'bx;   #250 D_in = 0; 
    join
endmodule