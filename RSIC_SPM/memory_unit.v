module Memory_Unit (data_out, data_in, address, clk, write);
    parameter word_size = 8;
    parameter memory_size = 256;

    output [word_size-1: 0] data_out;   //回傳給 Process
    input  [word_size-1: 0] data_in;    //BUS_1, Process 給
    input  [word_size-1: 0] address;    //Process 給
    input clk, write;                   //write由 Control 給
    reg [word_size-1: 0] memory [memory_size-1: 0]; //儲存

    //read
    assign data_out = memory[address];

    //write
    always @ (posedge clk)
        if (write) memory[address] = data_in;
endmodule