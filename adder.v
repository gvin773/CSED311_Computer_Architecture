//adder module to add and assign PC+4 to PC 
//hyunjun

module adder #(parameter data_width=32) (
    input[data_width-1:0] in_address,
    input[data_width-1:0] k,
    output[data_width-1:0] out_address);

    assign out_address = in_address + k;

endmodule
























