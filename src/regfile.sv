///////////////////////////////////////////////////////////////////
// File Name: regfile.sv
// Engineer:  Tarun Prakash
// Description: Dual-port register file for configuration bits 
//              Regfile has address space for 
//              256 distinct 8-bit registers
//
///////////////////////////////////////////////////////////////////

module regfile
    #(parameter NUMREGS = 16)
    (output logic [7:0] config_bits [0:NUMREGS-1], // output bits
    output logic [7:0] read_data,           // RAM data out (for readback)
    input logic [7:0] write_addr,           // RAM write address 
    input logic [7:0] write_data,           // RAM data in
    input logic [7:0] read_addr,            // RAM read address 
    input logic write,                      // high for write op
    input logic read,                       // high for read op
    input logic clk,                        // system clock
    input logic reset_n                     // digital reset (active low)
);

// configuration word definitions
// located at ../testbench/psd_chip/
// example compilation: 
//vlog +incdir+../testbench/psd_chip/ -incr -sv "../src/digital_core.sv"
`include "nanoCMOS_chip_constants.sv"

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        read_data <= 8'b0;
        // SET DEFAULTS
`include "regfile_assign.sv"
    end 
    else begin
        if (write) begin       
            config_bits[write_addr] <= write_data;
        end // write
        if (read) begin
            read_data <= config_bits[read_addr];
        end // write
    end    // else
end // always_ff

endmodule
                
        

