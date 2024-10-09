`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2024 09:46:57 AM
// Design Name: 
// Module Name: conv
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


module conv(

  input        i_clk,
input [71:0] i_pixel_data,// 72 bits becuase 8 *9 , 9 in the matrix each of 8 bit 
input        i_pixel_data_valid,
output reg [7:0] o_convolved_data,
output reg   o_convolved_data_valid,//
output      [15:0] approx_sum
    );
    
integer i; 
reg [7:0] kernel [8:0];
reg [15:0] multData[8:0];
reg [15:0] sumDataInt;
//wire [15:0]temp;
reg [15:0] sumData;
reg multDataValid;
reg sumDataValid;
reg convolved_data_valid;
wire [15:0] mem0;
wire [15:0] mem1;
wire [15:0] mem2;
wire [15:0] mem3;
wire [15:0] mem4;
wire [15:0] mem5;
wire [15:0] mem6;
wire [15:0] mem7;
wire [15:0] mem8;

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


//always @(*)
//begin
    
    initial sumDataInt = 0;
    assign mem0 = 16'd0;
   // genvar j;
    //generate
    //for(j=0;j<9;j=j+1)
    //begin : approx_adder_label
       // sumDataInt = sumDataInt + multData[i];
       approx_adder abc(.i1(mem0),.y(mem1),.i2(multData[0]));
       approx_adder abc1(.i1(mem1),.y(mem2),.i2(multData[1]));
       approx_adder abc2(.i1(mem2),.y(mem3),.i2(multData[2]));
       approx_adder abc3(.i1(mem3),.y(mem4),.i2(multData[3]));
       approx_adder abc4(.i1(mem4),.y(mem5),.i2(multData[4]));
       approx_adder abc5(.i1(mem5),.y(mem6),.i2(multData[5]));
       approx_adder abc6(.i1(mem6),.y(mem7),.i2(multData[6]));
       approx_adder abc7(.i1(mem7),.y(mem8),.i2(multData[7]));
       approx_adder abc8(.i1(mem8),.y(approx_sum),.i2(multData[7]));
     
       
       
       always@(*)
       begin
            sumDataInt=approx_sum;
       end 
   // end
  //  endgenerate
//end

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