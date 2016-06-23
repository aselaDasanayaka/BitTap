@ ARM Assembly - Project 1
@
@	E/12/047 
@	E/12/050
@	E/12/058
@
@ Bittap Algorithm

	.text 	
	.global main
	
main:

	sub sp, sp, #4
	str lr, [sp, #0]
	
		
	@----------create stack for varibles--------------------------------------------
	
	sub sp,sp,#800			@ allocate stack for pattren mask and text
	
	@*******************************************************************************
	
	@------------Enter pattren------------------------------------------------------
	
	ldr r0,=ptninp			
	bl printf			@ printf for enter pattren
	
	ldr r0,=inpstr
	add r1,sp,#512			@ point stack for scan pattren
	bl scanf
	
	add r0, sp,#512
	bl  strlen			@ find length of pattren
	
	mov r10,r0			@ store pattren length in reg. 10
	
	@*********************************************************************************
	
	@--------------Check pattren is large or empty------------------------------------
	
		@ 	if (pattern[0] == '\0') return text;
		@ 	if (m > 31) return "The pattern is too long!";
	
	@---------------------------------------------------------------------------------

	cmp r10,#0			@ check pattren is empty then quit
	beq ptnempty	
	
	cmp r10,#32			@ check pattren is larger than 32
	bge ptnlarge	
	
	@**********************************************************************************
		
	@-------------------Initialize pattren mask----------------------------------------

		@ 	R = ~1;
    		@ 	/* Initialize the pattern bitmasks */
     		@ 	for (i=0; i <= CHAR_MAX; ++i)
       		@ 	pattern_mask[i] = ~0;

	@----------------------------------------------------------------------------------
	
	mov r2,#0			@ i=0
	mov r3,#0
	mvn r3,r3
	
	loopptn1:
		cmp r2,#512		@ i < mask length
		beq end1		@ if i==512 end initialization
		str r3,[sp,r2]		@ store ffffffff in mask bytes	
		add r2,r2,#4		@ i=i+4 integer is size in 4 bytes
		
		b loopptn1	
	end1:

	@********************************************************
			
	@--------------Fill pattren mask-------------------------
	
		@	for (i=0; i < m; ++i)
       		@	pattern_mask[pattern[i]] &= ~(1UL << i);
	
	@--------------------------------------------------------
	
	mov r1,#0         	@ i=0
	@add r2,sp,#508
	mov r3,#4
	add r4,sp,#512		@move sp to r4
	
	
	
	loopfill:
		cmp r1,r10		@  check i<m
		beq end2		@  if equal loop ends		
		mov r0,#1		@ r0 = 1UL
		mvn r5,r0,lsl r1	@ @ r5 = ~(1UL << r0)		
		add r1,r1,#1		@ i++		
		ldrb r6,[r4,#0]		@ r6 = pattern[k]						
		add r4,r4,#1		@ k++
		mul r7,r6,r3		@ r6*4 as each index (0-127 )is need 4bytes .r3=4					
		ldr r8,[sp,r7]		@ pattern_mask[pattern[i]]=r8 where r7=pattern[i]		
		and r8,r8,r5		@ pattern_mask[pattern[i]] &= ~(1UL << i);		
		str r8,[sp,r7]
		
		b loopfill
			
	end2:	
	
	@********************************************************
		
	@----------------Enter text------------------------------
					
	ldr r0,=txtinp  		 
	bl printf			@ pritf for enter text
	
	add r1,sp,#544			@ point stack to r1
	ldr r0,=inpstr
	bl scanf			@ scan text
	
	add r0,sp,#544
	bl strlen			@ find text length
	mov r11,r0			@ store text length in re. 11
			
	@*************************************************************
	
	@------------------------Compare mask and text----------------
	
		@ for (i=0; text[i] != '\0'; ++i) {
         	@ /* Update the bit array */
         	@ R |= pattern_mask[text[i]];
         	@ R <<= 1; 
         	@ if (0 == (R & (1UL << m)))
           	@ return (text + i - m) + 1;
     		@ }
	
	@-------------------------------------------------------------
	
	mov r1,#0  		@ i=0
	add r2,sp,#544		@ text sp is in r2
	mov r4,#4
	mvn r7,#1		@ R = ~1;
	
	loopcomp:
		cmp r1,r11	@ i<text length
		bge end3		
		
		ldrb r3,[r2,#0]	@ r3= text[k]  k= 0,1,2,....		
		add r2,r2,#1	@ k++  0<= k <= text.length						
		mul r5,r3,r4	@ finding place at mask	
		ldr r6,[sp,r5]  @ load mask value to r6 (r6= pattern_mask[text[i]])
		orr r7,r7,r6	@ r7 = (R |= pattern_mask[text[i]];)						
		lsl r7,r7,#1	@ shift left R by 1						
		mov r8,#1	@ r8 = 00000001  in hexadecimal
		lsl r9,r8,r10	@ r9 = (1UL << m)						
		and r0,r9,r7	@ and new R and 1UL << m  (r0 = R & (1UL << m))
											
		cmp r0,#0 	@ compare r0 value and 0
		beq place	@ if equal print result
						
		add r1,r1,#1	@ i++
		b loopcomp
	
	end3:
		ldr r0,=notxt	@ If pattren is not there print no match found
		bl printf
		b exit
		
	place :			
		sub r2,r1,r10  @ if pattren is found calculate place 
		add r2,r2,#1   @ place = i - m + 1
		add r1,sp,#512 @ point r1 to pattren
		add r3,sp,#544 @ point r3 in to text
		ldr r0,=pos    @ print possition
		bl printf
		b exit					
	@*************************************************************
						
	@-------------------------- String length finding function-------------

	strlen:
		sub	sp, sp, #4
		str	lr, [sp, #0]
		mov	r1, #0	@ length counter
	loop:
		ldrb	r2, [r0, #0]
		cmp	r2, #0
		beq	endLoop
		add	r1, r1, #1	@ count length
		add	r0, r0, #1	@ move to the next element in the char array
		b	loop

	endLoop:
		mov	r0, r1		@ to return the length
		ldr	lr, [sp, #0]
		add	sp, sp, #4
		mov	pc, lr

	@*****************************************************************************	
	
	ptnempty:
		ldr r0,=oupptnempty  	@ print if pattren is empty
		bl printf
		b exit
		
	ptnlarge:
		ldr r0,=optptnlarge	@ print if pattren is larger than 32
		bl printf
		b exit	
	
	@-----------Relese stack------------------------------------------------------	
	exit:
		add sp,sp,#800
	
	@*****************************************************************************
	
	@ --------------------	
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr
	
	.data	@ data memory

ptninp: .asciz"Enter the pattern : "
inpstr: .asciz"%s"
txtinp: .asciz"Enter the text : "
oupptnempty: .asciz"Pattren is empty ! \n"
optptnlarge: .asciz"Pattren is too large !\n"
notxt: .asciz"No match found\n"
pos: .asciz "%s is at position %d in the text %s\n"
