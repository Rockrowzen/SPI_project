module spi_master(
    input  wire clk,          // System clock
    input  wire reset,
    input  wire start,        // Start transmission
    input  wire en,
    input  wire [1:0] slaveselect, // Slave select (active low)
    input  wire [7:0] data_in,     // Data to send
    input  wire miso,         // Master In Slave Out
    output reg  mosi,         // Master Out Slave In
    output reg  cs0, cs1, cs2,
    output reg  sclk,         // SPI clock
    output reg  [7:0] data_out
);

reg [7:0] shift_reg;
reg [3:0] bit_cnt;
reg [7:0] clk_div;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        clk_div <= 0;
        sclk <= 0;
    end else begin
        if (clk_div == 9) begin   // Clock divider
            clk_div <= 0;
            sclk <= ~sclk;
        end else begin
            clk_div <= clk_div + 1;
        end
    end
end

// SPI main state machine
always @(posedge sclk or posedge reset) begin
    if (reset) begin
        cs0 <= 1;
        cs1 <= 1;
        cs2 <= 1;
        mosi <= 0;
        data_out <= 0;
        bit_cnt <= 0;
        shift_reg <= 0;
    end else if (start && bit_cnt == 0) begin
        // Start transmission
        case(slaveselect)
            2'b00: cs0 <= 0;
            2'b01: cs1 <= 0;
            2'b10: cs2 <= 0;
            default: begin
                cs0 <= 1;
                cs1 <= 1;
                cs2 <= 1;
            end
        endcase
        shift_reg <= data_in;
        mosi <= data_in[7];
        bit_cnt <= 8;
    end else if (bit_cnt > 0) begin
        mosi <= shift_reg[6];
        shift_reg <= {shift_reg[6:0], miso};
        bit_cnt <= bit_cnt - 1;

        if (bit_cnt == 1) begin
            cs0 <= 1;
            cs1 <= 1;
            cs2 <= 1;
        end
    end
end

endmodule
