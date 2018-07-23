library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

--  Un testbench n a pas de port entree ou sortie
entity Exec_tb is
end Exec_tb;

architecture behavior of Exec_tb is
--  Declaration du composant Exec
component Exec
	port(
	-- Decode interface synchro
			dec2exe_empty	: in Std_logic;
			exe_pop			: out Std_logic;

	-- Decode interface operands
			dec_op1			: in Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: in Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: in Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: in Std_Logic; -- Rd destination write back
			dec_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Decode to mem interface 
			dec_mem_data	: in Std_Logic_Vector(31 downto 0); -- data to MEM W
			dec_mem_dest	: in Std_Logic_Vector(3 downto 0); -- Destination MEM R
			dec_pre_index 	: in Std_logic;

			dec_mem_lw		: in Std_Logic;
			dec_mem_lb		: in Std_Logic;
			dec_mem_sw		: in Std_Logic;
			dec_mem_sb		: in Std_Logic;

	-- Shifter command
			dec_shift_lsl	: in Std_Logic;
			dec_shift_lsr	: in Std_Logic;
			dec_shift_asr	: in Std_Logic;
			dec_shift_ror	: in Std_Logic;
			dec_shift_rrx	: in Std_Logic;
			dec_shift_val	: in Std_Logic_Vector(4 downto 0);
			dec_cy			: in Std_Logic;

	-- Mult command
			dec_start_mult		: in Std_Logic_vector(1 downto 0);


	-- Alu operand selection
			dec_comp_op1	: in Std_Logic;
			dec_comp_op2	: in Std_Logic;
			dec_alu_cy 		: in Std_Logic;

	-- Alu command
			dec_alu_cmd		: in Std_Logic_Vector(1 downto 0);

	-- Exe bypass to decod
			exe_res			: out Std_Logic_Vector(31 downto 0);
			exe_end_mult		: out Std_Logic_Vector(1 downto 0);
			exe_c				: out Std_Logic;
			exe_v				: out Std_Logic;
			exe_n				: out Std_Logic;
			exe_z				: out Std_Logic;

			exe_dest			: out Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: out Std_Logic; -- Rd destination write back
			exe_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Mem interface
			exe_mem_adr		: out Std_Logic_Vector(31 downto 0); -- Alu res register
			exe_mem_data	: out Std_Logic_Vector(31 downto 0);
			exe_mem_dest	: out Std_Logic_Vector(3 downto 0);

			exe_mem_lw		: out Std_Logic;
			exe_mem_lb		: out Std_Logic;
			exe_mem_sw		: out Std_Logic;
			exe_mem_sb		: out Std_Logic;

			exe2mem_empty	: out Std_logic;
			mem_pop			: in Std_logic;

	-- global interface
			ck				: in Std_logic;
			reset_n			: in Std_logic;
			vdd				: in bit;
			vss				: in bit);
end component;

-- Declaration des signaux

signal dec2exe_empty	: Std_logic;
signal exe_pop			: Std_logic;

signal dec_op1			: Std_Logic_Vector(31 downto 0);
signal dec_op2			: Std_Logic_Vector(31 downto 0);
signal dec_exe_dest	: Std_Logic_Vector(3 downto 0);
signal dec_exe_wb		: Std_Logic;
signal dec_flag_wb	: Std_Logic;

signal dec_mem_data	: Std_Logic_Vector(31 downto 0);
signal dec_mem_dest	: Std_Logic_Vector(3 downto 0);

signal dec_mem_lw		: Std_Logic;
signal dec_mem_lb		: Std_Logic;
signal dec_mem_sw		: Std_Logic;
signal dec_mem_sb		: Std_Logic;

signal dec_shift_lsl	: Std_Logic;
signal dec_shift_lsr	: Std_Logic;
signal dec_shift_asr	: Std_Logic;
signal dec_shift_ror	: Std_Logic;
signal dec_shift_rrx	: Std_Logic;
signal dec_shift_val	: Std_Logic_Vector(4 downto 0);
signal dec_cy			: Std_Logic;

signal dec_start_mult		: Std_Logic_Vector(1 downto 0);

signal dec_comp_op1		: Std_Logic;
signal dec_comp_op2		: Std_Logic;
signal dec_alu_cy 		: Std_Logic;

signal dec_alu_cmd		: Std_Logic_Vector(1 downto 0);

signal exe_res			: Std_Logic_Vector(31 downto 0);
signal exe_end_mult		: Std_Logic_Vector(1 downto 0);

signal exe_c			: Std_Logic;
signal exe_v			: Std_Logic;
signal exe_n			: Std_Logic;
signal exe_z			: Std_Logic;

signal exe_dest		: Std_Logic_Vector(3 downto 0);
signal exe_wb			: Std_Logic;
signal exe_flag_wb	: Std_Logic;

signal exe_mem_adr	: Std_Logic_Vector(31 downto 0);
signal exe_mem_data	: Std_Logic_Vector(31 downto 0);
signal exe_mem_dest	: Std_Logic_Vector(3 downto 0);
signal dec_pre_index	: Std_Logic;

signal exe_mem_lw		: Std_Logic;
signal exe_mem_lb		: Std_Logic;
signal exe_mem_sw		: Std_Logic;
signal exe_mem_sb		: Std_Logic;

signal exe2mem_empty	: Std_logic;
signal mem_pop			: Std_logic;

signal ck				: Std_logic := '0';
signal reset_n			: Std_logic;

constant vdd			: bit := '1';
constant vss			: bit := '0';

begin
-- instanciation du composant Exec
Exec_0: Exec
	port map (	dec2exe_empty	=> dec2exe_empty,
					exe_pop			=> exe_pop,

					dec_op1			=> dec_op1,
					dec_op2			=> dec_op2,
					dec_exe_dest	=> dec_exe_dest,
					dec_exe_wb		=> dec_exe_wb,
					dec_flag_wb		=> dec_flag_wb,
         
					dec_mem_data	=> dec_mem_data,
					dec_mem_dest	=> dec_mem_dest,
					dec_pre_index 	=> dec_pre_index,
         
					dec_mem_lw		=> dec_mem_lw,
					dec_mem_lb		=> dec_mem_lb,
					dec_mem_sw		=> dec_mem_sw,
					dec_mem_sb		=> dec_mem_sb,
         
					dec_shift_lsl	=> dec_shift_lsl,
					dec_shift_lsr	=> dec_shift_lsr,
					dec_shift_asr	=> dec_shift_asr,
					dec_shift_ror	=> dec_shift_ror,
					dec_shift_rrx	=> dec_shift_rrx,
					dec_shift_val	=> dec_shift_val,
					dec_cy			=> dec_cy,

					dec_start_mult  => dec_start_mult,
         
					dec_comp_op1	=> dec_comp_op1,
					dec_comp_op2	=> dec_comp_op2,
					dec_alu_cy 		=> dec_alu_cy ,
         
					dec_alu_cmd		=> dec_alu_cmd,
         
					exe_res			=> exe_res,
					exe_end_mult	=> exe_end_mult,
         
					exe_c			=> exe_c,
					exe_v			=> exe_v,
					exe_n			=> exe_n,
					exe_z			=> exe_z,
         
					exe_dest		=> exe_dest,
					exe_wb			=> exe_wb,
					exe_flag_wb		=> exe_flag_wb,
         
					exe_mem_adr		=> exe_mem_adr,
					exe_mem_data	=> exe_mem_data,
					exe_mem_dest	=> exe_mem_dest,
         
					exe_mem_lw		=> exe_mem_lw,
					exe_mem_lb		=> exe_mem_lb,
					exe_mem_sw		=> exe_mem_sw,
					exe_mem_sb		=> exe_mem_sb,
         
					exe2mem_empty	=> exe2mem_empty,
					mem_pop			=> mem_pop,
         
					ck				=> ck,
					reset_n			=> reset_n,
					vdd				=> vdd,
					vss				=> vss);

	process
	begin

			dec2exe_empty <= '0';

			dec_op1 <= X"00005678";
			dec_op2 <= X"00004321";
			
			dec_exe_dest <= X"C";
			dec_exe_wb <= '1';
			dec_flag_wb <= '1';

			dec_mem_data <= X"12345678";
			dec_mem_dest <= X"D";
			dec_pre_index <= '0';

			dec_mem_lw <= '0';
			dec_mem_lb <= '0';
			dec_mem_sw <= '0';
			dec_mem_sb <= '0';

			dec_shift_lsl <= '0';
			dec_shift_lsr <= '0';
			dec_shift_asr <= '0';
			dec_shift_ror <= '0';
			dec_shift_rrx <= '0';
			dec_shift_val <= "00000";
			dec_cy <= '0';

			dec_start_mult <= "01";

			dec_comp_op1 <= '0';
			dec_comp_op2 <= '0';
			dec_alu_cy  <= '0';

			dec_alu_cmd <= "00";

			mem_pop <= '0';

			reset_n <= '1';
			ck <= '1';
			wait for 1 ns;
			ck <= '0';
			wait for 1 ns;


			reset_n <= '0';
			ck <= '1';
			wait for 1 ns;
			ck <= '0';
			wait for 1 ns;


			reset_n <= '1';

	for I in 0 to 100 loop
			ck <= '1';
			wait for 1 ns;
			ck <= '0';
			wait for 1 ns;
	end loop;




		wait;
		end process;


			

end behavior;

