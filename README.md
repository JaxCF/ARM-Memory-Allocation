# ARM-Memory-Allocation
This project is an implementation of the C standard "malloc" and "free" functions in Assembly using the Thumb2 ARM instruction set. <br /> <br />

Using the Keil Micro-Vision software to develop, debug, and run Assembly code, these functions have been thoroughly tested to ensure proper memory management in a high-risk, high-performance environment.

## Malloc and Free
This implementation of the "malloc" function makes use of multiple important concepts regarding safe memory allocation: <br /> <br />

**Buddy Allocation** is used to ensure efficient allocation and deallocation of system memory. <br />
**Supervisor Calls** are used to differentiate user- and kernel-mode function calls, making sure that privledges are only given when absolutely necessary. <br />