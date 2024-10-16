`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2024 09:39:11 AM
// Design Name: 
// Module Name: imagecontrol
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


module imagecontrol(
input                    i_clk,
input                    i_rst,
input [7:0]              i_pixel_data,
input                    i_pixel_data_valid,
output reg [71:0]        o_pixel_data, // 8*9=72 final output 
output                   o_pixel_data_valid,
output reg               o_intr
);

reg [8:0] pixelCounter;
reg [1:0] currentWrLineBuffer;
reg [3:0] lineBuffDataValid;
reg [3:0] lineBuffRdData;
reg [1:0] currentRdLineBuffer;
wire [23:0] lb0data; // line buffer delceration 
wire [23:0] lb1data;
wire [23:0] lb2data;
wire [23:0] lb3data;
reg [8:0] rdCounter;
reg rd_line_buffer;
reg [11:0] totalPixelCounter; // to count 512*3=1536
reg rdState;

localparam IDLE = 'b0,
           RD_BUFFER = 'b1;

assign o_pixel_data_valid = rd_line_buffer;

always @(posedge i_clk)// total pixel counter 
begin
    if(i_rst)
        totalPixelCounter <= 0;
    else
    begin
        if(i_pixel_data_valid & !rd_line_buffer)
            totalPixelCounter <= totalPixelCounter + 1;
        else if(!i_pixel_data_valid & rd_line_buffer)
            totalPixelCounter <= totalPixelCounter - 1;
    end
end

always @(posedge i_clk)
begin
    if(i_rst)
    begin
        rdState <= IDLE;
        rd_line_buffer <= 1'b0;
        o_intr <= 1'b0;
    end
    else
    begin
        case(rdState) // reading from line buffer only if 1536 data is there that is 3 lines is full of pixels 
            IDLE:begin
                o_intr <= 1'b0;
                if(totalPixelCounter >= 1536)
                begin
                    rd_line_buffer <= 1'b1;
                    rdState <= RD_BUFFER;
                end
            end
            RD_BUFFER:begin
                if(rdCounter == 511)
                begin
                    rdState <= IDLE;
                    rd_line_buffer <= 1'b0;
                    o_intr <= 1'b1;
                end
            end
        endcase
    end
end
    
always @(posedge i_clk) // pixel counter 
begin
    if(i_rst)
        pixelCounter <= 0;
    else 
    begin
        if(i_pixel_data_valid)
            pixelCounter <= pixelCounter + 1;
    end
end


always @(posedge i_clk) // this part of the code controls writelinebuffer so everytime we read 512 pixels we need to shift the Wrlinebuffer 
begin
    if(i_rst)
        currentWrLineBuffer <= 0;
    else
    begin
        if(pixelCounter == 511 & i_pixel_data_valid)
            currentWrLineBuffer <= currentWrLineBuffer+1;
    end
end


always @(*)
begin
    lineBuffDataValid = 4'h0;
    lineBuffDataValid[currentWrLineBuffer] = i_pixel_data_valid;
end

always @(posedge i_clk)
begin
    if(i_rst)
        rdCounter <= 0;
    else 
    begin
        if(rd_line_buffer)
            rdCounter <= rdCounter + 1;
    end
end

always @(posedge i_clk) // this part of the code controls readlinebuffer so everytime we read 512 pixels we need to shift the currentrdlinebuffer 
begin
    if(i_rst)
    begin
        currentRdLineBuffer <= 0;
    end
    else
    begin
        if(rdCounter == 511 & rd_line_buffer)
            currentRdLineBuffer <= currentRdLineBuffer + 1;
    end
end


always @(*)
begin
    case(currentRdLineBuffer) // reading from which line buffer is decided here basically the mux code , its cyclic 
        0:begin
            o_pixel_data = {lb2data,lb1data,lb0data};
        end
        1:begin
            o_pixel_data = {lb3data,lb2data,lb1data};
        end
        2:begin
            o_pixel_data = {lb0data,lb3data,lb2data};
        end
        3:begin
            o_pixel_data = {lb1data,lb0data,lb3data};
        end
    endcase
end

always @(*)
begin
    case(currentRdLineBuffer)// this is to select 3 line buffers out of 4 for writing 
        0:begin
            lineBuffRdData[0] = rd_line_buffer;
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = 1'b0;
        end
       1:begin
            lineBuffRdData[0] = 1'b0;
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = rd_line_buffer;
        end
       2:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = 1'b0;
             lineBuffRdData[2] = rd_line_buffer;
             lineBuffRdData[3] = rd_line_buffer;
       end  
      3:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = rd_line_buffer;
             lineBuffRdData[2] = 1'b0;
             lineBuffRdData[3] = rd_line_buffer;
       end        
    endcase
end
    
linebuffer lB0(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_pixel_data),
    .i_data_valid(lineBuffDataValid[0]),
    .o_data(lb0data),
    .i_rd_data(lineBuffRdData[0])
 ); 
 
 linebuffer lB1(
     .i_clk(i_clk),
     .i_rst(i_rst),
     .i_data(i_pixel_data),
     .i_data_valid(lineBuffDataValid[1]),
     .o_data(lb1data),
     .i_rd_data(lineBuffRdData[1])
  ); 
  
  linebuffer lB2(
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_data(i_pixel_data),
      .i_data_valid(lineBuffDataValid[2]),
      .o_data(lb2data),
      .i_rd_data(lineBuffRdData[2])
   ); 
   
   linebuffer lB3(
       .i_clk(i_clk),
       .i_rst(i_rst),
       .i_data(i_pixel_data),
       .i_data_valid(lineBuffDataValid[3]),
       .o_data(lb3data),
       .i_rd_data(lineBuffRdData[3])
    );    
    
endmodule

