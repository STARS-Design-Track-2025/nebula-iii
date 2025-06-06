# SPDX-FileCopyrightText: 2020 Efabless Corporation
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
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

# ---- Test patterns for project striVe ----

.SUFFIXES:
.SILENT: clean all

PATTERNS := $(shell ls -d team_[0-9][0-9] 2>/dev/null)

all:  ${PATTERNS}

	for i in ${PATTERNS}; do \
		( cd $$i && make -f Makefile $${i}.vcd &> verify.log && grep Monitor verify.log) ; \
	done

DV_PATTERNS = $(foreach dv, $(PATTERNS), verify-$(dv))
$(DV_PATTERNS): verify-% : 
	cd $* && make

clean:  ${PATTERNS}
	for i in ${PATTERNS}; do \
		( cd $$i && \rm  -f *.elf *.hex *.bin *.vvp *.log *.vcd *.lst *.hexe ) ; \
	done
	for i in $(filter-out io_ports la_test1 la_test2 wb_port mprj_stimulus, $(PATTERNS)); do \
		( cd $$i && \cd module_tests && \make clean) ; \
	done
	rm -rf *.log
	
.PHONY: clean all
