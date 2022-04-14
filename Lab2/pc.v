module PC #(parameter data_width = 32) ( 
    input reset, 
	input clk,
    input [data_width - 1 : 0] next_pc,
       	output reg [data_width - 1: 0] current_pc);

always @(posedge clk) begin
    if(reset) current_pc <= 0;
    else current_pc <= next_pc; //update when posedge
end

endmodule