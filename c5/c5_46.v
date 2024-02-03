// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

module Universal_Shift_Reg #(parameter word_size = 4) (
    output reg [word_size-1:0] Data_Out,
    output                     MSB_Out, LSB_out,
    input      [word_size-1:0] Data_In,
    input                      MSB_In, LSB_In,
    input                      s0, s1, clk, rst
);
    assign MSB_Out = Data_Out[word_size-1];
    assign LSB_Out = Data_Out[0];

    always @(posedge clk) begin
        if (rst==1'b1)
            Data_Out <= 0;
        else
            case ({s1,s0})
                0: Data_Out <= Data_Out; //keep
                1: Data_Out <= { MSB_In, Data_Out[word_size-1:1] }; //Seq右傳MSB
                2: Data_Out <= { Data_Out[word_size-2:0], LSB_In }; //Seq左傳LSB
                3: Data_Out <= Data_In; //平行輸入
            endcase
    end
endmodule



// ==================== testbench.sv ====================
// Code your testbench here
// or browse Examples
module top();
    wire [3:0] Data_Out, Data_In;
    wire MSB_Out, LSB_out, LSB_In, MSB_In;
    reg  s0, s1, clk, rst;
    
    //EPWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        #1000 $finish;
    end

    //reset
    initial begin
        rst = 1;
        #20 rst = 0;
        #100 rst = 1;
        #20 rst = 0;
        #100 rst = 1;
        #20 rst = 0;
    end

    //clock
    initial begin
        clk = 0;
    end
    always #10 clk = ~clk;

    //load
    assign Data_In = 4'b1111;
    initial begin
        s0 = 0; s1 = 0; //{0,0} 0
        #40 s0 = 1;     //{1,0} 2
        #90 s0 = 0;     //{0,0} 0
        #30 s1 = 1;     //{0,1} 1
        #70 s1 = 0;     //{0,0} 0
        #10 s0 = 1;     //{1,0} 2
        #10 s1 = 1;     //{1,1} 3
    end

    //LSB, MSB input
    assign LSB_In = 1;
    assign MSB_In = 1;

    //module
    Universal_Shift_Reg USR1(
        Data_Out, MSB_Out, LSB_out,
        Data_In, MSB_In, LSB_In,
        s0, s1, clk, rst
    );
endmodule