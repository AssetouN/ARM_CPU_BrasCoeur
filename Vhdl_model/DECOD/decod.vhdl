library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decod is
	port(
	-- Exec  operands
			dec_op1			: out Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: out Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: out Std_Logic; -- Rd destination write back
			dec_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Decod to mem via exec
			dec_mem_data	: out Std_Logic_Vector(31 downto 0); -- data to MEM
			dec_mem_dest	: out Std_Logic_Vector(3 downto 0);
			dec_pre_index 	: out Std_logic;
			
			dec_mem_swp		: out Std_Logic;
			dec_mem_swpb	: out Std_Logic;
			dec_mem_lw		: out Std_Logic;
			dec_mem_lb		: out Std_Logic;
			dec_mem_sw		: out Std_Logic;
			dec_mem_sb		: out Std_Logic;
			dec2exe_kernel_right: out Std_Logic;

	-- Shifter command
			dec_shift_lsl	: out Std_Logic;
			dec_shift_lsr	: out Std_Logic;
			dec_shift_asr	: out Std_Logic;
			dec_shift_ror	: out Std_Logic;
			dec_shift_rrx	: out Std_Logic;
			dec_shift_val	: out Std_Logic_Vector(4 downto 0);
			dec_cy			: out Std_Logic;

	-- Multiplier command
			dec_start_mult	: out Std_Logic;

	-- Alu operand selection
			dec_comp_op1	: out Std_Logic;
			dec_comp_op2	: out Std_Logic;
			dec_alu_cy 		: out Std_Logic;

	-- Exec Synchro
			dec2exe_empty	: out Std_Logic;
			exe_pop			: in Std_logic;

	-- Alu command
			dec_alu_cmd		: out Std_Logic_Vector(1 downto 0);

	-- Exe Write Back to reg
			exe_res			: in Std_Logic_Vector(31 downto 0);
			exe_end_mult	: in Std_Logic;
			
			exe_c			: in Std_Logic;
			exe_v			: in Std_Logic;
			exe_n			: in Std_Logic;
			exe_z			: in Std_Logic;

			exe_dest		: in Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: in Std_Logic; -- Rd destination write back
			exe_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Ifetch interface
			dec_pc			: out Std_Logic_Vector(31 downto 0) ;
			if_ir			: in Std_Logic_Vector(31 downto 0) ;

	-- Ifetch synchro
			dec2if_empty	: out Std_Logic;
			if_pop			: in Std_Logic;

			if2dec_empty	: in Std_Logic;
			dec_pop			: out Std_Logic;

	-- Mem Write back to reg
			mem_res			: in Std_Logic_Vector(31 downto 0);
			mem_dest		: in Std_Logic_Vector(3 downto 0);
			mem_wb			: in Std_Logic;

	--Interrupt
			i_irq			: in Std_Logic;
			i_firq			: in Std_Logic;
			i_dabt			: in Std_Logic;
			i_iabt			: in Std_Logic;
			i_adrex			: in Std_Logic;
			
	-- global interface
			ck				: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd				: in bit;
			vss				: in bit);
end Decod;

----------------------------------------------------------------------

architecture Behavior OF Decod is

component registre
	port(
	-- Write Port 1 prioritaire
		wdata1				: in Std_Logic_Vector(31 downto 0);
		wadr1				: in Std_Logic_Vector(3 downto 0);
		wen1				: in Std_Logic;

	-- Write mode (user,irq,firq,svr)
        wmode       		: in Std_Logic_Vector(3 downto 0);
        acces_user_reg		: in Std_Logic;
	interrupt  		: in Std_Logic;

	-- Write Port 2 non prioritaire
		wdata2				: in Std_Logic_Vector(31 downto 0);
		wadr2				: in Std_Logic_Vector(3 downto 0);
		wen2				: in Std_Logic;

	-- Write CSPR Port
		wcry				: in Std_Logic;
		wzero				: in Std_Logic;
		wneg				: in Std_Logic;
		wovr				: in Std_Logic;
		cspr_wb				: in Std_Logic;
		
	-- Read Port 1 32 bits
		reg_rd1				: out Std_Logic_Vector(31 downto 0);
		radr1				: in Std_Logic_Vector(3 downto 0);
		reg_v1				: out Std_Logic;

	-- Read Port 2 32 bits
		reg_rd2				: out Std_Logic_Vector(31 downto 0);
		radr2				: in Std_Logic_Vector(3 downto 0);
		reg_v2				: out Std_Logic;

	-- Read Port 3 32 bits
		reg_rd3				: out Std_Logic_Vector(31 downto 0);
		radr3				: in Std_Logic_Vector(3 downto 0);
		reg_v3				: out Std_Logic;

	-- read CSPR Port
		reg_cry				: out Std_Logic;
		reg_zero			: out Std_Logic;
		reg_neg				: out Std_Logic;
		reg_cznv			: out Std_Logic;
		reg_ovr				: out Std_Logic;
		reg_vv				: out Std_Logic;
		
	-- Invalidate Port 
		inval_adr1			: in Std_Logic_Vector(3 downto 0);
		inval1				: in Std_Logic;

		inval_adr2			: in Std_Logic_Vector(3 downto 0);
		inval2				: in Std_Logic;

		inval_czn			: in Std_Logic;
		inval_ovr			: in Std_Logic;

	-- PC
		reg_pc				: out Std_Logic_Vector(31 downto 0);
		reg_pcv				: out Std_Logic;
		inc_pc				: in Std_Logic;
	
	-- global interface
		ck					: in Std_Logic;
		reset_n				: in Std_Logic;
		vdd					: in bit;
		vss					: in bit);
end component;

component fifo_131b
	port(
		din					: in std_logic_vector(130 downto 0);
		dout				: out std_logic_vector(130 downto 0);

		-- commands
		push				: in std_logic;
		pop					: in std_logic;

		-- flags
		full				: out std_logic;
		empty				: out std_logic;

		reset_n				: in std_logic;
		ck					: in std_logic;
		vdd					: in bit;
		vss					: in bit
	);
end component;

component fifo_32b
	port(
		din					: in std_logic_vector(31 downto 0);
		dout				: out std_logic_vector(31 downto 0);

		-- commands
		push				: in std_logic;
		pop					: in std_logic;

		-- flags
		full				: out std_logic;
		empty				: out std_logic;

		reset_n				: in std_logic;
		ck					: in std_logic;
		vdd					: in bit;
		vss					: in bit
	);
end component;

signal cond					: Std_Logic;
signal condv				: Std_Logic;
signal operv				: Std_Logic;
	
signal regop_t  			: Std_Logic;
signal mult_t   			: Std_Logic;
signal swap_t   			: Std_Logic;
signal trans_t  			: Std_Logic;
signal mtrans_t 			: Std_Logic;
signal branch_t 			: Std_Logic;
signal swi_t 				: Std_Logic;
signal copro_t				: Std_Logic;

-- regop instructions
signal and_i  				: Std_Logic;
signal eor_i  				: Std_Logic;
signal sub_i  				: Std_Logic;
signal rsb_i  				: Std_Logic;
signal add_i  				: Std_Logic;
signal adc_i  				: Std_Logic;
signal sbc_i  				: Std_Logic;
signal rsc_i  				: Std_Logic;
signal tst_i  				: Std_Logic;
signal teq_i  				: Std_Logic;
signal cmp_i  				: Std_Logic;
signal cmn_i  				: Std_Logic;
signal orr_i  				: Std_Logic;
signal mov_i  				: Std_Logic;
signal bic_i  				: Std_Logic;
signal mvn_i  				: Std_Logic;

-- mult instruction
signal mul_i  				: Std_Logic;
signal mla_i  				: Std_Logic;

-- trans instruction
signal ldr_i  				: Std_Logic;
signal str_i  				: Std_Logic;
signal ldrb_i 				: Std_Logic;
signal strb_i 				: Std_Logic;

-- mtrans instruction
signal ldm_i  				: Std_Logic;
signal stm_i  				: Std_Logic;

-- branch instruction
signal b_i   				: Std_Logic;
signal bl_i  				: Std_Logic;

-- swap instruction
signal swp_i   				: Std_Logic;
signal swpb_i  				: Std_Logic;

-- link
signal blink    			: Std_Logic;

-- Multiple transferts
signal mtrans_shift 		: Std_Logic;

signal mtrans_mask_shift	: Std_Logic_Vector(15 downto 0);
signal mtrans_mask 			: Std_Logic_Vector(15 downto 0);
signal mtrans_list 			: Std_Logic_Vector(15 downto 0);
signal mtrans_1un 			: Std_Logic;
signal mtrans_loop_adr 		: Std_Logic;
signal mtrans_nbr 			: Std_Logic_Vector(4 downto 0);
signal mtrans_rd 			: Std_Logic_Vector(3 downto 0);

-- RF read ports
signal radr1 				: Std_Logic_Vector(3 downto 0);
signal rdata1 				: Std_Logic_Vector(31 downto 0);
signal rvalid1 				: Std_Logic;

signal radr2 				: Std_Logic_Vector(3 downto 0);
signal rdata2 				: Std_Logic_Vector(31 downto 0);
signal rvalid2 				: Std_Logic;

signal radr3 				: Std_Logic_Vector(3 downto 0);
signal rdata3 				: Std_Logic_Vector(31 downto 0);
signal rvalid3 				: Std_Logic;

-- RF inval ports
signal inval_exe_adr 		: Std_Logic_Vector(3 downto 0);
signal inval_exe 			: Std_Logic;

signal inval_mem_adr 		: Std_Logic_Vector(3 downto 0);
signal inval_mem 			: Std_Logic;

-- Flags
signal cry					: Std_Logic;
signal zero					: Std_Logic;
signal neg					: Std_Logic;
signal ovr					: Std_Logic;

signal reg_cznv 			: Std_Logic;
signal reg_vv 				: Std_Logic;

signal inval_czn 			: Std_Logic;
signal inval_ovr 			: Std_Logic;

-- PC
signal only_pc				: Std_Logic_Vector(31 downto 0);
signal reg_pc 				: Std_Logic_Vector(31 downto 0);
signal reg_pcv 				: Std_Logic;
signal inc_pc 				: Std_Logic;

-- FIFOs
signal dec2if_full 			: Std_Logic;
signal dec2if_push 			: Std_Logic;

signal dec2exe_full 		: Std_Logic;
signal dec2exe_push 		: Std_Logic;

signal if2dec_pop 			: Std_Logic;

-- Exec  operands
signal op1					: Std_Logic_Vector(31 downto 0);
signal op2					: Std_Logic_Vector(31 downto 0);
signal alu_dest				: Std_Logic_Vector(3 downto 0);
signal alu_wb				: Std_Logic;
signal flag_wb				: Std_Logic;

signal offset32				: Std_Logic_Vector(31 downto 0);

-- Decod to mem via exec
signal mem_data				: Std_Logic_Vector(31 downto 0);
signal ld_dest				: Std_Logic_Vector(3 downto 0);
signal pre_index 			: Std_logic;

signal mem_swp				: Std_Logic;
signal mem_swpb				: Std_Logic;
signal mem_lw				: Std_Logic;
signal mem_lb				: Std_Logic;
signal mem_sw				: Std_Logic;
signal mem_sb				: Std_Logic;

-- Shifter command
signal shift_lsl			: Std_Logic;
signal shift_lsr			: Std_Logic;
signal shift_asr			: Std_Logic;
signal shift_ror			: Std_Logic;
signal shift_rrx			: Std_Logic;
signal shift_val			: Std_Logic_Vector(4 downto 0);
signal cy					: Std_Logic;

-- Alu operand selection
signal comp_op1				: Std_Logic;
signal comp_op2				: Std_Logic;
signal alu_cy 				: Std_Logic;

-- Alu command
signal alu_cmd				: Std_Logic_Vector(1 downto 0);

-- mul command
signal start_mult			: Std_Logic;

-- Acces type
signal r_access_level   	: Std_Logic; --register for acces level (0 = user; 1 = supervisor)

-- execution type register
signal exec_type        	: Std_Logic_Vector(3 downto 0);
signal acces_user_reg		: Std_Logic;
--above register is "one-hot" and read as such :
--bit (3) = Supervisor Mode
--bit (2) = IRQ mode
--bit (1) = FIRQ mode
--bit (0) = User Mode

-- Interrupt signal
signal rq_irq				: std_logic;
signal rq_firq				: std_logic;
signal rq_dabt				: std_logic;
signal rq_iabt				: std_logic;
signal rq_adrex				: std_logic;
signal rq_swi				: std_logic;
signal rq_undef				: std_logic;
signal mask_IRQ 			: std_logic;
signal mask_FIRQ 			: std_logic;

signal begin_pin_interrupt	: std_logic;
signal instr_interrupt		: std_logic;		--SWI and undefined instruction
signal pin_interrupt		: std_logic;		--data instruction abort, FIRQ and IRQ
signal itr_bl	 			: std_logic:='0';	--flag during interruption blink
signal itr_hdl_flg 			: std_logic;		--only one interruption handle
signal interrupt_mode 		: std_logic_vector(3 downto 0):= "0001";
signal interrupt_vector 	: std_logic_vector(31 downto 0);
signal next_interrupt 		: std_logic_vector(3 downto 0);
signal interrupt_process	: std_logic;

-- DECOD FSM

type state_type is (FETCH, RUN, BRANCH, LINK, MTRANS, MULT,MLA);
signal cur_state, next_state : state_type;

signal debug_state : Std_Logic_Vector(3 downto 0) := X"0";

begin

	dec2exec : fifo_131b
	port map (		din(130) 			=> r_access_level,
					din(129) 			=> start_mult,
					din(128) 			=> pre_index,
					din(127 downto 96)  => op1,
					din(95 downto 64)   => op2,
					din(63 downto 60)   => alu_dest,
					din(59)             => alu_wb,
					din(58)             => flag_wb,
					
					din(57 downto 26)   => rdata3,
					din(25 downto 22)   => ld_dest,
					
					din(21)             => mem_swpb,
					din(20)             => mem_swp,
					din(19)             => mem_lw,
					din(18)             => mem_lb,
					din(17)             => mem_sw,
					din(16)             => mem_sb,
					
					din(15)             => shift_lsl,
					din(14)             => shift_lsr,
					din(13)             => shift_asr,
					din(12)             => shift_ror,
					din(11)             => shift_rrx,
					din(10 downto 6)    => shift_val,
					din(5)              => cry,
					
					din(4)              => comp_op1,
					din(3)              => comp_op2,
					din(2)              => alu_cy,
					
					din(1 downto 0)     => alu_cmd,
					
					dout(130)			=> dec2exe_kernel_right,
					dout(129)			=> dec_start_mult,
					dout(128)           => dec_pre_index,
					dout(127 downto 96) => dec_op1,
					dout(95 downto 64)  => dec_op2,
					dout(63 downto 60)  => dec_exe_dest,
					dout(59)            => dec_exe_wb,
					dout(58)            => dec_flag_wb,
					
					dout(57 downto 26)  => dec_mem_data,
					dout(25 downto 22)  => dec_mem_dest,
					
					dout(21)            => dec_mem_swpb,
					dout(20)            => dec_mem_swp,
					dout(19)            => dec_mem_lw,
					dout(18)            => dec_mem_lb,
					dout(17)            => dec_mem_sw,
					dout(16)            => dec_mem_sb,
					
					dout(15)            => dec_shift_lsl,
					dout(14)            => dec_shift_lsr,
					dout(13)            => dec_shift_asr,
					dout(12)            => dec_shift_ror,
					dout(11)            => dec_shift_rrx,
					dout(10 downto 6)   => dec_shift_val,
					dout(5)             => dec_cy,
					
					dout(4)             => dec_comp_op1,
					dout(3)             => dec_comp_op2,
					dout(2)             => dec_alu_cy,
					
					dout(1 downto 0)    => dec_alu_cmd,
					
					push                => dec2exe_push,
					pop                 => exe_pop,
					
					empty               => dec2exe_empty,
					full                => dec2exe_full,
					
					reset_n             => reset_n,
					ck                  => ck,
					vdd                 => vdd,
					vss                 => vss);

	dec2if : fifo_32b
	port map (		din					=> only_pc,
					dout    			=> dec_pc,
					
					push   				=> dec2if_push,
					pop    				=> if_pop,
					
					empty   			=> dec2if_empty,
					full    			=> dec2if_full,
					
					reset_n 			=> reset_n,
					ck      			=> ck,
					vdd     			=> vdd,
					vss     			=> vss);

	reg_inst  : registre
	port map(		wdata1	  			=> exe_res,
					wadr1     			=> exe_dest,
					wen1      			=> exe_wb,

					wmode     			=> exec_type,
					acces_user_reg		=>acces_user_reg,
					interrupt  		=> interrupt_process,

					wdata2    			=> mem_res,
					wadr2     			=> mem_dest,
					wen2      			=> mem_wb,

					wcry      			=> exe_c,
					wzero     			=> exe_z,
					wneg      			=> exe_n,
					wovr      			=> exe_v,
					cspr_wb   			=> exe_flag_wb,

					reg_rd1   			=> rdata1,
					radr1     			=> radr1,
					reg_v1    			=> rvalid1,

					reg_rd2   			=> rdata2,
					radr2     			=> radr2,
					reg_v2    			=> rvalid2,

					reg_rd3   			=> rdata3,
					radr3     			=> radr3,
					reg_v3    			=> rvalid3,

					reg_cry   			=> cry,
					reg_zero  			=> zero,
					reg_neg   			=> neg,
					reg_ovr   			=> ovr,

					reg_cznv  			=> reg_cznv,
					reg_vv    			=> reg_vv,

					inval_adr1			=> inval_exe_adr,
					inval1    			=> inval_exe,

					inval_adr2			=> inval_mem_adr,
					inval2    			=> inval_mem,

					inval_czn 			=> inval_czn,
					inval_ovr 			=> inval_ovr,

					reg_pc    			=> reg_pc,
					reg_pcv   			=> reg_pcv,
					inc_pc    			=> inc_pc,

					ck        			=> ck,
					reset_n   			=> reset_n,
					vdd       			=> vdd,
					vss       			=> vss);

-- Execution condition

	cond <= '1' when	(if_ir(31 downto 28) = X"0" and zero = '1') or
							(if_ir(31 downto 28) = X"1" and zero = '0') or
							(if_ir(31 downto 28) = X"2" and cry = '1') or
							(if_ir(31 downto 28) = X"3" and cry = '0') or
							(if_ir(31 downto 28) = X"4" and neg = '1') or
							(if_ir(31 downto 28) = X"5" and neg = '0') or
							(if_ir(31 downto 28) = X"6" and ovr = '1') or
							(if_ir(31 downto 28) = X"7" and ovr = '0') or
							(if_ir(31 downto 28) = X"8" and cry = '1' and zero = '0') or
							(if_ir(31 downto 28) = X"9" and (cry = '0' or zero = '1')) or
							(if_ir(31 downto 28) = X"A" and neg = ovr) or
							(if_ir(31 downto 28) = X"B" and neg /= ovr) or
							(if_ir(31 downto 28) = X"C" and zero = '0' and neg = ovr) or
							(if_ir(31 downto 28) = X"D" and (zero = '1' or neg /= ovr)) or
							(if_ir(31 downto 28) = X"E") else '0';

	condv <= '1'		when if_ir(31 downto 28) = X"E" 			else
			reg_cznv	when (if_ir(31 downto 28) = X"0" or
									if_ir(31 downto 28) = X"1" or
									if_ir(31 downto 28) = X"2" or
									if_ir(31 downto 28) = X"3" or
									if_ir(31 downto 28) = X"4" or
									if_ir(31 downto 28) = X"8" or
									if_ir(31 downto 28) = X"9") 	else

			reg_vv	when (if_ir(31 downto 28) = X"6" or
							if_ir(31 downto 28) = X"7") 	else

			reg_cznv and reg_vv;


-- decod instruction type

	regop_t  <= '1' when	if_ir(27 downto 26) = "00"	   and
								mult_t = '0' and swap_t = '0'	else '0';

	mult_t   <= '1' when	if_ir(27 downto 22) = "000000" and
								if_ir(7 downto 4) = "1001"	  	else '0';

	swap_t   <= '1' when	if_ir(27 downto 23) = "00010"  and
								if_ir(11 downto 4) = "00001001" else '0';

	trans_t  <= '1' when	if_ir(27 downto 26) = "01" 			else '0';
	mtrans_t <= '1' when	if_ir(27 downto 25) = "100" 		else '0';
	branch_t <= '1' when	if_ir(27 downto 25) = "101" 		else '0';
	swi_t 	 <= '1' when	if_ir(27 downto 24) = "1111"		else '0';
	copro_t  <= '1' when	if_ir(27 downto 24) = "1110"		else '0';

-- decod regop opcode

	and_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"0" else '0';
	eor_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"1" else '0';
	sub_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"2" else '0';
	rsb_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"3" else '0';
	add_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"4" else '0';
	adc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"5" else '0';
	sbc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"6" else '0';
	rsc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"7" else '0';
	tst_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"8" else '0';
	teq_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"9" else '0';
	cmp_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"A" else '0';
	cmn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"B" else '0';
	orr_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"C" else '0';
	mov_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"D" else '0';
	bic_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"E" else '0';
	mvn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"F" else '0';

-- mult instruction
	mul_i <= '1' when mult_t = '1' and if_ir(21) = '0' else '0';
	mla_i <= '1' when mult_t = '1' and if_ir(21) = '1' else '0';

-- trans instruction
	ldr_i  <= '1' when trans_t = '1' and if_ir(22) = '0' and if_ir(20) = '1' else '0';
	str_i  <= '1' when trans_t = '1' and if_ir(22) = '0' and if_ir(20) = '0' else '0';
	ldrb_i <= '1' when trans_t = '1' and if_ir(22) = '1' and if_ir(20) = '1' else '0';
	strb_i <= '1' when trans_t = '1' and if_ir(22) = '1' and if_ir(20) = '0' else '0';

-- mtrans instruction
	ldm_i <= '1' when mtrans_t = '1' and if_ir(20) = '1' else '0';
	stm_i <= '1' when mtrans_t = '1' and if_ir(20) = '0' else '0';

-- branch instruction
	b_i  <= '1' when branch_t = '1' and if_ir(24) = '0' else '0';
	bl_i <= '1' when branch_t = '1' and if_ir(24) = '1' else '0';

-- swap instruction
	swp_i  <= '1' when swap_t = '1' and if_ir(22) = '0' else '0';
	swpb_i <= '1' when swap_t = '1' and if_ir(22) = '1' else '0';
	
-- Decode interface operande
	op1 <=	reg_pc		when ((pin_interrupt = '1' and (itr_bl = '1'	or begin_pin_interrupt = '1')) or instr_interrupt = '1') and blink='1'	else
			interrupt_vector	when (pin_interrupt = '1' and itr_bl = '1'	 ) or instr_interrupt = '1'	else
			reg_pc		when branch_t = '1'					else
			X"00000000" when mov_i = '1' or mvn_i = '1'		else
			exe_res		when mtrans_loop_adr = '1'			else
			exe_res 	when mla_i = '1'and exe_end_mult ='1'	else
			rdata1;

	offset32 <=	X"FF" & if_ir(23 downto 0) when if_ir(23) = '1' else
					X"00" & if_ir(23 downto 0);

	op2	<=	X"00000004" 	when ((pin_interrupt = '1' and (itr_bl = '1'	or begin_pin_interrupt = '1')) or instr_interrupt = '1') and blink='1'	    		else	
			X"00000000" 	when (pin_interrupt = '1' and (itr_bl = '1'	or begin_pin_interrupt = '1'))or instr_interrupt = '1'	else
			X"00000001"							when blink = '1'								else
			offset32							when branch_t = '1'								else
			X"000000" & if_ir(7 downto 0) 		when regop_t = '1' and if_ir(25) = '1'			else
			X"00000" & if_ir(11 downto 0)		when trans_t = '1' and if_ir(25) = '0'			else
			X"000000" & '0' & mtrans_nbr & "00"	when mtrans_t = '1' and mtrans_shift = '0' and
																	if_ir(23) = '0'				else
			X"00000000" 						when mtrans_t = '1' and mtrans_shift = '0' and
													 if_ir(23) = '1'							else
			X"00000004"							when mtrans_t = '1'								else
			rdata3								when mla_i = '1'and exe_end_mult ='1'			else

			rdata2;

	alu_dest <=	X"E"					when blink 		= '1'	else
				X"F"					when (pin_interrupt = '1' and (itr_bl = '1'	or begin_pin_interrupt = '1')) or instr_interrupt = '1'	else
				X"F"					when branch_t 	= '1'	else
				if_ir(15 downto 12)		when regop_t 	= '1'	else
				if_ir(19 downto 16);

	alu_wb	<=  '1'	when	branch_t = '1'																else
				'1'	when	and_i = '1' or eor_i = '1' or sub_i = '1' or rsb_i = '1' or
											add_i = '1' or adc_i = '1' or sbc_i = '1' or rsc_i = '1' or
											orr_i = '1' or mov_i = '1' or bic_i = '1' or mvn_i = '1'	else
				'1'	when	trans_t = '1'and (if_ir(24) = '0' or if_ir(21) = '1')						else
				'1'	when	swap_t = '1'																else
				'1'	when	mtrans_t = '1' and if_ir(21) = '1' and mtrans_shift = '1' and
											if_ir(23) = '1' 											else
				'1'	when	mtrans_t = '1' and if_ir(21) = '1' and mtrans_shift = '0' 					else
				'1'	when	mul_i = '1' or mla_i = '1' 													else
				'1'	when	(pin_interrupt = '1'	and (itr_bl = '1'	or begin_pin_interrupt = '1')) or instr_interrupt = '1'	else
				'0';

	flag_wb	<= if_ir(20) when	(regop_t = '1' or mult_t ='1' or swap_t='1') else '0';

-- reg read
	radr1 <= X"E" when bl_i = '1' else
				if_ir(11 downto 8) when mult_t='1' else
				if_ir(19 downto 16);
				
	radr2 <= if_ir(3 downto 0);

	radr3 <= mtrans_rd				when mtrans_t = '1'	else
				if_ir(15 downto 12)	when trans_t = '1' or swap_t = '1'	else
				if_ir(15 downto 12) when mult_t='1' else
				if_ir(11 downto 8);

-- Reg Invalid

	inval_exe_adr <=X"F"				when branch_t = '1'or instr_interrupt = '1'	or (pin_interrupt = '1' and (itr_bl = '1'or begin_pin_interrupt = '1')) else

					if_ir(19 downto 16)	when trans_t = '1' or mtrans_t = '1' or mult_t ='1'	else
					if_ir(15 downto 12);

	inval_exe <='1'	when	dec2exe_push = '1' and (branch_t = '1' or instr_interrupt = '1'	or (pin_interrupt = '1' and (itr_bl = '1'or begin_pin_interrupt = '1'))	 or
										(trans_t = '1' and (if_ir(21) = '1' or if_ir(24) = '0')) or 
										(mtrans_t = '1' and mtrans_shift = '0' and
										(if_ir(21) = '1' ))					 or
										and_i = '1' or eor_i = '1' or sub_i = '1' or rsb_i = '1' or
										add_i = '1' or adc_i = '1' or sbc_i = '1' or rsc_i = '1' or
										orr_i = '1' or mov_i = '1' or bic_i = '1' or mvn_i = '1' or 
										mul_i= '1' or mla_i='1' )									else
				'0';

	inval_mem_adr <=X"E"				when blink = '1'	else
					if_ir(15 downto 12)	when trans_t = '1' 	else
					mtrans_rd;

	inval_mem <='1'	when	dec2exe_push = '1' and (blink = '1'	or ldr_i = '1' or
								ldrb_i = '1' or ldm_i = '1')							else
				'0';

	inval_czn <='1'	when	dec2exe_push = '1' and (regop_t = '1' or mult_t='1') and if_ir(20) = '1' 		else
				'0';

	inval_ovr <='1'	when	dec2exe_push = '1' and if_ir(20) = '1' and (sub_i = '1'		or
								rsb_i = '1' or add_i = '1' or adc_i = '1' or sbc_i = '1'	or
								rsc_i = '1' or cmp_i = '1' or cmn_i = '1')						else
				'0';

-- operand validite

	operv <=	'1' when ((pin_interrupt = '1' and (itr_bl = '1'or begin_pin_interrupt = '1')) or instr_interrupt = '1') and reg_pcv = '1'		else
				'1' when branch_t = '1' and reg_pcv = '1'										else
				'1' when regop_t = '1' and rvalid1 = '1' and if_ir(25) = '1'					else
				'1' when regop_t = '1' and rvalid1 = '1' and if_ir(25) = '0' and               
							rvalid2 = '1' and if_ir(4) = '0'									else
				'1' when regop_t = '1' and rvalid1 = '1' and if_ir(25) = '1' and               
							rvalid2 = '1' and if_ir(4) = '1' and rvalid3 = '1'					else
				'1' when (ldr_i = '1' or ldrb_i = '1') and rvalid1 = '1' and if_ir(25) = '0'	else
				'1' when (ldr_i = '1' or ldrb_i = '1') and
							rvalid1 = '1' and if_ir(25) = '1' and rvalid2 = '1'					else
				'1' when (str_i = '1' or strb_i = '1') and rvalid3 = '1' and rvalid1 = '1' and
							if_ir(25) = '0' 													else
				'1' when (str_i = '1' or strb_i = '1') and rvalid3 = '1' and rvalid1 = '1' and
							if_ir(25) = '1' and rvalid2 = '1'									else
				'1' when ldm_i = '1' and rvalid1 = '1'											else
				'1' when stm_i = '1' and rvalid1 = '1' and rvalid3 = '1'						else
				'1' when mul_i = '1' and rvalid1 = '1' and rvalid3 = '1'						else
				'1' when mla_i ='1' and rvalid1 = '1' and rvalid2 = '1' and rvalid3 ='1'		else
				'1' when swap_t ='1' and rvalid1 = '1' and rvalid2 = '1' and rvalid3 ='1'		else
				
				'0';

-- Decode to mem interface 
	ld_dest <= mtrans_rd when mtrans_t = '1' else if_ir(15 downto 12);
	pre_index <=	if_ir(24)		when trans_t = '1'								else
					if_ir(24)		when mtrans_t = '1' and if_ir(23) = '1'			else
					not if_ir(24)	when mtrans_t = '1' and if_ir(23) = '0'			else
					'0';

	mem_swp <= swp_i;
	mem_swpb <= swpb_i;
	mem_lw <= ldr_i or (ldm_i and mtrans_shift);
	mem_lb <= ldrb_i;
	mem_sw <= str_i or (stm_i and mtrans_shift);
	mem_sb <= strb_i;



-- Shifter command

	shift_lsl <=	'1' when ((regop_t = '1' and if_ir(25) = '0') or (trans_t = '1' and if_ir(25) = '1'))
										and if_ir(6 downto 5) = "00"	else 
						'1' when branch_t = '1' 						else
						'0';

	shift_lsr <= '1' when ((regop_t = '1' and if_ir(25) = '0') or
	  							(trans_t = '1' and if_ir(25) = '1')) and if_ir(6 downto 5) = "01" 	else '0';
	shift_asr <= '1' when ((regop_t = '1' and if_ir(25) = '0') or
	  							(trans_t = '1' and if_ir(25) = '1')) and if_ir(6 downto 5) = "10" 	else '0';
	shift_ror <= '1' when (regop_t = '1' and if_ir(25) = '1') else
	  			 '1' when ((regop_t = '1' and if_ir(25) = '0' and  if_ir(11 downto 7) /= "00000") or 
	  							(trans_t = '1' and if_ir(25) = '1')) and if_ir(6 downto 5) = "11" 	else '0';
	shift_rrx <= '1' when regop_t = '1' and if_ir(25) = '0' and  if_ir(11 downto 7) = "00000"		else '0';

	shift_val <= "00000" 		when pin_interrupt = '1' and (itr_bl = '1'	or begin_pin_interrupt = '1') else
			"00010"			when branch_t = '1'							else
						if_ir(11 downto 8) & '0'	when regop_t = '1' and if_ir(25) = '1'		else
						rdata3(4 downto 0)			when if_ir(4) = '1'							else
						if_ir(11 downto 7);

-- Alu operand selection
	comp_op1	<= '1' when rsb_i = '1' or rsc_i = '1' else '0';
	comp_op2	<=	'1' when sub_i = '1' or sbc_i = '1' or cmp_i = '1' or bic_i = '1' or mvn_i = '1'	else
					not if_ir(23) when trans_t = '1' or (mtrans_t = '1' and mtrans_shift = '0')			else
					'1' when blink = '1' 															else
					'0';

	alu_cy <=	'1'				when sub_i = '1' or rsb_i = '1' or cmp_i = '1' or blink = '1'			else
				not if_ir(23)	when trans_t = '1' or (mtrans_t = '1' and mtrans_shift = '0')			else
				cry				when adc_i = '1'														else
				not cry			when sbc_i = '1' or rsc_i = '1'											else 
				'0';

	alu_cmd <=	"00" when (pin_interrupt = '1' and (itr_bl = '1'	or begin_pin_interrupt = '1')) else
					"11" when eor_i = '1' or teq_i = '1'						else
					"10" when orr_i = '1' or mov_i = '1' or mvn_i = '1'		else
					"01" when and_i = '1' or bic_i = '1' or tst_i = '1'		else
					"00";

-- Mult command
	start_mult <= '1' when mul_i = '1'	and exe_end_mult = '0'	else
					'1' when mla_i = '1' and exe_end_mult = '0' else
						'0'; 
--gestion exec_type

	process (ck)
	begin
		if (rising_edge(ck)) then
   			exec_type <= interrupt_mode;
   			if i_iabt='1' or i_irq='1' or i_adrex='1' or i_firq='1' or
				i_dabt='1' or rq_swi='1' or rq_undef='1' then
				mask_IRQ <= '1';
			else
				mask_IRQ <= '0';
			end if ;

			if i_firq='1' then
				mask_FIRQ <= '1';
			else
				mask_FIRQ <= '0';
			end if ;
		end if;
	end process;


-- gestion des interruptions

rq_firq	<= i_firq and mask_FIRQ;
rq_dabt	<= i_dabt;
rq_iabt	<= i_iabt;
rq_adrex<= i_adrex;
rq_swi  <= swi_t;
rq_undef<= copro_t;  

instr_interrupt <= '1' when rq_swi 	='1' or rq_undef 	='1' else 
					'0';

pin_interrupt <= '1' when rq_dabt ='1' or rq_irq='1' or rq_firq	='1' or rq_adrex 	='1' or rq_iabt	='1' else
					'0';


next_interrupt<=X"1"	when rq_dabt 	='1' else
				X"2"	when rq_firq	='1' else
				X"3"	when rq_irq 	='1' else
				X"4"	when rq_adrex 	='1' else
				X"5"	when rq_iabt	='1' else
				X"6"	when rq_swi 	='1' else
				X"7"	when rq_undef 	='1' else
				X"0"	;


with next_interrupt select
	interrupt_vector <= X"00000010"	when X"1", --data abord
                  		X"0000001c"	when X"2", --fast interrupt
                  		X"00000018"	when X"3", --interrupt
                  		X"0000000c"	when X"4", --address exeption
                  		X"00000014" when X"5", --instruction abord
                  		X"00000008"	when X"6", --software interruption
                  		X"00000004"	when X"7", --undefined instruction
                  		X"00000000"	when others;

interrupt_mode <= "1000"	when next_interrupt = X"1" else --data abord
                  "0010"	when next_interrupt = X"2" else--fast interrupt
                  "0100"	when next_interrupt = X"3" else--interrupt
                  "1000"	when next_interrupt = X"4" else --address exeption
                  "1000"	when next_interrupt = X"5" else--instruction abord
                  "1000"	when next_interrupt = X"6" else--software interruption
                  "1000"	when next_interrupt = X"7" else--undefined instruction
                  "0001" 	when reg_pc(1 downto 0) = "00" else
		          "0010" 	when reg_pc(1 downto 0) = "01" else
		          "0100" 	when reg_pc(1 downto 0) = "10" else
                  "1000" 	when reg_pc(1 downto 0) = "11" else
                  "0000";


-- user reg access

	acces_user_reg <= '1'when mtrans_t = '1' and if_ir(22) = '1' else
						'0';

-- Mtrans reg list

	process (ck)
	begin
		if (rising_edge(ck)) then
				if reset_n = '0' then
					mtrans_mask <= X"FFFF";
				elsif if2dec_pop = '1' then
					mtrans_mask <= X"FFFF";
				elsif mtrans_shift = '1' then
					mtrans_mask <= mtrans_mask_shift;
				end if;
		end if;
	end process;

	mtrans_mask_shift <=X"FFFE" when if_ir(0)  = '1' and mtrans_mask(0)  = '1' else
						X"FFFC" when if_ir(1)  = '1' and mtrans_mask(1)  = '1' else
						X"FFF8" when if_ir(2)  = '1' and mtrans_mask(2)  = '1' else
						X"FFF0" when if_ir(3)  = '1' and mtrans_mask(3)  = '1' else
						X"FFE0" when if_ir(4)  = '1' and mtrans_mask(4)  = '1' else
						X"FFC0" when if_ir(5)  = '1' and mtrans_mask(5)  = '1' else
						X"FF80" when if_ir(6)  = '1' and mtrans_mask(6)  = '1' else
						X"FF00" when if_ir(7)  = '1' and mtrans_mask(7)  = '1' else
						X"FE00" when if_ir(8)  = '1' and mtrans_mask(8)  = '1' else
						X"FC00" when if_ir(9)  = '1' and mtrans_mask(9)  = '1' else
						X"F800" when if_ir(10) = '1' and mtrans_mask(10) = '1' else
						X"F000" when if_ir(11) = '1' and mtrans_mask(11) = '1' else
						X"E000" when if_ir(12) = '1' and mtrans_mask(12) = '1' else
						X"C000" when if_ir(13) = '1' and mtrans_mask(13) = '1' else
						X"8000" when if_ir(14) = '1' and mtrans_mask(14) = '1' else
						X"0000";

	mtrans_list <= if_ir(15 downto 0) and mtrans_mask;

	process (mtrans_list)
	variable cpt : integer;
	begin
		cpt := 0;
		for i in 0 to 15 loop
			if mtrans_list(i) = '1' then
				cpt := cpt + 1;
			end if;
		end loop;
		mtrans_nbr <= Std_Logic_Vector(TO_SIGNED(cpt, 5));
	end process;

	mtrans_1un <= '1' when mtrans_nbr = "00001" else '0';

	mtrans_rd <=X"0" when mtrans_list(0)  = '1' else
				X"1" when mtrans_list(1)  = '1' else
				X"2" when mtrans_list(2)  = '1' else
				X"3" when mtrans_list(3)  = '1' else
				X"4" when mtrans_list(4)  = '1' else
				X"5" when mtrans_list(5)  = '1' else
				X"6" when mtrans_list(6)  = '1' else
				X"7" when mtrans_list(7)  = '1' else
				X"8" when mtrans_list(8)  = '1' else
				X"9" when mtrans_list(9)  = '1' else
				X"A" when mtrans_list(10) = '1' else
				X"B" when mtrans_list(11) = '1' else
				X"C" when mtrans_list(12) = '1' else
				X"D" when mtrans_list(13) = '1' else
				X"E" when mtrans_list(14) = '1' else
				X"F";

-- FSM

process (ck)
begin

if (rising_edge(ck)) then
	if (reset_n = '0') then
		cur_state <= FETCH;
	else
		cur_state <= next_state;
	end if;

	interrupt_process <= instr_interrupt or (pin_interrupt and not itr_hdl_flg ) or itr_bl ;

	if cur_state = RUN and pin_interrupt ='1' then
		itr_hdl_flg <= '1';
	elsif next_interrupt = X"0" then 
		itr_hdl_flg <= '0';
	else
	end if;

	if itr_hdl_flg = '0' and cur_state = RUN and pin_interrupt ='1' then
		itr_bl <= '1';
	end if;
	if next_state = RUN and itr_hdl_flg = '1' then 
			itr_bl <= '0';
	else
	end if;
end if;

end process;

inc_pc <= dec2if_push;
only_pc <=  "000000" & reg_pc(25 downto 2) & "00";
--state machine process.
process (cur_state, dec2if_full, cond, condv, operv, dec2exe_full, if2dec_empty,
 		reg_pcv, bl_i,branch_t, and_i, eor_i, sub_i, rsb_i, add_i, adc_i, sbc_i,
 		rsc_i, orr_i, mov_i, bic_i,mvn_i, ldr_i, ldrb_i, ldm_i, stm_i, if_ir, 
 		mtrans_rd,mtrans_1un, mtrans_t,mtrans_mask_shift,exe_end_mult,mult_t,
 		mla_i,mul_i,pin_interrupt,instr_interrupt,dec2exe_push,itr_bl,itr_hdl_flg)
begin



	case cur_state is

	when FETCH =>
		debug_state     <= X"1";
		if2dec_pop      <= '0';
		dec2exe_push    <= '0';
		blink           <= '0';
		mtrans_shift    <= '0';
		mtrans_loop_adr <= '0';

		if dec2if_full = '0' and reg_pcv = '1' then
			next_state  <= RUN;
			dec2if_push <= '1';
		else
			next_state  <= FETCH;
			dec2if_push <= '0';
		end if;
			

	
	when RUN =>
		debug_state     <= X"2";
		mtrans_loop_adr <= '0';

		if pin_interrupt ='1' and itr_hdl_flg = '0' then
			debug_state  <= X"0";
			begin_pin_interrupt <= '1';
			next_state   <= LINK;
			dec2if_push  <= '0';
			if2dec_pop   <= '0';
			dec2exe_push <= '1';
			blink        <= '1';
			mtrans_shift <= '0';
			

		elsif if2dec_empty = '1' or operv = '0' or dec2exe_full = '1' or condv = '0' then
			next_state <= RUN;
			begin_pin_interrupt <= '0';

			if dec2if_full = '0' and reg_pcv = '1' then
				dec2if_push	<= '1';
			else
				dec2if_push	<= '0';
			end if;

			if2dec_pop   <= '0';
			dec2exe_push <= '0';
			blink        <= '0';
			mtrans_shift <= '0';

		else
			begin_pin_interrupt <= '0';
			if cond = '0' then
				next_state   <= RUN;
				
				dec2if_push  <= '1';
				if2dec_pop   <= '1';
				dec2exe_push <= '0';
				blink        <= '0';
				mtrans_shift <= '0';

			else
				if bl_i = '1' then
					next_state   <= LINK;
					
					dec2if_push  <= '0';
					if2dec_pop   <= '0';
					dec2exe_push <= '1';
					blink        <= '1';
					mtrans_shift <= '0';
					
				elsif branch_t = '1' or
				 ((and_i = '1' or eor_i = '1' or sub_i = '1' or rsb_i = '1' or add_i = '1' or
				adc_i = '1' or sbc_i = '1' or rsc_i = '1' or orr_i = '1' or mov_i = '1' or
				bic_i = '1' or mvn_i = '1' or ldr_i = '1' or ldrb_i = '1') and
				if_ir(15 downto 12) = X"F") then
				--if_ir(15 downto 12) = X"F") or
				--(ldm_i = '1' and if_ir(15 downto 0) = X"8000") then
					next_state   <= BRANCH;
					
					dec2if_push  <= '0';
					if2dec_pop   <= '1';
					dec2exe_push <= '1';
					blink        <= '0';
					mtrans_shift <= '0';

				elsif mtrans_t = '1' and mtrans_1un = '0' then
					next_state <= MTRANS;
            
					if dec2if_full = '0' and reg_pcv = '1' then
						dec2if_push	<= '1';
					else
						dec2if_push	<= '0';
					end if;
					if2dec_pop   <= '0';
					dec2exe_push <= '1';
					blink        <= '0';
					mtrans_shift <= '0';

				elsif mult_t = '1' then
					next_state   <= MULT;
					
					dec2if_push  <= '0';
					if2dec_pop   <= '0';
					dec2exe_push <= '1';
					blink        <= '0';
					mtrans_shift <= '0';

				elsif instr_interrupt='1' then
					next_state   <= LINK;
					
					dec2if_push  <= '0';
					if2dec_pop   <= '0';
					dec2exe_push <= '1';
					blink        <= '1';
					mtrans_shift <= '0';

				else
					next_state   <= RUN;
					
					dec2if_push  <= '1';
					if2dec_pop   <= '1';
					dec2exe_push <= '1';
					blink        <= '0';
					mtrans_shift <= '0';

				end if;
			end if;
		end if;

	when BRANCH =>
		debug_state     	<= X"3";
		dec2exe_push    	<= '0';
		blink           	<= '0';
		
		mtrans_shift    	<= '0';
		mtrans_loop_adr 	<= '0';

		if if2dec_empty = '1' then
			next_state  	<= BRANCH;
				
			dec2if_push 	<= '0';
			if2dec_pop  	<= '0';
		else
			if reg_pcv = '1' and dec2if_full = '0' then
				next_state  <= RUN;
				
				dec2if_push <= '1';
				if2dec_pop  <= '1';

			else
				next_state  <= FETCH;
				
				dec2if_push <= '0';
				if2dec_pop  <= '1';
			end if;
		end if;

	when LINK =>
		debug_state     	<= X"4";
		begin_pin_interrupt <= '0';
		next_state      	<= BRANCH;
			
		dec2if_push     	<= '0';
		if2dec_pop      	<= '1';
		dec2exe_push    	<= '1';
		blink           	<= '0';
		mtrans_shift    	<= '0';
		mtrans_loop_adr 	<= '0';

	when MTRANS =>
		debug_state     	<= X"5";
		blink           	<= '0';
		mtrans_loop_adr 	<= '1';
		rq_irq	<= '1';

		if dec2exe_full = '1' or operv = '0' then
			next_state   	<= MTRANS;
				
			dec2if_push  	<= '0';
			if2dec_pop   	<= '0';
			dec2exe_push 	<= '0';
			mtrans_shift 	<= '0';

		elsif ldm_i = '1' and mtrans_rd = X"F" then 
			next_state  	<= BRANCH;
			
			dec2if_push 	<= '0';
			if2dec_pop  	<= '1';
			dec2exe_push	<= '1';
			mtrans_shift	<= '1';

		elsif mtrans_1un = '1' then
			next_state   	<= RUN;
			
			dec2if_push  	<= '1';
			if2dec_pop   	<= '1';
			dec2exe_push 	<= '1';
			mtrans_shift 	<= '1';

		else
			next_state   	<= MTRANS;
			
			dec2if_push  	<= '0';
			if2dec_pop   	<= '0';
			dec2exe_push 	<= '1';
			mtrans_shift 	<= '1';
		end if;

	when MULT =>
		debug_state     	<= X"6";
		blink           	<= '0';
		mtrans_shift    	<= '0';
		mtrans_loop_adr 	<= '0';
		--rq_irq	<= '1';
		

		if exe_end_mult='1' and mla_i='0' then 
			next_state 		<= RUN;
			dec2if_push		<= '1';
			if2dec_pop 		<= '1';
			dec2exe_push    <= '0';


		elsif exe_end_mult='1' and mla_i='1' then
			next_state  	<= MLA;
			dec2if_push 	<= '0';
			if2dec_pop  	<= '0';
			dec2exe_push    <= '1';

		else 
			next_state  	<= MULT;
			dec2if_push 	<= '0';
			if2dec_pop  	<= '0';
			dec2exe_push    <= '0';

		end if;

	when MLA =>
			debug_state     <= X"7";
			blink           <= '0';
			mtrans_shift    <= '0';
			mtrans_loop_adr <= '0';
			next_state 		<= RUN;
			dec2if_push		<= '1';
			if2dec_pop 		<= '1';
			dec2exe_push    <= '0';
	end case;




end process;

r_access_level <= not exec_type(0);
dec_pop <= if2dec_pop;
end Behavior;
