module lab_7(number, clk, equal, switch,anode,cathode,c_out,p);    
    input [3:0] number;
    input p;
    input clk,equal,switch;
    output c_out;
    output [3:0] anode;
    output [7:0] cathode;
    reg [3:0] anode;
    reg [7:0] cathode;
    wire [15:0] roll;
    wire clk1,clk5;
    wire [7:0] cathodea, cathodeb;
    wire [3:0] anodea, anodeb;
    Clock_Divider One(clk1,,clk, );
    Clock_Divider #(18,200000) five(clk5,,clk, );
    Shift shift(clk1,roll,p);
    Rolling rolling(roll,clk5,cathodea,anodea);
    Calculator calculator(clk, ,equal,number, c_out,anodeb, cathodeb);
    always@(posedge clk)
        begin
            if (switch==1) 
                begin
                    cathode <= cathodea;
                    anode <= anodea;
                end
            else if (switch==0) 
                begin
                    cathode <= cathodeb;
                    anode <= anodeb;
                end
            else 
                cathode = 8'b11111111;
        end
endmodule

module Clock_Divider(clock_out,Q, clock_in, reset);
    parameter n =  27, N = 50000000;
    input reset,clock_in;
    output clock_out = 0;
    output [n-1:0] Q = 0;
    reg [n-1:0] Q;
    reg clock_out;
    always @ (posedge reset or posedge clock_in)
        begin
            if (reset == 1'b1) 
                begin
                    Q <= 0;
                    clock_out<=0;
                end
            else if (Q == N-1) 
                begin
                    Q<= 0;
                    clock_out <= ~clock_out;
                end
            else Q <= Q + 1;
        end
endmodule

module Shift(clock,out,p);
    input clock,p;
    output reg [15:0] out;
    reg [0:63] ID=64'h519370910123FFFF;
    reg a=0;
    always@(posedge clock or posedge p or negedge p)
        begin
            ID[0:59]<= ID[4:63];
            ID[60:63]<= ID[0:3];
            if (a!=p) 
                begin
                    a<=p;
                    if (p==1'b0) ID<=64'h519370910123FFFF;
                    else  ID<=64'h519370910075FFFF;
                end
            out=ID[0:15];
        end
endmodule

module Rolling(roll,clock,cathode,anode);
    input [15:0] roll;
    input clock; 
    output [7:0] cathode;
    output [3:0] anode;
    reg[7:0] cathode;
    reg [3:0] anode;
    reg [1:0] i = 0;
    reg [3:0] disp; 
    always@ (*)
        case (i)
            0:  disp =  roll[3:0] ;
            1:  disp =  roll[7:4] ;
            2:  disp =  roll[11:8] ;
            3:  disp =  roll[15:12] ;
            default:disp =  roll[3:0] ;
        endcase
    always@ (*)
    case (disp)
        0:    cathode =8'b00000011;
        1:    cathode =8'b10011111;
        2:    cathode =8'b00100101;
        3:    cathode =8'b00001101;
        4:    cathode =8'b10011001;
        5:    cathode =8'b01001001;
        6:    cathode =8'b01000001;
        7:    cathode =8'b00011111;
        8:    cathode =8'b00000001;
        9:    cathode =8'b00001001; 
        default: cathode =8'b11111111;
    endcase  
    always@(*)
        begin
            anode=4'b1111;
            anode[i]=0;
        end
    always@ (posedge clock)
        i<=i+1;
endmodule

module Calculator(clock, reset,equal,number, c_out,anode, cathode);
    input clock, reset,equal;
    input[3:0] number;
    output c_out;
    output [3:0] anode;
    output[7:0] cathode;
    reg [7:0] cathode;
    wire [7:0] cathodea;
    wire [7:0] cathodeb;
    reg [7:0] cathodec;
    wire [7:0] cathoded;
    wire clock_500;
    wire clock_1;
    wire [3:0] anode;
    wire [3:0] SSD;
    wire sign;
    assign cathodea = 8'b11111111;
    assign cathodeb = 8'b11111111;
    Clock_Divider #(18,200000) Five(clock_500,, clock, reset);
    Ring_Counter ring (anode,clock_500,reset);
    Adder adder (equal, number, c_out,SSD, sign);
    Cathode cathodeR(SSD,cathoded);
    always @(sign)
        if(sign == 0)
            cathodec = 8'b11111111;
        else cathodec = 8'b11111101;
    always @(anode)begin
        case (anode)
            4'b0111: cathode<=cathodea;
            4'b1011: cathode<=cathodeb;
            4'b1101: cathode<=cathodec;
            4'b1110: cathode<=cathoded;
        endcase
     end
endmodule

module Ring_Counter(Out,clock, reset);
    input reset, clock;
    output [3:0] Out;
    reg [3:0] Out;
    reg [1:0] counter;
    always @ (posedge reset or posedge clock)begin
        if (reset == 1'b1) counter <= 0;
        else counter <= counter + 1;
    end
    always @ (Out)begin
        case (counter)
            2'b00: Out<=4'b0111;
            2'b01: Out<=4'b1011;
            2'b10: Out<=4'b1101;
            2'b11: Out<=4'b1110;
        endcase
    end
endmodule

module Adder(equal, number, c_out, SSD, sign);
    parameter N = 4;
    input [N-1:0] number;
    input equal;
    output c_out;
    output sign;
    output [N-1:0] SSD;
    reg c_out;
    reg sign;
    reg [N-1:0] sum;
    reg [N-1:0] SSD;
    reg [N-1:0] temp;
    reg [N-1:0] b;
    always @(number)begin
        b = number;
     end
    always @(posedge equal)begin
        if (sum == 0 && temp == 0)
            {c_out,sum} = b;
        else begin
            temp = sum;
            {c_out,sum} = sum + b;
        if (temp[3]^b[3] == 0)
            c_out = sum[3]^c_out;
        else
            c_out = 0;
        end
        if (sum[3] == 1)begin
            SSD = ~sum + 1; 
            sign = 1;
        end
        else begin
            SSD = sum; 
            sign = 0;
        end
    end 
endmodule


module Cathode(Input,cathode);
    parameter N = 4;
    input [N-1:0]Input;
    output [7:0]cathode;
    reg [7:0]cathode;
    always @(Input) begin
        case(Input)
            0: cathode <= 8'b00000011;
            1: cathode <= 8'b10011111;
            2: cathode <= 8'b00100101;
            3: cathode <= 8'b00001101;
            4: cathode <= 8'b10011001;
            5: cathode <= 8'b01001001;
            6: cathode <= 8'b01000001;
            7: cathode <= 8'b00011111;
            8: cathode <= 8'b00000001;
            9: cathode <= 8'b00001001;
            10: cathode <= 8'b00010001;
            11: cathode <= 8'b11000001;
            12: cathode <= 8'b01100011;
            13: cathode <= 8'b10000101;
            14: cathode <= 8'b01100001;
            default cathode <= 8'b01110001;
        endcase
    end
endmodule