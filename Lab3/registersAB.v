module UpdateRegistersAB #(parameter data_width = 32) ( 
    input reset,
	input clk,
    input [data_width - 1 : 0] A_new,
    input [data_width - 1 : 0] B_new,
       	output reg [data_width - 1 : 0] A,
        output reg [data_width - 1 : 0] B);

always @(*) begin
    if(reset) begin
        A <= 0;
        B <= 0;
    end
    else begin
        A <= A_new;
        B <= B_new;
    end
end

endmodule
