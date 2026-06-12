`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/06/2026 08:38:44 PM
// Design Name: 
// Module Name: gpio_controller
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


module gpio_controller(
    input clk,
    input rst_n,
    input [7:0] gpio_data,
    output reg [7:0] gpio_out
);

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        gpio_out <= 8'h00;
    else
        gpio_out <= gpio_data;
end

endmodule

