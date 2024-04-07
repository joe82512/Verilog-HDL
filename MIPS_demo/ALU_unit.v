module ALU(
    input [3:0] ALUCtl,
    input [31:0] ALU_A, ALU_B,
    output reg Zero,
    output reg [31:0] ALU_result
);
    // ALU design
    always @(*) begin
        case (ALUCtl)
            4'b0000: ALU_result = ALU_A & ALU_B;
            4'b0001: ALU_result = ALU_A | ALU_B;
            4'b0010: ALU_result = ALU_A + ALU_B;
            4'b0110: ALU_result = ALU_A - ALU_B;
            4'b0111: ALU_result = (ALU_A < ALU_B) ? 1:0; //slt, less than
            4'b1100: ALU_result = ~(ALU_A | ALU_B); //nor
            default: ALU_result = 0;
        endcase
        Zero = (ALU_result == 32'h00000000);
    end

endmodule