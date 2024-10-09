`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2024 09:37:11 AM
// Design Name: 
// Module Name: convo
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


module convo(
input        i_clk,
input [71:0] i_pixel_data,// 72 bits becuase 8 *9 , 9 in the matrix each of 8 bit 
input        i_pixel_data_valid,
output reg [7:0] o_convolved_data,
output reg   o_convolved_data_valid //
    );
    
integer i; 
reg [7:0] kernel [8:0];
reg [15:0] multData[8:0];
reg [15:0] sumDataInt;
reg [15:0] sumData;
reg multDataValid;
reg sumDataValid;
reg convolved_data_valid;

initial
begin
    for(i=0;i<9;i=i+1)
    begin
       // kernel[i] = 1; // we can replace this for loop by directly assinging for each kernel like kernel[0]<=1;
    kernel[0] = - 1;
    kernel[1] = -1;
    kernel[2] = -1;
    kernel[3] = -1;
    kernel[4] =  8;
    kernel[5] = -1;
    kernel[6] = -1;
    kernel[7] = -1;
    kernel[8] = -1;
    
    end
end    
    
always @(posedge i_clk)
begin
    for(i=0;i<9;i=i+1)
    begin
        multData[i] <= kernel[i]*i_pixel_data[i*8+:8]; // the syntax for multiplication 
    end
    multDataValid <= i_pixel_data_valid; // 1st piplining 
end


always @(*)
begin
    sumDataInt = 0;
    for(i=0;i<9;i=i+1)
    begin
        sumDataInt = sumDataInt + multData[i];
    end
end

always @(posedge i_clk)
begin
    sumData <= sumDataInt; // finally we store the answer in sumData but we haven't divided by 9 yet 
    sumDataValid <= multDataValid;
end
    
always @(posedge i_clk)
begin
    o_convolved_data <= sumData; // we might not get an integer , but it automatically take sonly integer part 
    o_convolved_data_valid <= sumDataValid;// last piplining 
end
    
endmodule

