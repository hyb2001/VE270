`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: digital_clock
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
module divider1(divided_clock,clock);
    parameter num=99999999;
    input clock;
    output reg divided_clock;
    reg [31:0] count;
    initial count=32'b0;
    
    always @(posedge clock)
        if (count<num) begin
            count=count+1;
            divided_clock=0;
        end
        else begin
            divided_clock=1;
            count=0;
        end
endmodule

module divider500(divided_clock,clock);
    parameter num=199999;
    input clock;
    output reg divided_clock;
    reg [31:0] count;
    initial count=32'b0;
    
    always @(posedge clock)
        if (count<num) begin
            count=count+1;
            divided_clock=0;
        end
        else begin
            divided_clock=1;
            count=0;
        end
endmodule

module ring(an,Q1,Q0,clock);
    input clock;
    input [3:0] Q1,Q0;
    output reg [3:0] an;
    initial an=4'b0111;
    reg [3:0] Q;
    
    always @(posedge clock) begin
        an[3]<=an[2];
        an[2]<=an[1];
        an[1]<=an[0];
        an[0]=an[3];
    end
endmodule

module counter(Q,carry,clock,CE,reset);
    parameter ending=9;
    input clock,CE,reset;
    output reg [3:0] Q;
    output reg carry;
    initial Q=4'b0;
    
    always @(posedge clock, posedge reset) begin
        if (reset==1) Q=4'b0;
        else begin
        if (CE==1)
        if (Q==ending) begin
            Q=4'b0;
            carry=0;
        end
        else begin
            Q=Q+1;
            carry=0;
            if (Q==ending) carry=1;
        end
        else carry=0;
        end
    end
endmodule

module lab5(c,an,clock,reset);
    input clock,reset;
    output reg [6:0] c;
    output [3:0] an;
    wire [3:0] Q0,Q1;
    reg [3:0] Q;
    wire divided_clock,divided_clock2;
    wire carry1,carry2;
     
    divider500 d(divided_clock,clock);
    divider1 d2(divided_clock2,clock);
    counter #9 c0(Q0,carry1,divided_clock,1'b1,reset);
    counter #5 c1(Q1,carry2,divided_clock,carry1,reset);
    ring get_an(an,Q1,Q0,divided_clock2);  
    
    always @(an) begin
        case (an)
            4'b1101: Q=Q1;
            4'b1110: Q=Q0;
            default Q=4'b0000;
        endcase;
        case (Q)
            4'h0: c=7'b0000001;
            4'h1: c=7'b1001111;
            4'h2: c=7'b0010010;
            4'h3: c=7'b0000110;
            4'h4: c=7'b1001100;
            4'h5: c=7'b0100100;
            4'h6: c=7'b0100000;
            4'h7: c=7'b0001111;
            4'h8: c=7'b0000000;
            4'h9: c=7'b0000100;
            4'ha: c=7'b0001000;
            4'hb: c=7'b1100000;
            4'hc: c=7'b0110001;
            4'hd: c=7'b1000010;
            4'he: c=7'b0110000;
            4'hf: c=7'b0111000;
        endcase
    end
endmodule
