/*----------------------------------------------------------------
//           test logic                                         //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	mov r4, #0x31
	mov r5, #0x23

bwhile:
	cmp r4, r5
	beq test_val
	subcs r4, r4, r5
	subcc r5, r5, r4
	b bwhile

test_val :
	cmp r4, #0x7
	beq _good

_bad :
	nop
	nop
_good :
	nop
	nop
