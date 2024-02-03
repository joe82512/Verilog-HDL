// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

// 隱式狀態機
module count_ones_IMP (bit_count, start, done, data, data_ready, clk, reset);
    parameter word_size= 4;
    parameter counter_size= 3;
    parameter state_size= 2;
    output [counter_size -1 : 0] bit_count;
    output                       start, done;
    input  [word_size-1:0]       data;
    input                        data_ready, clk, reset;

    reg                   bit_count;
    reg [state_size-1 :0] state, next_state;
    reg                   start, done, clear;
    reg [word_size-1:0]   temp;

    always @ (posedge clk)
        // reset
        if (reset) begin
            temp<= 0;
            bit_count <= 0;
            done <= 0;
            start <= 0;
        end
        // 計算開始
        else if (data_ready && data && !temp) begin
            temp <= data;
            bit_count <= 0;
            done <= 0;
            start <= 1;
        end
        // data 灌 0
        else if (data_ready && (!data) && done) begin
            bit_count <= 0;
            done <= 1;
        end
        // 末位為1 -> 移位
        else if (temp == 1) begin
            bit_count <= bit_count + temp[0];
            temp <= (temp >> 1);
            done <= 1;
        end
        // 計算過程
        else if (temp && !done) begin
            start <= 0;
            temp <= (temp >> 1);
            bit_count <= bit_count + temp[0];
        end
endmodule

// testcase
module t_count_ones_IMP ();
    parameter data_width = 4;
    parameter count_width = 3;
    wire [count_width-1:0] bit_count;
    wire                   start, done;
    reg  [data_width-1:0]  data;
    reg                    data_ready;
    reg                    clk, reset;

    //EPWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        #700 $finish;
    end

    initial begin
        #1 reset = 1;
        #31 reset = 0;
    end

    initial begin
        #120 reset = 1;
        #10 reset = 0;
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        #30 data_ready = 1;
        #20 data_ready = 0;
        #60 data_ready = 1;
        #40 data_ready = 0;
        #40 data_ready = 1;
        #20 data_ready = 0;
        #60 data_ready = 1;
    end

    initial begin
        #5 data = 4'hf;
        #55 data = 4'ha;
        #60 data = 4'h5;
        #60 data = 4'hb;
        #60 data = 4'h9;
        #60 data = 4'h0;
        #60 data = 4'hc;

        #60 data = 4'hd;
        #60 data = 4'h7;
    end

    count_ones_IMP M0 (bit_count, start, done, data, data_ready, clk, reset);

endmodule