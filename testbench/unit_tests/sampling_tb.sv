///////////////////////////////////////////////////////////////////
// File Name: external_interface_tb.sv
// Engineer:  
// Description: SystemVerilog testbench for External Interface.
//              The purpose of the external interface is to read 
//              and write the regfile and send the config bits
//              to the analog core. 
//
//          UART packet definition:
//  bit:      17       16:9         8:1       0 
//                  |          |          |
//          parity     addr        data      wrb  
// 
///////////////////////////////////////////////////////////////////


module sampling_tb();
    timeunit 1ns/10ps;
    localparam NUMREGS = 16;
    localparam PIXEL_NUM_ROW = 7;
    localparam PIXEL_NUM_COL = 16;
    localparam PIXEL_ADDR_BITS_ROW = $clog2(PIXEL_NUM_ROW);
    localparam PIXEL_ADDR_BITS_COL = $clog2(PIXEL_NUM_COL);


logic reset_n;          // active low reset
logic clk;           // system clock (sent to PSD_CHIP)
logic sample_en;       // high to enable clk
logic [PIXEL_NUM_ROW-1:0] row;
logic [PIXEL_NUM_COL-1:0] col;
logic single_pixel_en;
logic [7:0] single_pixel_row_addr;
logic [7:0] single_pixel_col_addr;
logic VG;
logic pixel_disable;
logic correlated_double_sampling;
logic start;
logic clk_out;
// uart

initial begin
    reset_n = 1;
    VG=0;
    clk = 0;
    sample_en = 0;
    single_pixel_en = 0;
    single_pixel_row_addr = '0;
    single_pixel_col_addr = '0;
    pixel_disable = 0;
    correlated_double_sampling  = 0;
// reset DUT
    #10 reset_n = 0;
    #100 reset_n = 1;
    #100 VG =1;
    
//    testExternalInterfaceUART(8'hab);
//#1000      randomTestExternalInterface(10);

// test RX rejection of run start bit
    #1000
    #10 correlated_double_sampling  = 1;
    #12 sample_en = 1;
    $display("Testing start sampling");
    //#400 pixel_disable =1;//////////////////////////////////////////////
    #3000 sample_en = 0;
    correlated_double_sampling  = 0;
    #50 VG = 0;
    #3
    //////////////////////////////////////////2222///////////////////////////////
    single_pixel_en = 1;
    single_pixel_row_addr = 8'b00000011;
    single_pixel_col_addr = 8'b00000111;
    //single_pixel_row_addr = '0;
    //single_pixel_col_addr = '0;
    #20 VG = 1;
    #1000 sample_en = 1;
    //#400 pixel_disable =0; //////////////////////////////////////////////
    #1000 sample_en = 0;
    single_pixel_en = 0;
    #50 VG = 0;
    //////////////////////////////////////////2222///////////////////////////////
    #1000
    #12 sample_en = 1;
    //#400 pixel_disable =1;//////////////////////////////////////////////
    #3000 sample_en = 0;
    #50 VG = 0;
    #3
    #1000
    $display("all testing complete");
end  // initial

// system clock generator
initial begin
    forever begin
      #5 clk = ~clk;
    end
end  // initial

// DUT
sample
    #(.PIXEL_NUM_ROW(PIXEL_NUM_ROW),
      .PIXEL_NUM_COL(PIXEL_NUM_COL),
     .PIXEL_ADDR_BITS_ROW (PIXEL_ADDR_BITS_ROW),
     .PIXEL_ADDR_BITS_COL (PIXEL_ADDR_BITS_COL)
    ) sampling_counter_dut (
    .clk        (clk), 
    .reset_n    (reset_n), 
    .enable     (sample_en),
    .single_pixel_en (single_pixel_en),
    .pixel_disable(pixel_disable), 
    .correlated_double_sampling (correlated_double_sampling),              
    .single_pixel_row_addr (single_pixel_row_addr),
    .single_pixel_col_addr (single_pixel_col_addr),
    .row        (row), 
    .col        (col),
    .start (start),
    .clk_out (clk_out)
    );
endmodule
