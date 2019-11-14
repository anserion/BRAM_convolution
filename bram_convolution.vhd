------------------------------------------------------------------
--Copyright 2019 Andrey S. Ionisyan (anserion@gmail.com)
--Licensed under the Apache License, Version 2.0 (the "License");
--you may not use this file except in compliance with the License.
--You may obtain a copy of the License at
--    http://www.apache.org/licenses/LICENSE-2.0
--Unless required by applicable law or agreed to in writing, software
--distributed under the License is distributed on an "AS IS" BASIS,
--WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--See the License for the specific language governing permissions and
--limitations under the License.
------------------------------------------------------------------

------------------------------------------------------------------------------
-- Engineer: Andrey S. Ionisyan <anserion@gmail.com>
-- 
-- Description:
-- Top level for the latency of BRAM read process (Alinx AX309 board).
-- graphics output - 480x272 24bpp LCD display (Alinx AN430 board)
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bram_convolution is
   Port (
      clk50_ucf: in STD_LOGIC;
      
      led      : out  STD_LOGIC_VECTOR(3 downto 0);
      key      : in  STD_LOGIC_VECTOR(3 downto 0);
      key_RESET: in  STD_LOGIC;

      lcd_red      : out   STD_LOGIC_VECTOR(7 downto 0);
      lcd_green    : out   STD_LOGIC_VECTOR(7 downto 0);
      lcd_blue     : out   STD_LOGIC_VECTOR(7 downto 0);
      lcd_hsync    : out   STD_LOGIC;
      lcd_vsync    : out   STD_LOGIC;
      lcd_dclk     : out   STD_LOGIC
	);
end bram_convolution;

architecture ax309 of bram_convolution is
   component vram_128x32_8bit
   port (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
   );
   end component;
   signal ch_video_out_clk  : std_logic:='0';
   signal ch_video_out_addr : std_logic_vector(11 downto 0):=(others=>'0');
   signal ch_video_out_char : std_logic_vector(7 downto 0):=(others=>'0');
   
   component keys_supervisor is
   Port ( 
      clk : in std_logic;
      en  : in std_logic;
      key : in std_logic_vector(3 downto 0);
      key_rst: in std_logic;
      param1 : out std_logic_vector(31 downto 0);
      param2 : out std_logic_vector(31 downto 0);
      reset_out: out std_logic
	);
   end component;
   signal param1_reg: std_logic_vector(31 downto 0):=(others=>'0');
   signal param2_reg: std_logic_vector(31 downto 0):=(others=>'0');
   signal reset_key_reg: std_logic:='0';

   component msg_center is
    Port ( 
		clk        : in  STD_LOGIC;
      en         : in std_logic;
      param1     : in std_logic_vector(31 downto 0);
      param2     : in std_logic_vector(31 downto 0);
      res_out1   : in std_logic_vector(31 downto 0);
      res_out2   : in std_logic_vector(31 downto 0);
		msg_char_x : out STD_LOGIC_VECTOR(6 downto 0);
		msg_char_y : out STD_LOGIC_VECTOR(4 downto 0);
		msg_char   : out STD_LOGIC_VECTOR(7 downto 0)
	 );
   end component;
   signal msg_char_x: std_logic_vector(6 downto 0);
   signal msg_char_y: std_logic_vector(4 downto 0);
   signal msg_char: std_logic_vector(7 downto 0);
   
   component clk_core
   port(
      CLK50_ucf: in std_logic;
      CLK100: out std_logic;
      CLK16: out std_logic;      
      CLK8: out std_logic;
      CLK25: out std_logic;
      CLK12_5: out std_logic
   );
   end component;
   signal clk25: std_logic:='0';
   signal clk12_5: std_logic:='0';
   signal clk16: std_logic:='0';
   signal clk8: std_logic:='0';
   signal clk100: std_logic:='0';
   signal clk_common: std_logic:='0';
   signal clk_common_value: STD_LOGIC_VECTOR(31 downto 0):=(others=>'0');
   
   component freq_div_module is
    Port ( 
		clk   : in  STD_LOGIC;
      en    : in  STD_LOGIC;
      value : in  STD_LOGIC_VECTOR(31 downto 0);
      result: out STD_LOGIC
	 );
   end component;
--   signal clk_1Mhz: std_logic:='0';
   signal clk_10Khz: std_logic:='0';
--   signal clk_200hz: std_logic:='0';
--   signal clk_100hz: std_logic:='0';
--   signal clk_50hz: std_logic:='0';
--   signal clk_10Hz: std_logic:='0';
--   signal clk_1Hz: std_logic:='0';
   
   signal gray_pixel : std_logic_vector(7 downto 0):=(others => '0');

   component lcd_AN430
    Port ( 
      en      : in std_logic;
      clk     : in  STD_LOGIC;
      red     : out STD_LOGIC_VECTOR(7 downto 0);
      green   : out STD_LOGIC_VECTOR(7 downto 0);
      blue    : out STD_LOGIC_VECTOR(7 downto 0);
      hsync   : out STD_LOGIC;
      vsync   : out STD_LOGIC;
      de	     : out STD_LOGIC;
      x       : out STD_LOGIC_VECTOR(9 downto 0);
      y       : out STD_LOGIC_VECTOR(9 downto 0);
      dirty_x : out STD_LOGIC_VECTOR(9 downto 0);
      dirty_y : out STD_LOGIC_VECTOR(9 downto 0);
      pixel   : in STD_LOGIC_VECTOR(23 downto 0);
      char_x    : out STD_LOGIC_VECTOR(6 downto 0);
      char_y	 : out STD_LOGIC_VECTOR(4 downto 0);
      char_code : in  STD_LOGIC_VECTOR(7 downto 0)
    );
   end component;
   signal lcd_clk   : std_logic;
   signal lcd_en    : std_logic := '1';
   signal lcd_rd_en : std_logic := '1';
   signal lcd_de    : std_logic :='0';
   signal lcd_reg_hsync: STD_LOGIC :='1';
   signal lcd_reg_vsync: STD_LOGIC :='1';
   signal lcd_x     : std_logic_vector(9 downto 0) := (others => '0');
   signal lcd_y     : std_logic_vector(9 downto 0) := (others => '0');
   signal lcd_dirty_x: std_logic_vector(9 downto 0) := (others => '0');
   signal lcd_dirty_y: std_logic_vector(9 downto 0) := (others => '0');	
   signal lcd_pixel : std_logic_vector(23 downto 0) := (others => '0');	
   signal lcd_char_x: std_logic_vector(6 downto 0) := (others => '0');
   signal lcd_char_y: std_logic_vector(4 downto 0) := (others => '0');
   signal lcd_char  : std_logic_vector(7 downto 0);
   
   signal res1_reg : std_logic_vector(31 downto 0) := (others => '0');
	signal res2_reg : std_logic_vector(31 downto 0) := (others => '0');

   component RNS_convolution is
   Port (
      clk : in STD_LOGIC;
      members_num: in std_logic_vector(15 downto 0);
      conv_res  : out std_logic_vector(59 downto 0);
      conv_ready: out   STD_LOGIC
	);
   end component;
   signal rns_conv_res : std_logic_vector(59 downto 0) := (others => '0');
   signal conv_ready_flag: std_logic:='0';
begin
   --------------------------------
   -- CLOCK section
   --------------------------------
   clocking_chip: clk_core port map (CLK50_ucf, clk100, clk16, clk8, clk25, clk12_5);
   lcd_clk<=clk8;
   lcd_dclk<=lcd_clk;

   freq_10Khz_chip: freq_div_module port map(clk16,'1',conv_std_logic_vector(800,32),clk_10Khz);
   --freq_1Hz_chip  : freq_div_module port map(clk16,'1',conv_std_logic_vector(8000000,32),clk_1Hz);

   --------------------------------
   -- Text messages supervisor section
   --------------------------------
   ch_video_chip : vram_128x32_8bit
   PORT MAP (
    clka => clk16,
    wea => (others=>'1'),
    addra => msg_char_y & msg_char_x,
    dina => msg_char,
    clkb => ch_video_out_clk,
    addrb => ch_video_out_addr,
    doutb => ch_video_out_char
   );
   ch_video_out_clk<=lcd_clk;
   ch_video_out_addr<=lcd_char_y & lcd_char_x;
   lcd_char<=ch_video_out_char;
   
   msg_center_chip: msg_center port map (clk_10Khz,'1',
         param1_reg,param2_reg, res1_reg, res2_reg,
         msg_char_x,msg_char_y,msg_char);
                                          
   --------------------------------
   -- LCD device section
   --------------------------------
   lcd_en<='1'; --not(video_out_reg);
   lcd_rd_en<='1' when (lcd_reg_vsync='0') and (lcd_y>0) and (lcd_y<272) else '0';
   
   lcd_hsync<=lcd_reg_hsync;
   lcd_vsync<=lcd_reg_vsync;
   lcd_AN430_chip: lcd_AN430 PORT MAP(
      en    => lcd_en,
		clk   => lcd_clk,
		red   => lcd_red,
		green => lcd_green,
		blue  => lcd_blue,
		hsync => lcd_reg_hsync,
		vsync => lcd_reg_vsync,
		de	   => lcd_de,
		x     => lcd_x,
		y     => lcd_y,
      dirty_x=>lcd_dirty_x,
      dirty_y=>lcd_dirty_y,
      pixel => lcd_pixel,
		char_x=> lcd_char_x,
		char_y=> lcd_char_y,
		char_code  => lcd_char
      );

   --------------------------------
   -- LEDs and KEYs section
   --------------------------------
   led<=not(key);
   keys_chip: keys_supervisor port map(clk_10Khz,'1',key,key_RESET,param1_reg,param2_reg,reset_key_reg);

   --------------------------------
   -- main process :)
   --------------------------------
   clk_common<='0' when param1_reg=0
      else clk8 when param1_reg=1
      else clk16 when param1_reg=2
      else clk25 when param1_reg=3
      else clk100 when param1_reg=4
      else '0';
   
   clk_common_value<=conv_std_logic_vector(0,32) when param1_reg=0
      else conv_std_logic_vector(8000000,32) when param1_reg=1
      else conv_std_logic_vector(16000000,32) when param1_reg=2
      else conv_std_logic_vector(25000000,32) when param1_reg=3
      else conv_std_logic_vector(100000000,32) when param1_reg=4
      else (others=>'0');
      
   clk_period_process:
   process (clk_common)
   variable conv_stat: natural:=0;
   variable clk_cnt: natural:=0;   
   begin
      if rising_edge(clk_common) then 
         if (clk_cnt>=conv_integer(clk_common_value))or(key_RESET='0')
         then
            clk_cnt:=0;
            res1_reg<=conv_std_logic_vector(conv_stat,32);
            conv_stat:=0;
         else clk_cnt:=clk_cnt+1;
         end if;
         if conv_ready_flag='1' then conv_stat:=conv_stat+1; end if;
      end if;
   end process;
   
   -- RNS convolution module instantiation
   RNS_convolution_chip: RNS_convolution port map
     (clk_common,param2_reg(15 downto 0),rns_conv_res,conv_ready_flag);

end ax309;