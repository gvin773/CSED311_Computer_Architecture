module MUX #(parameter data_width = 32) ( 
    input [data_width - 1 : 0] mux_in_1, 
	input [data_width - 1 : 0] mux_in_2,
    input select_in,
       	output [data_width - 1: 0] mux_result);
    
    assign mux_result = select_in == 0 ? mux_in_1 : mux_in_2;

endmodule
