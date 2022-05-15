`include "opcodes.v"

module ImmediateGenerator(part_of_inst, imm_gen_out);

input [31:0] part_of_inst;
output reg[31:0] imm_gen_out;

wire [6:0] Opcode;

assign Opcode = part_of_inst[6:0];

always @(*) begin
    if((Opcode==`ARITHMETIC_IMM) || (Opcode==`LOAD)) begin  //I-type
        imm_gen_out[11:0] <= part_of_inst[31:20];
    	if(part_of_inst[31]) imm_gen_out[31:12] <= 20'b11111111111111111111;
        else imm_gen_out[31:12] <= 20'b00000000000000000000;
    end

    else if(Opcode==`STORE) begin  //S-type
        imm_gen_out[11:5] <= part_of_inst[31:25];
        imm_gen_out[4:0] <= part_of_inst[11:7];
        if(part_of_inst[31]) imm_gen_out[31:12] <= 20'b11111111111111111111;
        else imm_gen_out[31:12] <= 20'b00000000000000000000;
    end

end
endmodule
