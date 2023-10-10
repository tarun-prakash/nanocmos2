///////////////////////////////////////////////////////////////////
// File Name: 
// Engineer:  Tarun Parakah (tprakash@lbl.gov)
// Description:
//
///////////////////////////////////////////////////////////////////



module sample
    #(parameter PIXEL_NUM_ROW = 7,
     parameter PIXEL_NUM_COL = 16,
     parameter PIXEL_ADDR_BITS_ROW = $clog2(PIXEL_NUM_ROW),
     parameter PIXEL_ADDR_BITS_COL = $clog2(PIXEL_NUM_COL ))
        (input logic clk, 
        input logic reset_n, 
        input logic enable,
        input logic single_pixel_en,
        input logic pixel_disable,
        input logic correlated_double_sampling,  
        input logic [7:0] single_pixel_row_addr,
        input logic [7:0] single_pixel_col_addr,
        output logic [PIXEL_NUM_ROW-1:0] row,
        output logic [PIXEL_NUM_COL-1:0] col,
        output logic clk_out,
        output logic start);

logic done;
logic enable_s;
logic done_s;
logic start_1;
logic start_0;
logic [PIXEL_ADDR_BITS_ROW-1:0] row_count;
logic [PIXEL_ADDR_BITS_COL-1:0] col_count;
logic [PIXEL_ADDR_BITS_ROW-1:0] row_count_ss;
logic [PIXEL_ADDR_BITS_COL-1:0] col_count_ss;
logic [PIXEL_NUM_ROW-1:0] row_decode;
logic [PIXEL_NUM_COL-1:0] col_decode;
logic [PIXEL_NUM_ROW-1:0] row_decode_single;
logic [PIXEL_NUM_COL-1:0] col_decode_single;
logic [PIXEL_ADDR_BITS_ROW-1:0] row_count_single;
logic [PIXEL_ADDR_BITS_COL-1:0] col_count_single;
logic [PIXEL_ADDR_BITS_ROW-1:0] row_count_cds;
logic [PIXEL_ADDR_BITS_COL-1:0] col_count_cds;
logic [1:0] clock_count;

always_comb begin 
    if (single_pixel_row_addr[PIXEL_ADDR_BITS_ROW-1:0] == '0)
        row_count_single = '0;
    else 
        row_count_single = single_pixel_row_addr[PIXEL_ADDR_BITS_ROW-1:0];
    
    if (single_pixel_col_addr[PIXEL_ADDR_BITS_COL-1:0] == '0)
        col_count_single = '0;
    else
        col_count_single = single_pixel_col_addr[PIXEL_ADDR_BITS_COL-1:0];
end //always


always_comb begin 
    row_count = correlated_double_sampling ? row_count_cds : row_count_ss;
    col_count = correlated_double_sampling ? col_count_cds : col_count_ss;
    start = start_0 | start_1;
end//always 


always_ff @(posedge clk or negedge reset_n)  begin // sampling counter
    if (!reset_n) begin
        row_count_ss <= '0;
        col_count_ss <= '0;
    end 
    else if (pixel_disable) begin
        row_count_ss <= '0;
        col_count_ss <= '0;
    end
    else if (enable_s) begin
        //if (done == 1'b1) begin
        if (done) begin
            row_count_ss <= '0;
            col_count_ss <= '0;
        end
        else begin 
            if (col_count_ss == PIXEL_NUM_COL-1) begin
                col_count_ss <= '0;
                row_count_ss <= row_count_ss + 1'b1;
            end else begin
                col_count_ss <= col_count_ss + 1'b1;
            end
        end
    end
    else begin
        row_count_ss <= '0;
        col_count_ss <= '0;
    end 
end //always

always_ff @(posedge clk or negedge reset_n) begin // sampling counter correlated double sampling
    if (!reset_n) begin
        row_count_cds <= '0;
        col_count_cds <= '0;
        clock_count <= '0;
    end 
    else if (pixel_disable) begin
        row_count_cds <= '0;
        col_count_cds <= '0;
    end
    else if (enable_s) begin
        //if (done == 1'b1) begin
        if (done) begin
            row_count_cds <= '0;
            col_count_cds <= '0;
        end
        else begin
            if(clock_count == 2'b01) begin
                clock_count <= '0;
                if (col_count_cds == PIXEL_NUM_COL - 1'b1) begin
                    col_count_cds <= 0;
                    if (row_count_cds == PIXEL_NUM_ROW - 1'b1) begin
                        row_count_cds <= 0;
                    end else begin
                        row_count_cds <= row_count_cds + 1'b1;
                    end
                end else begin
                    col_count_cds <= col_count_cds + 1'b1;
                end
            end else begin
                clock_count <= clock_count + 1'b1;
            end
        end
    end
    else begin
        row_count_cds <= '0;
        col_count_cds <= '0;
    end 
end //always



always_ff @ (posedge clk or negedge reset_n) begin //synchronizer 
    if (!reset_n) begin
        enable_s <= '0;
        done_s <= '0;
    end
    else begin
        enable_s <= enable;
        done_s <= done;
    end
end //always

always_ff @(negedge clk or negedge reset_n)  begin
//always_comb begin
    if (!reset_n) begin 
        done <= '0;
    end
    else if  (enable_s == 1) begin 
        if (row_count == PIXEL_NUM_ROW-1 && col_count == PIXEL_NUM_COL-1) begin
        done <= 1'b1;
        end
    end
    else 
        done <= '0;
end //always


always_ff @(negedge clk or negedge reset_n)  begin
    if (!reset_n) begin
        start_0 <= '0;
        start_1 <= '0;
    end
    else if (enable_s == 1'b1 && done_s == 1'b0) begin  
        start_1 <= 1'b1;
        start_0 <= start_1;
    end
    else begin 
        start_1 <= 1'b0;
        start_0 <= start_1;
    end
end //always

always_comb begin
    clk_out = clk & (start_0 | start_1);
end //always_comb

always_ff @(negedge clk or negedge reset_n)  begin // row and coloumn decoder 
    if (!reset_n) begin
        row <= '0;
        col <= '0;
    end 
    else if (pixel_disable) begin
        row <= '0;
        col <= '0;
    end
    else if (enable_s) begin
        if (done_s) begin 
            row <= '0; 
            col <= '0; 
        end 
        else if( correlated_double_sampling == 1'b1 && clock_count == 2'b01) begin
            row <= '0; 
            col <= '0; 
        end
        else begin
        row <= single_pixel_en ? row_decode_single : row_decode;
        col <= single_pixel_en ? col_decode_single : col_decode;
        end
    end
    else begin
        row <= '0; 
        col <= '0; 
    end
end //always

decoder38 
    decoder_row(
    .clk (clk), 
    .reset_n (reset_n), 
    .decode_in (row_count),
    .decode_out (row_decode)
    );

decoder416 
    decoder_col(
    .clk (clk), 
    .reset_n (reset_n), 
    .decode_in (col_count),
    .decode_out (col_decode)
    );

decoder38 
    decoder_row_single(
    .clk (clk), 
    .reset_n (reset_n), 
    .decode_in (row_count_single),
    .decode_out (row_decode_single)
    );

decoder416 
    decoder_col_single(
    .clk (clk), 
    .reset_n (reset_n), 
    .decode_in (col_count_single),
    .decode_out (col_decode_single)
    );

endmodule