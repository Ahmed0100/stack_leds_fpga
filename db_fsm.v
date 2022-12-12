module db_fsm
(
	input clk,
	input reset_n,
	input sw,
	output reg db
);
localparam [2:0]
				zero = 3'b000,
				wait_1_1 = 3'b001,
				wait_1_2 = 3'b010,
				wait_1_3 = 3'b011,
				one = 3'b100,
				wait_0_1 =3'b101,
				wait_0_2 = 3'b110,
				wait_0_3=3'b111;
localparam N=19;
reg [N-1:0] q_reg;
wire [N-1:0] q_next;
wire m_tick;
reg [2:0] current_state,next_state;
reg [1:0] sync_sw;

//synchronizer
always @(posedge clk)
begin
	sync_sw <= {sync_sw[0],sw};
end
//counter to generate 10 ms tick
always @(posedge clk)
begin
	q_reg<=q_next;
end
assign q_next = q_reg + 1;
assign m_tick = (q_reg==0);
//debounsing FSM current state
always @(posedge clk or negedge reset_n)
begin
	if(!reset_n)
		current_state <= zero;
	else
		current_state <= next_state;
end
//db FSM next state
always @*
begin
	next_state = current_state;
	db=1'b0;
	case(current_state)
		zero:
			if(sync_sw[1])
				next_state = wait_1_1;
		wait_1_1:
			if(~sync_sw[1])
				next_state = zero;
			else if(m_tick)
				next_state = wait_1_2;
		wait_1_2:
			if(~sync_sw[1])
				next_state = zero;
			else if(m_tick)	
				next_state = wait_1_3;
		wait_1_3:
			if(~sync_sw[1])
				next_state = zero;
			else if(m_tick)
				next_state = one;
		one:
		begin
			db=1;
			if(~sync_sw[1])
				next_state = wait_0_1;
		end
		wait_0_1:
		begin
			db=1'b1;
			if(sync_sw[1])
				next_state = one;
			else if(m_tick)
				next_state = wait_0_2;
		end
		wait_0_2:
		begin
			db=1'b1;
			if(sync_sw[1])
				next_state = one;
			else if(m_tick)
				next_state = wait_0_3;
		end
		wait_0_3:
		begin
			db=1'b1;
			if(sync_sw[1])
				next_state = one;
			else if(m_tick)
				next_state = zero;
		end
		default: next_state = zero;
	endcase
end
endmodule