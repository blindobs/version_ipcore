------------------------------------------------------------------------------------------------------------------------
--! @file      : version_axi_lite.vhd
--! @author    : Tomasz Oczkowski
--! @repository: TODO add git repo path
--! @version   : 1.0
--! @date      : 2020.01.22
--! @copyright : opensource based on Berkeley Software Distribution Licenses (BSDL)
------------------------------------------------------------------------------------------------------------------------
--! @class VERSION_IPCORE
--! @details AXI4_Lite interface, generated by Memory mapper Python script. Axi4-Lite supports write strobe signals. \n
--! Driver is always ready for new data -> 3 cycle read, 2 cycle write routine (ADDR, DATA| BRESP). \n
--! Module does not contain any clock domain crossing. It's assumes that addr/data interface is operation at the same \n
--! S_AXI_ACLK_i clock.
------------------------------------------------------------------------------------------------------------------------

--! Use standard library
library IEEE;
--! Use standard package
use IEEE.std_logic_1164.all;
--! Use numeric package
use IEEE.numeric_std.all;
--! Use mathematic package
use IEEE.math_real.all;

--! @brief  version axi lite
--! @code{.markdown}
--! entity template:
--!                ______
--!               |      |
--!   axi_lite=<>=|      |=>= version addr
--!               |      |=<= version data
--!               |______|
--!
--! @endcode
entity VERSION_AXI_LITE is
  generic (
    --! Width of S_AXI data bus
    C_S_AXI_DATA_WIDTH  : integer  := 32;
    --! Width of S_AXI address bus
    C_S_AXI_ADDR_WIDTH  : integer  := 4
  );
  port (
    --!\brief address line for version rom
    VERSION_ADDR_o : out std_logic_vector(C_S_AXI_ADDR_WIDTH-2 downto 0);
    --!\brief read version data from version_rom entity
    VERSION_DATA_i : in  std_logic_vector(31 downto 0);
    --!\brief Global Clock Signal
    S_AXI_ACLK_i     : in std_logic;
    --!\brief Global Reset Signal. This Signal is Active LOW
    S_AXI_ARESETN_i  : in std_logic;
    --!\brief Write address (issued by master, acceped by Slave)
    S_AXI_AWADDR_i   : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    --!\brief Write channel Protection type. This signal indicates the
    --! privilege and security level of the transaction, and whether
    --! the transaction is a data access or an instruction access.
    S_AXI_AWPROT_i   : in std_logic_vector(2 downto 0);
    --!\brief Write address valid. This signal indicates that the master signaling
    --! valid write address and control information.
    S_AXI_AWVALID_i  : in std_logic;
    --!\brief Write address ready. This signal indicates that the slave is ready
    --! to accept an address and associated control signals.
    S_AXI_AWREADY_o  : out std_logic;
    --! Write data (issued by master, acceped by Slave)
    S_AXI_WDATA_i    : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    --!\brief Write strobes. This signal indicates which byte lanes hold
    --! valid data. There is one write strobe bit for each eight
    --! bits of the write data bus.
    S_AXI_WSTRB_i    : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    --!\brief Write valid. This signal indicates that valid write
    --! data and strobes are available.
    S_AXI_WVALID_i   : in std_logic;
    --!\brief Write ready. This signal indicates that the slave
    --! can accept the write data.
    S_AXI_WREADY_o   : out std_logic;
    --!\brief Write response. This signal indicates the status
    --! of the write transaction.
    S_AXI_BRESP_o    : out std_logic_vector(1 downto 0);
    --!\brief Write response valid. This signal indicates that the channel
    --! is signaling a valid write response.
    S_AXI_BVALID_o   : out std_logic;
    --!\brief Response ready. This signal indicates that the master
    --! can accept a write response.
    S_AXI_BREADY_i   : in std_logic;
    --!\brief Read address (issued by master, acceped by Slave)
    S_AXI_ARADDR_i   : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    --!\brief Protection type. This signal indicates the privilege
    --! and security level of the transaction, and whether the
    --! transaction is a data access or an instruction access.
    S_AXI_ARPROT_i   : in std_logic_vector(2 downto 0);
    --!\brief Read address valid. This signal indicates that the channel
    --! is signaling valid read address and control information.
    S_AXI_ARVALID_i  : in std_logic;
    --!\brief Read address ready. This signal indicates that the slave is
    --! ready to accept an address and associated control signals.
    S_AXI_ARREADY_o  : out std_logic;
    --!\brief Read data (issued by slave)
    S_AXI_RDATA_o    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    --!\brief Read response. This signal indicates the status of the
    --! read transfer.
    S_AXI_RRESP_o    : out std_logic_vector(1 downto 0);
    --!\brief Read valid. This signal indicates that the channel is
    --! signaling the required read data.
    S_AXI_RVALID_o   : out std_logic;
    --!\brief Read ready. This signal indicates that the master can
    --! accept the read data and response information.
    S_AXI_RREADY_i   : in std_logic
  );
end entity VERSION_AXI_LITE;

architecture VERSION_AXI_LITE_BEHAVE_VHDL2002 of VERSION_AXI_LITE is

  --! AXI 4 Specification response okay opcode
  constant AXI_RESP_OKAY_C        : std_logic_vector (1 downto 0) := "00";

  --! axi bvalid internal signal
  signal axi_bvalid  : std_logic := '0';
  --! axi awready internal signal
  signal axi_awready : std_logic := '0';
  --! axi wready internal signal
  signal axi_wready  : std_logic := '0';
  --! axi arready internal signal
  signal axi_arready : std_logic := '0';
  --! axi rvalid internal signal
  signal axi_rvalid  : std_logic := '0';

  --! register write address
  signal waddr  : std_logic_vector(S_AXI_AWADDR_i'length-3 downto 0) := (others=>'0');
  --! register write data
  signal wdata  : std_logic_vector(S_AXI_WDATA_i'range)              := (others=>'0');
  --! register write strobe
  signal wstrb  : std_logic_vector(S_AXI_WSTRB_i'range)              := (others=>'0');
  --! register read data
  signal rdata   : std_logic_vector(S_AXI_RDATA_o'range)             := (others=>'0');
  --! register write ena
  signal wena   : std_logic := '0';
  --! register read ena
  signal rena   : std_logic := '1';

begin
------------------------------------------------------------------------------------------------------------------------
-- AXI port connections
------------------------------------------------------------------------------------------------------------------------

  S_AXI_BRESP_o   <= AXI_RESP_OKAY_C;
  S_AXI_BVALID_o  <= axi_bvalid;
  S_AXI_AWREADY_o <= axi_awready;
  S_AXI_WREADY_o  <= axi_wready;

  S_AXI_RDATA_o   <= rdata;
  S_AXI_RVALID_o  <= axi_rvalid;
  S_AXI_RRESP_o   <= AXI_RESP_OKAY_C;
  S_AXI_ARREADY_o <= axi_arready;

------------------------------------------------------------------------------------------------------------------------
-- Output ports drivers (no Clear, Set, Ena ports here)
------------------------------------------------------------------------------------------------------------------------

  VERSION_ADDR_o        <= S_AXI_ARADDR_i(S_AXI_ARADDR_i'length-1 downto 2); -- version addres is 4 bytes per word

------------------------------------------------------------------------------------------------------------------------
--! \brief READ PROCESS:
--! \details combines READ DATA CHANNEL, READ ADDRESS CHANNEL
--! process uses synchronous reset signal low active reset signal S_AXI_ARESETN_i (Xilinx recommendation)
------------------------------------------------------------------------------------------------------------------------
AXI_READ:process(S_AXI_ACLK_i)
variable addr_handshake_v  : std_logic := '0';
begin
  if rising_edge(S_AXI_ACLK_i)  then
    -- synchronous low active reset signal
    if '0' = S_AXI_ARESETN_i then
      axi_arready      <= '0';
      axi_rvalid       <= '0';
      addr_handshake_v := '0';
    else
      -- address channel axi protocol handshake
      if ('1' = S_AXI_ARVALID_i  and '1' = axi_arready) then
        addr_handshake_v     := '1';
      end if;
      -- data channel axi protocol handshake
      if ('1' = axi_rvalid and '1' = S_AXI_RREADY_i) then
        addr_handshake_v    := '0';
        axi_rvalid          <= '0';
      end if;

      -- can add any delay to this process for extra time before data arrives
      if '1' = addr_handshake_v then
        axi_rvalid  <= '1';
      end if;

      axi_arready <= not(addr_handshake_v);
      rena        <= not(addr_handshake_v);
    end if;
  end if;
end process AXI_READ;

------------------------------------------------------------------------------------------------------------------------
--! \brief USER REGISTERS connection:
--! \details read-registers template, reset is not needed as AXI4 data line can have anyvalue when rvalid signal is low
------------------------------------------------------------------------------------------------------------------------
READ_FROM_REGS_TEMPLATE:process(S_AXI_ACLK_i)
begin
  if rising_edge(S_AXI_ACLK_i) then
    if '1' = rena then
      rdata <= VERSION_DATA_i; 
    end if;
  end if;
end process READ_FROM_REGS_TEMPLATE;

end architecture VERSION_AXI_LITE_BEHAVE_VHDL2002;