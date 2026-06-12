`timescale 1ns / 1ps

module axi4_lite_slave(

    input  wire        ACLK,
    input  wire        ARESETN,

    // Write Address Channel
    input  wire [31:0] AWADDR,
    input  wire        AWVALID,
    output reg         AWREADY,

    // Write Data Channel
    input  wire [31:0] WDATA,
    input  wire        WVALID,
    output reg         WREADY,

    // Write Response Channel
    output reg [1:0]   BRESP,
    output reg         BVALID,
    input  wire        BREADY,

    // Read Address Channel
    input  wire [31:0] ARADDR,
    input  wire        ARVALID,
    output reg         ARREADY,

    // Read Data Channel
    output reg [31:0]  RDATA,
    output reg [1:0]   RRESP,
    output reg         RVALID,
    input  wire        RREADY,

    // Outputs to peripherals
    output reg [31:0] gpio_reg,
    output reg [31:0] uart_data_reg,
    output reg [31:0] uart_ctrl_reg,

    // Input from peripherals
    input  wire [31:0] status_reg


);

//--------------------------------------------------
// WRITE LOGIC
//--------------------------------------------------

always @(posedge ACLK or negedge ARESETN)
begin
    if(!ARESETN)
    begin
        gpio_reg      <= 32'd0;
        uart_data_reg <= 32'd0;
        uart_ctrl_reg <= 32'd0;

        AWREADY <= 0;
        WREADY  <= 0;
        BVALID  <= 0;
        BRESP   <= 2'b00;
    end
    else
    begin

        AWREADY <= 1'b1;
        WREADY  <= 1'b1;

      if(AWVALID && WVALID)
begin

    $display("WRITE Addr=%h Data=%h Time=%0t",
             AWADDR, WDATA, $time);

    case(AWADDR[5:2])

        4'h0:
            gpio_reg <= WDATA;

        4'h1:
            uart_data_reg <= WDATA;

        4'h2:
        begin
            uart_ctrl_reg <= WDATA;
            $display("UART CTRL WRITTEN = %h", WDATA);
        end

        default:
            ;

    endcase

    BVALID <= 1'b1;
    BRESP  <= 2'b00;

end

        if(BVALID && BREADY)
            BVALID <= 1'b0;

    end
end

//--------------------------------------------------
// READ LOGIC
//--------------------------------------------------

always @(posedge ACLK or negedge ARESETN)
begin
    if(!ARESETN)
    begin
        ARREADY <= 0;
        RVALID  <= 0;
        RDATA   <= 0;
        RRESP   <= 2'b00;
    end
    else
    begin

        ARREADY <= 1'b1;

        if(ARVALID)
        begin

            case(ARADDR[5:2])

                4'h0:
                    RDATA <= gpio_reg;

                4'h1:
                    RDATA <= uart_data_reg;

                4'h2:
                    RDATA <= uart_ctrl_reg;

                4'h3:
                    RDATA <= status_reg;

                default:
                    RDATA <= 32'hDEADBEEF;

            endcase

            RVALID <= 1'b1;
            RRESP  <= 2'b00;

        end

        if(RVALID && RREADY)
            RVALID <= 1'b0;

    end
end


endmodule