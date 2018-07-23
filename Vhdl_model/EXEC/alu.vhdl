library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Alu is
    port ( op1			: in Std_Logic_Vector(31 downto 0);
           op2			: in Std_Logic_Vector(31 downto 0);
           cin			: in Std_Logic;

           cmd			: in Std_Logic_Vector(1 downto 0);
			  -- "00" -> ADD
			  -- "01" -> AND
			  -- "10" -> OR
			  -- "11" -> XOR

           res			: out Std_Logic_Vector(31 downto 0);
           cout		: out Std_Logic;
           z			: out Std_Logic;
           n			: out Std_Logic;
           v			: out Std_Logic;
			  
			  vdd			: in bit;
			  vss			: in bit);
end Alu;

----------------------------------------------------------------------

architecture DataFlow OF Alu is

signal res_add	: Std_Logic_Vector(31 downto 0) ;
signal res_alu	: Std_Logic_Vector(31 downto 0) ;

begin
	process (op1, op2, cin)
		begin
		if (cin = '1') then
			res_add <= std_logic_vector( unsigned(op1) + unsigned(op2) + 1);
		else
			res_add <= std_logic_vector( unsigned(op1) + unsigned(op2));
		end if;
	end process;

	with cmd select
		res_alu <=	op1 and op2	when "01",
						op1 or op2	when "10",
						op1 xor op2	when "11",
						res_add		when others;


	z <= '1' when res_alu = X"00000000" else '0';
	n <= res_alu(31);
	cout <= '1' when ((op1(31) = '1') or (op2(31) = '1')) and (res_alu(31) = '0') else '0';
	v <= '1' when	((op1(31) = '1') and (op2(31) = '1') and (res_alu(31) = '0')) or
						((op1(31) = '0') and (op2(31) = '0') and (res_alu(31) = '1')) else '0';

	res <= res_alu;
end DataFlow;
----------------------------------------------------------------------
