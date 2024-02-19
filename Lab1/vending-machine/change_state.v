`include "vending_machine_def.v"


module change_state(clk,reset_n,current_total_nxt,current_total,o_available_item_nxt,o_available_item,flag,flag_nxt);

	input clk;//
	input reset_n;//
	input [`kTotalBits-1:0] current_total_nxt;//
	output reg [`kTotalBits-1:0] current_total;//
	output reg [`kNumItems-1:0] o_available_item_nxt;//
	output reg [`kNumItems-1:0] o_available_item;//
	output reg flag, flag_nxt;//
	
	initial begin
		current_total <= 0;
		flag <= 0;
		//o_available_item <= 0;
	end

	// Sequential circuit to reset or update the states
	always @(posedge clk ) begin
		if (!reset_n) begin
			current_total <= 0;
			//o_available_item <= 0;
		end
		else begin
			current_total <= current_total_nxt;
			//o_available_item <= o_available_item_nxt;
		end
	end
endmodule 