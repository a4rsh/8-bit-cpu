# CPU Architecture

After taking Intro to Digital System Design, I thought why not deisgn a basic CPU in verilog. Just for fun, I'll try to come up with the design and implementation myself and only use the basics of CPU layout that I learned at the end of this class.

This can kind of serve as a baseline for myself as I'll be able to compare this design to future ones after I've taken the ASIC Design and Computer Prototyping labs

### Instruction Set

I wanted my design to be simple, but also implement enough instructions to make writing programs not a complete pain. I initally started with 16-bit insturctions but things branched too quickly and I didn't want to have too many unused instructions, so I switched to 8-bit and I settled on the following basic specifications:

* 8 bit instruction, register, and memory address size 
* A whopping 256 bytes of memory
* Four Registers, R0-R4 (A, B, C, D)

And here's the instruction set that led me to this:

For an instruction: ins[7:0]
| ins[7:5] | Operation | Details |
|----------|-----------|---------|
| 000 | Write Lower | Write ins[3:0] into the lower 4 bits of R(ins[4]) <br> (Only R0 & R1)|
| 001 | Write Upper | Write ins[3:0] into the upper 4 bits of R(ins[4]) <br>(Only R0 & R1)|
| 010 | Move | Move the value stored in R(ins[1:0]) into R(ins[3:2]) |
| 011 | Load/Save | ins[4]: 0 is Load, 1 is Save <br> R(ins[3:2]) holds the value <br> R(ins[1:0]) holds the memory location |
| 100 | Arithmetic | ins[4]: 0 is Addition, 1 is Subtraction <br> R(ins[3:2]) holds operand 1 and stores the value <br> R(ins[1:0]) holds operand 2 |
| 101 | Bitwise | ins[4]: 0 is AND, 1 is XOR <br> R(ins[3:2]) holds operand 1 and stores the value <br> R(ins[1:0]) holds operand 2 |
| 110 | Jumps | ins[4]: 0 is Unconditional Jump, 1 is if Equal to Zero <br> R(ins[3:2]) holds the memory address to jump to <br> R(ins[1:0]) holds the checked value for conditional jumps |
| 111 | Halt | The program halts |

I think that this is a decent balance between usablity and simplicity.


### Implementation

The full code for the implementation can be found in the [src/](https://github.com/a4rsh/8-bit-cpu/tree/main/src) folder but I'll just highlight some design decisions.

The Artithmetic/Logic Unit (ALU) was fairly simple as it was purely combinational. For the registers, program counter, and memory I made reads combinational, and writes sequential. For example I can specify the register to be read through in_1 and out_1 will be updated immediately, but to write to a register, write enable (wen) and the data in must be enabled and a clock cycle must be waited.

The CPU module was then just putting these pieces together and implementing instructions using a state machine where FETCH gets an instruction, DECODE will set up the combinational logic, EXECUTE lets propagations occur, and HALT ends the program. I'm sure this isn't the standard way to do this as I think more sequential logic is used and the EXECUTE state has more function but I find it more enjoyable to derive the architecture myself.


### Testing

I wanted to take advantage of the modularity of this code. So I wrote [testbenches](https://github.com/a4rsh/8-bit-cpu/tree/main/tb) for each module to make my life easier at the end. This was good practice as well because I'm exploring Hardware Verification.

For testing the full design I made a module to simulate memory which reads from the input file program.bin and outputs to memory.bin 

Although the basics of this setup work, admittedly I have not fully tested the CPU design itself because I got really tired of looking at binary instructions. So I've decided that I'll make an assembler so that I can write more human-readable code that will automatically translate into binary instrcutions. After that is complete, I'll use it to more throughly verify my design.
