		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
HEAP_TOP	EQU		0x20001000
HEAP_BOT	EQU		0x20004FE0
MAX_SIZE	EQU		0x00004000		; 16KB = 2^14
MIN_SIZE	EQU		0x00000020		; 32B  = 2^5
	
MCB_TOP		EQU		0x20006800      ; 2^10B = 1K Space
MCB_BOT		EQU		0x20006BFE
MCB_ENT_SZ	EQU		0x00000002		; 2B per entry
MCB_TOTAL	EQU		512				; 2^9 = 512 entries
	
INVALID		EQU		-1				; an invalid id
	
;
; Each MCB Entry
; FEDCBA9876543210
; 00SSSSSSSSS0000U					S bits are used for Heap size, U=1 Used U=0 Not Used

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Control Block Initialization
; void _kinit( )
; this routine must be called from Reset_Handler in startup_TM4C129.s
; before you invoke main( ) in driver_keil
		EXPORT	_kinit
_kinit
		; you must correctly set the value of each MCB block
		; complete your code
		
		PUSH	{R0-R12}
		
		LDR		R0, =HEAP_TOP
		LDR		R1, =HEAP_BOT
		MOV		R2, #0x0
		
_init_heap

		STR 	R2, [R0]
		ADDS	R0, R0, #0x01
		
		CMP		R0, R1
		BLT		_init_heap
		
		LDR		R0, =MCB_TOP
		LDR		R1, =MCB_BOT
		
		LDR		R3, =MAX_SIZE
		STR		R3, [R0]
		ADDS	R0, R0, #0x02

_init_mcb

		STR		R2, [R0]
		STR		R2, [R0, #1]
		ADDS	R0, R0, #0x02

		CMP		R0, R1
		BLT		_init_mcb
		
_init_done

		POP		{R0-R12}
		BX		lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
; void* _k_alloc( int size )
;
; 		R0 : size

		EXPORT	_kalloc
_kalloc
		; complete your code
		; return value should be saved into r0
		PUSH	{lr}
		
		LDR		R1, =MCB_TOP			; R1 = MCB_LEFT
		LDR		R2, =MCB_BOT			; R2 = MCB_RIGHT

		CMP 	R0, #MIN_SIZE			; CHECK WITHIN BOUNDS
		BGE		_valid_size
		LDR		R0, =MIN_SIZE			; IF NOT IN BOUNDS SET TO MIN_SIZE
		
_valid_size
		
		BL		_ralloc					; Branch with Link so we can finalize R6 into R0
		
		POP		{lr}
		MOV		R0, R6
		MOV		pc, lr
		
_ralloc

		PUSH	{lr}					; FOR RECURSION

		SUBS	R3, R2, R1
		ADDS	R3, R3, #MCB_ENT_SZ				; R3 = ENTIRE_MCB_ADDR_SPACE
		LSR		R4, R3, #1						; R4 = HALF_MCB_ADDR_SPACE
		ADDS	R5, R1, R4						; R5 = MIDPOINT_MCB_ADDR
		
		MOV		R6, #0x0						; R6 = HEAP_ADDR
		
		LSL		R9, R3, #4						; R9 = ACT_ENTIRE_HEAP_SIZE
		LSL		R10, R4, #4						; R10 = ACT_HALF_HEAP_SIZE
		
		CMP 	R0, R10
		BGT		_ralloc_check					; SIZE > 1/2 HEAP
		
_ralloc_left

		PUSH	{R1-R5}
		PUSH	{R7-R12}
		
		SUBS 	R2, R5, #MCB_ENT_SZ				; right = mid - ent_sz
		BL		_ralloc
		
		POP		{R7-R12}
		POP		{R1-R5}
		
		CMP		R6, #0x0
		BEQ		_ralloc_right
		
		LDR		R11, [R5]
		AND		R11, R11, #0x01
		CMP		R11, #0
		BEQ		_ralloc_return_ptr
		
		B		_ralloc_done
		
_ralloc_right
		
		PUSH	{R1-R5}
		PUSH	{R7-R12}
		
		MOV		R1, R5							; left = mid
		BL		_ralloc
		
		POP		{R7-R12}
		POP 	{R1-R5}
		
		B		_ralloc_done
	
_ralloc_check
		
		LDR		R11, [R1]
		AND		R11, R11, #0x01
		CMP		R11, #0
		BNE		_ralloc_invalid
		
		LDR		R11, [R1]
		CMP		R11, R9
		BLT		_ralloc_invalid
		
		ORR		R11, R9, #0x01
		STR		R11, [R1]
		
_ralloc_large
		
		LDR		R11, =MCB_TOP
		LDR		R12, =HEAP_TOP
		
		; ( heap_top + ( left_mcb_addr - mcb_top ) * 16 )
		SUBS	R11, R1, R11
		LSL		R11, #4
		ADDS	R11, R11, R12
		
		MOV		R6, R11
		B		_ralloc_done
		
_ralloc_return_ptr
		
		STR		R10, [R5]
		B		_ralloc_done
		
_ralloc_invalid

		MOV		R6, #0x0
		B		_ralloc_done
		
_ralloc_done

		POP 	{lr}
		BX		lr
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void *_kfree( void *ptr )
;
;		R0 = ptr

		EXPORT	_kfree
_kfree
		; complete your code
		; return value should be saved into r0
		
		PUSH	{lr}
		
		MOV		R1, R0						; so we can use R0 for return value
		LDR		R2, =HEAP_TOP				; R2 = HEAP_TOP
		LDR		R3, =HEAP_BOT				; R3 = HEAP_BOT
		LDR		R9, =MCB_TOP				; R9 = MCB_TOP
		LDR		R10, =MCB_BOT				; R10 = MCB_BOT
		
		CMP 	R1, R2
		BLT		_rfree_invalid

		CMP		R1, R3
		BGT		_rfree_invalid
		
		SUBS	R5, R1, R2
		LSR		R5, #4
		ADDS	R5, R5, R9
		
		MOV		R1, R5						; R1 = MCB_ADDR
		MOV		R0, R1
		
		BL		_rfree
		
		POP		{lr}
		MOV		pc, lr
		
_rfree
		
		PUSH	{lr}
		
		LDR		R2, [R1]					; R2* = MCB_CONTENTS
		SUBS	R3, R1, R9					; R3 = MCB_INDEX
		
		LSR		R2, #4						; mcb_contents /= 16
		MOV		R4, R2						; R4 = MCB_DISP
		
		LSL		R2, #4						; mcb_contents *= 16
		MOV		R5, R2						; R5 = MY_SIZE

		
		STR		R2, [R1]					; clear used bit
		
		SDIV	R6, R3, R4					; mcb_index / mcb_disp
		AND		R6, R6, #1					; % 2
		
		CMP 	R6, #0x0					; ( mcb_index / mcb_disp ) % 2 == 0
		BNE		_rfree_odd					; EVEN / ODD CHECK
		
											; R2 & R6 open past here
		
_rfree_even

		LDR		R10, =MCB_BOT				; have to reload reg for recursion

		ADDS	R2, R1, R4					; R2 = MCB_BUDDY (ADDRESS)
		CMP		R2, R10						; done with R10 here
		BGE		_rfree_invalid
		
		LDR		R10, [R2]					; R10 = MCB_BUDDY (SIZE)
		
		AND		R6, R10, #1					; ( mcb_buddy & 0x0001 )
		CMP		R6, #0x0
		BNE		_rfree_done
		
		LSR		R10, #5
		LSL		R10, #5						; format buddy size
		
		CMP 	R10, R5						; MCB_BUDDY (SIZE) == MY_SIZE
		BNE		_rfree_done
		
		MOV		R6, #0x0
		STR		R6, [R2]					; zero out buddy
		
		LSL		R5, #1						; MY_SIZE *= 2
		STR		R5, [R1]					; set this block to double size
		
		MOV		R0, R1						; update return address to this block
		
		BL		_rfree
		B		_rfree_done
		
_rfree_odd

		LDR		R9, =MCB_TOP				; have to reload reg for recursion
		
		SUBS	R2, R1, R4					; R2 = MCB_BUDDY (ADDRESS)
		CMP		R2, R9						; done with R9 here
		BLT		_rfree_invalid
		
		LDR		R9, [R2]					; R9 = MCB_BUDDY (SIZE)
		
		AND		R6, R9, #1					; ( mcb_buddy & 0x0001 )
		CMP		R6, #0x0
		BNE		_rfree_done
		
		LSR		R9, #5
		LSL		R9, #5						; format buddy size
		
		CMP 	R9, R5						; MCB_BUDDY (SIZE) == MY_SIZE
		BNE		_rfree_done
		
		MOV		R6, #0x0
		STR		R6, [R1]					; zero this block
		
		LSL		R5, #1						; MY_SIZE *= 2
		STR		R5, [R2]					; set even buddy to double size
		
		MOV		R0, R2						; update return address to even buddy
		MOV		R1, R0
		
		BL		_rfree
		B		_rfree_done

_rfree_invalid

		MOV		R0, #0

_rfree_done
		
		POP		{lr}
		BX		lr
		
		END
			
			
			
			
			