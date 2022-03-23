`include "opcodes.v"

module ALUControlUnit #(parameter data_width = 11) (
	input [data_width - 1 : 0] part_of_inst,
	    output reg [3 : 0] alu_op);

    reg [6:0] Opcode; //inst[6:0]
    reg [2:0] Funct3; //inst[14:12]
    reg [6:0] Funct7; //inst[31:25], inst[30] for sub

initial begin
    alu_op <= `ALU_NONE; //do nothing
    Opcode <= 7'b0000000;
    Funct3 <= 3'b000;
    Funct7 <= 7'b0000000;
end

always @(part_of_inst) begin
    
    Opcode = part_of_inst[6:0];
    Funct3 = part_of_inst[9:7];
    Funct7 = 7'b0000000;
    Funct7[5] = part_of_inst[10];

	case(Opcode)
        `ARITHMETIC: begin//R-Type: funct3, funct7[5]
            if(Funct3 == `FUNCT3_ADD && Funct7 == `FUNCT7_OTHERS) alu_op = `ALU_ADD;
            else if(Funct3 == `FUNCT3_SUB && Funct7 == `FUNCT7_SUB) alu_op = `ALU_SUB;
            else if(Funct3 == `FUNCT3_OR) alu_op = `ALU_OR;
            else if(Funct3 == `FUNCT3_AND) alu_op = `ALU_AND;
            else if(Funct3 == `FUNCT3_SLL) alu_op = `ALU_SLL;
            else if(Funct3 == `FUNCT3_SRL) alu_op = `ALU_SRL;
            else if(Funct3 == `FUNCT3_XOR) alu_op = `ALU_XOR;
        end

        `ARITHMETIC_IMM: begin //I-Type - Arithmetic_imm: funct3
            if(Funct3 == `FUNCT3_ADD) alu_op = `ALU_ADD;
            else if(Funct3 == `FUNCT3_XOR) alu_op = `ALU_XOR;
            else if(Funct3 == `FUNCT3_OR) alu_op = `ALU_OR;
            else if(Funct3 == `FUNCT3_AND) alu_op = `ALU_AND;
            else if(Funct3 == `FUNCT3_SLL) alu_op = `ALU_SLL;
            else if(Funct3 == `FUNCT3_SRL) alu_op = `ALU_SRL;
        end

        `LOAD: begin //I-Type - Load Inst. (ex. LW)
            alu_op = `ALU_ADD;
        end

        `STORE: begin //S-Type - Store Inst. (ex. SW)
            alu_op = `ALU_ADD;
        end

        `JALR: begin //I-Type - Jump Indirect Inst.
            alu_op = `ALU_ADD;
        end

        `BRANCH: begin //B-Type - Cond. Branch Inst.
            if(Funct3 == `FUNCT3_BEQ) alu_op = `ALU_BEQ;
            else if(Funct3 == `FUNCT3_BNE) alu_op = `ALU_BNE;
            else if(Funct3 == `FUNCT3_BLT) alu_op = `ALU_BLT;
            else if(Funct3 == `FUNCT3_BGE) alu_op = `ALU_BGE;
        end

        default: begin
            alu_op = `ALU_NONE;
        end
	endcase
end

endmodule

