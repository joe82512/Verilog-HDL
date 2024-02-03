// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

// 靜態(loop次數已知) + 不帶內嵌時序
//ex6.37
module for_and_loop_comb (out, a, b);
    output [3: 0] out;
    input  [3: 0] a, b;
    
    reg    [2: 0] i;
    reg    [3: 0] out;
    wire   [3: 0] a, b;

    always @ (a or b) begin //與clk無關
        for (i = 0; i <= 3; i = i+1)
            out[i] = a[i] & b[i];
    end
endmodule

//ex6.38
module count_ones_a (bit_count, data, clk, reset);
    parameter data_width = 4;
    parameter count_width = 3;
    output [count_width-1:0] bit_count;
    input  [data_width-1:0]  data;
    input                    clk, reset;
    reg    [count_width-1:0] count, bit_count, index;
    reg    [data_width-1:0]  temp;
    
    always @ (posedge clk)
        if (reset) begin
            count = 0; bit_count = 0;
        end
        else begin
            count = 0;
            bit_count = 0;
            temp = data;
            // 在同一clk週期內完成
            for (index = 0; index < data_width; index = index + 1) begin
                count = count + temp[0];
                temp = temp >> 1;
            end
            bit_count = count; 
        end
endmodule

// testcase
module t_count_ones_a ();
    parameter data_width = 4;
    parameter count_width = 3;
    wire [count_width-1:0] bit_count;
    reg  [data_width-1:0]  data;
    reg                    clk, reset;
    
    //EPWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        #500 $finish;
    end

    initial fork
        reset = 1;  // modified 5-17-2002 for longer reset
        #10 reset = 0;
    join

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        #10 data = 4'hf;
        #40 data = 4'ha;
        #40 data = 4'h5;
        #60 data = 4'hb;
        #40 data = 4'h9;
        #40 data = 4'h0;
        #40 data = 4'hc;
    end

    count_ones_a M0 (bit_count, data, clk, reset);

endmodule