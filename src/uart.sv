///////////////////////////////////////////////////////////////////
// File Name: uart.sv
// Engineer:  Carl Grace
// Description:
//          Custom UART that interfaces with the regflile
//          Includes FSM and RX/TX blocks
//          Clock must be 16X data rate
//          UART packet definition:
//  bit:      17      16:9        8:1      0 
//                  |        |          |
//          parity     addr      data     wrb  
//
//  Output format: packet is sent LSB-first, preceded by a start bit = 0
//  and ended by a stop bit = 1          
///////////////////////////////////////////////////////////////////

module uart 
   (output logic piso,             // output from chip
    output logic [7:0] write_addr, // write addr from RAM to UART
    output logic [7:0] write_data, // RAM data from UART_RX
    output logic [7:0] read_addr,  // read addr from RAM to UART
    output logic write,            // high to write to RAM
    output logic read,             // high to read from RAM
    input logic posi,              // input to current chip
    input logic [7:0] read_data,   // data read from regfile
    input logic clk,               // controlling clk
    input logic reset_n);          // asynchronous reset (active low)   

// local signals

enum logic [2:0] {IDLE                  = 3'h0,
                DATA_IN_RX              = 3'h1,
                ULD_RX_DATA             = 3'h2,
                TRANSACTION_TYPE        = 3'h3,
                WRITE                   = 3'h4,
                READ                    = 3'h5} State, Next;

logic [17:0] finished_packet;   // packet to send off chip (includes parity)
logic [3:0] txclk_counter;      // tx clk is 1/16 rx clk speed 
logic [16:0] output_packet;     // packet without parity bit 
logic ld_tx_data;               // high to transfer data to tx uart
logic tx_busy;                  // high if tx uart sending data
logic uld_rx_data;              // clear (unload) rx uart data
logic [17:0] rx_data;           // data from rx_uart
logic rx_empty;                 // high if no data waiting in rx uart

// fsm signals
logic [1:0] write_counter;      // 2 clks to write
logic [4:0] read_counter;       // need to hold ld_tx_data 16 clk cycles

// calculate parity
always_comb begin
    finished_packet = {~^output_packet,output_packet};
end // always_comb

// ripple-carry counter to generate tx clock
tff
    tff_inst_0 (
    .q          (txclk_counter[0]),
    .clk        (clk),
    .reset_n    (reset_n)
    );

tff
    tff_inst_1 (
    .q          (txclk_counter[1]),
    .clk        (txclk_counter[0]),
    .reset_n    (reset_n)
    );

tff
    tff_inst_2 (
    .q          (txclk_counter[2]),
    .clk        (txclk_counter[1]),
    .reset_n    (reset_n)
    );

tff
    tff_inst_3 (
    .q          (txclk_counter[3]),
    .clk        (txclk_counter[2]),
    .reset_n    (reset_n)
    );

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) State <= IDLE;
    else State <= Next;
end // always

always_comb begin: set_next_state
    case (State)
        IDLE:   begin
                    if (!rx_empty)          Next = DATA_IN_RX;
                    else                    Next = IDLE;
                end
        DATA_IN_RX:                         Next = ULD_RX_DATA;
        ULD_RX_DATA:                        Next = TRANSACTION_TYPE;
        TRANSACTION_TYPE: begin
                    if (rx_data[0])         Next = WRITE;
                    else                    Next = READ;
                end
        WRITE:  begin
                    if (write_counter == 2'd2)  Next = IDLE;
                    else                        Next = WRITE;
                end
        READ:   begin
                    if (read_counter == 5'd20)  Next = IDLE;
                    else                        Next = READ;
                end
        default:                            Next = IDLE;         
    endcase
end :set_next_state

// registered outputs
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        output_packet <= 21'b0;
        ld_tx_data <= 1'b0;
        write_addr <= 8'b0;
        write_data <= 8'b0;
        read_addr <= 8'b0;
        uld_rx_data <= 1'b0;
        write_counter <= 2'b0;
        read_counter <= 5'b0;
        read <= 1'b0;
        write <= 1'b0;        
    end 
    else begin
        uld_rx_data <= 1'b0;
        ld_tx_data <= 1'b0;
        read <= 1'b0;
        write <= 1'b0;

        unique case (Next)
            IDLE:               begin
                                    write_counter <= 2'b0;
                                    read_counter <= 5'b0;
                                end
            DATA_IN_RX:         begin
                                    uld_rx_data <= 1'b1;
                                end
            ULD_RX_DATA:        ;
            TRANSACTION_TYPE:   begin
                                    output_packet <= rx_data[16:0];
                                end 
            WRITE:              begin
                                    write_data <= rx_data[8:1];
                                    write_addr <= rx_data[16:9];
                                    write <= 1'b1;
                                    write_counter <= write_counter + 1'b1;
                                end
            READ:               begin
                                    if (read_counter < 5'b00011) begin
                                        ld_tx_data <= 1'b0;
                                    end
                                    else begin
                                        ld_tx_data <= 1'b1;
                                    end
                                    read_addr <= rx_data[16:9];
                                    output_packet[8:1] <= read_data;
                                    read <= 1'b1;
                                    read_counter <= read_counter + 1'b1;
                                end
            default:            ;
       endcase
    end
end // case
        
// block instantiations
uart_rx uart_rx_inst(
    .rx_data        (rx_data),
    .rx_empty       (rx_empty),
    .rx_in          (posi),
    .uld_rx_data    (uld_rx_data),
    .rxclk          (clk),
    .reset_n        (reset_n)
    );

uart_tx uart_tx_inst (
    .tx_out         (piso),
    .tx_busy        (tx_busy),
    .tx_data        (finished_packet),
    .ld_tx_data     (ld_tx_data),
    .txclk          (txclk_counter[3]),
    .reset_n        (reset_n)
    );

endmodule
