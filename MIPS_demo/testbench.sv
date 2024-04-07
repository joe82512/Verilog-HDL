// Code your testbench here
// or browse Examples

`include "Clock_Unit.v"

module top();
    reg rst;
    wire clk;
    reg [5:0] k; //2^6=64

    // set EPWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        #200 $finish;
    end
    
    // load hardware
    Clock_Unit M1 (clk);
    MIPS M2 (clk, rst);

    // load program
    initial begin
        #0  rst = 1; 
            for (k=0;k<=31;k=k+1) M2.DataMem.Mem[k] = 0; //initial memory
        #5  M2.DataMem.Mem[0] = 5;
            M2.DataMem.Mem[1] = 6;
            M2.DataMem.Mem[2] = 7;
        #10 rst = 0; //start
            M2.RegFile.reg_mem[0] = 0;  //R0
            M2.RegFile.reg_mem[1] = 8;  //R1
            M2.RegFile.reg_mem[2] = 20; //R2
    end

endmodule