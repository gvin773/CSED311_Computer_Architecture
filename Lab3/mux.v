module MUX2 #(parameter data_width = 32) ( 
    input [data_width - 1 : 0] mux_in_1, 
	input [data_width - 1 : 0] mux_in_2,
    input select_in,
       	output [data_width - 1: 0] mux_result);
    
    assign mux_result = select_in == 0 ? mux_in_1 : mux_in_2;

endmodule

module MUX4 #(parameter data_width = 32) (
    input [data_width - 1 : 0] mux_in_1,
    input [data_width - 1 : 0] mux_in_2,
    input [data_width - 1 : 0] mux_in_3,
    input [data_width - 1 : 0] mux_in_4,
    input [1:0] select_in,
        output [data_width - 1 : 0] mux_result);

    assign mux_result = select_in[1] ? (select_in[0] ? mux_in_4 : mux_in_3) : (select_in[0] ? mux_in_2 : mux_in_1);

endmodule
