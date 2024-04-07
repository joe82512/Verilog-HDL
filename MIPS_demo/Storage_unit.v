
module ProgramCounter(
    input clk, rst,
    input [31:0] PC,
    output reg [31:0] PC_next
);
    // PC+4
    always @(posedge clk) begin
        PC_next <= (rst) ? 32'h00000000 : PC+4;
    end
endmodule

module InstructionMemory(
    input clk,
    input [31:0] ReadAddress, //ProgramCounter
    output reg [31:0] Instruction
);
    // get instruction : instruction depend on compiler
    always @(posedge clk) begin
        case (ReadAddress[9:2])
            8'd0:   Instruction <= 32'h00221820; //add: R3, R1, R2
            8'd1:   Instruction <= 32'hAC010000; //sw: R1, 0(R0)
            8'd2:   Instruction <= 32'h8C240000; //lw R4, 0(R1)
            8'd3:   Instruction <= 32'h10210001; //beq R1, R1, +8
            8'd4:   Instruction <= 32'h00001820; //add R3, R0, R0
            8'd5:   Instruction <= 32'h00411822; //sub R3, R2, R1
            default:Instruction <= 32'h00000000;
        endcase
    end
endmodule

module RegisterFiles(
    input clk, rst, RegWrite,
    input [4:0] WriteRegister,
    input [31:0] Instruction, WriteData,
    output[31:0] ReadData1, ReadData2
);
    reg [31:0] reg_mem[31:0];
    
    // instruction
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i=0;i<32;i=i+1) begin
                reg_mem[i] <= 32'h00000000;
            end
        end
        else begin
            // Control -> R-type update rd, load update rt
            if (RegWrite == 1)
                reg_mem[WriteRegister] <= WriteData;
        end
    end
    // get register data
    assign ReadData1 = reg_mem[Instruction[25:21]]; //ReadRegister1
    assign ReadData2 = reg_mem[Instruction[20:16]]; //ReadRegister2
endmodule

module DataMemory(
    input clk, MemRead, MemWrite,
    input [31:0] Address, Write_data,
    output reg [31:0] ReadData
);
    reg [31:0] Mem[31:0];
    // load-store
    always @(posedge clk) begin
        if (MemRead==1)
            ReadData <= Mem[Address[31:2]];
        else if (MemWrite==1)
            Mem[Address[31:2]] <= Write_data;
    end
endmodule