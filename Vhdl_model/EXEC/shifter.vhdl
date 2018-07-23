library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
	port(
			shift_lsl	: in Std_Logic;
			shift_lsr	: in Std_Logic;
			shift_asr	: in Std_Logic;
			shift_ror	: in Std_Logic;
			shift_rrx	: in Std_Logic;
			sh_val	: in Std_Logic_Vector(4 downto 0);

			din			: in Std_Logic_Vector(31 downto 0);
			cin			: in Std_Logic;

			dout			: out Std_Logic_Vector(31 downto 0);
			cout			: out Std_Logic;

	-- global interface
			vdd				: in bit;
			vss				: in bit);
end shifter;

----------------------------------------------------------------------

architecture Behavior OF shifter is

signal din_lsl0	: std_logic_vector(32 downto 0);
signal din_lsl1	: std_logic_vector(32 downto 0);
signal din_lsl2	: std_logic_vector(32 downto 0);
signal din_lsl3	: std_logic_vector(32 downto 0);
signal din_lsl		: std_logic_vector(32 downto 0);

signal din_lsr		: std_logic_vector(31 downto 0);
signal din_asr		: std_logic_vector(31 downto 0);

signal shift_asr32	: std_logic_vector(31 downto 0);
signal shift_ror32	: std_logic_vector(31 downto 0);
signal sign_din	: std_logic_vector(31 downto 0);

signal shin_r	: std_logic_vector(31 downto 0);

signal din_r0	: std_logic_vector(64 downto 0);
signal din_r1	: std_logic_vector(64 downto 0);
signal din_r2	: std_logic_vector(64 downto 0);
signal din_r3	: std_logic_vector(64 downto 0);
signal din_r4	: std_logic_vector(64 downto 0);
signal din_r	: std_logic_vector(64 downto 0);

signal left_cy		: std_logic;
signal right_cy	: std_logic;
signal shift_c 	: std_logic;

begin

	din_lsl0 <= din(31 downto 0)			& '0'			when sh_val(0) = '1' else '0' & din;
	din_lsl1 <= din_lsl0(30 downto 0)	& "00"		when sh_val(1) = '1' else din_lsl0;
	din_lsl2 <= din_lsl1(28 downto 0)	& X"0"		when sh_val(2) = '1' else din_lsl1;
	din_lsl3 <= din_lsl2(24 downto 0)	& X"00"		when sh_val(3) = '1' else din_lsl2;
	din_lsl  <= din_lsl3(16 downto 0)	& X"0000"	when sh_val(4) = '1' else din_lsl3;

	sign_din <= x"ffffffff" when din(31) = '1' else x"00000000";
	shift_asr32 <= X"FFFFFFFF" when shift_asr = '1' else X"00000000";
	shift_ror32 <= X"FFFFFFFF" when shift_ror = '1' else X"00000000";
	shin_r <= (sign_din and shift_asr32) or (din and shift_ror32);

	din_r0 <= '0'		& shin_r & din				when sh_val(0) = '1' else shin_r & din & '0';
	din_r1 <= "00"		& din_r0(64 downto 2)	when sh_val(1) = '1' else din_r0;
	din_r2 <= X"0"		& din_r1(64 downto 4)	when sh_val(2) = '1' else din_r1;
	din_r3 <= X"00"	& din_r2(64 downto 8)	when sh_val(3) = '1' else din_r2;
	din_r  <= X"0000"	& din_r3(64 downto 16)	when sh_val(4) = '1' else din_r3;


	dout <=	din_lsl(31 downto 0)		when shift_lsl = '1' else
				cin & din(31 downto 1)	when shift_rrx = '1' else
				din_r(32 downto 1)		when shift_lsr = '1' or shift_asr = '1' or shift_ror = '1' else
				din;

-- Shifter carry

	right_cy <=	din_r(0);
	left_cy <= din_lsl(32);

	cout <=	(left_cy and shift_lsl) or
					(din(0)	and shift_rrx) or
					(right_cy and (shift_lsr or shift_asr or shift_ror));
end Behavior;
