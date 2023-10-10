///////////////////////////////////////////////////////////////////
// File Name: uart_tx.sv
// Engineer:  Carl Grace
// Description: Simple UART transmitter.
//              RX should use 16X oversampled clock relative to TX
//              UART word width is 18 bits.
///////////////////////////////////////////////////////////////////

module uart_tx_fpga
    #(parameter WIDTH = 18)
    (output logic tx_out,           // tx bit
    output logic tx_busy,           // high when transmitter sending data
    input logic [WIDTH-1:0] tx_data,     // data to be sent by uart
    input logic ld_tx_data,         // high to transfer data word to uart tx
    input logic txclk,              // baud-rate clock for tx
                                    // 1/16th rate of rx clock
    input logic reset_n);           // digital reset (active low) 

// Internal Variables 
logic [WIDTH-1:0] tx_reg;
logic [4:0] tx_cnt;

// UART TX Logic
always_ff @ (posedge txclk or negedge reset_n) begin
    if (!reset_n) begin
        tx_reg <= 0;
        tx_busy <= 1'b0;
        tx_out <= 1'b1;
        tx_cnt <= 8'b0;
    end 
    else begin
        if (ld_tx_data) begin
            tx_reg   <= tx_data;
            tx_busy <= 1'b1;
        end
        if (tx_busy) begin
            tx_cnt <= tx_cnt + 1'b1;
            if (tx_cnt == 8'b0) begin
                tx_out <= 1'b0;
            end
            if (tx_cnt > 8'b0 && tx_cnt <= 8'd18) begin
                tx_out <= tx_reg[tx_cnt - 1'b1];
            end
            if (tx_cnt > 8'd18) begin
                tx_out <= 1'b1;
                tx_cnt <= 8'b0;
                tx_busy <= 1'b0;
            end
        end

    end 
end // always_ff
endmodule

