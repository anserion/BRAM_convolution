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
-- RNS addmod module (10 modulos 37,41,43,47,53,55,59,61,63,64).
-- op1 - 10 6-bit values
-- op2 - 10 6-bit values
-- res - 10 6-bit values
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RNS_addmod_6bit is
   Port (
      clk : in STD_LOGIC;
      op1 : in  STD_LOGIC_VECTOR(59 downto 0);
      op2 : in  STD_LOGIC_VECTOR(59 downto 0);
      res : out STD_LOGIC_VECTOR(59 downto 0)
   );
end RNS_addmod_6bit;

architecture ax309 of RNS_addmod_6bit is
   COMPONENT BRAM_addmod_37_6bit
   PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
   );
   END COMPONENT;

   COMPONENT BRAM_addmod_41_6bit
   PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT BRAM_addmod_43_6bit
   PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT BRAM_addmod_47_6bit
   PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT BRAM_addmod_53_6bit
   PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT BRAM_addmod_55_6bit
   PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT BRAM_addmod_59_6bit
   PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT BRAM_addmod_61_6bit
   PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT BRAM_addmod_63_6bit
   PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT BRAM_addmod_64_6bit
   PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
   );
   END COMPONENT;
   
begin
BRAM_addmod_37_chip: BRAM_addmod_37_6bit port map (clk, op1(5 downto 0) & op2(5 downto 0), res(5 downto 0));
BRAM_addmod_41_chip: BRAM_addmod_41_6bit port map (clk, op1(11 downto 6) & op2(11 downto 6), res(11 downto 6));
BRAM_addmod_43_chip: BRAM_addmod_43_6bit port map (clk, op1(17 downto 12) & op2(17 downto 12), res(17 downto 12));
BRAM_addmod_47_chip: BRAM_addmod_47_6bit port map (clk, op1(23 downto 18) & op2(23 downto 18), res(23 downto 18));
BRAM_addmod_53_chip: BRAM_addmod_53_6bit port map (clk, op1(29 downto 24) & op2(29 downto 24), res(29 downto 24));
BRAM_addmod_55_chip: BRAM_addmod_55_6bit port map (clk, op1(35 downto 30) & op2(35 downto 30), res(35 downto 30));
BRAM_addmod_59_chip: BRAM_addmod_59_6bit port map (clk, op1(41 downto 36) & op2(41 downto 36), res(41 downto 36));
BRAM_addmod_61_chip: BRAM_addmod_61_6bit port map (clk, op1(47 downto 42) & op2(47 downto 42), res(47 downto 42));
BRAM_addmod_63_chip: BRAM_addmod_63_6bit port map (clk, op1(53 downto 48) & op2(53 downto 48), res(53 downto 48));
BRAM_addmod_64_chip: BRAM_addmod_64_6bit port map (clk, op1(59 downto 54) & op2(59 downto 54), res(59 downto 54));
end ax309;