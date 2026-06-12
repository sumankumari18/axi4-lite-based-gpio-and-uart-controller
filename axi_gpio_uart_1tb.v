

`timescale 1ns/1ps

module tb_axi_gpio_uart;

// Clock and Reset
reg ACLK;
reg ARESETN;

// AXI Write Address Channel
reg [31:0] AWADDR;
reg AWVALID;
wire AWREADY;

// AXI Write Data Channel
reg [31:0] WDATA;
reg WVALID;
wire WREADY;

// AXI Write Response Channel
wire [1:0] BRESP;
wire BVALID;
reg BREADY;

// AXI Read Address Channel
reg [31:0] ARADDR;
reg ARVALID;
wire ARREADY;

// AXI Read Data Channel
wire [31:0] RDATA;
wire [1:0] RRESP;
wire RVALID;
reg RREADY;

// Peripheral Outputs
wire [7:0] gpio_out;
wire tx;wire uart_start;



// DUT
top_axi_gpio_uart DUT(
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

    .gpio_out(gpio_out),
    .tx(tx)
);

// Clock Generation
always #5 ACLK = ~ACLK;

//================================================
// AXI WRITE TASK
//================================================
task axi_write;
input [31:0] addr;
input [31:0] data;
begin
    @(posedge ACLK);

    AWADDR  = addr;
    AWVALID = 1'b1;

    WDATA   = data;
    WVALID  = 1'b1;

    @(posedge ACLK);

    AWVALID = 1'b0;
    WVALID  = 1'b0;

    BREADY  = 1'b1;

    @(posedge ACLK);

end
endtask

//================================================
// AXI READ TASK
//================================================
task axi_read;
input [31:0] addr;
begin
    @(posedge ACLK);

    ARADDR  = addr;
    ARVALID = 1'b1;

    @(posedge ACLK);

    ARVALID = 1'b0;
    RREADY  = 1'b1;

    @(posedge ACLK);

    $display("Read Addr=%h Data=%h", addr, RDATA);

end
endtask

//------------------------------------------------
// TEST
//------------------------------------------------
initial
begin

    ACLK = 0;
    ARESETN = 0;

    AWADDR = 0;
    AWVALID = 0;

    WDATA = 0;
    WVALID = 0;

    BREADY = 0;

    ARADDR = 0;
    ARVALID = 0;

    RREADY = 0;

    //--------------------------
    // Reset
    //--------------------------
    #20;
    ARESETN = 1;

    //--------------------------
    // GPIO Write
    //--------------------------
    axi_write(32'h00000000,
              32'h00000055);
axi_write(32'h4, 32'hA5);
axi_write(32'h8, 32'h1);
    #20;

    //--------------------------
    // GPIO Read
    //--------------------------
    axi_read(32'h00000000);

    #20;

    //--------------------------
    // UART DATA Write
    //--------------------------
    
    
    axi_write(32'h00000004, 32'h000000A5);

// Start pulse
axi_write(32'h00000008, 32'h00000001);
#100000;

$display("uart_data_reg = %h", DUT.uart_data_reg);
$display("uart_ctrl_reg = %h", DUT.uart_ctrl_reg);
$display("uart_start    = %b", DUT.uart_start);



// Clear start bit
axi_write(32'h00000008, 32'h00000000);
    #100000;
    
    $finish;

end

endmodule