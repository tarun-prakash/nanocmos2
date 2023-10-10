///////////////////////////////////////////////////////////////////
// File Name: digital_core_tb.sv
// Engineer:  
// Description: SystemVerilog testbench for digital_core.sv.
//              The purpose of the digital_core is to read 
//              and write the regfile and send the config bits
//              to the analog core. 
//
//          UART packet definition:
//  bit:      17       16:9         8:1       0 
//                  |          |          |
//          parity     addr        data      wrb  
// 
///////////////////////////////////////////////////////////////////


module digital_core_tb();
    timeunit 1ns/10ps;
    localparam NUMREGS = 16;
    localparam PIXEL_NUM_ROW = 7;
    localparam PIXEL_NUM_COL = 16;
    localparam PIXEL_ADDR_BITS_ROW = $clog2(PIXEL_NUM_ROW);
    localparam PIXEL_ADDR_BITS_COL = $clog2(PIXEL_NUM_COL);

// config bits
logic [7:0] opamp_bias1; // opamp biasing configuration registers
logic [7:0] opamp_bias2; // opamp biasing configuration registers
logic [7:0] spare0;  // 8 spare configuration bits
logic [7:0] spare1;  // 8 spare configuration bits
logic [7:0] spare2;  // 8 spare configuration bits
logic [7:0] spare3;  // 8 spare configuration bits

// local digital_signals

logic sample_en;
//logic gate_reset;
//logic vg;
logic [PIXEL_NUM_ROW-1:0] row_sample;
logic [PIXEL_NUM_COL-1:0] col_sample;

logic reset_n;          // active low reset
logic clk;           // system clock (sent to PSD_CHIP)
logic clk_free_running;       // clock ANDed with en to get system clk
logic clk_en;       // high to enable clk

// uart
logic piso;     // output from current chip (input to FPGA)
logic posi;     // input to current chip (output from FPGA)
logic posi_tx;     // (output from FPGA)
logic posi_tx_en; // high to enable posi

// external FPGA signals
logic txclk_fpga; // clock used to define data sent to PSD_CHIP
logic tx_busy_fpga;
logic ld_tx_data_fpga;
logic [17:0] tx_data_fpga;
logic rx_empty_fpga;
logic uld_rx_data_fpga;
logic [17:0] rx_data_fpga;

// parse rx data

logic [17:0] receivedData;
logic rcvd_wrb;
logic [7:0] rcvd_data_word;
logic [7:0] rcvd_data_address;
logic rcvd_parity_bit;
logic first; // suppress first readout
logic verbose;
logic adc_start;
logic clk_out;
`include "../tasks/uart_tasks.sv"
`include "../tasks/uart_tests.sv"

       
initial begin
    verbose = TRUE;
    reset_n = 1;
    sample_en = 0;
    //gate_reset = 0;
    //vg = 0;
    clk_free_running = 0;
    txclk_fpga = 1;
    ld_tx_data_fpga = 0;
    receivedData = 0;
    uld_rx_data_fpga = 1'b0;
    first = 1;
    posi_tx_en = 1;
    clk_en = 0;
// reset DUT
    #100 reset_n = 0;
    #100002 //VCD
    #100 reset_n = 1;
//    #100 clk_en = 0;
//#1000   isDefaultConfig();
//#1000   randomTestExternalInterface(100);

// test RX rejection of run start bit
    #1000 clk_en = 1;
    #1000 $display("Testing runt start bit rejection");
    posi_tx_en = 0;
    #15 posi_tx_en = 1;
    #1000 clk_en = 0;
    //#1000
    //regfileOpUART(WRITE,PIXEL_DISABLE,0);
    //regfileOpUART(WRITE,CDS,8'b00000001);
    //regfileOpUART(READ,PIXEL_DISABLE,0);
    //regfileOpUART(READ,CDS,0);
    //#100 sample_en = 1;
    //#3000 sample_en = 0;
    
    
    //#1000   isDefaultConfig();
   //#1000   randomTestExternalInterface(100);
     
    //#100 regfileOpUART(WRITE,12,8'had);
    //#100 regfileOpUART(READ,12,0);

    `include "cds.mcp"
   // `include "single_pixel.mcp"
    //`include "default_sampling.mcp"
   // `include "pixel_disable.mcp"

    $display("all testing complete");
end  // initial


// system clock generator
initial begin

    #100002 //VCD
    forever begin
      #5 clk_free_running = ~clk_free_running;
    end
end  // initial

initial begin
    forever begin
        // this is the clock that controls the data being sent out   
        #80 txclk_fpga = ~txclk_fpga; // 1/16th speed of clk
    end
end // initial

always_comb begin
    posi = posi_tx & posi_tx_en;
    //clk = clk_free_running & clk_en;
    clk = clk_free_running;

end // always_comb

// read out FPGA received UART
always @(negedge rx_empty_fpga) begin

    @(posedge txclk_fpga);
        uld_rx_data_fpga = 1'b1;
    @(posedge clk);
        uld_rx_data_fpga = 1'b0;
    @(posedge clk);
        receivedData = rx_data_fpga;
    
end // always
 
always_comb begin
    rcvd_wrb = receivedData[0];
    rcvd_data_word = receivedData[8:1];
    rcvd_data_address = receivedData[16:9];
    rcvd_parity_bit = receivedData[17];
end

always @(receivedData) begin
    if (first) begin
        first = 0;
    end
    else begin
        if (verbose) begin
            #10 $display("UART data received:");
            $display("rcvd_data_address = 0x%h", rcvd_data_address);
            $display("rcvd_data_word = 0x%h",rcvd_data_word);
            $display("wrb = 0x%h",rcvd_wrb);
            $display("parity bit = 0x%h",rcvd_parity_bit);
            $display("*********************************************");
                
        end
    end
end
// DUT

digital_core 
    digital_core_inst
    (.PISO (piso),
    .opamp_bias1 (opamp_bias1),
    .opamp_bias2 (opamp_bias2), 
    .spare0 (spare0),  
    .spare1 (spare1),  
    .spare2 (spare2),  
    .spare3 (spare3),  
    .row_sample (row_sample ),
    .col_sample (col_sample),
    .SAMPLE_EN (sample_en),
    .ADC_EN (adc_start), 
    .CLK_OUT (clk_out),
    .POSI (posi),
    .CLK (clk),
    .RESET_N (reset_n)
    );   

// external UART RX & TX models FPGA interface
uart_tx_fpga
    uart_tx_FPGA_inst
    (.tx_out        (posi_tx),
    .tx_busy        (tx_busy_fpga),
    .tx_data        (tx_data_fpga),
    .ld_tx_data     (ld_tx_data_fpga),
    .txclk          (txclk_fpga),
    .reset_n        (reset_n)
    );

uart_rx_fpga
    uart_rx_FPGA_inst
    (.rx_data       (rx_data_fpga),
    .rx_empty       (rx_empty_fpga),
    .rx_in          (piso),
    .uld_rx_data    (uld_rx_data_fpga),
    .rxclk          (clk),
    .reset_n        (reset_n)
    );

endmodule
