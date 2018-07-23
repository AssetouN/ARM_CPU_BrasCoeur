library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Registre is
	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0);
		wadr1		: in Std_Logic_Vector(3 downto 0);
		wen1		: in Std_Logic;

  	-- Write mode (user, irq,firq,svr)
                wmode           : in Std_Logic_Vector(3 downto 0);
                acces_user_reg  : in Std_Logic;
		interrupt  : in Std_Logic;

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0);
		wadr2		: in Std_Logic_Vector(3 downto 0);
		wen2		: in Std_Logic;

	-- Write CSPR Port
		wcry		: in Std_Logic;
		wzero		: in Std_Logic;
		wneg		: in Std_Logic;
		wovr		: in Std_Logic;
		cspr_wb		: in Std_Logic;
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0);
		radr1		: in Std_Logic_Vector(3 downto 0);
		reg_v1		: out Std_Logic;

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0);
		radr2		: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic;

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3		: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

	-- read CSPR Port
		reg_cry		: out Std_Logic;
		reg_zero	: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_cznv	: out Std_Logic;
		reg_ovr		: out Std_Logic;
		reg_vv		: out Std_Logic;
		
	-- Invalidate Port 
		inval_adr1	: in Std_Logic_Vector(3 downto 0);
		inval1		: in Std_Logic;

		inval_adr2	: in Std_Logic_Vector(3 downto 0);
		inval2		: in Std_Logic;

		inval_czn	: in Std_Logic;
		inval_ovr	: in Std_Logic;

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0);
		reg_pcv		: out Std_Logic;
		inc_pc		: in Std_Logic;
	
	-- global interface
		ck			: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
end Registre;

architecture Behavior OF Registre is

-- RF 
-- type rf_array is array(15 downto 0) of std_logic_vector(31 downto 0);
-- signal r_reg	: rf_array;
signal r_0 			: Std_Logic_Vector(31 downto 0);
signal r_1 			: Std_Logic_Vector(31 downto 0);
signal r_2 			: Std_Logic_Vector(31 downto 0);
signal r_3 			: Std_Logic_Vector(31 downto 0);
signal r_4 			: Std_Logic_Vector(31 downto 0);
signal r_5 			: Std_Logic_Vector(31 downto 0);
signal r_6 			: Std_Logic_Vector(31 downto 0);
signal r_7 			: Std_Logic_Vector(31 downto 0);
signal r_8 			: Std_Logic_Vector(31 downto 0);
signal r_9 			: Std_Logic_Vector(31 downto 0);
signal r_10 		: Std_Logic_Vector(31 downto 0);
signal r_11 		: Std_Logic_Vector(31 downto 0);
signal r_12 		: Std_Logic_Vector(31 downto 0);
signal r_13 		: Std_Logic_Vector(31 downto 0);
signal r_14 		: Std_Logic_Vector(31 downto 0);
signal r_15 		: Std_Logic_Vector(31 downto 0);

--FIRQ register
signal r_8_F   		: Std_logic_vector(31 downto 0); 
signal r_9_F   		: Std_logic_vector(31 downto 0); 
signal r_10_F  		: Std_logic_vector(31 downto 0); 
signal r_11_F  		: Std_logic_vector(31 downto 0); 
signal r_12_F  		: Std_logic_vector(31 downto 0); 
signal r_13_F  		: Std_logic_vector(31 downto 0); 
signal r_14_F  		: Std_logic_vector(31 downto 0); 

--IRQ register
signal r_13_I   	: Std_logic_vector(31 downto 0); 
signal r_14_I   	: Std_logic_vector(31 downto 0); 

--Supervisor register
signal r_13_S   	: std_logic_vector(31 downto 0); 
signal r_14_S   	: std_logic_vector(31 downto 0); 

signal r_valid 		: Std_Logic_Vector(15 downto 0);
signal r_valid_F	: Std_Logic_Vector(6 downto 0);  --valid for FIRQ registers
signal r_valid_I	: Std_Logic_Vector(1 downto 0);  --valid for IRQ registers
signal r_valid_S	: Std_Logic_Vector(1 downto 0);  --valid for Supervisor registers
signal r_c			: Std_Logic;
signal r_z			: Std_Logic;
signal r_n			: Std_Logic;
signal r_v			: Std_Logic;
signal r_cznv		: Std_Logic;
signal r_vv			: Std_Logic;
signal pcp4			: Std_Logic_Vector(31 downto 0);

signal internal_rd1	: Std_Logic_Vector(31 downto 0);
signal internal_rd2	: Std_Logic_Vector(31 downto 0);
signal internal_rd3	: Std_Logic_Vector(31 downto 0);

signal internal_rv1	: Std_Logic;
signal internal_rv2	: Std_Logic;
signal internal_rv3	: Std_Logic;

signal mode	: Std_Logic_Vector(1 downto 0);

begin

pcp4 <= Std_Logic_Vector(unsigned(r_15) + 4);

process (ck)
variable i_std :Std_Logic_Vector(4 downto 0);
begin
	if rising_edge(ck) then
		if reset_n = '0' then
			r_valid 	<= X"FFFF";
			r_valid_F   <= "1111111";
            		r_valid_I   <= "11";
            		r_valid_S   <= "11";
			r_15 		<= X"FFFFFFFC";
			r_cznv		<= '1';
			r_vv		<= '1';
		else

-- Update PC
			if r_valid(15) = '1' then
				if inc_pc = '1' then
					if interrupt='1'then
						r_15 <= pcp4;
					end if;
					r_15 <= pcp4(31 downto 2) & mode;
				end if;
			else
				if wen1 = '1' and wadr1 = X"F" then
					if interrupt='1'then
						r_15 <=wdata1(31 downto 2) & mode;
					end if;
					r_15 <= wdata1;
				elsif wen2= '1' and wadr2 = X"F" then
					if interrupt='1'then
						r_15 <=wdata2(31 downto 2) & mode;
					end if;
					r_15 <= wdata2;
				end if;
			end if;
					
-- update registers
       	if (wmode = x"1") then --USER
			if wen1 = '1' and wadr1 = X"E" then
				r_14 <= wdata1;
			elsif wen2= '1' and wadr2 = X"E" then
				r_14 <= wdata2;
			end if;
				
			if wen1 = '1' and wadr1 = X"D" then
				r_13 <= wdata1;
			elsif wen2= '1' and wadr2 = X"D" then
				r_13 <= wdata2;
			end if;
		end if;
		
		if (wmode = x"4") then --IRQ mode

            if wen1 = '1' and wadr1 = X"E" then
              r_14_I <= wdata1;
            elsif wen2= '1' and wadr2 = X"E" then
              r_14_I <= wdata2;
            end if;
            
            if wen1 = '1' and wadr1 = X"D" then
              r_13_I <= wdata1;
            elsif wen2= '1' and wadr2 = X"D" then
              r_13_I <= wdata2;
            end if;
        end if;

        if (wmode = x"8") then --Supervisor
            if wen1 = '1' and wadr1 = X"E" then
              r_14_S <= wdata1;
            elsif wen2= '1' and wadr2 = X"E" then
              r_14_S <= wdata2;
            end if;
            
            if wen1 = '1' and wadr1 = X"D" then
              r_13_S <= wdata1;
            elsif wen2= '1' and wadr2 = X"D" then
              r_13_S <= wdata2;
            end if;
        end if;   

        if (wmode = x"2") then --FIRQ mode

            if wen1 = '1' and wadr1 = X"E" then
              r_14_F <= wdata1;
            elsif wen2= '1' and wadr2 = X"E" then
              r_14_F <= wdata2;
            end if;
            
            if wen1 = '1' and wadr1 = X"D" then
              r_13_F <= wdata1;
            elsif wen2= '1' and wadr2 = X"D" then
              r_13_F <= wdata2;
            end if;
            
            if wen1 = '1' and wadr1 = X"C" then
              r_12_F <= wdata1;
            elsif wen2= '1' and wadr2 = X"C" then
              r_12_F <= wdata2;
            end if;
            
            if wen1 = '1' and wadr1 = X"B" then
              r_11_F <= wdata1;
            elsif wen2= '1' and wadr2 = X"B" then
              r_11_F <= wdata2;
            end if;
            
            if wen1 = '1' and wadr1 = X"A" then
              r_10_F <= wdata1;
            elsif wen2= '1' and wadr2 = X"A" then
              r_10_F <= wdata2;
            end if;
            
            if wen1 = '1' and wadr1 = X"9" then
              r_9_F <= wdata1;
            elsif wen2= '1' and wadr2 = X"9" then
              r_9_F <= wdata2;
            end if;
            
            if wen1 = '1' and wadr1 = X"8" then
              r_8_F <= wdata1;
            elsif wen2= '1' and wadr2 = X"8" then
              r_8_F <= wdata2;
            end if;
        else
			if wen1 = '1' and wadr1 = X"C" then
				r_12 <= wdata1;
			elsif wen2= '1' and wadr2 = X"C" then
				r_12 <= wdata2;
			end if;
				
			if wen1 = '1' and wadr1 = X"B" then
				r_11 <= wdata1;
			elsif wen2= '1' and wadr2 = X"B" then
				r_11 <= wdata2;
			end if;
				
			if wen1 = '1' and wadr1 = X"A" then
				r_10 <= wdata1;
			elsif wen2= '1' and wadr2 = X"A" then
				r_10 <= wdata2;
			end if;
				
			if wen1 = '1' and wadr1 = X"9" then
				r_9 <= wdata1;
			elsif wen2= '1' and wadr2 = X"9" then
				r_9 <= wdata2;
			end if;
				
			if wen1 = '1' and wadr1 = X"8" then
				r_8 <= wdata1;
			elsif wen2= '1' and wadr2 = X"8" then
				r_8 <= wdata2;
			end if;
		end if;
				
			if wen1 = '1' and wadr1 = X"7" then
				r_7 <= wdata1;
			elsif wen2= '1' and wadr2 = X"7" then
				r_7 <= wdata2;
			end if;
				
			if wen1 = '1' and wadr1 = X"6" then
				r_6 <= wdata1;
			elsif wen2= '1' and wadr2 = X"6" then
				r_6 <= wdata2;
			end if;
				
			if wen1 = '1' and wadr1 = X"5" then
				r_5 <= wdata1;
			elsif wen2= '1' and wadr2 = X"5" then
				r_5 <= wdata2;
			end if;
				
			if wen1 = '1' and wadr1 = X"4" then
				r_4 <= wdata1;
			elsif wen2= '1' and wadr2 = X"4" then
				r_4 <= wdata2;
			end if;
				
			if wen1 = '1' and wadr1 = X"3" then
				r_3 <= wdata1;
			elsif wen2= '1' and wadr2 = X"3" then
				r_3 <= wdata2;
			end if;
				
			if wen1 = '1' and wadr1 = X"2" then
				r_2 <= wdata1;
			elsif wen2= '1' and wadr2 = X"2" then
				r_2 <= wdata2;
			end if;
				
			if wen1 = '1' and wadr1 = X"1" then
				r_1 <= wdata1;
			elsif wen2= '1' and wadr2 = X"1" then
				r_1 <= wdata2;
			end if;
				
			if wen1 = '1' and wadr1 = X"0" then
				r_0 <= wdata1;
			elsif wen2= '1' and wadr2 = X"0" then
				r_0 <= wdata2;
			end if;

        
-- update valid flag


for i in 0 TO 15 loop
            i_std := Std_Logic_Vector(TO_SIGNED(i, 5));
				if (i <= 7) or i = 15 then
              		if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
              	  		(inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
              	 		r_valid(i) <= '0';
              		elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
              	  		(wen2= '1' and wadr2 = i_std(3 downto 0)) then
              	  		r_valid(i) <= '1';
              	  	end if ;

              	elsif i>= 8 and i<= 12 then
					if (wmode(1)= '0') then --  NOT FIRQ
              			if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
              	  			(inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
              	 			r_valid(i) <= '0';
              			elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
              	  			(wen2= '1' and wadr2 = i_std(3 downto 0)) then
              	  			r_valid(i) <= '1';
              	  		end if;
              	  	else 
              	  		if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
              	  			(inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
              	 			r_valid_F(i mod 7) <= '0';
              			elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
              	  			(wen2= '1' and wadr2 = i_std(3 downto 0)) then
              	  			r_valid_F(i mod 7) <= '1';
              	  		end if;
              	  	end if ;

              	else
              	     if  (wmode = X"1") then
              	  		if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
              	  			(inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
              	 			r_valid(i) <= '0';
              			elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
              	  			(wen2= '1' and wadr2 = i_std(3 downto 0)) then
              	  			r_valid(i) <= '1';
              	  		end if;
					elsif (wmode = X"2") then --  NOT FIRQ
              			if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
              	  			(inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
              	 			r_valid_F(i mod 7) <= '0';
              			elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
              	  			(wen2= '1' and wadr2 = i_std(3 downto 0)) then
              	  			r_valid_F(i mod 7) <= '1';
              	  		end if;

              	  	elsif (wmode = X"4") then --  NOT FIRQ
              			if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
              	  			(inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
              	 			r_valid_I(i mod 2) <= '0';
              			elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
              	  			(wen2= '1' and wadr2 = i_std(3 downto 0)) then
              	  			r_valid_I(i mod 2) <= '1';
              	  		end if;

              	  	elsif (wmode = X"8") then --  NOT FIRQ
              			if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
              	  			(inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
              	 			r_valid_S(i mod 2) <= '0';
              			elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
              	  			(wen2= '1' and wadr2 = i_std(3 downto 0)) then
              	  			r_valid_S(i mod 2) <= '1';
              	  		end if;


              	  	end if ;


              	end if;
            end loop;


        --==========================================

        -- if (wmode = X"1") then --USER
        --   for i in 0 TO 15 loop
        --     i_std := Std_Logic_Vector(TO_SIGNED(i, 5));

        --     if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --       (inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
        --       r_valid(i) <= '0';
        --     elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --       (wen2= '1' and wadr2 = i_std(3 downto 0)) then
        --       r_valid(i) <= '1';
        --     end if;
        --   end loop;

        -- elsif (wmode = X"2") then --FIRQ
        --   for i in 0 TO 15 loop

        --     i_std := Std_Logic_Vector(TO_SIGNED(i, 5));
            
        --     if (i <= 7) or i = 15 then
        --       if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --         (inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
        --         r_valid(i) <= '0';
        --       elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --         (wen2= '1' and wadr2 = i_std(3 downto 0)) then
        --         r_valid(i) <= '1';
        --       end if;
              
        --     else
              
        --       if ((inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --           (inval2 = '1' and inval_adr2 = i_std(3 downto 0))) and i = 8 then
        --         r_valid_f(0) <= '0';
        --       elsif ((inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --              (inval2 = '1' and inval_adr2 = i_std(3 downto 0))) and i = 9 then
        --         r_valid_f(1) <= '0';
        --       elsif ((inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --              (inval2 = '1' and inval_adr2 = i_std(3 downto 0))) and i = 10 then
        --         r_valid_f(2) <= '0';
        --       elsif ((inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --              (inval2 = '1' and inval_adr2 = i_std(3 downto 0))) and i = 11 then
        --         r_valid_f(3) <= '0';
        --       elsif ((inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --              (inval2 = '1' and inval_adr2 = i_std(3 downto 0))) and i = 12 then
        --         r_valid_f(4) <= '0';
        --       elsif ((inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --              (inval2 = '1' and inval_adr2 = i_std(3 downto 0))) and i = 13 then
        --         r_valid_f(5) <= '0';
        --       elsif ((inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --              (inval2 = '1' and inval_adr2 = i_std(3 downto 0))) and i = 14 then
        --         r_valid_f(6) <= '0';
        --         -- the if case underneath is a better way to code this but the
        --         -- conversion with VASY fails if an other layer of "if" is added
        --         -- if i = 8 then
        --         --   r_valid_F(0)    <= '0';
        --         -- elsif i = 9 then
        --         --   r_valid_F(1)    <= '0';
        --         -- elsif i = 10 then
        --         --   r_valid_F(2)    <= '0';
        --         -- elsif i = 11 then
        --         --   r_valid_F(3)    <= '0';
        --         -- elsif i = 12 then
        --         --   r_valid_F(4)    <= '0';
        --         -- elsif i = 13 then
        --         --   r_valid_F(5)    <= '0';
        --         -- elsif i = 14 then
        --          -- r_valid_F(6)    <= '0';
        --         --else
        --         --end if;
        --       elsif ((wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --              (wen2= '1' and wadr2 = i_std(3 downto 0))) and i = 8 then
        --         r_valid_F(0) <= '1' ;
        --       elsif ((wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --              (wen2= '1' and wadr2 = i_std(3 downto 0))) and i = 9 then
        --         r_valid_F(1) <= '1' ;
        --       elsif ((wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --              (wen2= '1' and wadr2 = i_std(3 downto 0))) and i = 10 then
        --         r_valid_F(2) <= '1' ;             
        --       elsif ((wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --              (wen2= '1' and wadr2 = i_std(3 downto 0))) and i = 11 then
        --         r_valid_F(3) <= '1' ;
        --       elsif ((wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --              (wen2= '1' and wadr2 = i_std(3 downto 0))) and i = 12 then
        --         r_valid_F(4) <= '1' ;
        --       elsif ((wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --              (wen2= '1' and wadr2 = i_std(3 downto 0))) and i = 13 then
        --         r_valid_F(5) <= '1' ;
        --       elsif ((wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --              (wen2= '1' and wadr2 = i_std(3 downto 0))) and i = 14 then
        --         r_valid_F(6) <= '1' ;
        --         -- if i = 8 then            
        --         --   r_valid_F(0)    <= '1';
        --         -- elsif i = 9 then         
        --         --   r_valid_F(1)    <= '1';
        --         -- elsif i = 10 then        
        --         --   r_valid_F(2)    <= '1';
        --         -- elsif i = 11 then        
        --         --   r_valid_F(3)    <= '1';
        --         -- elsif i = 12 then        
        --         --   r_valid_F(4)    <= '1';
        --         -- elsif i = 13 then        
        --         --   r_valid_F(5)    <= '1';
        --         -- elsif i = 14 then        
        --         -- r_valid_F(6)    <= '1';
        --         -- else
        --         -- end if;
        --         else                                     
        --       end if;
        --     end if;
        --   end loop;

        -- elsif (wmode = X"4") then --IRQ
        --     for i in 0 TO 15 loop
        --       i_std := Std_Logic_Vector(TO_SIGNED(i, 5));
        --       if (i <= 12) or i = 15 then
        --         if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --           (inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
        --           r_valid(i) <= '0';
        --         elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --           (wen2= '1' and wadr2 = i_std(3 downto 0)) then
        --           r_valid(i) <= '1';
        --         end if;
        --       else
        --         if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --           (inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
        --           if i = 13 then
        --             r_valid_I(13) <= '0';
        --           else
        --             r_valid_I(14) <= '0';
        --           end if; 
        --         elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --           (wen2= '1' and wadr2 = i_std(3 downto 0)) then
        --           if i = 13 then 
        --             r_valid_I(13) <= '1';
        --           else
        --             r_valid_I(14) <= '1';
        --           end if;
        --         end if;
        --       end if;
        --     end loop;
        -- elsif (wmode = X"8") then --Supervisor
        --     for i in 0 TO 15 loop
        --       	i_std := Std_Logic_Vector(TO_SIGNED(i, 5));
        --       	if i <= 12 or i = 15 then
        --       	  	if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --       	  	  	(inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
        --       	  	  	r_valid(i) <= '0';
        --       	  	elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --       	  	  	(wen2= '1' and wadr2 = i_std(3 downto 0)) then
        --       	  	  	r_valid(i) <= '1';
        --       	  	end if;
        --       	else
        --       	  	if (inval1 = '1' and inval_adr1 = i_std(3 downto 0)) or
        --                   (inval2 = '1' and inval_adr2 = i_std(3 downto 0)) then
        --                   if i = 13 then
        --                     r_valid_S(13) <= '0';
        --                   else
        --                     r_valid_S(14) <= '0';
        --                   end if;                          
        --       	  	elsif (wen1 = '1' and wadr1 = i_std(3 downto 0)) or
        --                   (wen2= '1' and wadr2 = i_std(3 downto 0)) then
        --                   if i = 13 then 
        --                     r_valid_S(13) <= '1';
        --                   else
        --                     r_valid_S(14) <= '1';
        --                   end if;
        --       	  	end if;
        --       	end if;
        --     end loop;
        --   end if;



-- update flags
			if cspr_wb = '1' then
				if r_cznv = '0' then
					r_c <= wcry;
					r_z <= wzero;
					r_n <= wneg;
					r_cznv <= '1';
				end if;
				if r_vv = '0' then
					r_v <= wovr;
					r_vv <= '1';
				end if;
			end if;

-- invalid flags
			if inval_czn = '1' then
				r_cznv <= '0';
			end if;
			if inval_ovr = '1' then
				r_vv <= '0';
			end if;

		end if;
	end if;

end process;


-- read registers ports
internal_rd1 <= r_0  when radr1 = X"0"  						else
		r_1  	when radr1 = X"1"						 		else
		r_2  	when radr1 = X"2" 								else
		r_3  	when radr1 = X"3" 								else
		r_4  	when radr1 = X"4" 								else
		r_5  	when radr1 = X"5" 								else
		r_6  	when radr1 = X"6" 								else
		r_7  	when radr1 = X"7" 								else
		r_8  	when radr1 = X"8" and  ( wmode(1) = '0'  or acces_user_reg = '1')       	else
		r_9  	when radr1 = X"9" and  ( wmode(1) = '0'  or acces_user_reg = '1')       	else
		r_10 	when radr1 = X"A" and  ( wmode(1) = '0'  or acces_user_reg = '1')       	else
		r_11 	when radr1 = X"B" and  ( wmode(1) = '0'  or acces_user_reg = '1')       	else
		r_12 	when radr1 = X"C" and  ( wmode(1) = '0'  or acces_user_reg = '1')       	else
		r_13 	when radr1 = X"D" and  ( wmode = X"1"    or acces_user_reg = '1') 		else
		r_14 	when radr1 = X"E" and  ( wmode = X"1"    or acces_user_reg = '1') 		else
		pcp4 	when radr1 = X"F"                			else
-- FIRQ mode				
		r_8_F  	when radr1 = X"8" and 	wmode = X"2" 			else
		r_9_F  	when radr1 = X"9" and 	wmode = X"2" 			else
		r_10_F 	when radr1 = X"A" and 	wmode = X"2" 			else
		r_11_F 	when radr1 = X"B" and 	wmode = X"2" 			else
		r_12_F 	when radr1 = X"C" and 	wmode = X"2" 			else
		r_13_F 	when radr1 = X"D" and 	wmode = X"2" 			else
		r_14_F 	when radr1 = X"E" and 	wmode = X"2" 			else
-- IRQ mode				
                r_13_I 	when radr1 = X"D" and 	wmode = X"4" 			else
                r_14_I 	when radr1 = X"E" and 	wmode = X"4" 			else
-- Supervisor mode				
                r_13_S 	when radr1 = X"D" and 	wmode = X"8" 			else
                r_14_S 	when radr1 = X"E" and 	wmode = x"8"                    else
                (others => '0');

--update output
reg_rd1 <=	wdata1	when (wen1 = '1') and (wadr1 = radr1)  else
                wdata2	when (wen2 = '1') and (wadr2 = radr1)  else
                internal_rd1;

--Port 1 validity:

--USER mode
internal_rv1 <= r_valid(0)   when radr1 = X"0" 					else
		r_valid(1)   when radr1 = X"1" 							else
		r_valid(2)   when radr1 = X"2" 							else
		r_valid(3)   when radr1 = X"3" 							else
		r_valid(4)   when radr1 = X"4" 							else
		r_valid(5)   when radr1 = X"5" 							else
		r_valid(6)   when radr1 = X"6" 							else
		r_valid(7)   when radr1 = X"7" 							else
		r_valid(8)   when radr1 = X"8" and ( wmode(1) = '0'  or acces_user_reg = '1')	else
		r_valid(9)   when radr1 = X"9" and ( wmode(1) = '0'  or acces_user_reg = '1')   else
		r_valid(10)  when radr1 = X"a" and ( wmode(1) = '0'  or acces_user_reg = '1')   else
		r_valid(11)  when radr1 = X"b" and ( wmode(1) = '0'  or acces_user_reg = '1')   else
		r_valid(12)  when radr1 = X"c" and ( wmode(1) = '0'  or acces_user_reg = '1')   else
		r_valid(13)  when radr1 = X"d" and ( wmode = X"1"    or acces_user_reg = '1')   else
		r_valid(14)  when radr1 = X"e" and ( wmode = X"1"    or acces_user_reg = '1')   else
		r_valid(15)  when radr1 = X"f" 							else
-- FIRQ mode:
                r_valid_F(1) when radr1 = X"8" and wmode = X"2" 		else 
		r_valid_F(2) when radr1 = X"9" and wmode = X"2" 		else 
		r_valid_F(3) when radr1 = X"a" and wmode = X"2" 		else 
		r_valid_F(4) when radr1 = X"b" and wmode = X"2" 		else 
		r_valid_F(5) when radr1 = X"c" and wmode = X"2" 		else 
		r_valid_F(6) when radr1 = X"d" and wmode = X"2" 		else 
		r_valid_F(0) when radr1 = X"e" and wmode = X"2" 		else 
-- IRQ mode:		
                r_valid_I(1) when radr1 = X"D" and wmode = X"4" 		else 
                r_valid_I(0) when radr1 = X"E" and wmode = X"4" 		else
-- Supervisor mode		
                r_valid_S(1) when radr1 = X"D" and wmode = X"8" 		else 
                r_valid_S(0) when radr1 = X"E" and wmode = X"8"                else
                '0';
                
-- update output                
reg_v1 <=	'1' when	((wen1 = '1') and (wadr1 = radr1)) or ((wen2 = '1') and (wadr2 = radr1)) else
         	internal_rv1;

-- Port 2 data:
-- for USER mode
internal_rd2 <= r_0  when radr2 = X"0"  						else
		r_1  	when radr2 = X"1"						 		else
		r_2  	when radr2 = X"2" 								else
		r_3  	when radr2 = X"3" 								else
		r_4  	when radr2 = X"4" 								else
		r_5  	when radr2 = X"5" 								else
		r_6  	when radr2 = X"6" 								else
		r_7  	when radr2 = X"7" 								else
		r_8  	when radr2 = X"8" and 	( wmode(1) = '0'  or acces_user_reg = '1')		else
		r_9	when radr2 = X"9" and	( wmode(1) = '0'  or acces_user_reg = '1')		else
		r_10	when radr2 = X"A" and	( wmode(1) = '0'  or acces_user_reg = '1')		else
		r_11	when radr2 = X"B" and	( wmode(1) = '0'  or acces_user_reg = '1')		else
		r_12	when radr2 = X"C" and	( wmode(1) = '0'  or acces_user_reg = '1')		else
		r_13	when radr2 = X"D" and	( wmode = X"1"    or acces_user_reg = '1')	        else
		r_14	when radr2 = X"E" and	( wmode = X"1"    or acces_user_reg = '1')	        else
		pcp4 	when radr2 = X"F"                			else
-- FIRQ mode				
		r_8_F  	when radr2 = X"8" and 	wmode = X"2" 			else
		r_9_F  	when radr2 = X"9" and 	wmode = X"2" 			else
		r_10_F 	when radr2 = X"A" and 	wmode = X"2" 			else
		r_11_F 	when radr2 = X"B" and 	wmode = X"2" 			else
		r_12_F 	when radr2 = X"C" and 	wmode = X"2" 			else
		r_13_F 	when radr2 = X"D" and 	wmode = X"2" 			else
		r_14_F 	when radr2 = X"E" and 	wmode = X"2" 			else
-- IRQ mode				
                r_13_I 	when radr2 = X"D" and 	wmode = X"4" 			else
                r_14_I 	when radr2 = X"E" and 	wmode = X"4" 			else
-- Supervisor mode				
                r_13_S 	when radr2 = X"D" and 	wmode = X"8" 			else
                r_14_S 	when radr2 = X"E" and 	wmode = x"8"                    else
                (others => '0');


-- update output
reg_rd2 <=	wdata1	when (wen1 = '1') and (wadr1 = radr2) else
                wdata2	when (wen2 = '1') and (wadr2 = radr2) else
                internal_rd2;

-- Port 2 validity :
--USER mode
internal_rv2 <= r_valid(0)   when radr2 = X"0" 					else
		r_valid(1)   when radr2 = X"1" 							else
		r_valid(2)   when radr2 = X"2" 							else
		r_valid(3)   when radr2 = X"3" 							else
		r_valid(4)   when radr2 = X"4" 							else
		r_valid(5)   when radr2 = X"5" 							else
		r_valid(6)   when radr2 = X"6" 							else
		r_valid(7)   when radr2 = X"7" 							else
		r_valid(8)   when radr2 = X"8" and ( wmode(1) = '0'  or acces_user_reg = '1')	else
		r_valid(9)   when radr2 = X"9" and ( wmode(1) = '0'  or acces_user_reg = '1')       else
		r_valid(10)  when radr2 = X"a" and ( wmode(1) = '0'  or acces_user_reg = '1')       else
		r_valid(11)  when radr2 = X"b" and ( wmode(1) = '0'  or acces_user_reg = '1')       else
		r_valid(12)  when radr2 = X"c" and ( wmode(1) = '0'  or acces_user_reg = '1')       else
		r_valid(13)  when radr2 = X"d" and ( wmode = X"1"    or acces_user_reg = '1')       else
		r_valid(14)  when radr2 = X"e" and ( wmode = X"1"    or acces_user_reg = '1')       else
		r_valid(15)  when radr2 = X"f" 							else
-- FIRQ mode:
                r_valid_F(1) when radr2 = X"8" and wmode = X"2" 		else 
		r_valid_F(2) when radr2 = X"9" and wmode = X"2" 		else 
		r_valid_F(3) when radr2 = X"a" and wmode = X"2" 		else 
		r_valid_F(4) when radr2 = X"b" and wmode = X"2" 		else 
		r_valid_F(5) when radr2 = X"c" and wmode = X"2" 		else 
		r_valid_F(6) when radr2 = X"d" and wmode = X"2" 		else 
		r_valid_F(0) when radr2 = X"e" and wmode = X"2" 		else 
-- IRQ mode:		
                r_valid_I(1) when radr2 = X"D" and wmode = X"4" 		else 
                r_valid_I(0) when radr2 = X"E" and wmode = X"4" 		else
-- Supervisor mode		
                r_valid_S(1) when radr2 = X"D" and wmode = X"8" 		else 
                r_valid_S(0) when radr2 = X"E" and wmode = X"8"                    else
                '0';
               
--update output
reg_v2 <=	'1' when	((wen1 = '1') and (wadr1 = radr2)) or ((wen2 = '1') and (wadr2 = radr2)) else
         	internal_rv2;

--Port 3 data:

-- for USER mode
internal_rd3 <= r_0  when radr3 = X"0"  						else
		r_1  	when radr3 = X"1"						 		else
		r_2  	when radr3 = X"2" 								else
		r_3  	when radr3 = X"3" 								else
		r_4  	when radr3 = X"4" 								else
		r_5  	when radr3 = X"5" 								else
		r_6  	when radr3 = X"6" 								else
		r_7  	when radr3 = X"7" 								else
		r_8  	when radr3 = X"8" and 	( wmode(1) = '0'  or acces_user_reg = '1')		else
		r_9	when radr3 = X"9" and	( wmode(1) = '0'  or acces_user_reg = '1')		else
		r_10	when radr3 = X"A" and	( wmode(1) = '0'  or acces_user_reg = '1')		else
		r_11	when radr3 = X"B" and	( wmode(1) = '0'  or acces_user_reg = '1')		else
		r_12	when radr3 = X"C" and	( wmode(1) = '0'  or acces_user_reg = '1')		else
		r_13	when radr3 = X"D" and	( wmode = X"1"    or acces_user_reg = '1')	        else
		r_14	when radr3 = X"E" and	( wmode = X"1"    or acces_user_reg = '1')	        else
		pcp4 	when radr3 = X"F"  	         			                        else
-- FIRQ mode				
		r_8_F  	when radr3 = X"8" and 	wmode = X"2" 			else
		r_9_F  	when radr3 = X"9" and 	wmode = X"2" 			else
		r_10_F 	when radr3 = X"A" and 	wmode = X"2" 			else
		r_11_F 	when radr3 = X"B" and 	wmode = X"2" 			else
		r_12_F 	when radr3 = X"C" and 	wmode = X"2" 			else
		r_13_F 	when radr3 = X"D" and 	wmode = X"2" 			else
		r_14_F 	when radr3 = X"E" and 	wmode = X"2" 			else
-- IRQ mode				
                r_13_I 	when radr3 = X"D" and 	wmode = X"4" 			else
                r_14_I 	when radr3 = X"E" and 	wmode = X"4" 			else
-- Supervisor mode				
                r_13_S 	when radr3 = X"D" and 	wmode = X"8" 			else
                r_14_S 	when radr3 = X"E" and 	wmode = x"8"                    else
                (others => '0');

-- update output :
reg_rd3 <=	wdata1	when (wen1 = '1') and (wadr1 = radr3) else
                wdata2	when (wen2 = '1') and (wadr2 = radr3) else
                internal_rd3;

-- Port 3 validity :
--USER mode
internal_rv3 <= r_valid(0)   when radr3 = X"0" 					else
		r_valid(1)   when radr3 = X"1" 							else
		r_valid(2)   when radr3 = X"2" 							else
		r_valid(3)   when radr3 = X"3" 							else
		r_valid(4)   when radr3 = X"4" 							else
		r_valid(5)   when radr3 = X"5" 							else
		r_valid(6)   when radr3 = X"6" 							else
		r_valid(7)   when radr3 = X"7" 							else
		r_valid(8)   when radr3 = X"8" and ( wmode(1) = '0'  or acces_user_reg = '1')	else
		r_valid(9)   when radr3 = X"9" and ( wmode(1) = '0'  or acces_user_reg = '1')   else
		r_valid(10)  when radr3 = X"a" and ( wmode(1) = '0'  or acces_user_reg = '1')   else
		r_valid(11)  when radr3 = X"b" and ( wmode(1) = '0'  or acces_user_reg = '1')   else
		r_valid(12)  when radr3 = X"c" and ( wmode(1) = '0'  or acces_user_reg = '1')   else
		r_valid(13)  when radr3 = X"d" and ( wmode = X"1"    or acces_user_reg = '1')   else
		r_valid(14)  when radr3 = X"e" and ( wmode = X"1"    or acces_user_reg = '1')   else
		r_valid(15)  when radr3 = X"f" 							else
-- FIRQ mode:
                r_valid_F(1) when radr3 = X"8" and wmode = X"2" 		else 
		r_valid_F(2) when radr3 = X"9" and wmode = X"2" 		else 
		r_valid_F(3) when radr3 = X"a" and wmode = X"2" 		else 
		r_valid_F(4) when radr3 = X"b" and wmode = X"2" 		else 
		r_valid_F(5) when radr3 = X"c" and wmode = X"2" 		else 
		r_valid_F(6) when radr3 = X"d" and wmode = X"2" 		else 
		r_valid_F(0) when radr3 = X"e" and wmode = X"2" 		else 
-- IRQ mode:		
                r_valid_I(1) when radr3 = X"D" and wmode = X"4" 		else 
                r_valid_I(0) when radr3 = X"E" and wmode = X"4" 		else
-- Supervisor mode		
                r_valid_S(1) when radr3 = X"D" and wmode = X"8" 		else 
                r_valid_S(0) when radr3 = X"E" and wmode = X"8"                else
                '0';

-- update output:
reg_v3 <=	'1' when	((wen1 = '1') and (wadr1 = radr3)) or ((wen2 = '1') and (wadr2 = radr3)) else
         	internal_rv3;

-- update pc
reg_pc <=	wdata1(31 downto 2) & mode when	((wen1 = '1') and (wadr1 = X"F")) and (r_valid(15) = '0') and interrupt ='1'else
                wdata2(31 downto 2) & mode when ((wen2 = '1') and (wadr2 = X"F")) and (r_valid(15) = '0') and interrupt ='1' else
		wdata1			   when	((wen1 = '1') and (wadr1 = X"F")) and (r_valid(15) = '0') else
                wdata2			   when ((wen2 = '1') and (wadr2 = X"F")) and (r_valid(15) = '0') else
		pcp4			   when interrupt='1' else
                pcp4(31 downto 2) & mode;

--update pc validity
reg_pcv <=	'1' when	((wen1 = '1') and (wadr1 = X"F")) or ((wen2 = '1') and (wadr2 = X"F")) else
        	r_valid(15);

-- update mode in r15

with wmode select mode <=
    "00" when "0001",
    "01" when "0010",
    "10" when "0100",
    "11" when "1000",
    "00" when others;


-- read CSPR Port
reg_cry <= r_c when r_cznv = '1' else wcry;
reg_zero <= r_z when r_cznv = '1' else wzero;
reg_neg <= r_n when r_cznv = '1' else wneg;
reg_ovr <= r_v when r_vv = '1' else wovr;

-- CSPR validity
reg_cznv <= r_cznv or cspr_wb;
reg_vv <= r_vv or cspr_wb;

end Behavior;

