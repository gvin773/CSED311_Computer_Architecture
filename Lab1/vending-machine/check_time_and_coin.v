`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,i_select_item,clk,reset_n,i_trigger_return,current_total,coin_value,item_price,wait_time,o_return_coin,o_available_item);
	input clk;//
	input reset_n;//
	input i_trigger_return;//
	input [`kNumCoins-1:0] i_input_coin;//
	input [`kNumItems-1:0]	i_select_item;//
	input [`kTotalBits-1:0] current_total;//
	input [31:0] coin_value [`kNumCoins-1:0];//
	input [31:0] item_price [`kNumItems-1:0];//
	output reg  [`kNumCoins-1:0] o_return_coin;//
	output reg [31:0] wait_time;//
	output reg [`kNumItems-1:0] o_available_item;//
	integer i, sum;//

	// initiate values
	initial begin
		wait_time <= `kWaitTime;
	end


	// update coin return time
	always @(i_input_coin, i_select_item) begin
		if(i_input_coin) wait_time = 100;
		//case 1: inserting money

		for(i = `kNumItems; i >= 0; i = i-1) begin
			if(i_select_item[i] && current_total >= item_price[i]) wait_time = 100;
		end //비트 성질(avail_item) 이용해서 더 빠르게 수정해볼까?
		//case 2: selecting an item & the item is available
	end

	always @(*) begin
		o_return_coin = 0;
		if(($signed(wait_time) <= 0) || i_trigger_return) begin
			sum = 0;
			for(i = `kNumCoins-1; i >= 0; i = i-1) begin
				if(current_total-sum >= coin_value[i]) begin
					o_return_coin[i] = 1'b1;
					sum = sum + coin_value[i];
				end
			end
		end
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
			wait_time <= `kWaitTime;
		end
		else begin
			wait_time <= wait_time - 1;
		end
	end
endmodule 