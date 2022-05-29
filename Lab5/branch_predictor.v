`include "opcodes.v"

module BranchPredictor #(parameter data_width = 32) ( 
	input alu_bcond,
        output reg PCSrc);

always @(*) begin
    PCSrc = 0;
    if(alu_bcond) begin
        PCSrc = 1;
    end
end

endmodule
