#!/usr/bin/env python3
# Copyright 2021 The CFU-Playground Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.SHELL := /bin/bash

# This Makefile builds the LiteX SoC.
#
# Typically, you would run 'make' in a project directory, which would use this Makefile recursively.
#

HELP_MESSAGE:= Run make from your project directory instead of using this file directly.

ifndef PROJ
  $(error PROJ must be set. $(HELP_MESSAGE))
endif

ifndef UART_SPEED
  $(error UART_SPEED must be set. $(HELP_MESSAGE))
endif

ifndef CFU_ROOT
  $(error CFU_ROOT must be set. $(HELP_MESSAGE))
endif

PROJ_DIR:=  $(CFU_ROOT)/proj/$(PROJ)
CFU_V:=     $(PROJ_DIR)/cfu.v
CFU_ARGS:=  --cfu $(CFU_V)

SOC_NAME:=  gem.$(PROJ)
OUT_DIR:=   build/$(SOC_NAME)
UART_ARGS=  --uart-baudrate $(UART_SPEED)
#LITEX_ARGS= --output-dir $(OUT_DIR) --csr-csv $(OUT_DIR)/csr.csv $(UART_ARGS)
#LITEX_ARGS= --output-dir $(OUT_DIR) --csr-csv $(OUT_DIR)/csr.csv $(CFU_ARGS) $(UART_ARGS)
LITEX_ARGS= --output-dir $(OUT_DIR) --csr-csv $(OUT_DIR)/csr.csv $(CFU_ARGS) $(UART_ARGS) --slim-cpu

ifdef USE_SYMBIFLOW
LITEX_ARGS += --toolchain symbiflow
endif

PYRUN:=     $(CFU_ROOT)/scripts/pyrun
GEM_RUN:=  MAKEFLAGS=-j8 $(PYRUN) ./gem.py $(LITEX_ARGS)

SOFTWARE_BIN := $(PROJ_DIR)/build/software.bin
BIOS_BIN := $(OUT_DIR)/software/bios/bios.bin
BITSTREAM:= $(OUT_DIR)/gateware/gem.bit
GATEWARE := $(OUT_DIR)/gateware/gem.bin

GEM_SCRIPTS=soc_gem/scripts
GEM_FLASH_MAP=${GEM_SCRIPTS}/Digital_Programming_Flash.csv
GEM_SCRIPT_A=${GEM_SCRIPTS}/A_sfabric.sh
GEM_SCRIPT_B=${GEM_SCRIPTS}/B_flash.sh
GEM_SCRIPT_B_ALL=${GEM_SCRIPTS}/B_flash_all.sh
GEM_SCRIPT_C=${GEM_SCRIPTS}/C_camera_test.sh
GEM_SCRIPT_D=${GEM_SCRIPTS}/D_zephyr_boot.sh

.PHONY: bitstream litex-software prog clean check-timing

bitstream: $(BITSTREAM) check-timing

litex-software: $(BIOS_BIN)

ifndef USE_SYMBIFLOW
ifndef IGNORE_TIMING
check-timing:
	@echo Checking Vivado timing.
	@echo To disable this check, set IGNORE_TIMING=1
	@if grep -B 6 "Timing constraints are not met" $(OUT_DIR)/gateware/vivado.log  ; then exit 1 ; fi
else
check-timing:
	@echo Vivado timing check is skipped.
endif
else
check-timing:
	@echo Timing check not performed for SymbiFlow.
endif

load: $(BITSTREAM) check-timing
	@echo Loading bitstream onto Gem && \
	./$(GEM_SCRIPT_A) && \
	export GEM_FLASH_MAP=${GEM_FLASH_MAP} && \
	export CFU_GATEWARE=${GATEWARE} && \
	export CFU_BIOS=${BIOS_BIN} && \
	export CFU_SOFTWARE=${SOFTWARE_BIN} && \
	echo LOADING GEM && \
	./$(GEM_SCRIPT_B_ALL)


prog: $(BITSTREAM) check-timing
	@echo Loading bitstream onto Gem
	./$(GEM_SCRIPT_A) && \
	export GEM_FLASH_MAP=${GEM_FLASH_MAP} && \
	export CFU_GATEWARE=${GATEWARE} && \
	export CFU_BIOS=${BIOS_BIN} && \
	./$(GEM_SCRIPT_B)

clean:
	@echo Removing $(OUT_DIR)
	rm -rf $(OUT_DIR)

$(CFU_V):
	$(error $(CFU_V) not found. $(HELP_MESSAGE))

$(BIOS_BIN): $(CFU_V)
	$(GEM_RUN)

$(BITSTREAM): $(CFU_V)
	@echo Building bitstream for GEM. CFU option: $(CFU_ARGS)
	$(GEM_RUN) --build
