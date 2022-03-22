module PC #(parameter data_width = 32) ( 
    input reset, 
	input clk,
    input [data_width - 1 : 0] next_pc,
       	output reg [data_width - 1: 0] current_pc);

initial begin
    current_pc <= 0;
end

always @(posedge clk) begin
    if(reset) current_pc = 0;
    else current_pc = next_pc;
end

endmodule
