///////////////////////////////////////////////////////////////////
// File Name: uart_tasks.sv
// Engineer:  
// Description:     Tasks for operating the PSD_CHIP UART 
//          
///////////////////////////////////////////////////////////////////

`ifndef _uart_tasks_
`define _uart_tasks_

`include "nanoCMOS_chip_constants.sv"  // all sim constants defined here

task regfileOpUART
    // external read or write from register file
    (input logic wrb,
    input logic [7:0] addr,
    input logic [7:0] data);

logic debug;

begin

// first build tx word
    debug = FALSE;
    if (debug) begin
        $display("regfileOpUART:");
        $display("wrb = %d",wrb);
        $display("addr = %d",addr);
        $display("data = %d",data);
    end
    // enable clock for transaction, then disable
    clk_en = 1;
    #10 tx_data_fpga[0] = wrb;
    tx_data_fpga[8:1] = data;
    tx_data_fpga[16:9] = addr;
    tx_data_fpga[17] = ~^tx_data_fpga[16:0];
// need to hold ld_tx_data_fpga at least 16 rx clks
    @(negedge txclk_fpga) ld_tx_data_fpga = 1;
    @(negedge txclk_fpga) ld_tx_data_fpga = 0;

// wait 24 clocks
    for (int i = 0; i < 24; i++) begin
        @(posedge txclk_fpga);
    end
// if executing a READ, wait 24 more clocks for readback
    if (!wrb) begin
        for (int i = 0; i < 24; i++) begin
            @(posedge txclk_fpga);
        end // for
    end // if
    # 10 clk_en = 0;
    #10000 ;
end
endtask     




`endif // _uart_tasks_
