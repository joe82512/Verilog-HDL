// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

// 靜態(loop次數已知) + 帶內嵌時序
//forever
module count_ones_b0 (bit_count, data, clk, reset);
    parameter data_width = 4;
    parameter count_width = 3;
    output [count_width-1: 0] bit_count;
    input  [data_width-1: 0]  data;
    input                     clk, reset;
    reg    [count_width-1: 0] count, bit_count;
    reg    [data_width-1: 0]  temp;
    integer index;

    always begin: wrapper_for_synthesis 
        @ (posedge clk) begin: machine
            if (reset) begin
                bit_count = 0;
                disable machine;
            end
            else
                count = 0;
                bit_count = 0;
                index = 0;
                temp = data;
                forever @ (posedge clk) //帶時序的forever
                    if (reset) begin
                        bit_count = 0;
                        disable machine;
                    end
                    else if (index < data_width-1) begin  
                        count = count + temp[0];
                        temp = temp >> 1;
                        index = index + 1;
                    end
                    else begin 
                        bit_count = count + temp[0];
                        disable machine; 
                    end
        end // machine
    end // wrapper_for_synthesis
endmodule

//while
module count_ones_b1 (bit_count, data, clk, reset);
    parameter data_width = 4;
    parameter count_width = 3;
    output [count_width-1: 0] bit_count;
    input  [data_width-1: 0]  data;
    input                     clk, reset;
    reg    [count_width-1: 0] count, bit_count;
    reg    [data_width-1: 0]  temp;
    integer index;

    always begin: wrapper_for_synthesis
        @ (posedge clk) begin: machine
            if (reset) begin
                bit_count = 0;
                disable machine;
            end
            else begin
                count = 0;
                bit_count = 0;
                index = 0;
                temp = data;  
                while (index < data_width) begin 
                    if (reset) begin
                        bit_count = 0;
                        disable machine;
                    end
                    else if ((index < data_width) && (temp[0] )) 
                        count = count + 1;
                        temp = temp >> 1;   
                        index = index +1;
                        @ (posedge clk); //帶時序的while loop
                end

                if (reset) begin
                    bit_count = 0;
                    disable machine;
                end
                else
                    bit_count = count;
                    disable machine;   
            end
        end // machine
    end // wrapper_for_synthesis
endmodule

//for: 綜合工具不支持
module count_ones_b2 (bit_count, data, clk, reset);
    parameter data_width = 4;
    parameter count_width = 3;
    output [count_width-1: 0] bit_count;
    input  [data_width-1: 0]  data;
    input                     clk, reset;
    reg    [count_width-1: 0] count, bit_count;
    reg    [data_width-1: 0]  temp;
    integer index;

    always begin: machine
        for (index = 0; index <= data_width; index = index +1) begin
            @ (posedge clk)
                if (reset) begin
                    bit_count = 0;
                    disable machine;
                end
                else if (index == 0) begin
                    count = 0;
                    bit_count = 0;
                    temp = data;
                end
                else if (index < data_width) begin
                    count = count + temp[0];
                    temp = temp >> 1;
                end 
                else
                    bit_count = count + temp[0]; 
        end
    end // machine
endmodule

// testcase
module t_count_ones_b ();
    parameter data_width = 4;
    parameter count_width = 3;
    wire [count_width-1:0] bit_count_0, bit_count_1, bit_count_2;
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
        #200 reset = 1;
        #211 reset = 0;
    join

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
    end

    count_ones_b0 M0 (bit_count_0, data, clk, reset);
    count_ones_b1 M1 (bit_count_1, data, clk, reset);
    count_ones_b2 M2 (bit_count_2, data, clk, reset);

endmodule