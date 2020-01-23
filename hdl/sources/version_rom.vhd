------------------------------------------------------------------------------------------------------------------------
--! @file      : version_rom.vhd
--! @author    : Tomasz Oczkowski
--! @repository: TODO add git repo path
--! @version   : 1.0
--! @date      : 2020.01.22
--! @copyright : opensource based on Berkeley Software Distribution Licenses (BSDL)
------------------------------------------------------------------------------------------------------------------------
--! @class VERSION_IPCORE
--! @details Module stores generics as strings in internal rom interface \n
--! Data stored is available in addr/data interface as four string characters per address line. \n
--! Maximum stored string length is equall to ADDR_LENGTH_G*4 characters. If string length is greater then this assertion \n
--! is raised. Stored string is terminated with '\0'. From processor side view data can be read as *char.
--! Stored string is formatted: USER_INFO_G+' '+string(MAJOR_G)+'.'+string(MINOR_G)+' '+NODE_SHORT_G+'\0'.
------------------------------------------------------------------------------------------------------------------------

--! Use standard library
library IEEE;
--! Use standard package
use IEEE.std_logic_1164.all;
--! Use numeric package
use IEEE.numeric_std.all;
--! Use math package
use IEEE.math_real.all;

--! @brief Version control IPCORE
--! @code{.markdown}
--! entity template:
--!            ______
--!           |      |
--!   addr =>=|      |=>= data
--!    clk ->-|      |
--!           |______|
--!
--! addr : ram address line
--! clk  : ram clock
--! data : read ram data
--! @endcode
entity VERSION_ROM is
  generic (
    ADDR_WIDTH_G   : natural := 8;                                --! address line width
    MAJOR_G        : integer range 0 to 9 := 1;                   --! major hw version
    MINOR_G        : integer range 0 to 9 := 0;                   --! minor hw version
    USER_INFO_G    : string := "Compiled by XXX";                 --! custom user string ident
    NODE_SHORT_G   : string := "0xDEEDBEEF!!"                     --! short node hash
  );
  port (
    CLK_i  : in  std_logic;                                       --! main system clock
    ADDR_i : in  std_logic_vector(ADDR_WIDTH_G-1 downto 0);       --! address line
    DATA_o : out std_logic_vector(31 downto 0) := (others=>'0')   --! four string characters
  );
end entity VERSION_ROM;

--! @brief VHDL2002 compilant code for VERSION_ROM entity
--! @details \b Hardware \b Utilization : \n
--! approx. no impact on device resources \n
--! \b Synthesis : \n
--! Xilinx Vivado 2019.1, Active-HDL Lattice Edition 3.11
architecture VERSION_ROM_ARCH_VHDL2002 of VERSION_ROM is

  --! ROM constant with HW version encoded on Ascii characters
  constant VERSION_TABLE_C : string := USER_INFO_G&' '&INTEGER'IMAGE(MAJOR_G)&"."&INTEGER'IMAGE(MINOR_G)&
                                       " "&NODE_SHORT_G&NUL;

begin
------------------------------------------------------------------------------------------------------------------------
-- ASSERT CHECKER
------------------------------------------------------------------------------------------------------------------------
can_be_stored_check: IF NOT (2**ADDR_WIDTH_G*4 >= USER_INFO_G'length + NODE_SHORT_G'length +3) GENERATE
  assert false report "Given string is to big and cannot be stored in internal ROM" severity failure;
END GENERATE can_be_stored_check;

------------------------------------------------------------------------------------------------------------------------
-- main process description
--! @brief rom based read data process
--! @details
--! \b Description \n
--! This process is used to fetch 4 ascii characters from VERSION_TABLE_C. \n
--! Process adds 1 cycle delay and should be implemented on ROM/LUT
--!
--! @param  CLK_i input rom clock
--!
--! @return Four ascii characters converted to std_logic_vector based on ADDR_i
--!
------------------------------------------------------------------------------------------------------------------------
main:process(CLK_i)
begin
  if rising_edge(CLK_i) then
    conv_string_to_std_loop:for i in 0 to 3 loop
      if 4*to_integer(unsigned(ADDR_i))+i+1 <= VERSION_TABLE_C'length then
        DATA_o((i+1)*8-1 downto i*8) <= std_logic_vector(to_unsigned(character'pos(
          VERSION_TABLE_C(4*to_integer(unsigned(ADDR_i))+i+1)), 8));
      else
        DATA_o((i+1)*8-1 downto i*8) <= std_logic_vector(to_unsigned(character'pos(NUL),8));
      end if;
    end loop conv_string_to_std_loop;
  end if;
end process main;


end architecture VERSION_ROM_ARCH_VHDL2002;