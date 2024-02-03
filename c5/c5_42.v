// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

module up_down_counter (
    output reg [2:0] Count,
    input load, count_up, counter_on, clk, reset,
    input [2:0] Data_in
);
    // 加減計數器
    always @(posedge clk, posedge reset) begin //異步復位
        if (reset)           Count <= 3'b0;
        else if (load==1'b1) Count <= Data_in;
        else if (counter_on==1'b1) begin
            if (count_up) Count <= Count + 1;
            else          Count <= Count - 1;
        end
    end
endmodule



// ==================== testbench.sv ====================
// Code your testbench here
// or browse Examples
module top();
    wire [2:0] Count, Data_in;
    reg load, count_up, counter_on, clk, reset;
    
    //EPWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        #1000 $finish;
    end

    //reset
    initial begin
        reset = 1;
        #10 reset = 0;
        #105 reset = 1; //異步復位
        #10 reset = 0;
    end

    //load
    assign Data_in = 3'b111;
    initial begin
        load = 0;
        #120 load = 1;
        #10 load = 0;
    end

    //clock
    initial begin
        clk = 0;
    end
    always #10 clk = ~clk;
    
    //counter up
    initial begin
        counter_on = 1;
        count_up = 1; //up
        #120 count_up = 0; //down
    end

    up_down_counter UD1(Count, load, count_up, counter_on, clk, reset, Data_in);
endmodule