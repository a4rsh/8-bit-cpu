VERILATE := verilator
VERILATE_FLAGS := --binary --trace-fst

MODULES := pc alu register memory
BINARIES := $(notdir $(wildcard obj_dir/V*))

all: $(MODULES)

clean:
	rm -rf obj_dir
	rm -rf waveform.fst
	rm -rf $(BINARIES)

$(MODULES): %: src/%.sv tb/tb_%.sv
	$(VERILATE) $(VERILATE_FLAGS) $^
	cp obj_dir/V$@ .

cpu: src/cpu.sv  src/alu.sv src/pc.sv src/register.sv tb/tb_cpu.sv src/memory.sv
	$(VERILATE) $(VERILATE_FLAGS) $^
	cp obj_dir/Vcpu .