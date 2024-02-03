// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

module ring_counter #(parameter word_size = 8) (
    output reg [word_size-1:0] count,
    input enable, clock, reset
);
    // 環形計數器
    always @(posedge clock, posedge reset) begin //異步復位
        if (reset)             count <= { {(word_size-1){1'b0}}, 1'b1 };
        else if (enable==1'b1) count <= { count[word_size-2:0], count[word_size-1] };
    end
endmodule



// ==================== testbench.sv ====================
// Code your testbench here
// or browse Examples
module top();
    wire [7:0] count;
    wire enable, clock, reset;
    reg osc, rst;
    
    //EPWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        #1000 $finish;
    end

    //enable
    assign enable = 1;

    //clock
    initial begin
        osc = 0;
    end

    always begin
        #10 osc = ~osc;
    end

    assign clock = osc;
    
    //reset
    initial begin
        rst = 1;
        #10 rst = 0;
        #105 rst = 1; //異步復位
        #10 rst = 0;
    end

    assign reset = rst;

    ring_counter R1(count, enable, clock, reset);
endmodule