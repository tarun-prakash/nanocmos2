///////////////////////////////////////////////////////////////////
// File Name: 
// Engineer:  Tarun Parakah (tprakash@lbl.gov)
// Description:
//
///////////////////////////////////////////////////////////////////



module decoder38 (input logic clk, 
        input logic reset_n, 
        input logic [2:0] decode_in,
        output logic [7:0] decode_out);


//always @(negedge clk or negedge reset_n)  begin // row and coloumn decoder 
always_comb begin 
    if (!reset_n) begin
        decode_out = '0;
    end 
    else begin
        case (decode_in) 
        3'b000  : decode_out = 8'b00000001;
        3'b001  : decode_out = 8'b00000010;
        3'b010  : decode_out = 8'b00000100;
        3'b011  : decode_out = 8'b00001000;
        3'b100  : decode_out = 8'b00010000;
        3'b101  : decode_out = 8'b00100000;
        3'b110  : decode_out = 8'b01000000;
        3'b111  : decode_out = 8'b10000000;
        default : decode_out = 8'b00000000; 
        endcase
    end
end //always

endmodule