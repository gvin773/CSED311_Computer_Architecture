module adder #(parameter data_width=32) (
    input[data_width-1:0] in1,
    input[data_width-1:0] in2,
        output[data_width-1:0] out);

    assign out = in1 + in2;

endmodule
