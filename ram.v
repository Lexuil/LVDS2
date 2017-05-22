module ram(
	output reg [5:0]d_outR,
	output reg [5:0]d_outG,
	output reg [5:0]d_outB,
	input clkq,
	input wire[15:0]addrX,
	input [1:0]en
);

reg    [5:0] ramR [0:9999];
reg    [5:0] ramG [0:9999];
reg    [5:0] ramB [0:9999];

always @(posedge clkq) begin
	if(en) begin
		d_outR = ramR[addrX];
		d_outG = ramG[addrX];
		d_outB = ramB[addrX];
	end
end

initial begin
	d_outR =0;
	d_outG =0;
	d_outB =0;
	$readmemh("/scriptimg2ram/imageR.mem", ramR);
	$readmemh("/scriptimg2ram/imageG.mem", ramG);
	$readmemh("/scriptimg2ram/imageB.mem", ramB);
end

endmodule

