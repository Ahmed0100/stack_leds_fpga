module stack_test
(
	input clk,reset_n,
	input push,pop,
	input [1:0] sw,
	output [3:0] led
);
wire push_db,pop_db;

db_fsm inst0
(
	.clk(clk),
	.reset_n(reset_n),
	.sw(~push),
	.db(push_db)
);
db_fsm inst1
(
	.clk(clk),
	.reset_n(reset_n),
	.sw(~pop),
	.db(pop_db)
);

stack #(.WIDTH(2), .ADDR_WIDTH(2)) stack_unit
(.clk(clk), .reset(reset_n),
 .push(push_db), .pop(pop_db), .w_data(sw),
.r_data(led[1:0]), .full(led[2]), .empty(led[3]));

endmodule