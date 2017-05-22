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


wire [7:0] Rimg;
wire [7:0] Gimg;
wire [7:0] Bimg;
reg [30:0]  Contador=0;

reg [30:0]  Cont1=0;
reg [30:0]  ContRx=0;
reg [30:0]  ContRy=0;
reg [30:0]  ContRh=0;
reg [1:0]  en=0;

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
	.CLKIN_PERIOD	(20),  // from 50MHz Input (valor del periodo en ns)
	.CLKFX_MULTIPLY(7),
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

ram image(
	.d_outR(Rimg),
	.d_outG(Gimg),
	.d_outB(Bimg),
	.clkq(clk6x),
	.addrX(Cont1),
	.en(en)
);

always @(posedge clk6x)begin
	if(ContadorX == 683)begin
		Red   <= 8'hFF;  
		Green <= 8'hFF;
		Blue  <= 8'hFF;
	end else if(en == 1)begin
		Red   <= Rimg;  
		Green <= Gimg;
		Blue  <= Bimg;
	end else begin
		Red   <= 0;  
		Green <= 0;
		Blue  <= 0;
	end
end

// test led

always @(posedge clk6x)begin
	Contador <= Contador + 1;
  if (Contador==36000000*2)begin
		led <= ~led;
		Contador <= 0;
  end
  if(Cont1 == 9999) begin
  	Cont1 <= 0;
  end
	if((ContadorX < 100) & (ContadorY < 400)) begin
		en = 1;
		if (Cont1 == (((ContadorY%4)*100) + 99)) begin
 			Cont1 <= (ContadorY%4)*100;
			if(ContRy == 3) begin
				ContRy <= 0;
			end else begin
				ContRy <= ContRy +1;
			end
		end else begin
			Cont1 <= Cont1 + 1;
		end
	end else begin
		en = 0;
	end
end

//RAM image


/* 

always @(posedge clk6x)begin
	Contador <= Contador + 1;
  if (Contador==36000000*2)begin
		led <= ~led;
		Contador <= 0;
  end
	if((ContadorX < 400) & (ContadorY < 400)) begin
		en = 1;
		if (Cont1 == ((ContRh*100) + 99) & ContRx == 3) begin
			if(ContRy == 3) begin
				ContRy <= 0;
				if(ContRh == 99) begin
					ContRh <= 0;
				end else begin
					ContRh <= ContRh + 1;
				end
			end else begin
				ContRy <= ContRy +1;
			end
 			Cont1 <= ContRh*100;
 			ContRx <= 0;
		end else begin
			if (ContRx == 3) begin
				ContRx <= 0;
				Cont1 <= Cont1 + 1;
			end else begin
				ContRx <= ContRx + 1;
			end
		end
	end else begin
		en = 0;
	end
end

always @(posedge clk6x)begin
	Contador <= Contador + 1;
  if (Contador==36000000*2)begin
		led <= ~led;
		Contador <= 0;
  end
	if((ContadorX < 400) & (ContadorY < 400)) begin
		en = 1;
		if (ContRx == 3) begin
			ContRx <= 0;
			if (Cont1 == ((ContRh*99) + 99)) begin				
				Cont1 <= ContRh*99;
				if(ContRy == 3) begin
					ContRy <= 0;
					if(ContRh == 99) begin
						ContRh <= 0;
					end else begin
						ContRh <= ContRh + 1;
					end
				end else begin
					ContRy <= ContRy +1;
				end
			end else begin
				Cont1 <= Cont1 + 1;
			end
		end else begin
			ContRx <= ContRx + 1;
		end
	end else begin
		en = 0;
	end
end


always @(posedge clk6x)begin
	Contador <= Contador + 1;
  if (Contador==36000000*2)begin
		led <= ~led;
		Contador <= 0;
  end
	if((ContadorX < 400) & (ContadorY < 400)) begin
		en = 1;
		if (ContRx == 3) begin
			ContRx <= 0;
			if (Cont1 == 9999) begin				
				Cont1 <= 0;
			end else begin
				Cont1 <= Cont1 + 1;
			end
		end else begin
			ContRx <= ContRx + 1;
		end
	end else begin
		en = 0;
	end
end


parameter tm = (1<<13) -1;

reg    [7:0] ramR [0:39999];
reg    [7:0] ramG [0:39999];
reg    [7:0] ramB [0:39999];

always @(posedge clk6x) begin
	if((ContadorX < 200) & (ContadorY < 200)) begin
		Rimg = ramR[Cont1];
		Gimg = ramG[Cont1];
		Bimg = ramB[Cont1];
		if (Cont1 == 39999) begin
				Cont1 <= 0;
		end else begin
			Cont1 <= Cont1 + 1;
		end

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

	end else begin
		Rimg = 0;
		Gimg = 0;
		Bimg = 0;
	end
end

initial 
begin
	$readmemh("/scriptimg2ram/image.mem", ram);
	$readmemh("/scriptimg2ram/imageR.mem", ramR);
	$readmemh("/scriptimg2ram/imageG.mem", ramG);
	$readmemh("/scriptimg2ram/imageB.mem", ramB);
end
*/
endmodule


//////////////////////////////////////////////////////////////////


