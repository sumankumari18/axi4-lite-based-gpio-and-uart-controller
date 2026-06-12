`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/06/2026 08:42:19 PM
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx
#(
    parameter CLKS_PER_BIT = 20
)
(
    input clk,
    input rst_n,
    input start,
    input [7:0] tx_data,

    output reg tx,
    output reg busy,
    output reg done
);

reg [15:0] clk_count;
reg [3:0] bit_index;
reg [9:0] shift_reg;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        tx <= 1'b1;
        busy <= 0;
        done <= 0;
        clk_count <= 0;
        bit_index <= 0;
    end
    else
    begin
        done <= 0;

        if(start && !busy)
        begin
            busy <= 1;
            shift_reg <= {1'b1, tx_data, 1'b0};
            bit_index <= 0;
            clk_count <= 0;
        end

        if(busy)
        begin
            if(clk_count == CLKS_PER_BIT-1)
            begin
                clk_count <= 0;

                tx <= shift_reg[0];
                shift_reg <= shift_reg >> 1;

                if(bit_index == 9)
                begin
                    busy <= 0;
                    done <= 1;
                    tx <= 1'b1;
                end

                bit_index <= bit_index + 1;
            end
            else
                clk_count <= clk_count + 1;
        end
    end
end

endmodule
