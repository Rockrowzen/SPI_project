`timescale 1ns/1ps

module spi_master(
    input  wire clk,           // System clock
    input  wire reset,         // Active high reset
    input  wire start,         // Start transmission pulse
    input  wire en,            // Enable signal (not used but kept)
    input  wire [1:0] slaveselect, // Slave select (active low)
    input  wire [7:0] data_in, // Data to send (MSB first)
    input  wire miso,          // Master In Slave Out
    output reg  mosi,          // Master Out Slave In
    output reg  cs0, cs1, cs2, // Chip selects
    output reg  sclk,          // SPI clock
    output reg  [7:0] data_out,// Received data
    output reg  done           // Transmission complete flag
);

    // Internal signals
    reg [7:0] shift_reg;
    reg [3:0] bit_cnt;
    reg [7:0] clk_div;
    reg start_pending;         // Latch short start pulses
    reg xfer_active;           // Track ongoing transfer

    //---------------------------------------
    // Clock divider: generates slower sclk
    //---------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_div <= 0;
            sclk <= 0;
        end else begin
            if (clk_div == 9) begin
                clk_div <= 0;
                sclk <= ~sclk;
            end else begin
                clk_div <= clk_div + 1;
            end
        end
    end

    //---------------------------------------
    // Latch start pulse
    //---------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset)
            start_pending <= 0;
        else if (start)
            start_pending <= 1;
        else if (done)
            start_pending <= 0;
    end

    //---------------------------------------
    // SPI Core (posedge sclk)
    //---------------------------------------
    always @(posedge sclk or posedge reset) begin
        if (reset) begin
            cs0 <= 1; cs1 <= 1; cs2 <= 1;
            mosi <= 0;
            data_out <= 0;
            bit_cnt <= 0;
            shift_reg <= 0;
            done <= 0;
            xfer_active <= 0;
        end 

        // Start transmission
        else if (start_pending && !xfer_active) begin
            case (slaveselect)
                2'b00: begin cs0 <= 0; cs1 <= 1; cs2 <= 1; end
                2'b01: begin cs0 <= 1; cs1 <= 0; cs2 <= 1; end
                2'b10: begin cs0 <= 1; cs1 <= 1; cs2 <= 0; end
                default: begin cs0 <= 1; cs1 <= 1; cs2 <= 1; end
            endcase

            shift_reg <= data_in;
            mosi <= data_in[7];
            bit_cnt <= 8;
            done <= 0;
            xfer_active <= 1;
        end 

        // Transfer ongoing
        else if (xfer_active) begin
            mosi <= shift_reg[6];
            shift_reg <= {shift_reg[6:0], miso};

            if (bit_cnt > 1)
                bit_cnt <= bit_cnt - 1;
            else if (bit_cnt == 1) begin
                // Last bit now received
                data_out <= {shift_reg[6:0], miso};
                bit_cnt <= 0;
                xfer_active <= 0;
            end
        end
    end

    //---------------------------------------
    // Post-transfer completion (posedge clk)
    // ensures done and CS deassert AFTER final bit
    //---------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset)
            done <= 0;
        else if (!xfer_active && (cs0 == 0 || cs1 == 0 || cs2 == 0)) begin
            // Deassert CS after MISO sampled fully
            cs0 <= 1; cs1 <= 1; cs2 <= 1;
            done <= 1;          // ? done goes HIGH now
        end
    end

endmodule
