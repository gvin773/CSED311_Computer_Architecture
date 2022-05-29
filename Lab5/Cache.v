`include "CLOG2.v"
module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = 16,
               parameter NUM_WAYS = 1) (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_read,
    input mem_write,
    input [31:0] din,

    output is_ready,
    output is_output_valid,
    output [31:0] dout,
    output is_hit);
  // Wire declarations
    wire is_data_mem_ready;
    wire [23:0] tag;
    wire [3:0] index;
    wire [1:0] block_offset;
    wire [1:0] offset;

    wire is_hit_read;
    wire is_hit_write;

    wire [16*8-1:0] dm_din;
    wire [16*8-1:0] cache_in;
    wire is_dout_valid;
  // Reg declarations
    reg [23:0] cache_tag_array [0:15];
    reg [16*8-1:0] cache_data_array [0:15];
    reg [15:0] valid_bit;
    reg [15:0] dirty_bit;

  // You might need registers to keep the status.
    assign tag = addr[31:8];
    assign index = addr[7:4];
    assign block_offset = addr[3:2];
    assign offset = addr[1:0];

    assign is_ready = is_data_mem_ready;
    assign dout = (mem_read && valid_bit[index] && (cache_tag_array[index] == tag)) ? cache_data_array[index][32*block_offset +: 32] : 0; //hit-read
    assign is_output_valid = (!mem_read && !mem_write) || mem_write || (mem_read && valid_bit[index] && (cache_tag_array[index] == tag));
    assign is_hit_read = mem_read && valid_bit[index] && (cache_tag_array[index] == tag); //read hit
    assign is_hit_write = mem_write && valid_bit[index] && (cache_tag_array[index] == tag);
    assign is_hit = (!mem_read && !mem_write) || (mem_read && is_hit_read) || (mem_write && is_hit_write);

    always@(posedge clk) begin
      if(reset) begin
        cache_tag_array[0] <= 24'b0;
        cache_tag_array[1] <= 24'b0;
        cache_tag_array[2] <= 24'b0;
        cache_tag_array[3] <= 24'b0;
        cache_tag_array[4] <= 24'b0;
        cache_tag_array[5] <= 24'b0;
        cache_tag_array[6] <= 24'b0;
        cache_tag_array[7] <= 24'b0;
        cache_tag_array[8] <= 24'b0;
        cache_tag_array[9] <= 24'b0;
        cache_tag_array[10] <= 24'b0;
        cache_tag_array[11] <= 24'b0;
        cache_tag_array[12] <= 24'b0;
        cache_tag_array[13] <= 24'b0;
        cache_tag_array[14] <= 24'b0;
        cache_tag_array[15] <= 24'b0;
        cache_data_array[0] <= 128'b0;
        cache_data_array[1] <= 128'b0;
        cache_data_array[2] <= 128'b0;
        cache_data_array[3] <= 128'b0;
        cache_data_array[4] <= 128'b0;
        cache_data_array[5] <= 128'b0;
        cache_data_array[6] <= 128'b0;
        cache_data_array[7] <= 128'b0;
        cache_data_array[8] <= 128'b0;
        cache_data_array[9] <= 128'b0;
        cache_data_array[10] <= 128'b0;
        cache_data_array[11] <= 128'b0;
        cache_data_array[12] <= 128'b0;
        cache_data_array[13] <= 128'b0;
        cache_data_array[14] <= 128'b0;
        cache_data_array[15] <= 128'b0;
        valid_bit <= 16'b0;
        dirty_bit <= 16'b0;
      end
      else if(is_hit_write) begin //write hit
        cache_data_array[index][32*block_offset +: 32] <= din;
        dirty_bit[index] <= 1'b1;
      end
      else if(mem_read && !is_hit_read) begin //read miss
        if(is_data_mem_ready && is_dout_valid) begin
          dirty_bit[index] <= 1'b0;
          cache_data_array[index] <= cache_in;
          cache_tag_array[index] <= tag;
          valid_bit[index] <= 1'b1;
        end
      end
      else if(mem_write) begin //write miss
        if(is_data_mem_ready && is_dout_valid) begin
          dirty_bit[index] <= 1'b0;
          cache_data_array[index] <= cache_in;
          cache_tag_array[index] <= tag;
          valid_bit[index] <= 1'b1;
        end
      end
    end

    assign dm_din = cache_data_array[index];
  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),

    .is_input_valid(1'b1),
    .addr(addr>>`CLOG2(LINE_SIZE)), // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(!is_hit),
    .mem_write((!is_hit && mem_read && dirty_bit[index]) || (!is_hit && mem_write && dirty_bit[index])),
    .din(dm_din),

    // is output from the data memory valid?
    .is_output_valid(is_dout_valid),
    .dout(cache_in),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );
endmodule
