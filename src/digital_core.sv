///////////////////////////////////////////////////////////////////
// File Name: digital_core.sv
// Engineer:  Tarun Prakash (tprakash@lbl.gov)
// Description: nanoCMOS synthesized digital core.  
//              Includes:
//              UARTs for inter-chip communcation
//              64-byte Register Map for configuration bits
//
//              Note that the "primary" is the chip writing to and reading
//              from the current chip. It could also be the FPGA.
//              The "secondary" is always the current chip.
//
///////////////////////////////////////////////////////////////////

module digital_core
    #(parameter NUMREGS = 16, // number of configuration registers
        parameter PIXEL_NUM_ROW = 7,   
        parameter PIXEL_NUM_COL = 16)   
    
    (output logic PISO,// PRIMARY-IN-SECONDARY-OUT TX UART output bit
    
// ANALOG CORE CONFIGURATION SIGNALS
    output logic [7:0] opamp_bias1, // opamp biasing configuration registers
    output logic [7:0] opamp_bias2, // opamp biasing configuration registers
// SPARES
    output logic [7:0] spare0,  // 8 spare configuration bits
    output logic [7:0] spare1,  // 8 spare configuration bits
    output logic [7:0] spare2,  // 8 spare configuration bits
    output logic [7:0] spare3,  // 8 spare configuration bits
//readout switching logic
    output logic [PIXEL_NUM_ROW-1:0] row_sample,
    output logic [PIXEL_NUM_COL-1:0] col_sample,
    
    
    input logic SAMPLE_EN,
    //input logic gate_reset, // TP: removed
    //input logic vg, // TP: removed 
    
    output logic ADC_EN, //adc_enable
    output logic CLK_OUT,
// INPUTS
    input logic POSI,       // PRIMARY-OUT-SECONDARY-IN: RX UART input bit  
    input logic CLK,        // clk for UART
    input logic RESET_N);   // asynchronous reset for UART (active low)

`include "nanoCMOS_chip_constants.sv"
localparam PIXEL_ADDR_BITS_ROW = $clog2(PIXEL_NUM_ROW);
localparam PIXEL_ADDR_BITS_COL = $clog2(PIXEL_NUM_COL );

logic [7:0] config_bits [0:NUMREGS-1];// regmap config bit outputs
logic       single_pixel_en;
logic       pixel_disable;
logic [7:0] single_pixel_row_addr;
logic [7:0] single_pixel_col_addr;
logic correlated_double_sampling;

always_comb begin
    opamp_bias1                 = config_bits[OPBIAS1][7:0];
    opamp_bias2                 = config_bits[OPBIAS2][7:0];
    single_pixel_en             = config_bits[S_PIXEL_EN][0];
    single_pixel_row_addr       = config_bits[S_PIXEL_ROW][7:0];
    single_pixel_col_addr       = config_bits[S_PIXEL_COL][7:0];
    pixel_disable               = config_bits[PIXEL_DISABLE][0];
    correlated_double_sampling  = config_bits[CDS][0];

    
    spare0 = config_bits[REG12][7:0]; // GAINSEL
    spare1 = config_bits[REG13][7:0]; //SOURCE/SOURCEN & SINK/SINKN
    spare2 = config_bits[REG14][7:0];
    spare3 = config_bits[REG15][7:0];
end // always_comb

external_interface
    #(.NUMREGS(NUMREGS)
    ) external_interface_inst (
    .config_bits            (config_bits),
    .piso                   (PISO),
    .posi                   (POSI),
    .clk                    (CLK),
    .reset_n                (RESET_N)
    );

sample
    #(.PIXEL_NUM_ROW (PIXEL_NUM_ROW),
      .PIXEL_NUM_COL (PIXEL_NUM_COL),
      .PIXEL_ADDR_BITS_ROW (PIXEL_ADDR_BITS_ROW),
      .PIXEL_ADDR_BITS_COL (PIXEL_ADDR_BITS_COL)
    ) sampling_counter (
    .clk            (CLK), 
    .reset_n        (RESET_N), 
    .enable         (SAMPLE_EN),
    .single_pixel_en(single_pixel_en),
    .pixel_disable  (pixel_disable),
    .correlated_double_sampling  (correlated_double_sampling),               
    .single_pixel_row_addr (single_pixel_row_addr),
    .single_pixel_col_addr (single_pixel_col_addr),
    .row            (row_sample), 
    .col            (col_sample),
    .start          (ADC_EN),
    .clk_out        (CLK_OUT)
    );

endmodule
