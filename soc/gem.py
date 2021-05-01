import sys
import struct
import os.path
import argparse

from migen import *
from migen.fhdl import verilog

from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from soc_gem.target.gem import BaseSoC

class GemSoC(BaseSoC):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        # Add in debug registers
        # if 'debug' in kwargs['cpu_variant']:
            # self.register_mem("vexriscv_debug", 0xf00f0000, self.cpu.debug_bus, 0x100)

def main():
    parser = argparse.ArgumentParser(description="LiteX SoC on GEM1")
    parser.add_argument("--build",             action="store_true", help="Build bitstream")
    parser.add_argument("--sys-clk-freq",      default=12e6,        help="System clock frequency (default: 12MHz)")
    parser.add_argument("--bios-flash-offset", default=0x60000,     help="BIOS offset in SPI Flash (default: 0x60000)")
    parser.add_argument("--flash",             action="store_true", help="Flash Bitstream")
    parser.add_argument("--cfu", default=None, help="Specify file containing CFU Verilog module")
    parser.set_defaults(
            csr_csv='csr.csv',
            uart_name='serial',
            uart_baudrate=921600,
            cpu_variant='minimal',    # don't specify 'cfu' here
            integrated_rom_size=0,
            integrated_sram_size=0,
            with_etherbone=False)
    builder_args(parser)
    soc_core_args(parser)
    args = parser.parse_args()

    soc = GemSoC()
    builder = Builder(soc, **builder_argdict(args))
    builder.build(run=args.build)

    if args.flash:
        flash(args.bios_flash_offset)

if __name__ == "__main__":
    main()
