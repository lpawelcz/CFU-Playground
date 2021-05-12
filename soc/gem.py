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
    parser.add_argument("--debug",             action="store_true", help="Enable debug mode")
    parser.add_argument("--slim-cpu",          action="store_true", help="Use slimmer VexRiscv (required for mnv2_first)")
    parser.add_argument("--build",             action="store_true", help="Build bitstream")
    parser.add_argument("--sys-clk-freq",      default=12e6,        help="System clock frequency (default: 12MHz)")
    parser.add_argument("--bios-flash-offset", default=0x60000,     help="BIOS offset in SPI Flash (default: 0x60000)")
    parser.add_argument("--flash",             action="store_true", help="Flash Bitstream")
    parser.add_argument("--cfu", default=None, help="Specify file containing CFU Verilog module")

    builder_args(parser)
    soc_core_args(parser)
    args = parser.parse_args()

    soc = GemSoC()

    # get the CFU version, plus the CFU itself and a wrapper
    # ...since we're using stock litex, it doesn't know about the Cfu variants, so we need to use "external_variant"
    print("args.cfu: " + str(args.cfu))
    print("args.slim_cpu: " + str(args.slim_cpu))
    print("soc.cpu.variant: " + str(soc.cpu.variant))
    print("args.debug: " + str(args.debug))
    if args.cfu:
        assert 'full' in soc.cpu.variant
        if args.slim_cpu:
            var = "LiteCfuDebug" if args.debug else "LiteCfu"
        else:
            var = "FullCfuDebug" if args.debug else "FullCfu"
        vexriscv = "../third_party/python/pythondata_cpu_vexriscv/pythondata_cpu_vexriscv"
        soc.cpu.use_external_variant(f"{vexriscv}/verilog/VexRiscv_{var}.v")
        soc.platform.add_source(args.cfu)
        soc.platform.add_source(f"{vexriscv}/verilog/wrapVexRiscv_{var}.v")

    builder = Builder(soc, **builder_argdict(args))
    builder.build(run=args.build)

    if args.flash:
        flash(args.bios_flash_offset)

if __name__ == "__main__":
    main()
