library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity multiplier is
  Port (
        Clk     : in std_logic ;
        Reset   : in std_logic;

        ld      : in std_logic;
        M       : in std_logic_vector(31 downto 0);
        R       : in std_logic_vector(31 downto 0);

        N       : out std_logic;
        Z       : out std_logic;  
        Valid   : out std_logic;  
        Result  : out std_logic_vector(31 downto 0)      
   );
end multiplier;

architecture Behavioral of multiplier is

    
    signal Cntr     : integer range 0 to 34;
    signal Booth    : std_logic_vector(4 downto 0);
    signal Guard    : std_logic;
    signal A        : std_logic_vector(35 downto 0);
    signal B        : std_logic_vector(35 downto 0);
    signal C        : std_logic_vector(35 downto 0);
    signal Mx8      : std_logic_vector(35 downto 0);
    signal Mx4      : std_logic_vector(35 downto 0);
    signal Mx2      : std_logic_vector(35 downto 0);
    signal Mx1      : std_logic_vector(35 downto 0);
    signal T        : std_logic_vector(35 downto 0);
    signal S        : std_logic_vector(35 downto 0);
    signal Op_ctrl  : std_logic_vector(5 downto 0);
    signal Hi       : std_logic_vector(35 downto 0);
    signal Ci_B     : std_logic;
    signal Ci_C     : std_logic;
    signal Prod     : std_logic_vector(67 downto 0);
    signal Ci2_B    : unsigned(0 downto 0);
    signal Ci2_C    : unsigned(0 downto 0);
    signal signal_Res      : std_logic_vector(31 downto 0)  ;

begin  
    process (Clk,Reset,ld,Cntr)
        begin
           if (rising_edge(Clk)) then
                if (Reset='0') then
                     Cntr <= 0;
                     
                elsif (ld='1' and Cntr = 0 ) then
                    Cntr <= 9;              
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
                                   
                elsif (ld='1' and (Cntr = 9 or Cntr = 0))  then
                     A<= M(31) & M(31)& M(31) & M(31) & M;
                end if;
           end if;
    end process;
    
    
    process (Clk,reset,ld,Cntr)
        begin
           if (rising_edge(Clk)) then
                if (Reset='0') then
                     Prod <= (others =>'0');
                                   
                elsif (ld = '1' and (Cntr = 9 or Cntr = 0) ) then
                     Prod(31 downto 0) <= R(31 downto 0);
                elsif (Cntr/=0) then
                    Prod <=  S(35) & S(35) & S(35) & S(35) & S & Prod(31 downto 4) ;
                end if;
           end if;
    end process;  
    
    process (Clk,reset,ld,Cntr)
        begin
           if (rising_edge(Clk)) then
                if (Reset='0') then
                     Guard <= '0';
                                   
                elsif (ld = '1' and (Cntr = 9 or Cntr = 0)) then
                     Guard <= '0';
                elsif (Cntr/=0) then
                     Guard <= Prod(3);
                end if;
           end if;
    end process;  
    
    process (Clk,reset,cntr)
        begin
           if (rising_edge(Clk)) then
                if (Reset='0') then
                     signal_Res <= (others => '0');
                                   
                elsif (Cntr = 1) then
                     signal_Res <= S(3 downto 0) & Prod(31 downto 4);
                end if;
           end if;
    end process;  
    
    process (Clk,cntr)
        begin
           if (rising_edge(Clk)) then
                if (Reset='0') then
                    Valid <= '0';
                elsif (Cntr = 1) then
                    Valid <= '1';
                else Valid <= '0';
                     
                end if;
           end if;
    end process;
    

    process (Clk,Cntr,Booth,Guard,A,B,C,Mx8,Mx4,Mx2,Mx1,S,T,Op_ctrl,Hi,Ci_B,Ci_C,Prod,Ci2_B,Ci2_C,signal_Res,ld)
        begin

    Booth <= Prod(3 downto 0) & Guard;
    Mx8     <= A (32 downto 0) & "000";
    Mx4     <= A (33 downto 0) & "00";
    Mx2     <= A (34 downto 0) & '0';
    Mx1     <= A;
    Hi      <= Prod(67 downto 32);    
    Ci2_B(0)<= Ci_B;
    Ci2_C(0)<= Ci_C;
    T       <=  std_logic_vector(unsigned(Hi) + unsigned(B) + Ci2_B);
    S       <=  std_logic_vector(unsigned(T) + unsigned(C) + Ci2_C);
    end process;

    with Booth select
    Op_ctrl<= "000000"  when "00000",
               "001000" when "00001",
               "001000" when "00010",
               "011000" when "00011",
               "011000" when "00100",
               "101001" when "00101",
               "101001" when "00110",
               "000001" when "00111",
               "000001" when "01000",
               "001001" when "01001",
               "001001" when "01010",
               "011001" when "01011",
               "011001" when "01100",
               "101011" when "01101",
               "101011" when "01110",
               "000011" when "01111",
               "000111" when "10000",
               "001111" when "10001",
               "001111" when "10010",
               "111101" when "10011",
               "111101" when "10100",
               "101101" when "10101",
               "101101" when "10110",
               "000101" when "10111",
               "000101" when "11000",
               "001101" when "11001",
               "001101" when "11010",
               "111000" when "11011",
               "111000" when "11100",
               "101000" when "11101",
               "101000" when "11110",
               "000000" when "11111",
               "000000" when others;

    Ci_B <=  Op_ctrl(2);
    Ci_C <=  Op_ctrl(5);

    with Op_ctrl(2 downto 0) select
    B <= Mx4  when "001",
            Mx8  when "011",
            not Mx4  when "101",
            not Mx8  when "111",
            (OTHERS=>'0') when others;

    with Op_ctrl(5 downto 3) select
    C <= Mx1  when "001",
            Mx2  when "011",
            not Mx1  when "101",
            not Mx2  when "111",
            (OTHERS=>'0')  when others;

    Z      <= '1' when signal_Res = X"00000000" else '0';
    N      <= signal_Res(31);
    Result <= signal_Res;
end Behavioral;