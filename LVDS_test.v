`timescale 1ns / 1ps

module LVDS_test(
    input clk,

	 output channel1_p,
	 output channel1_n,
	 output channel2_p,
	 output channel2_n,
	 output channel3_p,
	 output channel3_n,
	 output clock_p,
	 output clock_n,
	 output reg led
    );


reg [7:0] Rimg;
reg [7:0] Gimg;
reg [7:0] Bimg;
reg [30:0]  Contador=0;

parameter ScreenX = 1365;
parameter ScreenY = 768;

parameter BlankingVertical = 12;
parameter BlankingHorizontal = 50;

wire clo,clk6x,clk_lckd, clkdcm;

reg [7:0] Red   = 8'h0;
reg [7:0] Blue  = 8'h0;
reg [7:0] Green = 8'hFF;



reg [10:0] ContadorX = ScreenX+BlankingHorizontal-3; // Contador de colunas
reg [10:0] ContadorY = ScreenY+BlankingVertical; // Contador de lineas




assign clkprueba =clk6x;

wire HSync =((ContadorX>ScreenX) & (ContadorX<(ScreenX+(BlankingHorizontal/2))))?0:1;
wire VSync =((ContadorY>ScreenY) & (ContadorY<(ScreenY+(BlankingVertical/2))))?0:1;
wire DataEnable = ((ContadorX<ScreenX) & (ContadorY<ScreenY));

always @(posedge clk6x) begin

	ContadorX <= (ContadorX==(ScreenX+BlankingHorizontal)) ? 0 : ContadorX+1;
	if(ContadorX==(ScreenX+BlankingHorizontal)) ContadorY <= (ContadorY==(ScreenY+BlankingVertical)) ? 0 : ContadorY+1;

end

DCM_SP #(
//	.CLKIN_PERIOD	(63), // 64MHz Clock from 16MHz Input
	.CLKIN_PERIOD	(20),  // from 12MHz Input
	.CLKFX_MULTIPLY	(7),   // 72 MHz Clock
	.CLKFX_DIVIDE 	(5)
	)
dcm_main (
	.CLKIN   	(clk),
	.CLKFB   	(clo),
	.RST     	(1'b0),
	.CLK0    	(clkdcm),
	.CLKFX   	(clk6x),
	.LOCKED  	(clk_lckd)
);


BUFG 	clk_bufg	(.I(clkdcm), 	.O(clo) ) ;


video_lvds videoencoder (
    .DotClock(clk6x), 
    .HSync(HSync), 
    .VSync(VSync), 
    .DataEnable(DataEnable), 
    .Red(Red), 
    .Green(Green), 
    .Blue(Blue), 
    .channel1_p(channel1_p), 
    .channel1_n(channel1_n), 
    .channel2_p(channel2_p), 
    .channel2_n(channel2_n), 
    .channel3_p(channel3_p), 
    .channel3_n(channel3_n), 
    .clock_p(clock_p), 
    .clock_n(clock_n)
    );




//Video Generator


always @(posedge clk6x)

begin
	if (led) begin
		if(ContadorX < ScreenX/8) begin            Blue <= 8'b00; Red 	<= 8'b0;  Green	<= 8'b0;
		end else if(ContadorX < ScreenX/4)   begin Blue <= 8'hFF; Red 	<= 8'b0;  Green	<= 8'b0;
		end else if(ContadorX < 3*ScreenX/8) begin Blue <= 8'b00; Red 	<= 8'HFF; Green	<= 8'b0;
		end else if(ContadorX < ScreenX/2)   begin Blue	<= 8'hff; Red 	<= 8'hff; Green <= 8'b0;
		end else if(ContadorX < 5*ScreenX/8) begin Blue <= 8'b0;  Red 	<= 8'b0;  Green <= 8'hff;
		end else if(ContadorX < 3*ScreenX/4) begin Blue <= 8'hff; Red 	<= 8'b0;  Green <= 8'hff;
		end else if(ContadorX < 7*ScreenX/8) begin Blue <= 8'b0;  Red 	<= 8'hff; Green <= 8'hff;
		end else begin Blue <= 8'b11111111; Red <= 8'hff; Green <= 8'b11111111;
		end 
	end else begin
		Red   <= Rimg;  
		Green <= Gimg;
		Blue  <= Bimg; 
	end
end



// test led

always @(posedge clk6x)
begin
	Contador <= Contador + 1;
        if (Contador==36000000*2)
	begin
		led <= ~led;
		Contador <= 0;
	
        end
end
//RAM image
 
parameter tm = (1<<12) -1;
reg    [7:0] ram [0:tm];
always @(clk6x) begin
	if ((ContadorX+ (ScreenX*ContadorY))< 300000) begin
		if(ContadorX < 102) begin
			if(ContadorY < 102) begin
				Gimg = ram[(ContadorX+ (ScreenX*ContadorY))*3 -2];
				Bimg = ram[(ContadorX+ (ScreenX*ContadorY))*3 -1];
				Rimg = ram[(ContadorX+ (ScreenX*ContadorY))*3];
			end
		end else begin
			Gimg = 8'h00;
			Bimg = 8'h00;
			Rimg = 8'hFF;
		end
	end else begin
		Rimg = 8'hFF;  
		Gimg = 8'hFF;
		Bimg = 8'hFF;
	end
end

initial 
begin
	$readmemh("/scriptimg2ram/image.mem", ram);
end

endmodule


//////////////////////////////////////////////////////////////////


