
//Immediate Generator module - hyunjun
//sign extension of immediate value 

`include "opcodes.v"

module ImmediateGenerator(part_of_inst, imm_gen_out);

input [31:0] part_of_inst;
output reg[31:0] imm_gen_out;


initial begin
    imm_gen_out = 32'b0;
end

always @(*) begin
    if((part_of_inst==`ARITHMETIC_IMM) || (part_of_inst==`LOAD) || (part_of_inst==`JALR)) begin  //I-type
        imm_gen_out[11:0] <= part_of_inst[31:20];
    	imm_gen_out[31:12] <= 20'b0;
    end

    else if(part_of_inst==`STORE) begin  //S-type
        imm_gen_out[11:5] <= part_of_inst[31:25];
        imm_gen_out[4:0] <= part_of_inst[11:7];
	    imm_gen_out[31:12] <= 20'b0;
    end

    else if(part_of_inst==`JAL) begin  //UJ-type
        imm_gen_out[0] <= 1'b0;
	    imm_gen_out[20] <= part_of_inst[31];
	    imm_gen_out[10:1] <= part_of_inst[30:21];
	    imm_gen_out[11] <= part_of_inst[20];
	    imm_gen_out[19:12] <= part_of_inst[19:12];
	    imm_gen_out[31:21] <= 11'b0;
    end

    else if(part_of_inst==`BRANCH) begin  //B-type
        imm_gen_out[0] <= 1'b0;
	    imm_gen_out[12] <= part_of_inst[31];
        imm_gen_out[10:5] <= part_of_inst[30:25];
	    imm_gen_out[4:1] <= part_of_inst[11:8];
	    imm_gen_out[11] <= part_of_inst[7];
    end

end
endmodule

