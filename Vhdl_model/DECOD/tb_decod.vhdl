library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_decod is  
end tb_decod;

architecture test of tb_decod is
 signal       		dec_op1		: Std_Logic_Vector(31 downto 0); -- first alu input  
 signal       		dec_op2		: Std_Logic_Vector(31 downto 0); -- shifter input    
 signal       		dec_exe_dest	: Std_Logic_Vector(3 downto 0); -- Rd destination    
 signal       		dec_exe_wb	: Std_Logic; -- Rd destination write back	     
 signal       		dec_flag_wb	: Std_Logic; -- CSPR modifiy			     
      										     
      -- Decod to mem via exec							     
 signal       		dec_mem_data	: Std_Logic_Vector(31 downto 0); -- data to MEM	     
 signal       		dec_mem_dest	: Std_Logic_Vector(3 downto 0);			     
 signal       		dec_pre_index	: Std_logic;					     
 signal       										     
 signal       		dec_mem_lw	: Std_Logic;					     
 signal       		dec_mem_lb	: Std_Logic;					     
 signal       		dec_mem_sw	: Std_Logic;					     
 signal       		dec_mem_sb	: Std_Logic;					     
 signal       		mem_kernel_right: Std_Logic;					     
     										     
     -- Shifter command								     
 signal       		dec_shift_lsl	: Std_Logic;					     
 signal       		dec_shift_lsr	: Std_Logic;					     
 signal       		dec_shift_asr	: Std_Logic;					     
 signal       		dec_shift_ror	: Std_Logic;					     
 signal       		dec_shift_rrx	: Std_Logic;					     
 signal       		dec_shift_val	: Std_Logic_Vector(4 downto 0);			     
 signal       		dec_cy		: Std_Logic;					     
      										     
      -- Alu operand selection							     
 signal       		dec_comp_op1	: Std_Logic;					     
 signal       		dec_comp_op2	: Std_Logic;					     
 signal       		dec_alu_cy	: Std_Logic;					     
      										     
      -- Exec Synchro									     
 signal       		dec2exe_empty	: Std_Logic;					     
 signal       		exe_pop		: Std_logic;					      
      										     
      -- Alu command									     
 signal       		dec_alu_cmd	: Std_Logic_Vector(1 downto 0);			     
     										     
     -- Exe Write Back to reg							     
 signal       		exe_res		: Std_Logic_Vector(31 downto 0);		      

 signal       		exe_c		: Std_Logic;					      
 signal       		exe_v		: Std_Logic;					      
 signal       		exe_n		: Std_Logic;					      
 signal       		exe_z		: Std_Logic;					      
       										     
 signal       		exe_dest	: Std_Logic_Vector(3 downto 0); -- Rd destination     
 signal       		exe_wb		: Std_Logic; -- Rd destination write back	      
 signal       		exe_flag_wb	: Std_Logic; -- CSPR modifiy			      
										     
      -- Ifetch interface								     
 signal       		dec_pc		: Std_Logic_Vector(31 downto 0) ;		     
 signal       		if_ir		: Std_Logic_Vector(31 downto 0) ;		      
										     
      -- Ifetch synchro								     
 signal       		dec2if_empty	: Std_Logic;					     
 signal       		if_pop		: Std_Logic;					      
										     
 signal       		if2dec_empty	: Std_Logic;					      
 signal       		dec_pop		: Std_Logic;					     
										     
      -- Mem Write back to reg							     
 signal       		mem_res		: Std_Logic_Vector(31 downto 0);		      
 signal       		mem_dest	: Std_Logic_Vector(3 downto 0);			      
 signal       		mem_wb		: Std_Logic;					      
										     
      -- global interface								     
 signal       		ck		: Std_Logic;					      
 signal       		reset_n		: Std_Logic;					      
 signal       		vdd		: bit;						      
 signal       		vss		: bit;						      


component decod is
  	port(
	-- Exec  operands
			dec_op1		: out Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2		: out Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb	: out Std_Logic; -- Rd destination write back
			dec_flag_wb	: out Std_Logic; -- CSPR modifiy

	-- Decod to mem via exec
			dec_mem_data	: out Std_Logic_Vector(31 downto 0); -- data to MEM
			dec_mem_dest	: out Std_Logic_Vector(3 downto 0);
			dec_pre_index 	: out Std_logic;

			dec_mem_lw	: out Std_Logic;
			dec_mem_lb	: out Std_Logic;
			dec_mem_sw	: out Std_Logic;
			dec_mem_sb	: out Std_Logic;
                        mem_kernel_right: out Std_Logic;

	-- Shifter command
			dec_shift_lsl	: out Std_Logic;
			dec_shift_lsr	: out Std_Logic;
			dec_shift_asr	: out Std_Logic;
			dec_shift_ror	: out Std_Logic;
			dec_shift_rrx	: out Std_Logic;
			dec_shift_val	: out Std_Logic_Vector(4 downto 0);
			dec_cy		: out Std_Logic;

	-- Alu operand selection
			dec_comp_op1	: out Std_Logic;
			dec_comp_op2	: out Std_Logic;
			dec_alu_cy 	: out Std_Logic;

	-- Exec Synchro
			dec2exe_empty	: out Std_Logic;
			exe_pop		: in Std_logic;

	-- Alu command
			dec_alu_cmd	: out Std_Logic_Vector(1 downto 0);

	-- Exe Write Back to reg
			exe_res		: in Std_Logic_Vector(31 downto 0);

			exe_c		: in Std_Logic;
			exe_v		: in Std_Logic;
			exe_n		: in Std_Logic;
			exe_z		: in Std_Logic;

			exe_dest	: in Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb		: in Std_Logic; -- Rd destination write back
			exe_flag_wb	: in Std_Logic; -- CSPR modifiy

	-- Ifetch interface
			dec_pc		: out Std_Logic_Vector(31 downto 0) ;
			if_ir		: in Std_Logic_Vector(31 downto 0) ;

	-- Ifetch synchro
			dec2if_empty	: out Std_Logic;
			if_pop		: in Std_Logic;

			if2dec_empty	: in Std_Logic;
			dec_pop		: out Std_Logic;

	-- Mem Write back to reg
			mem_res		: in Std_Logic_Vector(31 downto 0);
			mem_dest	: in Std_Logic_Vector(3 downto 0);
			mem_wb		: in Std_Logic;
			
	-- global interface
			ck		: in Std_Logic;
			reset_n		: in Std_Logic;
			vdd		: in bit;
			vss		: in bit);
end component;

begin
  decod_inst : decod
    port map(
      dec_op1           => dec_op1         , 
      dec_op2           => dec_op2         , 
      dec_exe_dest      => dec_exe_dest    , 
      dec_exe_wb        => dec_exe_wb      , 
      dec_flag_wb       => dec_flag_wb     , 
                                            
                                            
      dec_mem_data      => dec_mem_data    , 
      dec_mem_dest      => dec_mem_dest    , 
      dec_pre_index     => dec_pre_index   , 
                                            
      dec_mem_lw        => dec_mem_lw      , 
      dec_mem_lb        => dec_mem_lb      , 
      dec_mem_sw        => dec_mem_sw      , 
      dec_mem_sb        => dec_mem_sb      , 
      mem_kernel_right  => mem_kernel_right, 
                                            
                                            
      dec_shift_lsl     => dec_shift_lsl   , 
      dec_shift_lsr     => dec_shift_lsr   , 
      dec_shift_asr     => dec_shift_asr   , 
      dec_shift_ror     => dec_shift_ror   , 
      dec_shift_rrx     => dec_shift_rrx   , 
      dec_shift_val     => dec_shift_val   , 
      dec_cy            => dec_cy          , 
                                            
                                            
      dec_comp_op1      => dec_comp_op1    , 
      dec_comp_op2      => dec_comp_op2    , 
      dec_alu_cy        => dec_alu_cy      , 
                                            
                                            
      dec2exe_empty     => dec2exe_empty   , 
      exe_pop           => exe_pop         , 
                                            
                                            
      dec_alu_cmd       => dec_alu_cmd     , 
                                            
                                            
      exe_res           => exe_res         , 
                                            
      exe_c             => exe_c           , 
      exe_v             => exe_v           , 
      exe_n             => exe_n           , 
      exe_z             => exe_z           , 
                                            
      exe_dest          => exe_dest        , 
      exe_wb            => exe_wb          , 
      exe_flag_wb       => exe_flag_wb     , 
                                            
                                            
      dec_pc            => dec_pc          , 
      if_ir             => if_ir           , 
                                            
                                            
      dec2if_empty      => dec2if_empty    , 
      if_pop            => if_pop          , 
                                            
      if2dec_empty      => if2dec_empty    , 
      dec_pop           => dec_pop         , 
                                            
                                            
      mem_res           => mem_res         , 
      mem_dest          => mem_dest        , 
      mem_wb            => mem_wb          , 
                                            
                                           
      ck                => ck              , 
      reset_n           => reset_n         , 
      vdd               => vdd             , 
      vss               => vss             ); 

  process
    variable  i : integer := 0 ;
  begin
    
    --init
    if i=0 then
      wait for 100 ns;
    end if;

           --init reset
    if reset_n = '0' then
      reset_n <= not reset_n;
    end if;
    
    --bascule de ck
    ck <= not ck;
    i := i + 1;
    wait for 50 ns;
    ck <= not ck;
    wait for 50 ns;
    
    if i = 6 then
      reset_n <= not reset_n;
    end if;
    
    --end
    if i = 102 then
      wait;
    end if;
    
  end process;








 
end test;
