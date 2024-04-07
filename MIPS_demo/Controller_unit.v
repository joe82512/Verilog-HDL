module Control(
    input [31:0] Instruction,
    output reg  RegDst, ALUSrc, MemtoReg, RegWrite,
                MemRead, MemWrite, Branch, Jump,
    output reg [1:0] ALUOp
);
    reg [5:0] OpCode;
    always @(*) begin
        OpCode = Instruction[31:26];
        case (OpCode)
            6'b000000: begin //R-type
                RegDst = 1;
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                Jump = 0;
                ALUOp = 2'b10;
            end
            6'b100011: begin //lw: load
                RegDst = 0;
                ALUSrc = 1;
                MemtoReg = 1;
                RegWrite = 1;
                MemRead = 1;
                MemWrite = 0;
                Branch = 0;
                Jump = 0;
                ALUOp = 2'b00;
            end
            6'b101011: begin //sw: store
                RegDst = 0; //X
                ALUSrc = 1;
                MemtoReg = 0; //X
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 1;
                Branch = 0;
                Jump = 0;
                ALUOp = 2'b00;
            end
            6'b000100: begin //beq
                RegDst = 0; //X
                ALUSrc = 0;
                MemtoReg = 0; //X
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                Branch = 1;
                Jump = 0;
                ALUOp = 2'b01;
            end
            6'b000010: begin //jump
                RegDst = 0; //X
                ALUSrc = 0; //X
                MemtoReg = 0; //X
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                Jump = 1;
                ALUOp = 2'b00; //XX
            end
            default: begin
                RegDst = 0;
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                Jump = 0;
                ALUOp = 2'b00;
            end
        endcase
    end
endmodule

module MUX_RegDst(
    input RegDst,
    input [31:0] Instruction,
    output reg [4:0] WriteRegister
);
    // Control 1 -> R type: [rd] = rs+rt
    //         0 -> I type: [rt] = Mem[rs+imm16]

    always @(*) begin
        WriteRegister = (RegDst) ? Instruction[15:11] : Instruction[20:16];
    end
endmodule

module SignExtend(
    input [31:0] Instruction,
    output reg [31:0] SignExt_imm16
);
    // lw/sw/beq used
    always @(*) begin
        SignExt_imm16 = (Instruction[15]) ? {16'hFFFF,Instruction[15:0]} : {16'h0000,Instruction[15:0]};
    end
endmodule

module MUX_ALUSrc(
    input ALUSrc,
    input [31:0] ReadData2, SignExt_imm16,
    output reg [31:0] ALU_B
);
    // Control 1 -> load-store (lw, sw)
    //         0 -> others
    always @(*) begin
        ALU_B = (ALUSrc) ? SignExt_imm16 : ReadData2;
    end
endmodule

module MUX_MemtoReg(
    input MemtoReg,
    input [31:0] ReadData, ALU_result,
    output reg [31:0] WriteData
);
    // Control 1 -> load memory (lw)
    //         0 -> others
    always @(*) begin
        WriteData = (MemtoReg) ? ReadData : ALU_result;
    end
endmodule

module gen_PC_branch(
    input [31:0] PC_next, SignExt_imm16,
    output reg [31:0] PC_branch
);
    // beq: (PC+4) + SignExt_imm16*4
    always @(*) begin
        PC_branch = PC_next + (SignExt_imm16<<2);
    end
endmodule

module MUX_Branch(
    input Branch, Zero,
    input [31:0] PC_next, PC_branch,
    output reg [31:0] PC_out
);
    // Control 1 -> branch (beq)
    //         0 -> others
    always @(*) begin
        PC_out = (Branch & Zero) ? PC_branch : PC_next;
    end
endmodule

module gen_PC_jump(
    input [31:0] PC_next, Instruction,
    output reg [31:0] PC_jump
);
    // jump: {[4-bit PC+4] + [26-bit address] + [2-bit *4] }
    always @(*) begin
        PC_jump = {PC_next[31:28], Instruction[25:0], 2'b00};
    end
endmodule

module MUX_Jump(
    input Jump,
    input [31:0] PC_out, PC_jump,
    output reg [31:0] PC_result
);
    // Control 1 -> jump (J type)
    //         0 -> others 
    always @(*) begin
        PC_result = (Jump) ? PC_jump : PC_out;
    end
endmodule

module ALUControl(
    input [1:0] ALUOp,
    input [31:0] Instruction,
    output reg [3:0] ALUCtl //ALU control signal
);
    // select ALU input signal
    reg [5:0] FuncCode; // R-type
    always @(*) begin
        FuncCode = Instruction[5:0];
        if (ALUOp==2'b00) begin //lw, sw -> ALU: add
            ALUCtl = 4'b0010;
        end
        else if (ALUOp==2'b01) begin //beq -> ALU: sub
            ALUCtl = 4'b0110;
        end
        else begin //R-type
            case (FuncCode)
                6'b100000: ALUCtl = 4'b0010; //add
                6'b100010: ALUCtl = 4'b0110; //sub
                6'b100100: ALUCtl = 4'b0000; //and
                6'b100101: ALUCtl = 4'b0001; //or
                6'b100111: ALUCtl = 4'b1100; //nor
                6'b101010: ALUCtl = 4'b0111; //slt
                default:   ALUCtl = 4'b1111; //X
            endcase
        end
    end
endmodule