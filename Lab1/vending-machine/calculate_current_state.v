
`include "vending_machine_def.v"
	

module calculate_current_state(i_input_coin,i_select_item,item_price,coin_value,current_total,
input_total, output_total, return_total,current_total_nxt,wait_time,o_return_coin,o_available_item,o_output_item);


	
	input [`kNumCoins-1:0] i_input_coin,o_return_coin;//
	input [`kNumItems-1:0]	i_select_item;//			
	input [31:0] item_price [`kNumItems-1:0];//
	input [31:0] coin_value [`kNumCoins-1:0];//	
	input [`kTotalBits-1:0] current_total;//
	input [31:0] wait_time;//
	output reg [`kNumItems-1:0] o_available_item,o_output_item;//
	output reg  [`kTotalBits-1:0] input_total, output_total, return_total,current_total_nxt;//
	integer i;//
	//output reg[`kNumItems-1:0] o_available_item_nxt;

	initial begin
		input_total <= 0;
		output_total <= 0;
		return_total <= 0;
		current_total_nxt <= 0;
		o_available_item <= 0;
		o_output_item <= 0;
	end
	
	// Combinational logic for the next states
	always @(*) begin
		if(i_input_coin) begin
			for(i = `kNumCoins-1; i >= 0; i = i-1) begin
				if(i_input_coin[i]) input_total = input_total + coin_value[i];
			end
		end

		else if(i_select_item) begin
			for(i = `kNumItems-1; i >= 0; i = i-1) begin
				if(i_select_item[i] && current_total >= item_price[i]) output_total = output_total + item_price[i];
			end
		end

		else begin
			for(i = `kNumCoins-1; i >= 0; i = i-1) begin
				if(o_return_coin[i]) return_total = return_total + coin_value[i];
			end
		end

		current_total_nxt = input_total - return_total - output_total;
	end

	
	
	// Combinational logic for the outputs
	always @(*) begin
		if(current_total >= item_price[3]) o_available_item = 4'b1111;
		else if(current_total >= item_price[2]) o_available_item = 4'b0111;
		else if(current_total >= item_price[1]) o_available_item = 4'b0011;
		else if(current_total >= item_price[0]) o_available_item = 4'b0001;
		else o_available_item = 4'b0000;

		if(i_select_item) begin
			o_output_item = 0;
			for(i = `kNumItems; i >= 0; i = i-1) begin
				if(i_select_item[i] && current_total >= item_price[i]) o_output_item[i] = 1'b1;
			end
		end
	end

endmodule 