		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _bzero( void *s, int n )
; Parameters
;	s 		- pointer to the memory location to zero-initialize
;	n		- a number of bytes to zero-initialize
; Return value
;   none
		EXPORT	_bzero
_bzero
		; r0 = s
		; r1 = n
		PUSH {r1-r12,lr}		
		; you need to add some code here for part 1 implmentation
;;;;;		
		
			MOV		R2, #0
		
b_loop		CMP		R1, #1
			BLT		b_return
			
			STRB 	R2, [R0], #1
			SUB		R1, R1, #1
			
			B		b_loop
			
b_return 	POP {r1-r12,lr}	
			BX		lr



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; char* _strncat( char* dest, char* src, int size )
; Parameters
;   dest 	- pointer to the destination array
;	src		- pointer to string to be appended
;	size	- Maximum number of characters to be appended
; Return value
;   dest
		EXPORT	_strncat
_strncat
		; r0 = dest
		; r1 = src
		; r2 = size
		PUSH {r1-r12,lr}		
		; you need to add some code here for part 1 implmentation
		POP {r1-r12,lr}	
		BX		lr
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; char* _strncpy( char* dest, char* src, int size )
; Parameters
;   dest 	- pointer to the buffer to copy to
;	src		- pointer to the zero-terminated string to copy from
;	size	- a total of n bytes
; Return value
;   dest
		EXPORT	_strncpy
_strncpy
		; r0 = dest
		; r1 = src
		; r2 = size
		; r3 = a copy of original dest
		; r4 = src[i]
			
			MOV		R3, R0

str_loop	CMP		R2, #0
			BEQ		fill_null
			
			LDRB	R4, [R1], #1
			CMP		R4, #0
			BEQ		fill_null

			STRB	R4, [R0], #1
			SUBS	R2, R2, #1
			B		str_loop
			
fill_null	CMP		R2, #0
			BEQ		str_return
			
;store_null	MOV		R4, #0
;			STRB	R4, [R0], #1
;			SUBS	R2, R2, #1
;			
;			CMP		R2, #0
;			BNE		store_null
			
str_return	MOV		R0, R3
			MOV		PC, LR
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _malloc( int size )
; Parameters
;	size	- #bytes to allocate
; Return value
;   void*	a pointer to the allocated space
		EXPORT	_malloc
_malloc
		; r0 = size
		PUSH {r1-r12,lr}		
		; you need to add two lines of code here for part 2 implmentation
		MOV 	R7, #1
		SVC		#0x0
		
		POP {r1-r12,lr}	
		BX		lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _free( void* addr )
; Parameters
;	size	- the address of a space to deallocate
; Return value
;   none
		EXPORT	_free
_free
		; r0 = addr
		PUSH {r1-r12,lr}		
		; you need to add two lines of code here for part 2 implmentation
		MOV		R7, #2
		SVC		#0x0
		
		POP {r1-r12,lr}	
		BX		lr
		
		END