///////////////////////////////////////////////////////////////////
// File Name: 
// Engineer:  Tarun Parakah (tprakash@lbl.gov)
// Description:
//
///////////////////////////////////////////////////////////////////



module decoder416 (input logic clk, 
        input logic reset_n, 
        input logic [3:0] decode_in,
        output logic [15:0] decode_out);


//always @(negedge clk or negedge reset_n)  begin // row and coloumn decoder 
always_comb begin 
    if (!reset_n) begin
        decode_out = '0;
    end 
    else begin
        case (decode_in) 
        4'b0000  : decode_out = 16'b0000000000000001;
        4'b0001  : decode_out = 16'b0000000000000010;
        4'b0010  : decode_out = 16'b0000000000000100;
        4'b0011  : decode_out = 16'b0000000000001000;
        4'b0100  : decode_out = 16'b0000000000010000;
        4'b0101  : decode_out = 16'b0000000000100000;
        4'b0110  : decode_out = 16'b0000000001000000;
        4'b0111  : decode_out = 16'b0000000010000000;
        4'b1000  : decode_out = 16'b0000000100000000;
        4'b1001  : decode_out = 16'b0000001000000000;
        4'b1010  : decode_out = 16'b0000010000000000;
        4'b1011  : decode_out = 16'b0000100000000000;
        4'b1100  : decode_out = 16'b0001000000000000;
        4'b1101  : decode_out = 16'b0010000000000000;
        4'b1110  : decode_out = 16'b0100000000000000;
        4'b1111  : decode_out = 16'b1000000000000000;
        default  : decode_out = 16'b0000000000000000;
        endcase
    end
end //always

endmodule