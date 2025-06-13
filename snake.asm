.macro  getxy  %offset
        srli	t6 %offset 2
        andi	t5 t6 127
        srli	t6 t6 7
.end_macro
.macro	draw
	la	a1 len
	lw	a1 (a1)
	la	a2 zmey
loor:	bltz a1 endr
	addi	a1 a1 -1
	lw	a3 (a2)
	addi	a2 a2 4
	add	a3 a3 t2
	sw	t3 (a3)
	b	loor
endr:	la a1 food
	lw	a1 (a1)
	add	a1 a1 t2
	sw	t4 (a1)
.end_macro
.macro	snakemove
	la	a1 move
	lw	a1 (a1)
	add	a1 a1 t2
	lw	a2 (a1)
	li	a5 1
	bne	a2 t4 nofoo # skip growth if head pixel is not orange
	# food found - grow snake
	la	a0 len
	lw	a1 (a0)
	addi	a1 a1 1
	sw	a1 (a0)
	li	a5 0 # flag: tail removal
nofoo:	la a0 move # body shifting loop
	lw	a0 (a0)
	la	a2 zmey
	la	a1 len
	lw	a1 (a1)
mloo:	bltz a1 done
	addi	a1 a1 -1
	lw	a3 (a2)
	sw	a0 (a2)
	addi	a2 a2 4
	mv	a0 a3
	b	mloo	
done:	beqz a5 alld # if we grew (a5=0), skip tail removal
	add	a0 a0 t2
	li	a1 0
	sw	a1 (a0)
alld:	
	
.end_macro

.data
bitmap:	.space 32768    # 128×64×4 framebuffer
move:	.space 4        # Current snake head position  
food:	.space 4        # Food position
len:	.space 4        # Snake length
nmove:	.space 4        # Next move direction
zmey:                   # Snake body positions (dynamic array)
.text
	li      a0 2
	sw      a0 0xffff0000 t0
        
	li	t3 0x00ff00 # green
	li	t4 0xff8800 # orange
	li	t2 0x10010000
	li	t5 0xFFFF0018        # Timer register address
	lw      t5 (t5)          # read time
	addi	t6 t5 100        # Add 100ms
	li      t5 0xFFFF0020    # Timer compare register
	sw      t6 (t5)          # set next interrupt time
	la      t5 handler       # interrupt handler address to t5
	csrw    t5 utvec         # se? 
	csrwi   uie 0x110        # add interrupts  
	csrwi   ustatus 1        # add user interrupts
	la	a1 zmey
	li	a0 16128 # initial snake position
	sw	a0 (a1)
	la	a1 move
	li	a0 16128 # initial head position
	sw	a0 (a1)
	la	a1 food
	li	a0 5888 # initial food position
	sw	a0 (a1)
	la	a1 nmove
	li	a0 0 # no initial movement
	sw	a0 (a1)
	draw
loop:	b	loop # loop iz semi zaloop

handler:
	csrr	a0 ucause
	andi	a0 a0 8
	beqz	a0 timehandler
	lb      a0 0xffff0004
	la	a2 nmove
        li	a1 119
        bne	a0 a1 sk1
        li	a3 -512 # up
        sw	a3 (a2)
sk1:    li	a1 97
        bne	a0 a1 sk2
        li	a3 -4 # left
        sw	a3 (a2)
sk2:    li	a1 115
        bne	a0 a1 sk3
        li	a3 512 # down
        sw	a3 (a2)
sk3:    li	a1 100
        bne	a0 a1 sk4
        li	a3 4 # right	
        sw	a3 (a2) 
sk4:	uret
timehandler:
	li	t5 0xFFFF0020       # timer register
	lw      t6 (t5)             # read timer
	addi	t6 t6 100           
	sw      t6 (t5)         # schedule next timer interrupt
	la	a0 nmove            # get player input
	la	a1 move
	lw	a0 (a0)
	lw	a2 (a1)             # load current head position
	getxy	a2              # convert to X,Y coordinates
	mv	t0 t5
	mv	t1 t6
	add	a2 a2 a0            # add movement direction
	sw	a2 (a1)             # store new head position
	getxy	a2              # convert new position to X,Y
	# boundary checking
	bltz	t5 theend       # X < 0 (left wall)
	bltz	t6 theend       # Y < 0 (top wall)  
	li	a0 127
	bgt	t5 a0 theend        # X > 127 (right wall)
	li	a0 63
	bgt	t6 a0 theend        # Y > 63 (bottom wall)
	beq	t0 t5 ok            # Check if X changed
	beq	t1 t6 ok            # Check if Y changed
	b	theend              # No movement = error
ok:	snakemove # move snake
	la	a0 zmey
	lw	a1 (a0)
	la	a0 food
	lw	a2 (a0)
	mv	a3 a1
	add	a3 a3 t2
	lw	a3 (a3)
	beq	a3 t3 theend
        bne	a1 a2 nofood # if head pixel is not green, skip food placement
rloo:	li	a7 42 # random number generator
	li	a0 0
	li	a1 8192
	ecall
	slli	a0 a0 2
	mv	a1 t2
	add	a1 a1 a0
	lw	a2 (a1)
	bnez	a2 rloo
	la	a1 food
	sw	a0 (a1)
nofood:	draw # draw snake and food
	uret
theend:	la	a0 len # game over
	lw	a0 (a0)
	li	a7 1
	ecall
	li	a7 11
	li	a0 10
	ecall
	li	a7 10
	ecall
