///////////////////////////////////////////////////////////////////
// File Name: external_interface.sv
// Engineer:  Tarun Prakash (tprakash@lbl.gov)
// Description: Contains Register file, UART
//              Regfile contains configuration registers 
//
//          UART packet definition:
//  bit:      17       16:9         8:1       0 
//                  |          |          |
//          parity     addr        data      wrb  
// 
///////////////////////////////////////////////////////////////////

module external_interface
    #(parameter NUMREGS = 16)
    (output logic [7:0] config_bits [0:NUMREGS-1], // output bits
    output logic piso,      // UART output
    input logic posi,       // UART input
    input logic clk,        // system clock
    input logic reset_n     // digital reset (active low)
);

// internal signals

logic [7:0] write_addr;  // location to write to in regfile 
logic [7:0] write_data; // data to write to regfile
logic [7:0] read_addr;  // location to read from in regfilt 
logic [7:0] read_data;  // data read from regfile
logic write;  // high for external write 
logic read;   // high for read op

// Instances  
regfile
    #(.NUMREGS(NUMREGS)) 
    regfile_inst
    (.config_bits           (config_bits),
    .read_data              (read_data),
    .write_addr             (write_addr),
    .write_data             (write_data),
    .read_addr              (read_addr),
    .write                  (write),   
    .read                   (read),
    .clk                    (clk),
    .reset_n                (reset_n)
    );

uart uart_inst 
    (.piso                  (piso),
    .write_addr             (write_addr),
    .write_data             (write_data),
    .read_addr              (read_addr),
    .write                  (write),
    .read                   (read),
    .posi                   (posi),
    .read_data              (read_data),
    .clk                    (clk),
    .reset_n                (reset_n)
    );

endmodule
