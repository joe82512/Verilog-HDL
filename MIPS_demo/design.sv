// Code your design here
// waveform: Icarus Verilog 0.9.7

`include "ALU_unit.v"
`include "Controller_unit.v"
`include "Storage_unit.v"

module MIPS(clk, rst);
    input clk, rst;

    // PC
    wire [31:0] PC, PC_next, PC_branch, PC_out, PC_jump;
    
    // instruction code
    wire [31:0] Instruction;
    
    // Register
    wire [4:0] ReadRegister1, ReadRegister2, WriteRegister;
    wire [31:0] WriteData;
    wire [31:0] ReadData1, ReadData2;

    // DataMemory
    wire [31:0] ReadData;

    // ALU
    wire [3:0] ALUCtl; //ALUControl
    wire Zero;
    wire [31:0] ALU_B, ALU_result;

    // Control
    wire RegDst, ALUSrc, MemtoReg, RegWrite,
         MemRead, MemWrite, Branch, Jump;
    wire [1:0] ALUOp;

    // SignExtend
    wire [31:0] SignExt_imm16;

    ProgramCounter ProgramCnt(
        .clk(clk), .rst(rst),
        .PC(PC), .PC_next(PC_next)
    );

    InstructionMemory InstMem(
        .clk(clk),
        .ReadAddress(PC), //ProgramCounter
        .Instruction(Instruction)
    );

    RegisterFiles RegFile(
        .clk(clk), .rst(rst),
        .RegWrite(RegWrite),
        .Instruction(Instruction), .WriteRegister(WriteRegister),
        .WriteData(WriteData), .ReadData1(ReadData1), .ReadData2(ReadData2)
    );

    DataMemory DataMem(
        .clk(clk),
        .MemRead(MemRead), .MemWrite(MemWrite),
        .Address(ALU_result), //Address==ALU_result
        .Write_data(ReadData2), //Write_data==ReadData2
        .ReadData(ReadData)
    );
    
    ALU A1(
        .ALUCtl(ALUCtl),
        .ALU_A(ReadData1), .ALU_B(ALU_B), //ReadData1==ALU_A
        .Zero(Zero), .ALU_result(ALU_result)
    );

    Control C1(
        .Instruction(Instruction),
        .RegDst(RegDst), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), .RegWrite(RegWrite),
        .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .Jump(Jump),
        .ALUOp(ALUOp)
    );

    MUX_RegDst Mux1(
        .RegDst(RegDst), .Instruction(Instruction),
        .WriteRegister(WriteRegister)
    );

    SignExtend SE1(
        .Instruction(Instruction), .SignExt_imm16(SignExt_imm16)
    );

    MUX_ALUSrc M2(
        .ALUSrc(ALUSrc), 
        .ReadData2(ReadData2), .SignExt_imm16(SignExt_imm16),
        .ALU_B(ALU_B)
    );

    MUX_MemtoReg M3(
        .MemtoReg(MemtoReg), .ReadData(ReadData), .ALU_result(ALU_result),
        .WriteData(WriteData)
    );

    gen_PC_branch PC2(
        .PC_next(PC_next), .SignExt_imm16(SignExt_imm16), .PC_branch(PC_branch)
    );

    MUX_Branch M4(
        .Branch(Branch), .Zero(Zero),
        .PC_next(PC_next), .PC_branch(PC_branch), .PC_out(PC_out)
    );

    gen_PC_jump PC3(
        .PC_next(PC_next), .Instruction(Instruction), .PC_jump(PC_jump)
    );

    MUX_Jump M5(
        .Jump(Jump), .PC_out(PC_out), .PC_jump(PC_jump),
        .PC_result(PC) //PC_result==PC
    );

    ALUControl C2(
        .Instruction(Instruction), .ALUOp(ALUOp), .ALUCtl(ALUCtl)
    );
endmodule