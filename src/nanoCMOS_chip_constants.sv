///////////////////////////////////////////////////////////////////
// File Name: nanoCMOS_chip_constants.sv
// Engineer:  Tarun Prakash (tprakash@lbl.gov)
// Description:  Constants for PSD_CHIP operation and simulation
//          
///////////////////////////////////////////////////////////////////

`ifndef _nanoCMOS_chip_constants_
`ifndef SYNTHESIS 
`define _nanoCMOS_chip_constants_
`endif

// declare needed variables
localparam TRUE = 1;
localparam FALSE = 0;
localparam SILENT = 0;
localparam VERBOSE = 0;          // high to print out verification results

// localparams to define config registers
// configuration word definitions
localparam OPBIAS1 = 0;
localparam OPBIAS2 = 1;
localparam S_PIXEL_EN = 2;
localparam S_PIXEL_ROW = 3;
localparam S_PIXEL_COL = 4;
localparam PIXEL_DISABLE = 5;
localparam CDS = 6;
localparam REG8 = 7;
localparam REG9 = 8;
localparam REG10 = 9;
localparam REG11 = 10;
localparam REG12 = 11;
localparam REG13 = 12;
localparam REG14 = 13;
localparam REG15 = 14;
localparam REG16 = 15;

// UART ops
localparam WRITE = 1;
localparam READ = 0;


`endif // _nanoCMOS_chip_constants_
