`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2024 10:06:07 AM
// Design Name: 
// Module Name: approx_adder
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


module approx_adder(
input [15:0]i1,
input [15:0]i2,
output reg [15:0]y



    );
    reg [3:0]t;
    always @(*)
    begin 
    y[7:4]=i1[7:4]|i2[7:4];
    y[1:0]=2'b00;
    t={i1[3:2],i2[3:2]};
    y[15:8]=i1[15:8] + i2[15:8];
    case(t)
    4'b0000:y[3:2]=2'b00;
    4'b0001:y[3:2]=2'b01;
    4'b0010:y[3:2]=2'b10;
    4'b0011:y[3:2]=2'b11;
    4'b0100:y[3:2]=2'b01; 
    4'b0101:y[3:2]=2'b00; 
    4'b0110:y[3:2]=2'b01; 
    4'b0111:y[3:2]=2'b00; 
    4'b1000:y[3:2]=2'b10; 
    4'b1001:y[3:2]=2'b01; 
    4'b1010:y[3:2]=2'b00;  
    4'b1011:y[3:2]=2'b11; 
    4'b1100:y[3:2]=2'b11; 
    4'b1101:y[3:2]=2'b00; 
    4'b1110:y[3:2]=2'b11; 
    4'b1111:y[3:2]=2'b00; 
   
    endcase
    
    end
    
endmodule
