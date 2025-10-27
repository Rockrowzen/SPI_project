module spi_master(
    input  wire clk,          // System clock
    input  wire reset,
    input  wire start,        // Start transmission
    input  wire en,
    input  wire [1:0] slaveselect,     // Slave Select (active low)
    input  wire [7:0] data_in, // 8-bit master Data sent to slave
    input  wire miso,         // Master In Slave out
    output reg  mosi,         // Master Out Slave in 
    output reg  cs0,cs1,cs2,
    output reg  sclk,         // SPI clock
    output reg  [7:0] data_out // 8 bit master Data Received from slave
);

integer counter = 0;

// toggle clock = To reduce the speed. 

reg [7:0] tgl_clk ;

always @(posedge clk or reset) begin
    if(reset) begin
        tgl_clk <= 0;
        sclk <= 0;
    end
    else begin
        if(tgl_clk == 9) begin // speed is reduced to 2.5 Mhz
            tgl_clk <= 0;
            sclk <= ~sclk; // toggles here
        end
        else begin
            tgl_clk <= tgl_clk + 1;
        end
    end
end

always @(posedge clk or negedge clk or reset ) begin 

    if(reset) begin
        data_out <= 0;
        cs0 <= 1;
        cs1 <= 1;
        cs2 <= 1;
        mosi <= 0;
        counter <= 0;
    end

    else if(clk == 1) begin
        if(start == 1) begin
            counter = 1;
            case(slaveselect)
                2'b00 : cs0 <= 0;
                2'b01 : cs1 <= 0;
                2'b10 : cs2 <= 0;
                default : begin
                    cs0 <= 1;
                    cs1 <= 1;
                    cs2 <= 1;
                end
            endcase
            mosi = data_in[8-counter];
        end
    end

    else if (counter <=8 && counter > 0) begin
        mosi = data_in[8-counter];
    end

    else if (clk == 0 && counter <=8 && counter >0) begin
        data_out = data_out << 1;
        data_out[0] = miso;
        counter = counter + 1;
    end
end
endmodule
