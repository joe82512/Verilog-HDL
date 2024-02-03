// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

// 動態(loop次數未知) + 帶內嵌時序
module count_ones_d (bit_count, data, clk, reset);
    parameter data_width = 4;
    parameter count_width = 3;
    output [count_width-1:0] bit_count;
    input  [data_width-1:0]  data;
    input                    clk, reset;
    reg    [count_width-1:0] count, bit_count;
    reg    [data_width-1:0]  temp;

    always @ (posedge clk)
        if (reset) begin
            count = 0;
            bit_count = 0;
        end
        else begin: bit_counter
            count = 0;
            temp = data;
            while (temp)
                @ (posedge clk) //帶時序
                    if (reset) begin
                        count = 2'b0;
                        disable bit_counter;
                    end 
                    else begin
                        count = count + temp[0];    
                        temp = temp >> 1;
                    end
            // not in while-loop
            @ (posedge clk) //帶時序
                if (reset) begin
                    count = 0;
                    disable bit_counter;
                end
                else
                    bit_count = count;
        end
endmodule

// testcase
module t_count_ones_d ();
    parameter data_width = 4;
    parameter count_width = 3;
    wire [count_width-1:0] bit_count;
    reg  [data_width-1:0]  data;
    reg                    clk, reset;
 
    count_ones_d M0 (bit_count, data, clk, reset);

    //EPWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        #500 $finish;
    end
    
    initial fork
        reset = 1;
        #10 reset = 0;
        #180 reset = 1;
        #190 reset = 0;
    join

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        #5 data = 4'hf;
        #55 data = 4'h3; 
        #60 data = 4'h5;
        #60 data = 4'hb;
        #60 data = 4'h9;
        #60 data = 4'h0;
        #60 data = 4'hc;

        #60 data = 4'hd;
        #60 data = 4'h7;
    end

endmodule



module count_ones_SD (bit_count, done, data, start, clk, reset);
    parameter data_width = 4;  
    parameter count_width = 3;
    output [count_width-1:0] bit_count;
    output                   done;
    input  [data_width-1:0]  data;
    input                    start, clk, reset;
    reg    [count_width-1:0] count, bit_count, index;
    reg    [data_width-1:0]  temp;
    reg                      done;
  
    always @ (posedge clk) begin: bit_counter
        if (reset) begin
            count = 0;
            bit_count = 0;
            done = 0;
        end
        else if (start) begin
            done = 0;
            count = 0;
            bit_count = 0;
            temp = data;
            for (index = 0; index < data_width; index = index + 1) 
                @ (posedge clk) // Synchronize
                    if (reset) begin 
                        count = 0; 
                        bit_count = 0; 
                        done = 0;
                        disable bit_counter;
                    end 
                    else begin 
                        count = count + temp[0];
                        temp = temp >> 1;
                    end
            // not in for-loop
            @ (posedge clk) // Required for final register transfer
                if (reset) begin
                    count = 0;
                    bit_count = 0;
                    done = 0;
                    disable bit_counter;
                end 
                else begin 
                    bit_count = count; 
                    done = 1; 
                end
        end
    end  // bit_counter
endmodule

// testcase
module t_count_ones_SD();
    parameter counter_size = 3;
    parameter word_size = 4;

    wire [counter_size -1 : 0] bit_count;
    wire                       done;
    reg  [word_size-1: 0]      data;
    reg                        start, clk, reset;

    count_ones_SD M1 (bit_count, done, data, start, clk, reset);
    
    initial fork
        #40 start = 1;
        #120 start = 0;
    join

    //EPWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        #500 $finish;
    end

    initial fork
        reset = 1;
        #10 reset = 0;
    join

    /*initial begin
        #75 reset = 1;
        #10 reset = 0;
        end
        initial begin
        #120 reset = 1;
        #10 reset = 0;
    end*/

    initial begin
        #300 reset = 1;
        #10 reset = 0;
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        #10 data = 4'hf;
        #60 data = 4'ha;
        #60 data = 4'h5;
        #60 data = 4'hb;
        #60 data = 4'h9;
        #60 data = 4'h0;
        #60 data = 4'hc;

        #60 data = 4'hd;
        #60 data = 4'h7;
    end
endmodule