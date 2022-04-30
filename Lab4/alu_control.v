//completed-gyubin
`include "opcodes.v"

module ALUControlUnit #(parameter data_width = 4) (
	input [data_width - 1 : 0] part_of_inst,
    input [6 : 0] Opcode,
	    output reg [3 : 0] alu_op);

    reg [2:0] Funct3; //inst[14:12]
    reg [6:0] Funct7; //inst[31:25], inst[30] for sub

always @(*) begin

    Funct3 = part_of_inst[2:0];
    Funct7 = 7'b0000000;
    Funct7[5] = part_of_inst[3];

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

        default: begin
            alu_op = `ALU_NONE;
        end
	endcase
end

endmodule
