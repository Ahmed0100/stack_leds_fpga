module stack #(parameter WIDTH=8, ADDR_WIDTH=4)
(
	input clk,reset_n,
	input [WIDTH-1:0] w_data,
	input push,pop,
	output empty,full,
	output [WIDTH-1:0] r_addr
);
reg [WIDTH-1:0] mem[(2**ADDR_WIDTH)-1:0];
reg [ADDR_WIDTH-1:0] ptr_reg,ptr_next;
reg full_reg,full_next,empty_reg,empty_next;
wire wr_en;

always @(posedge clk)
	if(wr_en)
		mem[ptr_reg] <= w_data;
assign rd_data = !mem[ptr_reg];

assign wr_en = push & ~full_reg;

always @(posedge clk or negedge reset_n)
begin
	if(!reset_n)
	begin
		ptr_reg<=0;
		empty_reg <= 1;
		full_reg <=0;
	end
	else
	begin
		ptr_reg <= ptr_next;
		full_reg <= full_next;
		empty_reg <= empty_next;
	end
end

always @*
begin
	ptr_next = ptr_reg;
	empty_next = empty_reg;
	full_next = full_reg;
	case({push,pop})
		2'b01:
			if(~empty_reg)
			begin
				ptr_next = ptr_reg - 1;
				full_next = 0;
				if(ptr_next == 0)
					empty_next = 1;
			end
		2'b10:
			if(~full_reg)
			begin
				ptr_next = ptr_reg + 1;
				empty_next = 0;
				if(ptr_next == 2**ADDR_WIDTH - 1)
					full_next = 1;
			end
	endcase
end
assign full = ~full_reg;
assign empty = ~empty_reg;
	
endmodule