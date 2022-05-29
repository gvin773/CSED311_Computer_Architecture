// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
  //for pc
  wire [31:0] pc4;
  wire [31:0] next_pc;
  wire [31:0] current_pc;

  //for inst mem
  wire [31:0] Instr;

  //for HazardDetection
  wire stall;

  //for Registers
  wire [4:0] rs1;
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;
  wire [31:0] write_data;

  //for Control Unit
  wire mem_read;
  wire mem_to_reg;
  wire mem_write;
  wire alu_src;
  wire write_enable;
  wire pc_to_reg;
  wire [6:0] alu_op;
  wire is_ecall;
  wire is_jal;
  wire is_jalr;
  wire branch;

  //for Imm Gen
  wire [31:0] imm_gen_out;

  //for ALU Control
  wire [3:0] ALUOp;

  //for ALU
  wire [31:0] alu_in_1;
  wire [31:0] alu_in_2;
  wire [31:0] alu_result;
  wire alu_bcond;

  //for branch, jmp
  wire [31:0] adder_in;
  wire [31:0] pc_candidate;
  wire PCSrc;

  //for Cache for Data Memory
  wire [31:0] dout;
  wire is_ready;
  wire is_output_valid;
  wire is_hit;
  wire neg_stall_for_cache;

  //for starting
  reg ID;
  reg EX;
  reg MEM;

  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  /***** IF/ID pipeline registers *****/
  reg [31:0] IF_ID_inst;           // will be used in ID stage
  reg [31:0] IF_ID_pc;
  /***** ID/EX pipeline registers *****/
  // From the control unit
  reg [6:0] ID_EX_alu_op;         // will be used in EX stage
  reg ID_EX_alu_src;        // will be used in EX stage
  reg ID_EX_mem_write;      // will be used in MEM stage
  reg ID_EX_mem_read;       // will be used in MEM stage
  reg ID_EX_mem_to_reg;     // will be used in WB stage
  reg ID_EX_reg_write;      // will be used in WB stage
  reg ID_EX_pc_to_reg;
  reg ID_EX_is_jal;
  reg ID_EX_is_jalr;
  reg ID_EX_branch;
  // From others
  reg [31:0] ID_EX_rs1_data;
  reg [31:0] ID_EX_rs2_data;
  reg [31:0] ID_EX_imm;
  reg [3:0] ID_EX_ALU_ctrl_unit_input;
  reg [4:0] ID_EX_rd;
  reg [31:0] ID_EX_pc;

  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg EX_MEM_mem_write;     // will be used in MEM stage
  reg EX_MEM_mem_read;      // will be used in MEM stage
  reg EX_MEM_mem_to_reg;    // will be used in WB stage
  reg EX_MEM_reg_write;     // will be used in WB stage
  reg EX_MEM_pc_to_reg;
  // From others
  reg [31:0] EX_MEM_alu_out;
  reg [31:0] EX_MEM_dmem_data;
  reg [4:0] EX_MEM_rd;

  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage
  // From others
  reg [31:0] MEM_WB_mem_to_reg_src_1;
  reg [31:0] MEM_WB_mem_to_reg_src_2;
  reg [4:0] MEM_WB_rd;

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .stall(stall || !neg_stall_for_cache),
    .PCSource(PCSrc),
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );

  adder add4(
    .in1(current_pc),
    .in2(4),
    .out(pc4)
  );

  MUX get_nextpc(
    .mux_in_1(pc4),
    .mux_in_2(pc_candidate),
    .select_in(PCSrc),
    .mux_result(next_pc)
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(Instr)     // output
  );

  // Update IF/ID pipeline registers here
  always @(posedge clk) begin
    if (reset || PCSrc) begin
      IF_ID_inst <= 0;
      IF_ID_pc <= 0;
      ID <= 0;
    end
    else if(!stall && neg_stall_for_cache) begin
      IF_ID_inst <= Instr;
      IF_ID_pc <= current_pc;
      ID <= 1;
    end
  end

  HazardDetectionUnit detect_hazard (
    .Instruction(IF_ID_inst),
    .EX_rd(ID_EX_rd),
    .MEM_rd(EX_MEM_rd),
    .WB_rd(MEM_WB_rd),
    .EX_reg_write(ID_EX_reg_write),
    .MEM_reg_write(EX_MEM_reg_write),
    .WB_reg_write(MEM_WB_reg_write),
    .stall(stall)
  );

  assign rs1 = (is_ecall) ? 17 : IF_ID_inst[19:15];
  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (rs1),          // input
    .rs2 (IF_ID_inst[24:20]),          // input
    .rd (MEM_WB_rd),           // input
    .rd_din (write_data),       // input
    .write_enable (MEM_WB_reg_write),    // input
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout)      // output
  );
  assign is_halted = is_ecall && rs1_dout == 10;

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(IF_ID_inst[6:0]),  // input
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .write_enable(write_enable),  // output
    .pc_to_reg(pc_to_reg),     // output
    .alu_op(alu_op),        // output
    .is_ecall(is_ecall),       // output (ecall inst)
    .is_jal(is_jal),
    .is_jalr(is_jalr),
    .branch(branch)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IF_ID_inst),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset || stall || PCSrc) begin
      ID_EX_alu_op <= 7'b0000000;
      ID_EX_alu_src <= 1'b0;
      ID_EX_mem_write <= 1'b0;
      ID_EX_mem_read <= 1'b0;
      ID_EX_mem_to_reg <= 1'b0;
      ID_EX_reg_write <= 1'b0;
      ID_EX_pc_to_reg <= 1'b0;
      ID_EX_is_jal <= 1'b0;
      ID_EX_is_jalr <= 1'b0;
      ID_EX_branch <= 1'b0;
      ID_EX_rs1_data <= 0;
      ID_EX_rs2_data <= 0;
      ID_EX_imm <= 0;
      ID_EX_ALU_ctrl_unit_input <= 4'b0000;
      ID_EX_rd <= 5'b00000;
      ID_EX_pc <= 0;
      EX <= 0;
    end
    else if(ID && neg_stall_for_cache) begin
      ID_EX_alu_op <= alu_op;
      ID_EX_alu_src <= alu_src;
      ID_EX_mem_write <= mem_write;
      ID_EX_mem_read <= mem_read;
      ID_EX_mem_to_reg <= mem_to_reg;
      ID_EX_reg_write <= write_enable;
      ID_EX_pc_to_reg <= pc_to_reg;
      ID_EX_is_jal <= is_jal;
      ID_EX_is_jalr <= is_jalr;
      ID_EX_branch <= branch;
      ID_EX_rs1_data <= rs1_dout;
      ID_EX_rs2_data <= rs2_dout;
      ID_EX_imm <= imm_gen_out;
      ID_EX_ALU_ctrl_unit_input <= {IF_ID_inst[30], IF_ID_inst[14:12]};
      ID_EX_rd <= IF_ID_inst[11:7];
      ID_EX_pc <= IF_ID_pc;
      EX <= 1;
    end
  end

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(ID_EX_ALU_ctrl_unit_input),  // input
    .Opcode(ID_EX_alu_op), //input
    .alu_op(ALUOp)         // output
  );

  MUX get_alu_in_1 (
    .mux_in_1(ID_EX_rs1_data),
    .mux_in_2(ID_EX_pc),
    .select_in(ID_EX_is_jal || ID_EX_is_jalr),
    .mux_result(alu_in_1)
  );

  MUX get_alu_in_2 (
    .mux_in_1(ID_EX_rs2_data),
    .mux_in_2(ID_EX_imm),
    .select_in(ID_EX_alu_src),
    .mux_result(alu_in_2)
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(ALUOp),      // input
    .alu_in_1(alu_in_1),    // input  
    .alu_in_2(alu_in_2),    // input
    .alu_result(alu_result),  // output
    .alu_bcond(alu_bcond)
  );

  MUX get_adder_in(
    .mux_in_1(ID_EX_pc),
    .mux_in_2(ID_EX_rs1_data),
    .select_in(ID_EX_is_jalr),
    .mux_result(adder_in)
  );

  adder get_pc_candidate(
    .in1(adder_in),
    .in2(ID_EX_imm),
    .out(pc_candidate)
  );

  BranchPredictor predict_branch(
    .alu_bcond(alu_bcond),
    .PCSrc(PCSrc)
  );

  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset || !EX) begin
      EX_MEM_mem_write <= 1'b0;
      EX_MEM_mem_read <= 1'b0;
      EX_MEM_mem_to_reg <= 1'b0;
      EX_MEM_reg_write <= 1'b0;
      EX_MEM_pc_to_reg <= 1'b0;
      EX_MEM_alu_out <= 0;
      EX_MEM_dmem_data <= 0;
      EX_MEM_rd <= 5'b00000;
      MEM <= 0;
    end
    else if(EX && neg_stall_for_cache) begin
      EX_MEM_mem_write <= ID_EX_mem_write;
      EX_MEM_mem_read <= ID_EX_mem_read;
      EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
      EX_MEM_reg_write <= ID_EX_reg_write;
      EX_MEM_pc_to_reg <= ID_EX_pc_to_reg;
      EX_MEM_alu_out <= alu_result;
      EX_MEM_dmem_data <= ID_EX_rs2_data;
      EX_MEM_rd <= ID_EX_rd;
      MEM <= 1;
    end
  end

  // ---------- Cache for Data Memory ----------
  Cache cache(
    .reset(reset),
    .clk(clk),
    .is_input_valid(1'b1),
    .addr(EX_MEM_alu_out),
    .mem_read(EX_MEM_mem_read),
    .mem_write(EX_MEM_mem_write),
    .din(EX_MEM_dmem_data), //input
    .is_ready(is_ready),
    .is_output_valid(is_output_valid),
    .dout(dout),
    .is_hit(is_hit) //output
  );
  assign neg_stall_for_cache = (is_ready && is_hit && is_output_valid);

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset || !MEM) begin
      MEM_WB_mem_to_reg <= 1'b0;
      MEM_WB_reg_write <= 1'b0;
      MEM_WB_mem_to_reg_src_1 <= 0;
      MEM_WB_mem_to_reg_src_2 <= 0;
      MEM_WB_rd <= 5'b00000;
    end
    else if(MEM) begin
      MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
      MEM_WB_reg_write <= EX_MEM_reg_write;
      MEM_WB_mem_to_reg_src_1 <= EX_MEM_alu_out;
      MEM_WB_mem_to_reg_src_2 <= dout;
      MEM_WB_rd <= EX_MEM_rd;
    end
  end

  MUX get_write_data(
    .mux_in_1(MEM_WB_mem_to_reg_src_1),
    .mux_in_2(MEM_WB_mem_to_reg_src_2),
    .select_in(MEM_WB_mem_to_reg),
    .mux_result(write_data)
  );
  
endmodule
