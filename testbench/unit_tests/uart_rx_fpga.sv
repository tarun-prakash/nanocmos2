///////////////////////////////////////////////////////////////////
// File Name: uart_rx.sv
// Engineer:  Carl Grace    
// Description: Simple UART receiver
//              RX should use a 16X oversampled clock relative to TX
//
// If rx_empty is low then data is waiting. It should be read and then
// uld_rx_data should be asserted to enable rx for another reception.
//
// 
//             Start bit = 0;
//              Stop bit = 1;
//
//  UART word width is 18 bits.
//
///////////////////////////////////////////////////////////////////

module uart_rx_fpga

    (output logic [17:0] rx_data,    // data received by UART
    output logic rx_empty,           // high if no data in rx
    input logic rx_in,               // input bit
    input logic uld_rx_data,         // transfer data to output (rx_data)
    input logic rxclk,               // 16X oversampling receiving clock
    input logic reset_n);             // digital reset (active low) 

// Internal Variables 
logic [17:0] rx_reg;
logic [3:0] rx_sample_cnt;
logic [7:0] rx_cnt;  
logic rx_d1;
logic rx_d2;
logic rx_busy;

// UART RX Logic
always_ff @ (posedge rxclk or negedge reset_n) begin
    if (!reset_n) begin
        rx_reg <= 18'b0; 
        rx_data <= 18'b0;
        rx_sample_cnt <= 4'b0000;
        rx_cnt <= 8'b0;
        rx_empty <= 1'b1;
        rx_d1 <= 1'b1;
        rx_d2 <= 1'b1;
        rx_busy <= 1'b0;
    end else begin
        // Synchronize the asynch signal
        rx_d1 <= rx_in;
        rx_d2 <= rx_d1;
        // Unload the rx data
        if (uld_rx_data) begin
            rx_data  <= rx_reg;
            rx_empty <= 1'b1;
        end
        // Check if just received start of frame
        if (!rx_busy && !rx_d2) begin
            rx_busy <= 1'b1;
            rx_sample_cnt <= 4'b0001;
            rx_cnt <= 8'b0;
        end
        // Start of frame detected, Proceed with rest of data
        if (rx_busy) begin
            rx_sample_cnt <= rx_sample_cnt + 1'b1;
            // Logic to sample at middle of data
            // makes sure we don't start based on runt start bit
            if (rx_sample_cnt == 4'd7) begin
                if ((rx_d2 == 1'b1) && (rx_cnt == 8'b0)) begin
                    rx_busy <= 1'b0;
                end 
                else begin
                    rx_cnt <= rx_cnt + 1'b1; 
                    // Start storing the rx data
                    if ((rx_cnt >= 8'd1) && (rx_cnt <= 8'd18)) begin
                        rx_reg[rx_cnt - 1'b1] <= rx_d2;
                    end
                    if ((rx_cnt > 8'd18)) begin
                        rx_busy <= 1'b0;
                        rx_empty <= 1'b0;
                    end
                end
            end 
        end 
    end
end // always_ff
endmodule

