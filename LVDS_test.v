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

reg [30:0]  Cont1=0;
reg [30:0]  Cont2=1;
reg [30:0]  Cont3=2;
parameter Cont32 = 30'h752f;
parameter Cont22 = 30'h752e;
parameter Cont12 = 30'h752d;

parameter ScreenX = 1366;
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

wire HSync =(((ContadorX-1)==ScreenX) & ((ContadorX-1)==(ScreenX+(BlankingHorizontal/2))))?0:1;
wire VSync =((ContadorY>ScreenY) & (ContadorY<(ScreenY+(BlankingVertical/2))))?0:1;
wire DataEnable = ((ContadorX<ScreenX) & (ContadorY<ScreenY));

always @(posedge clk6x) begin

	ContadorX <= ((ContadorX-1)==(ScreenX+BlankingHorizontal)) ? 0 : ContadorX+1;
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


always @(posedge clk6x)begin
	if(ContadorX > 682 & ContadorX < 684)begin
		Red   <= 8'hFF;  
		Green <= 8'hFF;
		Blue  <= 8'hFF;
	end else if(ContadorY > 383 & ContadorY < 385)begin
		Red   <= 8'hFF;  
		Green <= 8'hFF;
		Blue  <= 8'hFF;
	end else begin
		Red   <= Rimg;  
		Green <= Gimg;
		Blue  <= Bimg;
	end
end

// test led

always @(posedge clk6x)begin
	Contador <= Contador + 1;
  if (Contador==36000000*2)begin
		led <= ~led;
		Contador <= 0;
  end
end

//RAM image
 
parameter tm = (1<<12) -1;
reg    [7:0] ram [0:tm];
always @(posedge clk6x) begin
	if((ContadorX < 100) & (ContadorY < 100)) begin
		Rimg = ram[Cont1*3];
		Gimg = ram[(Cont1*3)+1];
		Bimg = ram[(Cont1*3)+2];
		if (Cont1 == 9999) begin
				Cont1 <= 0;
		end else begin
			Cont1 <= Cont1 + 1;
		end
/*
		if (Cont2 == Cont22) begin
				Cont2 <= 1;
		end else begin
			Cont2 <= Cont2 + 3;
		end
		if (Cont3 == Cont32) begin
				Cont3 <= 2;
		end else begin
			Cont3 <= Cont3 + 3;
		end
*/
	end else begin
		Rimg = 0;
		Gimg = 0;
		Bimg = 0;
	end
end

initial 
begin
	$readmemh("/scriptimg2ram/image.mem", ram);
end

endmodule


//////////////////////////////////////////////////////////////////


