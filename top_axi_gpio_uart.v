`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/06/2026 09:00:35 PM
// Design Name: 
// Module Name: top_axi_gpio_uart
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
module top_axi_gpio_uart(

    input wire ACLK,
    input wire ARESETN,
  

    // AXI Write Address
    input wire [31:0] AWADDR,
    input wire AWVALID,
    output wire AWREADY,

    // AXI Write Data
    input wire [31:0] WDATA,
    input wire WVALID,
    output wire WREADY,

    // AXI Write Response
    output wire [1:0] BRESP,
    output wire BVALID,
    input wire BREADY,

    // AXI Read Address
    input wire [31:0] ARADDR,
    input wire ARVALID,
    output wire ARREADY,

    // AXI Read Data
    output wire [31:0] RDATA,
    output wire [1:0] RRESP,
    output wire RVALID,
    input wire RREADY,

    output wire [7:0] gpio_out,
    output wire tx
);
  wire [31:0] gpio_reg;
wire [31:0] uart_data_reg;
wire [31:0] uart_ctrl_reg;


wire [31:0] status_reg;

wire uart_busy;
wire uart_done;


axi4_lite_slave AXI_SLAVE (

    .ACLK(ACLK),
    .ARESETN(ARESETN),

    .AWADDR(AWADDR),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),

    .WDATA(WDATA),
    .WVALID(WVALID),
    .WREADY(WREADY),

    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY),

    .ARADDR(ARADDR),
    .ARVALID(ARVALID),
    .ARREADY(ARREADY),

    .RDATA(RDATA),
    .RRESP(RRESP),
    .RVALID(RVALID),
    .RREADY(RREADY),

    .gpio_reg(gpio_reg),
    .uart_data_reg(uart_data_reg),
    .uart_ctrl_reg(uart_ctrl_reg),

    .status_reg(status_reg)
);
gpio_controller GPIO (
    .clk(ACLK),
    .rst_n(ARESETN),
    .gpio_data(gpio_reg[7:0]),
    .gpio_out(gpio_out)
);
//--------------------------------------------------
// UART Transmitter Instance
//--------------------------------------------------

assign status_reg = {29'd0, uart_done, uart_busy,tx};
wire uart_start;

assign uart_start = uart_ctrl_reg[0];

uart_tx UART(
    .clk(ACLK),
    .rst_n(ARESETN),

    .start(uart_start),
    .tx_data(uart_data_reg[7:0]),

    .tx(tx),
    .busy(uart_busy),
    .done(uart_done)
);

endmodule