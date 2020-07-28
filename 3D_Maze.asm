;#r0# = {0-None}{1-FWD}{2-LEFT}{3-RIGHT}{4-BACK}
;-r1- = X location (0-7)
;-r2- = Y location (0-7)
;-r3- = Direction - {0-D-S}{1-L-W}{2-U-N}{3-R-E}
;-r4- = Display byte #1
;-r5- = Display byte #2

;-r12-= Pointer to maze goal
;-r13-= Pointer to maze data

entry_point:
		;mov		r1, 0x10
.r_mkey:test	r1, 0x10
		jz		.r_mkey
		sub		r1, 0x10
		mov		r12, [gl_ptr+r1]
		mov		r13, [mz_ptr+r1]
.reset:	mov		r1, 0
		mov		r2, 0
		mov		r3, 0
		mov		r4, 0
		mov		r5, 0
		call	render
		call	send_display
.r_key:	cmp		r0, 0
		je		.r_key
		mov		r6, r0
		add		r6, .tab
		jmp		r6
.tab:	jmp		.r_key
		jmp		.fwd
		jmp		.left
		jmp		.right
		jmp		.back
.fwd:	test	r4, 2	;#1 1
		jz		.fwd1
.fwd0:	call	send_display
		jmp		.r_key
.fwd1:	add		r1, [dir_x+r3]
		add		r2, [dir_y+r3]
		jmp		.m_done
.left:	sub		r3, 1
		and		r3, 3
		jmp		.m_done
.right:	add		r3, 1
		and		r3, 3
		jmp		.m_done
.back:	add		r3, 2
		and		r3, 3
		;jmp		.m_done
.m_done:call	render
		call	send_display
		jmp		.r_key

render:	;0=black 1=white	| r6=addr r7=[addr] r8=dir_bitmask r9=dir_save
		mov		r6, r2;Y
		shl		r6, 3 ;*8
		add		r6, r1;+X
		add		r6, r13;Pointer to maze data
		;<DISTANCE = 0>
		mov		r7, 1
		shl		r7, r3
		test	[r6], r7
		jz		.nblck
		mov		r4, 0xFFFF
		mov		r5, 0x0FFF
		cmp		r6, r12;Goal?
		jne		.notwon
		;cmp		r1, 7
		;jne		.notwon
		;cmp		r2, 7
		;jne		.notwon
.won:	or		r5, 0x5000	;WIN SIGN + disable DEAD END
.notwon:ret
;.notwon:jmp		.yDE
.nblck:	;<DISTANCE = 1>
		mov		r4, 0
		mov		r5, 0
		mov		r9, r3
		add		r6, [addr_r+r3]
		mov		r7, [r6]
		sub		r3, 1
		and		r3, 3
		mov		r8, 1
		shl		r8, r3
		test	r7, r8;Left
		jz		.n0L
.y0L:		or		r4, 9		;#1 0+3
			or		r5, 512		;#2 9
			jmp		.x0L
.n0L:		or		r4, 8		;#1 3
.x0L:	sub		r3, 2
		and		r3, 3
		mov		r8, 1
		shl		r8, r3
		test	r7, r8;Right
		jz		.n0R
.y0R:		or		r4, 132		;#1 2+7
			or		r5, 2048	;#2 11
			jmp		.x0R
.n0R:		or		r4, 128		;#1 7
.x0R:	cmp		r6, r12;Bottom
		jnz		.x0B
.y0B:		or		r5, 1024	;#2 10
.x0B:	mov		r3, r9
		mov		r8, 1
		shl		r8, r3
		test	r7, r8;Center
		jz		.x0C
.y0C:		or		r4, 65392	;#1 4+5+6+8+9+10+11+12+13+14+15
			or		r5, 511		;#2 0+1+2+3+4+5+6+7+8
			jmp		.break		;DONE
.x0C:	;<DISTANCE = 2>
		add		r6, [addr_r+r3]
		mov		r7, [r6]
		sub		r3, 1
		and		r3, 3
		mov		r8, 1
		shl		r8, r3
		test	r7, r8;Left
		jz		.n1L
.y1L:		or		r4, 272		;#1 4+8
			or		r5, 64		;#2 6
			jmp		.x1L
.n1L:		or		r4, 256		;#1 8
.x1L:	sub		r3, 2
		and		r3, 3
		mov		r8, 1
		shl		r8, r3
		test	r7, r8;Right
		jz		.n1R
.y1R:		or		r4, 4160	;#1 6+12
			or		r5, 256		;#2 8
			jmp		.x1R
.n1R:		or		r4, 4096	;#1 12
.x1R:	cmp		r6, r12;Bottom
		jnz		.x1B
.y1B:		or		r5, 128		;#2 7
.x1B:
		mov		r3, r9
		mov		r8, 1
		shl		r8, r3
		test	r7, r8;Center
		jz		.x1C
.y1C:		or		r4, 60928	;#1 9+10+11+13+14+15
			or		r5, 63		;#2 0+1+2+3+4+5
			jmp		.break		;DONE
.x1C:	;<DISTANCE = 3>
		add		r6, [addr_r+r3]
		mov		r7, [r6]
		sub		r3, 1
		and		r3, 3
		mov		r8, 1
		shl		r8, r3
		test	r7, r8;Left
		jz		.n2L
.y2L:		or		r4, 8704	;#1 9+13
			or		r5, 8		;#2 3
			jmp		.x2L
.n2L:		or		r4, 8192	;#1 13
.x2L:	sub		r3, 2
		and		r3, 3
		mov		r8, 1
		shl		r8, r3
		test	r7, r8;Right
		jz		.n2R
.y2R:		or		r4, 2048	;#1 11
			or		r5, 34		;#2 1+5
			jmp		.x2R
.n2R:		or		r5, 2		;#2 1
.x2R:	cmp		r6, r12;Bottom
		jnz		.x2B
.y2B:		or		r5, 16		;#2 4
.x2B:
		mov		r3, r9
		mov		r8, 1
		shl		r8, r3
		test	r7, r8;Center
		jz		.x2C
.y2C:		or		r4, 49152	;#1 14+15
			or		r5, 5		;#2 0+2
			jmp		.break		;DONE
.x2C:	;<DISTANCE = 4>
		add		r6, [addr_r+r3]
		mov		r7, [r6]
		sub		r3, 1
		and		r3, 3
		mov		r8, 1
		shl		r8, r3
		test	r7, r8;Left
		jz		.x3L
.y3L:		or		r4, 32768	;#1 15
.x3L:	sub		r3, 2
		and		r3, 3
		mov		r8, 1
		shl		r8, r3
		test	r7, r8;Right
		jz		.x3R
.y3R:		or		r5, 1		;#2 0
.x3R:	cmp		r6, r12;Bottom
		jnz		.x3B
.y3B:		or		r5, 4		;#2 2
.x3B:
.break:	mov		r3, r9
		mov		r9, r4
		and		r9, 33297		;#1 0+4+9+15
		cmp		r9, 33297
		jne		.noDE
		mov		r9, r4
		and		r9, 2116		;#1 11+6+2
		cmp		r9, 2116
		jne		.noDE
		mov		r9, r5
		and		r9, 1			;#2 0
		jz		.noDE

		mov		r6, r5
		shr		r6, 9		;#2 10 > #1 1
		xor		r6, r4
		test	r6, 2		;1
		jnz		.noDE
		mov		r6, r5
		shr		r6, 2		;#2 7 > #1 5
		xor		r6, r4
		test	r6, 32		;5
		jnz		.noDE
		mov		r6, r5
		shl		r6, 6		;#2 4 > #1 10
		xor		r6, r4
		test	r6, 1024	;10
		jnz		.noDE
		mov		r6, r5
		shl		r6, 13		;#2 1 > #1 14
		xor		r6, r4
		test	r6, 16384	;14
		jnz		.noDE
.yDE:	or		r5, 0x2000		;Enable dead end
		ret
.noDE:	or		r5, 0x1000		;Disable dead end
		ret

send_display:
		send	r0, r4
		mov		r6, 5
.wait:	sub		r6, 1
		jnz		.wait
		test	r5, 0x4000;WIN SIGN?
		jnz		.won
		send	r0, r5
		ret
.won:	send	r0, r5
.hlt:	hlt
		jmp		.hlt	;"Disable" (re)start button

;               D   L   U  R
dir_x:	dw		0, -1,  0, 1
dir_y:	dw		1,  0, -1, 0
addr_r:	dw		8, -1, -8, 1

mz_ptr:	dw		maze_00, maze_01, maze_02, maze_03, maze_04, maze_05, maze_06, maze_07
gl_ptr:	dw		gl00,    gl01,    gl02,    gl03,    gl04,    gl05,    gl06,    gl07

;8x8 - down=1 / left=2 / up=4 / right=8

;MazeGen #00
maze_00:dw	14,	6,	5,	5,	5,	12,	6,	12
		dw	10,	3,	5,	12,	14,	3,	9,	10
		dw	3,	12,	7,	1,	9,	6,	12,	10
		dw	14,	3,	5,	4,	13,	10,	2,	9
		dw	2,	5,	13,	3,	5,	9,	2,	13
		dw	3,	5,	4,	5,	5,	13,	3,	12
		dw	6,	5,	9,	6,	5,	4,	13,	10
		dw	3,	5,	5,	1,	13,	3,	5
gl00:	dw								9
;x_xx_xx_xx_xx_xx_xx_xx_x
;|.||.  .  .  .  .||.  .|
;x xx xx_xx_xx_xx xx xx x
;x xx xx_xx_xx_xx xx xx x
;|.||.  .  .||.||.  .||.|
;x xx_xx_xx xx xx_xx_xx x
;x xx_xx_xx xx xx_xx_xx x
;|.  .||.  .  .||.  .||.|
;x_xx xx_xx_xx_xx xx xx x
;x_xx xx_xx_xx_xx xx xx x
;|.||.  .  .  .||.||.  .|
;x xx_xx_xx xx_xx xx xx_x
;x xx_xx_xx xx_xx xx xx_x
;|.  .  .||.  .  .||.  .|
;x xx_xx_xx_xx_xx_xx xx_x
;x xx_xx_xx_xx_xx_xx xx_x
;|.  .  .  .  .  .||.  .|
;x_xx_xx xx_xx_xx_xx_xx x
;x_xx_xx xx_xx_xx_xx_xx x
;|.  .  .||.  .  .  .||.|
;x xx_xx_xx xx_xx xx_xx x
;x xx_xx_xx xx_xx xx_xx x
;|.  .  .  .  .||.  .  .|
;x_xx_xx_xx_xx_xx_xx_xx_x

;MazeGen #01
maze_01:dw	14,	7,	5,	5,	4,	5,	12,	14
		dw	10,	6,	5,	5,	9,	14,	3,	8
		dw	3,	9,	7,	4,	12,	2,	5,	9
		dw	7,	5,	4,	9,	11,	3,	5,	12
		dw	6,	5,	8,	6,	4,	5,	13,	10
		dw	10,	7,	9,	10,	3,	5,	5,	9
		dw	2,	12,	6,	9,	6,	5,	12,	14
		dw	11,	3,	1,	5,	9,	7,	1
gl01:	dw								9
;x_xx_xx_xx_xx_xx_xx_xx_x
;|.||.  .  .  .  .  .||.|
;x xx_xx_xx_xx xx_xx xx x
;x xx_xx_xx_xx xx_xx xx x
;|.||.  .  .  .||.||.  .|
;x xx xx_xx_xx_xx xx_xx x
;x xx xx_xx_xx_xx xx_xx x
;|.  .||.  .  .||.  .  .|
;x_xx_xx_xx xx xx xx_xx_x
;x_xx_xx_xx xx xx xx_xx_x
;|.  .  .  .||.||.  .  .|
;x_xx_xx xx_xx_xx_xx_xx x
;x_xx_xx xx_xx_xx_xx_xx x
;|.  .  .||.  .  .  .||.|
;x xx_xx xx xx xx_xx_xx x
;x xx_xx xx xx xx_xx_xx x
;|.||.  .||.||.  .  .  .|
;x xx_xx_xx xx_xx_xx_xx_x
;x xx_xx_xx xx_xx_xx_xx_x
;|.  .||.  .||.  .  .||.|
;x xx xx xx_xx xx_xx xx x
;x xx xx xx_xx xx_xx xx x
;|.||.  .  .  .||.  .  .|
;x_xx_xx_xx_xx_xx_xx_xx_x

;MazeGen #02
maze_02:dw	14,	7,	12,	6,	4,	13,	6,	12
		dw	10,	6,	9,	10,	3,	5,	8,	10
		dw	10,	10,	6,	9,	6,	12,	11,	10
		dw	10,	3,	1,	13,	10,	3,	12,	10
		dw	10,	6,	5,	5,	9,	6,	9,	10
		dw	3,	9,	6,	12,	6,	9,	7,	8
		dw	6,	5,	8,	11,	3,	5,	5,	8
		dw	3,	13,	3,	5,	5,	5,	5
gl02:	dw								9
;x_xx_xx_xx_xx_xx_xx_xx_x
;|.||.  .||.  .  .||.  .|
;x xx_xx xx xx xx_xx xx x
;x xx_xx xx xx xx_xx xx x
;|.||.  .||.||.  .  .||.|
;x xx xx_xx xx_xx_xx xx x
;x xx xx_xx xx_xx_xx xx x
;|.||.||.  .||.  .||.||.|
;x xx xx xx_xx xx xx_xx x
;x xx xx xx_xx xx xx_xx x
;|.||.  .  .||.||.  .||.|
;x xx_xx_xx_xx xx_xx xx x
;x xx_xx_xx_xx xx_xx xx x
;|.||.  .  .  .||.  .||.|
;x xx xx_xx_xx_xx xx_xx x
;x xx xx_xx_xx_xx xx_xx x
;|.  .||.  .||.  .||.  .|
;x_xx_xx xx xx xx_xx_xx x
;x_xx_xx xx xx xx_xx_xx x
;|.  .  .||.||.  .  .  .|
;x xx_xx xx_xx_xx_xx_xx x
;x xx_xx xx_xx_xx_xx_xx x
;|.  .||.  .  .  .  .  .|
;x_xx_xx_xx_xx_xx_xx_xx_x

;MazeGen #03
maze_03:dw	14,	6,	5,	5,	12,	6,	4,	12
		dw	10,	3,	5,	12,	3,	9,	10,	11
		dw	3,	12,	7,	8,	6,	13,	3,	12
		dw	14,	3,	12,	3,	8,	6,	5,	9
		dw	2,	5,	9,	7,	9,	3,	5,	12
		dw	10,	7,	4,	5,	5,	5,	12,	10
		dw	3,	5,	9,	6,	5,	13,	3,	8
		dw	7,	5,	5,	1,	5,	5,	5
gl03:	dw								9
;x_xx_xx_xx_xx_xx_xx_xx_x
;|.||.  .  .  .||.  .  .|
;x xx xx_xx_xx xx xx xx x
;x xx xx_xx_xx xx xx xx x
;|.||.  .  .||.  .||.||.|
;x xx_xx_xx xx_xx_xx xx_x
;x xx_xx_xx xx_xx_xx xx_x
;|.  .||.  .||.  .||.  .|
;x_xx xx_xx xx xx_xx_xx x
;x_xx xx_xx xx xx_xx_xx x
;|.||.  .||.  .||.  .  .|
;x xx_xx xx_xx xx xx_xx_x
;x xx_xx xx_xx xx xx_xx_x
;|.  .  .||.  .||.  .  .|
;x xx_xx_xx_xx_xx_xx_xx x
;x xx_xx_xx_xx_xx_xx_xx x
;|.||.  .  .  .  .  .||.|
;x xx_xx xx_xx_xx_xx xx x
;x xx_xx xx_xx_xx_xx xx x
;|.  .  .||.  .  .||.  .|
;x_xx_xx_xx xx_xx_xx_xx x
;x_xx_xx_xx xx_xx_xx_xx x
;|.  .  .  .  .  .  .  .|
;x_xx_xx_xx_xx_xx_xx_xx_x

;MazeGen #04
maze_04:dw	14,	6,	4,	12,	7,	4,	5,	12
		dw	10,	11,	10,	3,	12,	10,	6,	8
		dw	3,	5,	9,	14,	10,	10,	10,	10
		dw	6,	12,	6,	1,	9,	11,	10,	10
		dw	10,	3,	9,	6,	5,	5,	9,	11
		dw	10,	6,	12,	2,	12,	6,	5,	12
		dw	10,	11,	3,	9,	3,	9,	6,	8
		dw	3,	5,	5,	5,	5,	5,	9
gl04:	dw								11
;x_xx_xx_xx_xx_xx_xx_xx_x
;|.||.  .  .||.  .  .  .|
;x xx xx xx xx_xx xx_xx x
;x xx xx xx xx_xx xx_xx x
;|.||.||.||.  .||.||.  .|
;x xx_xx xx_xx xx xx xx x
;x xx_xx xx_xx xx xx xx x
;|.  .  .||.||.||.||.||.|
;x_xx_xx_xx xx xx xx xx x
;x_xx_xx_xx xx xx xx xx x
;|.  .||.  .  .||.||.||.|
;x xx xx xx_xx_xx_xx xx x
;x xx xx xx_xx_xx_xx xx x
;|.||.  .||.  .  .  .||.|
;x xx_xx_xx xx_xx_xx_xx_x
;x xx_xx_xx xx_xx_xx_xx_x
;|.||.  .||.  .||.  .  .|
;x xx xx xx xx xx xx_xx x
;x xx xx xx xx xx xx_xx x
;|.||.||.  .||.  .||.  .|
;x xx_xx_xx_xx_xx_xx xx x
;x xx_xx_xx_xx_xx_xx xx x
;|.  .  .  .  .  .  .||.|
;x_xx_xx_xx_xx_xx_xx_xx_x

;MazeGen #05
maze_05:dw	14,	6,	5,	4,	13,	6,	4,	13
		dw	10,	2,	12,	11,	6,	9,	3,	12
		dw	10,	11,	2,	5,	9,	6,	5,	8
		dw	3,	12,	10,	6,	5,	9,	14,	10
		dw	6,	9,	11,	2,	5,	12,	2,	9
		dw	3,	5,	12,	10,	6,	9,	3,	12
		dw	6,	5,	9,	11,	10,	6,	13,	10
		dw	3,	5,	5,	5,	9,	3,	5
gl05:	dw								9
;x_xx_xx_xx_xx_xx_xx_xx_x
;|.||.  .  .  .||.  .  .|
;x xx xx_xx xx_xx xx xx_x
;x xx xx_xx xx_xx xx xx_x
;|.||.  .||.||.  .||.  .|
;x xx xx xx_xx xx_xx_xx x
;x xx xx xx_xx xx_xx_xx x
;|.||.||.  .  .||.  .  .|
;x xx_xx xx_xx_xx xx_xx x
;x xx_xx xx_xx_xx xx_xx x
;|.  .||.||.  .  .||.||.|
;x_xx xx xx xx_xx_xx xx x
;x_xx xx xx xx_xx_xx xx x
;|.  .||.||.  .  .||.  .|
;x xx_xx_xx xx_xx xx xx_x
;x xx_xx_xx xx_xx xx xx_x
;|.  .  .||.||.  .||.  .|
;x_xx_xx xx xx xx_xx_xx x
;x_xx_xx xx xx xx_xx_xx x
;|.  .  .||.||.||.  .||.|
;x xx_xx_xx_xx xx xx_xx x
;x xx_xx_xx_xx xx xx_xx x
;|.  .  .  .  .||.  .  .|
;x_xx_xx_xx_xx_xx_xx_xx_x

;MazeGen #06
maze_06:dw	14,	6,	4,	12,	6,	5,	5,	12
		dw	10,	11,	10,	11,	3,	12,	6,	8
		dw	3,	12,	10,	6,	12,	10,	10,	11
		dw	14,	10,	3,	9,	3,	9,	3,	12
		dw	2,	9,	6,	5,	5,	12,	6,	8
		dw	3,	5,	9,	6,	12,	3,	9,	10
		dw	6,	4,	5,	9,	3,	13,	6,	9
		dw	11,	3,	5,	5,	5,	5,	1
gl06:	dw								13
;x_xx_xx_xx_xx_xx_xx_xx_x
;|.||.  .  .||.  .  .  .|
;x xx xx xx xx xx_xx_xx x
;x xx xx xx xx xx_xx_xx x
;|.||.||.||.||.  .||.  .|
;x xx_xx xx_xx_xx xx xx x
;x xx_xx xx_xx_xx xx xx x
;|.  .||.||.  .||.||.||.|
;x_xx xx xx xx xx xx xx_x
;x_xx xx xx xx xx xx xx_x
;|.||.||.  .||.  .||.  .|
;x xx xx_xx_xx_xx_xx_xx x
;x xx xx_xx_xx_xx_xx_xx x
;|.  .||.  .  .  .||.  .|
;x xx_xx xx_xx_xx xx xx x
;x xx_xx xx_xx_xx xx xx x
;|.  .  .||.  .||.  .||.|
;x_xx_xx_xx xx xx_xx_xx x
;x_xx_xx_xx xx xx_xx_xx x
;|.  .  .  .||.  .||.  .|
;x xx xx_xx_xx_xx_xx xx_x
;x xx xx_xx_xx_xx_xx xx_x
;|.||.  .  .  .  .  .  .|
;x_xx_xx_xx_xx_xx_xx_xx_x

;MazeGen #07
maze_07:dw	14,	6,	13,	6,	5,	4,	5,	12
		dw	10,	3,	5,	8,	6,	9,	14,	10
		dw	3,	5,	12,	11,	10,	6,	9,	10
		dw	6,	13,	3,	5,	9,	10,	6,	9
		dw	2,	5,	5,	5,	12,	2,	9,	14
		dw	10,	7,	5,	12,	3,	9,	6,	9
		dw	3,	5,	5,	1,	12,	7,	1,	12
		dw	7,	5,	5,	5,	1,	5,	5
gl07:	dw								9
;x_xx_xx_xx_xx_xx_xx_xx_x
;|.||.  .||.  .  .  .  .|
;x xx xx_xx xx_xx xx_xx x
;x xx xx_xx xx_xx xx_xx x
;|.||.  .  .||.  .||.||.|
;x xx_xx_xx xx xx_xx xx x
;x xx_xx_xx xx xx_xx xx x
;|.  .  .||.||.||.  .||.|
;x_xx_xx xx_xx xx xx_xx x
;x_xx_xx xx_xx xx xx_xx x
;|.  .||.  .  .||.||.  .|
;x xx_xx_xx_xx_xx xx xx_x
;x xx_xx_xx_xx_xx xx xx_x
;|.  .  .  .  .||.  .||.|
;x xx_xx_xx_xx xx xx_xx x
;x xx_xx_xx_xx xx xx_xx x
;|.||.  .  .||.  .||.  .|
;x xx_xx_xx xx_xx_xx xx_x
;x xx_xx_xx xx_xx_xx xx_x
;|.  .  .  .  .||.  .  .|
;x_xx_xx_xx_xx xx_xx_xx x
;x_xx_xx_xx_xx xx_xx_xx x
;|.  .  .  .  .  .  .  .|
;x_xx_xx_xx_xx_xx_xx_xx_x
