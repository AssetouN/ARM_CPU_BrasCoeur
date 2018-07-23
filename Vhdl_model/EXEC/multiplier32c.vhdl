library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity multiplier is
  Port (
        Clk     : in std_logic ;
        Reset   : in std_logic;

        ld      : in std_logic_vector(1 downto 0);
        M       : in std_logic_vector(31 downto 0);
        R       : in std_logic_vector(31 downto 0);

        N       : out std_logic;
        Z       : out std_logic;  
        Valid   : out std_logic_vector(1 downto 0);  
        Result  : out std_logic_vector(31 downto 0)      
   );
end multiplier;

architecture Behavioral of multiplier is

    
    signal Cntr     : integer range 0 to 34;
    signal Booth    : std_logic_vector(1 downto 0);
    signal Guard    : std_logic;
    signal A        : std_logic_vector(32 downto 0);
    signal B        : std_logic_vector(32 downto 0);
    signal S        : std_logic_vector(32 downto 0);
    signal Ci       : std_logic;
    signal Hi       : std_logic_vector(32 downto 0);
    signal Prod     : std_logic_vector(64 downto 0);
    signal Ci2      : unsigned(0 downto 0);
    signal signal_Res      : std_logic_vector(31 downto 0)  ;

begin  
    process (Clk,Reset,ld,Cntr)
        begin
           if (rising_edge(Clk)) then
                if (Reset='0') then
                     Cntr <= 0;
                     
                elsif (ld(0)='1' and Cntr = 0 ) then
                    Cntr <= 33;              
                elsif (Cntr /= 0) then
                    Cntr <= Cntr - 1;
  
                else null;
                end if;
            end if;

    end process;

    
    process (Clk,Cntr,reset)
        begin

           if (rising_edge(Clk)) then
                if (Reset='0') then
                     A <= (others=>'0');
                                   
                elsif (ld(0)='1' and (Cntr = 33 or Cntr = 0))  then
                     A (32 downto 0) <= M(31) & M;
                end if;
           end if;
    end process;
    
    process (Clk,Cntr,reset,Booth,Guard,A,B,S,Ci,Hi,Prod) 
        begin
            if Booth  = "01" then
                Ci <= '0';
                B <= A;
            elsif Booth  = "10" then 
                Ci <= '1';
                B <= not A;
            else 
                Ci <= '0';
                B <= (others => '0');
            end if;
   end process;
    
    
    process (Clk,reset,ld,Cntr)
        begin
           if (rising_edge(Clk)) then
                if (Reset='0') then
                     Prod <= (others =>'0');
                                   
                elsif (ld(0) = '1' and (Cntr = 33 or Cntr = 0) ) then
                     Prod(31 downto 0) <= R(31 downto 0);
                elsif (Cntr/=0) then
                    Prod <= S(32) & S & Prod(31 downto 1) ;
                end if;
           end if;
    end process;  
    
    process (Clk,reset,ld,Cntr)
        begin
           if (rising_edge(Clk)) then
                if (Reset='0') then
                     Guard <= '0';
                                   
                elsif (ld(0) = '1' and (Cntr = 33 or Cntr = 0)) then
                     Guard <= '0';
                elsif (Cntr/=0) then
                     Guard <= Prod(0);
                end if;
           end if;
    end process;  
    
    process (Clk,reset,cntr)
        begin
           if (rising_edge(Clk)) then
                if (Reset='0') then
                     signal_Res <= (others => '0');
                                   
                elsif (Cntr = 1 and ld = "01") then
                     signal_Res <= S(0) & Prod(31 downto 1);
                elsif (Cntr = 1 and ld = "11") then  
                     signal_Res <= std_logic_vector (unsigned (S(0) & Prod(31 downto 1))+ unsigned(R));
                end if;
           end if;
    end process;  
    
    process (Clk,cntr)
        begin
           if (rising_edge(Clk)) then
                if (Reset='0') then
                    Valid <= "00";
                elsif (Cntr = 6 and ld = "11") then
                    Valid <="10";
                elsif (Cntr = 1) then
                    Valid <= ld;
                else Valid <= "00";
                     
                end if;
           end if;
    end process;
    
    Booth(1)<= Prod(0);
    Booth(0)<= Guard;
    Hi      <= Prod(64 downto 32);
    ci2(0)  <= ci;
    S       <=  std_logic_vector(unsigned(Hi) + unsigned(B) + ci2);
  

    Z      <= '1' when signal_Res = X"00000000" else '0';
    N      <= signal_Res(31);
    Result <= signal_Res;
end Behavioral;

