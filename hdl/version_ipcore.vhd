------------------------------------------------------------------------------------------------------------------------
--! @file      : version_ipcore.vhd
--! @author    : Tomasz Oczkowski
--! @repository: TODO add git repo path
--! @version   : 1.0
--! @date      : 2020.01.22
--! @copyright : opensource based on Berkeley Software Distribution Licenses (BSDL)
------------------------------------------------------------------------------------------------------------------------
--! @class VERSION_IPCORE
--! @details VERSION_ROM module encapsulated in axi4_lite wrapper \n
--! For more information about generic please visit VERSION_ROM entity \n
--! Module stores given data to internal rom that can be read by axi interface. As this module stores only constant \n
--! string for software validation speed is not an issue , so AXI4 LITE interface was used for minimal footprint.
------------------------------------------------------------------------------------------------------------------------


--! Use standard library
library IEEE;
--! Use standard package
use IEEE.std_logic_1164.all;
--! Use numeric package
use IEEE.numeric_std.all;

--! @brief Version IPCORE
--! @code{.markdown}
--! entity template: 
--!                ______ 
--!               |      |
--!   axi_bus =<>=|      |
--!   axi_clk ->- |      |
--!               |______|
--!
--! axi_bus : axi4 lite bus signals
--! axi_clk : axi4 lite bus signals clock
--! @endcode 
entity VERSION_IPCORE is
  generic (
    MAJOR_G              : integer range 0 to 9 := 1;      --! major hw version
    MINOR_G              : integer range 0 to 9 := 0;      --! minor hw version
    USER_INFO_G          : string := "Compiled by XXX";    --! custom user string ident
    NODE_SHORT_G         : string := "0xDEEDBEEF!!";       --! short node hash
    -- Parameters of Axi Slave Bus Interface S_AXI
    C_S_AXI_DATA_WIDTH_G : integer   := 32;                --! axi interface data width
    C_S_AXI_ADDR_WIDTH_G : integer   := 6                  --! axi interface addr width
  );
  port (
    -- Ports of Axi Slave Bus Interface S_AXI
    S_AXI_ACLK     : in  std_logic;                                             --! Global Clock Signal
    s_axi_aresetn  : in  std_logic;                                             --! Global Reset Signal. This Signal is Active LOW
    s_axi_awaddr   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH_G-1 downto 0);     --! Write address (issued by master, acceped by Slave)
    s_axi_awprot   : in  std_logic_vector(2 downto 0);                          --! Write channel Protection type
    s_axi_awvalid  : in  std_logic;                                             --! Write address valid.
    s_axi_awready  : out std_logic;                                             --! Write address ready.
    s_axi_wdata    : in  std_logic_vector(C_S_AXI_DATA_WIDTH_G-1 downto 0);     --! Write data
    s_axi_wstrb    : in  std_logic_vector((C_S_AXI_DATA_WIDTH_G/8)-1 downto 0); --! Write strobes.
    s_axi_wvalid   : in  std_logic;                                             --! Write valid.
    s_axi_wready   : out std_logic;                                             --! Write ready
    s_axi_bresp    : out std_logic_vector(1 downto 0);                          --! Write response
    s_axi_bvalid   : out std_logic;                                             --! Write response valid
    s_axi_bready   : in  std_logic;                                             --! Response ready
    s_axi_araddr   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH_G-1 downto 0);     --! Read address
    s_axi_arprot   : in  std_logic_vector(2 downto 0);                          --! Read Protection type
    s_axi_arvalid  : in  std_logic;                                             --! Read address valid
    s_axi_arready  : out std_logic;                                             --! Read address ready.
    s_axi_rdata    : out std_logic_vector(C_S_AXI_DATA_WIDTH_G-1 downto 0);     --! Read data
    s_axi_rresp    : out std_logic_vector(1 downto 0);                          --! Read response
    s_axi_rvalid   : out std_logic;                                             --! Read valid
    s_axi_rready   : in  std_logic                                              --! Read ready
   );
end entity VERSION_IPCORE;

--! @brief VHDL2002 compilant code for VERSION_IPCORE entity
--! @details \b Hardware \b Utilization : \n
--! approx. very low impact on device resources \n
--! \b Synthesis : \n
--! Xilinx Vivado 2019.1, Active-HDL Lattice Edition 3.11
architecture VERSION_IPCORE_ARCH_VHDL2002 of VERSION_IPCORE is

  --! wires VERSION_ROM addres line to version_ipcore_v1_0_S_AXI_inst entity
  signal addr_to_version_rom   : std_logic_vector(C_S_AXI_ADDR_WIDTH_G-3 downto 0) := (others=>'0');

  --! wires VERSION_ROM data line to version_ipcore_v1_0_S_AXI_inst entity
  signal data_from_version_rom : std_logic_vector(31 downto 0):= (others=>'0');
  
begin
------------------------------------------------------------------------------------------------------------------------
--! VERSION_ROM initialization \n
--! rom based module that stores version in ROM
------------------------------------------------------------------------------------------------------------------------
version_control: entity work.VERSION_ROM generic map (
    ADDR_WIDTH_G   => addr_to_version_rom'length,
    MAJOR_G        => MAJOR_G,
    MINOR_G        => MINOR_G,
    USER_INFO_G    => USER_INFO_G,
    NODE_SHORT_G   => NODE_SHORT_G
  )
  port map (
    CLK_i  => s_axi_aclk,
    ADDR_i => addr_to_version_rom,
    DATA_o => data_from_version_rom
);

------------------------------------------------------------------------------------------------------------------------
--! version_axi_lite initialization \n
--!  axi4-lite interface wrapper for version_rom
------------------------------------------------------------------------------------------------------------------------
axi4_lite_interface : entity work.VERSION_AXI_LITE generic map (
    C_S_AXI_DATA_WIDTH   => C_S_AXI_DATA_WIDTH_G,
    C_S_AXI_ADDR_WIDTH   => C_S_AXI_ADDR_WIDTH_G
  )
  port map (
    -- user
    VERSION_ADDR_o => addr_to_version_rom,
    VERSION_DATA_i => data_from_version_rom,
    -- axi lite interface
    S_AXI_ACLK_i     => s_axi_aclk,
    S_AXI_ARESETN_i  => s_axi_aresetn,
    S_AXI_AWADDR_i   => s_axi_awaddr,
    S_AXI_AWPROT_i   => s_axi_awprot,
    S_AXI_AWVALID_i  => s_axi_awvalid,
    S_AXI_AWREADY_o  => s_axi_awready,
    S_AXI_WDATA_i    => s_axi_wdata,
    S_AXI_WSTRB_i    => s_axi_wstrb,
    S_AXI_WVALID_i   => s_axi_wvalid,
    S_AXI_WREADY_o   => s_axi_wready,
    S_AXI_BRESP_o    => s_axi_bresp,
    S_AXI_BVALID_o   => s_axi_bvalid,
    S_AXI_BREADY_i   => s_axi_bready,
    S_AXI_ARADDR_i   => s_axi_araddr,
    S_AXI_ARPROT_i   => s_axi_arprot,
    S_AXI_ARVALID_i  => s_axi_arvalid,
    S_AXI_ARREADY_o  => s_axi_arready,
    S_AXI_RDATA_o    => s_axi_rdata,
    S_AXI_RRESP_o    => s_axi_rresp,
    S_AXI_RVALID_o   => s_axi_rvalid,
    S_AXI_RREADY_i   => s_axi_rready
);

end architecture VERSION_IPCORE_ARCH_VHDL2002;
