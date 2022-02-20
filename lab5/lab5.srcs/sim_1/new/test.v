`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: test
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


module test;
    parameter half_period=0.0005; 
    reg clock,reset;
    wire [6:0]c;
    wire [3:0] an;
    digital_clock UUT(c,an,clock,reset);
    
    initial begin
        #0 clock=0; reset=0;
        #200 reset=1;
        #50 reset=0;
    end
    always #half_period clock=~clock;
    initial #2000 $stop;        
endmodule
