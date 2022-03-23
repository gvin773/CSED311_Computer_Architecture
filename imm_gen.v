
//Immediate Generator module - hyunjun
//sign extension of immediate value 

`include "opcodes.v"

module imm_gen(part_of_inst, alu_op);

input [31:0] part_of_inst;
output reg[31:0] alu_op;


initial begin
    alu_op = 32'b0;
end

always @(*) begin
    if((part_of_inst==`ARITHMETIC_IMM) || (part_of_inst==`LOAD) || (part_of_inst==`JALR))  //I-type
        alu_op[11:0] <= part_of_inst[31:20];
    	alu_op[31:12] <= 20'b0;
    end

    else if(part_of_inst==`STORE)  //S-type
        alu_op[11:5] <= part_of_inst[31:25];
        alu_op[4:0] <= part_of_inst[11:7];
	alu_op[31:12] <= 20'b0;
    end

    else if(part_of_inst==`JAL)  //UJ-type
        alu_op[0] <= 1'b0;
	alu_op[20] <= part_of_inst[31];
	alu_op[10:1] <= part_of_inst[30:21];
	alu_op[11] <= part_of_inst[20];
	alu_op[19:12] <= part_of_inst[19:12];
	alu_op[31:21] <= 11'b0;
    end

    else if(part_of_inst==`BRANCH)  //B-type
        alu_op[0] <= 1'b0;
	alu_op[12] <= part_of_inst[31]
        alu_op[10:5] <= part_of_inst[30:25];
	alu_op[4:1] <= part_of_inst[11:8];
	alu_op[11] <= part_of_inst[7];
    end

end
endmodule

