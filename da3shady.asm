.data
	GPAddress: .word 0x10008000    
	
	backgroundColour: .word 0xFFA500	 #orange color
	platformColour: .word 0x5C4033		 #Dark brown
	spriteColour: .word 0xFFC0CB		 #Pink 
	red_lava: .word 0xE42217		 
	spriteColour2: .word 0xff0000		#red
	black: .word 0x000000			
	textColour: .word 0x02075d		#blue
	platforms: .space 16			#array of platforms
		 
.text

main:
	lw $t0, GPAddress	# $t0 stores $GP address which is the display address 
	la $t1, platforms # t1 = platforms
	jal ColorBackground  
	jal startingPlatforms
	
	lw $t2, 12($t1) # t2 stores location of sprite
	addi $t2, $t2, -496 #makes sprite 3 pixels above middle of lowest platform
	jal drawSprite
	
	li $t3, 0 #jump counter, if <20, jump up, if 20, jump down until lose/platform
	li $t4, 0 #score counter, score += 1 if new platform is made
	li $t5, 8 #difficulty level. Easiest is lvl 8, hardest is lvl 0
	#difficulty increases each time score goes up by 10
	li $t6, 1 #a variable to help relate score and updating difficulty 
	
mainLoop:
	jal Input  	#Detect input
	
	beq $t3, 18, GoDown	

GoUp:
	addi $t2, $t2, -128
	addi $t3, $t3, 1
	j mainLoop2
	
GoDown: #check if sprite fell down
	addi $t2, $t2, 128
	jal FellInLava
	jal checkJump

mainLoop2:
	jal checkMoveScreen
	
redrawScreen:
	jal ColorBackground
	
	jal InGameScore #difficulty adjusted here
	li $s0, 0
	addi $s0, $t0, 0  # place score at the top left
	move $s6, $s3
	jal drawDigit
	addi $s0, $s0, 16
	move $s6, $s4
	jal drawDigit
	addi $s0, $s0, 16
	move $s6, $s5
	jal drawDigit
	
	jal drawPlatforms
	jal drawSprite
	
	j mainLoop
	
Input:
	li $v0, 32
	li $a0, 50
	syscall
	lw $s0, 0xffff0000
	beq $s0, 1, checkInput #there is input
	jr $ra #no input
	
checkInput:
	lw $s1, 0xffff0004
	beq $s1, 97, InputIsA #input is A
	beq $s1, 100, InputIsD #input is D
	jr $ra #input is not A nor D
	
InputIsA:
	addi $t2, $t2, -4 #move sprite one pixel to the left
	jr $ra

InputIsD:
	addi $t2, $t2, 4 #move sprite one pixel to the right
	jr $ra

FellInLava: #check if sprite fell in the lava
	li $s0, 0
	addi $s0, $t0, 4096
	#if sprite location greater than bottom-right pixel location, end game
	bgt $t2, $s0, gameOver
	jr $ra
	
gameOver:
	j exit
	
checkJump:
	li $s0, 0
	li $s1, 4
	la $s2, 0($t1)

checkJumpLoop:
	beq $s0, $s1, checkJumpEnd
	lw $s3, 0($s2)
	li $s4, 0 #leftmost possible pixel
	li $s5, 0 #rightmost possible pixel
	li $s6, 8 #to help adjust rightmost pixel based on difficulty
	sub $s6, $s6, $t5
	mul $s6, $s6, 4
	addi $s4, $s3, -260
	addi $s5, $s3, -220
	sub $s5, $s5, $s6
	bge $t2, $s4, restartJump

checkJumpLoopCont:
	addi $s0, $s0, 1
	addi $s2, $s2, 4
	j checkJumpLoop
	
restartJump:
	bgt $t2, $s5, checkJumpLoopCont
	li $t3, 0
jumpSound:
	# add jump sound
	li $v0, 31
	li $a0, 61
	li $a1, 200
	li $a2, 100
	li $a3, 170		
	syscall	

checkJumpEnd:
	jr $ra
	
checkMoveScreen:
	li $s0, 0
	addi $s0, $t0, 896
	blt $t2, $s0, moveScreen
	jr $ra

moveScreen:
	li $s0, 0
	la $s2, 0($t1)
	addi $s0, $s2, 12
	add $s4, $t0, 3968 #location of last row
	lw $s3, 0($s0) #location of bottom platform
	addi $t2, $t2, 128 #sprite go down one row
	bge $s3, $s4, addPlatform

movePlatformsDown:
	li $s5, 0
	li $s6, 16
	li $s4, 0

movePlatformsLoop:
	beq $s5, $s6, movePlatformsEnd
	la $s7, 0($t1)
	add $s4, $s7, $s5
	lw $s3, 0($s4)
	addi $s3, $s3, 128
	sw $s3, 0($s4)
	addi $s5, $s5, 4
	j movePlatformsLoop
	
movePlatformsEnd:
	jr $ra

addPlatform:
	li $v0, 42
	li $a1, 32
	sub $a1, $a1, $t5
	syscall
	
	#multiply random number by 4
	li $s1, 4
	mul $s1, $s1, $a0
	add $s1, $t0, $s1  #location of new platform, one row above screen
	addi $s1, $s1, -128
	
	addi $t4, $t4, 1 #score increases by 1
	
	#now we want to shift the platform array
	li $s5, 12 #loop counter
	li $s6, 0 #loop counter end, we will keep adding 4.
	li $s4, 0

shiftPlatforms:
	beq $s5, $s6, shiftPlatformsEnd
	la $s7, 0($t1)
	add $s4, $s7, $s5 #platform at index ($s5/4) location
	lw $s0, -4($s4) #get previous platform	
	sw $s0, 0($s4) #store at current
	addi $s5, $s5, -4
	j shiftPlatforms

shiftPlatformsEnd:
	li $s4, 0
	la $s7, 0($t1)
	addi $s4, $s7, 0
	sw $s1, 0($s4) #store new platform at index 0 of platform array
	j movePlatformsDown

############################## DRAWING FUNCTIONS ##########################
#Backgroud coloring:
ColorBackground:
	add $s0, $t0, $zero
	li $s1, 0 #loop counter
	li $s2, 960 #loop counter end condition
	li $s4, 1024

ColorBackgroundLoop:
	beq $s1, $s2, ColorBackground2 #loop condition check
	lw $s3, backgroundColour #s3 stores background colour
	sw $s3, 0($s0) #draw current pixel
	addi $s0, $s0, 4 #increment by 4 (go to next) 
	addi $s1, $s1, 1 #increment loop counter by 1
	j ColorBackgroundLoop #back to start of loop
ColorBackground2:
	beq $s1, $s4, ColorBackgroundEnd
	lw $s5, red_lava
	sw $s5, 0($s0)
	addi $s0, $s0, 4
	addi $s1, $s1, 1
	j ColorBackground2

ColorBackgroundEnd:
	jr $ra
	
ColorBackgroundGameOver:
	add $s0, $t0, $zero
	li $s1, 0 #loop counter
	li $s2, 1024 #loop counter end condition

ColorBackgroundLoopGameOver:
	beq $s1, $s2, ColorBackgroundEndGameOver #loop condition check
	lw $s3, red_lava #s3 stores background colour
	sw $s3, 0($s0) #draw current pixel
	addi $s0, $s0, 4 #increment by 4 (go to next) 
	addi $s1, $s1, 1 #increment loop counter by 1
	j ColorBackgroundLoopGameOver #back to start of loop

ColorBackgroundEndGameOver:
	jr $ra

startingPlatforms:
	li $s0, 0 #loop counter
	li $s1, 4 #loop counter end 0-3 = 4 platforms
	li $s4, 896 #row 7, if indexing start at 0
	li $s6, 0
	add $s6, $s6, $t1
	
startingPlatformsLoop: 
	beq $s0, $s1, startingPlatformsEnd
	#generate a random number between 0 and 23, platform will have the length 9
	li $v0, 42
	li $a1, 24 
	syscall
	
	#multiply rand 4
	li $s2, 4
	mul $s3, $s2, $a0
	
	#draw the platform
	add $s5, $t0, $s4
	add $s5, $s5, $s3
	lw $s7, platformColour	# $s7 contains the platform colour 
	sw $s7, 0($s5) #first position at 0($s5)
	sw $s7, 4($s5)
	sw $s7, 8($s5)
	sw $s7, 12($s5)
	sw $s7, 16($s5)
	sw $s7, 20($s5)
	sw $s7, 24($s5)
	sw $s7, 28($s5)
	sw $s7, 32($s5) #last position at 32($s5)
	addi $s4, $s4, 1024
	addi $s0, $s0, 1
	
	#put the platform in the array of platform
	sw $s5, 0($s6)
	addi $s6, $s6, 4
	
	j startingPlatformsLoop
	

startingPlatformsEnd:
	jr $ra

drawPlatforms:
	li $s0, 0 #loop counter
	li $s1, 4 #loop counter max
	la $s2, ($t1)

drawPlatformsLoop:
	beq $s0, $s1, drawPlatformsEnd #end loop when s0 is equal to 4
	lw $s7, platformColour	# s7 stores the platform colour code
	lw $s5, 0($s2)
	li $s3, 4
	li $s4, 0
	add $s4, $s4, $t5
	addi $s4, $s4, 1
	mul $s4, $s4, $s3
	li $s3, 0

drawPlatformsLoopLoop:
	beq $s3, $s4, drawPlatformsLoop2
	add $s6, $s5, $s3
	sw $s7, 0($s6)
	addi $s3, $s3, 4
	j drawPlatformsLoopLoop

drawPlatformsLoop2:
	addi $s0, $s0, 1
	addi $s2, $s2, 4
	j drawPlatformsLoop

drawPlatformsEnd:
	jr $ra



#drawing sprite
drawSprite:
		lw $s1, spriteColour # $t0 stores the sprite colour code
		move $s0, $t2
		sw $s1, -128($s0)
		sw $s1, -256($s0)
		sw $s1, -4($s0)
		sw $s1,4($s0)
		sw $s1, -384($s0)
		sw $s1, -252($s0)
		sw $s1, -260($s0)
		sw $s1, -512($s0)
		sw $s1, -516($s0)
		sw $s1, -508($s0)
		sw $s1, -640($s0)
		
		#eyes
		lw $s2, black
		sw $s2, -644($s0)
		sw $s2, -636($s0)
		
		jr $ra	
	


#Score
InGameScore :
	lw $s1, textColour	#t1 has the color of the text
	
	#know the triple, double, and single digits of the score
	li $s2, 100
	div $t4, $s2
	mflo $s3 #hundredth
	
	li $s2, 10
	mfhi $s4  #tenth
	div $s4, $s2
	mflo $s4
	mfhi $s5  #single digit
	
	beq $s4, 0, drawInGameScoreEnd
	beq $s5, 0,  raiseDifficulty
	
drawInGameScoreEnd:
	jr $ra
#Dificulty update, the platforms get shorter the higher the score
raiseDifficulty:
	beq $t5, 0, drawInGameScoreEnd
	bne $t6, $s4, drawInGameScoreEnd
	addi $t6, $t6, 1
	addi $t5, $t5, -1
	j drawInGameScoreEnd


#Drawing the score on screen
drawDigit:
	beq $s6, 0, drawZero
	beq $s6, 1, drawOne
	beq $s6, 2, drawTwo
	beq $s6, 3, drawThree
	beq $s6, 4, drawFour
	beq $s6, 5, drawFive
	beq $s6, 6, drawSix
	beq $s6, 7, drawSeven
	beq $s6, 8, drawEight
	beq $s6, 9, drawNine
	addi $s0, $s0, 16
	jr $ra 
	
	
	
	
##########################################Final Message############################################
#drawing the letters of the Final Message: "DA3 SHADY"
drawD:

    lw $s1, textColour  #text color in s1
    #Drawing '|' of 'D' 
    sw $s1, 116($s0) 	#first point  
    sw $s1, 244($s0) 	#  116 + 128  = 244 so i can move to the next line 
    sw $s1, 372($s0)   # 244 + 128 = 372 
    sw $s1, 500($s0)   #+128
    sw $s1, 628($s0)   #+128
    sw $s1, 756($s0)   #+128
    sw $s1, 884($s0)  #+128
    #Drawing the ')' of 'D'
    sw $s1, 120($s0) 	#first point+4 so i can move one pixel to the right  
    sw $s1, 252($s0) 	# +128+4 
    sw $s1, 384($s0)   # +128+4
    sw $s1, 512($s0)   # +128
    sw $s1, 640($s0)   # +128
    sw $s1, 764($s0)   #+128-4
    sw $s1, 888($s0)	#+128-4
    
    jr $ra
    
draw3:
    sw $s1, 124($s0)
    sw $s1, 128($s0) 	  
    sw $s1, 132($s0) 	 
    sw $s1, 264($s0)   
    sw $s1, 392($s0)   
    sw $s1, 516($s0)
    sw $s1, 512($s0)
    sw $s1, 508($s0)
    sw $s1, 648($s0)
    sw $s1, 776($s0)
    sw $s1, 900($s0)
    sw $s1, 896($s0)
    sw $s1, 892($s0)
 
    jr $ra
	
drawA:
    lw $s1, textColour
    #first drawing the '/\' of 'A'
    sw $s1, 876($s0)	#first point on  line 7 (-20+(128*7))
    sw $s1, 748($s0) 	#  876 - 128 = 748
    sw $s1, 620($s0) 	# 748 - 128 = 620
    sw $s1, 492($s0)   # 620 - 128 = 492
    sw $s1, 364($s0)   # 492  - 128 = 364
    sw $s1, 240($s0)   #364 - 128 + 4 = 240240 + 4 = 244
    sw $s1, 244($s0)     #240 + 4 = 244
    sw $s1, 248($s0)     #  244 + 4 = 
    sw $s1, 380($s0)     # 248 + 128 + 4 = 380
    sw $s1, 508($s0)     # 380 + 128 = 508
    sw $s1, 636($s0)     # 508 + 128 
    sw $s1, 764($s0)     # 636 + 128
    sw $s1, 892($s0)     # 764 + 128
    # drawing the '-' of 'A'
    sw $s1, 624($s0)  #876 -128 -128 + 4 (going two lines up of where the bottom of A is then moving one square to the right)
    sw $s1, 628($s0) #+4
    sw $s1, 632($s0) #+4
    jr $ra
    
drawS_SecondLine: 
	lw $s1, textColour
	sw $s1, 1228($s0) 
	sw $s1, 1232($s0)
    	sw $s1, 1236($s0) 
    	sw $s1, 1352($s0) 
    	sw $s1, 1484($s0) 
    	sw $s1, 1488($s0) 
    	sw $s1, 1620($s0) 
    	sw $s1, 1744($s0) 
    	sw $s1, 1740($s0) 
	sw $s1, 1736($s0) 
    	jr $ra
    
drawH_SecondLine:	
	lw $s1, textColour
	
	sw $s1, 1236($s0) 
	sw $s1, 1364($s0)  
	sw $s1, 1492($s0)  
	sw $s1, 1620($s0)  
	sw $s1, 1748($s0)  
	sw $s1, 1876($s0)   
	
	sw $s1, 1496($s0) 
	sw $s1, 1500($s0)
	sw $s1, 1504($s0) 
	sw $s1, 1632($s0) 
	sw $s1, 1376($s0) 
	sw $s1, 1248($s0)
	sw $s1, 1632($s0)
	sw $s1, 1760($s0)
	sw $s1, 1888($s0)
	jr $ra
drawA_secondLine:
	lw $s1, textColour
    	#first drawing the '/\' of 'A'
    	sw $s1, 1900($s0)	#first point
    	sw $s1, 1772($s0) 	#  - 128 
    	sw $s1, 1644($s0) 	# - 128 
    	sw $s1, 1516($s0)   #  - 128
    	sw $s1, 1388($s0)   # - 128 
    	sw $s1, 1264($s0)   # - 128 + 4
    	sw $s1, 1268($s0)     #+ 4 
    	sw $s1, 1272($s0)     #  4  
    	sw $s1, 1404($s0)     # 128 + 4
	sw $s1, 1532($s0)     #  + 128
    	sw $s1, 1660($s0)     # 128 
    	sw $s1, 1788($s0)     # 128
    	sw $s1, 1916($s0)     # 128
    	# drawing the '-' of 'A'
    	sw $s1, 1648($s0)  # -128 -128 + 4 (going two lines up of where the bottom of A is then moving one square to the right)
    	sw $s1, 1652($s0) #+4
    	sw $s1, 1656($s0) #+4
    	jr $ra
    	
drawD_secondLine:

    lw $s1, textColour
    #drawing the '|' in 'D'
    sw $s1, 1140($s0) 	#first point  
    sw $s1, 1268($s0) 	#+128
    sw $s1, 1396($s0)   
    sw $s1, 1524($s0)   
    sw $s1, 1652($s0)   
    sw $s1, 1780($s0)   
    sw $s1, 1908($s0)
    #drawing ')' in 'D'
    sw $s1, 1144($s0) 	  
    sw $s1, 1276($s0) 	 
    sw $s1, 1408($s0)   
    sw $s1, 1536($s0)   
    sw $s1, 1664($s0)   
    sw $s1, 1788($s0)   
    sw $s1, 1912($s0)
    
    jr $ra
drawY_secondLine:
    lw $s1, textColour
    sw $s1, 1140($s0) 	#first point  
    sw $s1, 1268($s0) 	#  128   so i can move to the next line 
    sw $s1, 1400($s0)   #  + 128 + 4 (+4 so i can move to the right)
    sw $s1, 1408($s0)   # + 8  (completing the y from above)
    sw $s1, 1284($s0)   #9+16 
    sw $s1, 1156($s0)   #+24
    
    sw $s1, 1532($s0)   # + 128+ 4 
    sw $s1, 1660($s0)	# + 128
    sw $s1, 1788($s0)	#  + 128
    sw $s1, 1916($s0)	#  + 128
    jr $ra

    
  ####################################Drawing score#######################################
#Drawing each digit
drawZero:
#drawing the upper horizontal line
	lw $s1, textColour     #Setting the color in $s1
	sw $s1, 0($s0)		#Filling 
	sw $s1, 4($s0)
	sw $s1, 8($s0)
#left vertical line
	sw $s1, 128($s0)
	sw $s1, 256($s0)
	sw $s1, 384($s0)
	sw $s1, 512($s0)
#lower horizontal line
	sw $s1, 516($s0)
	sw $s1, 520($s0)
#right vertical line
	sw $s1, 392($s0)
	sw $s1, 264($s0)
	sw $s1, 136($s0)
	jr $ra
	
drawOne:
	lw $s1, textColour
	sw $s1, 4($s0)
	sw $s1, 132($s0)
	sw $s1, 128($s0)
	sw $s1, 260($s0)
	sw $s1, 388($s0)
	sw $s1, 516($s0)
	jr $ra
	
drawTwo:
	lw $s1, textColour
	sw $s1, 0($s0)
	sw $s1, 4($s0)
	sw $s1, 8($s0)
	sw $s1, 136($s0)
	sw $s1, 256($s0)
	sw $s1, 260($s0)
	sw $s1, 264($s0)
	sw $s1, 384($s0)
	sw $s1, 520($s0)
	sw $s1, 516($s0)
	sw $s1, 512($s0)
	jr $ra
	
drawThree:
	lw $s1, textColour
	sw $s1, 0($s0)
	sw $s1, 4($s0)
	sw $s1, 8($s0)
	sw $s1, 136($s0)
	sw $s1, 256($s0)
	sw $s1, 260($s0)
	sw $s1, 264($s0)
	sw $s1, 392($s0)
	sw $s1, 512($s0)
	sw $s1, 516($s0)
	sw $s1, 520($s0)
	jr $ra
	
drawFour:
	lw $s1, textColour
	sw $s1, 0($s0)
	sw $s1, 8($s0)
	sw $s1, 128($s0)
	sw $s1, 136($s0)
	sw $s1, 256($s0)
	sw $s1, 260($s0)
	sw $s1, 264($s0)
	sw $s1, 392($s0)
	sw $s1, 520($s0)
	jr $ra
	
drawFive:
	lw $s1, textColour
	sw $s1, 0($s0)
	sw $s1, 4($s0)
	sw $s1, 8($s0)
	sw $s1, 128($s0)
	sw $s1, 256($s0)
	sw $s1, 260($s0)
	sw $s1, 264($s0)
	sw $s1, 392($s0)
	sw $s1, 520($s0)
	sw $s1, 516($s0)
	sw $s1, 512($s0)
	jr $ra
	
drawSix:
	lw $s1, textColour
	sw $s1, 0($s0)
	sw $s1, 4($s0)
	sw $s1, 8($s0)
	sw $s1, 128($s0)
	sw $s1, 256($s0)
	sw $s1, 260($s0)
	sw $s1, 264($s0)
	sw $s1, 392($s0)
	sw $s1, 520($s0)
	sw $s1, 516($s0)
	sw $s1, 512($s0)
	sw $s1, 384($s0)
	jr $ra
	
drawSeven:
	lw $s1, textColour
	sw $s1, 0($s0)
	sw $s1, 4($s0)
	sw $s1, 8($s0)
	sw $s1, 136($s0)
	sw $s1, 264($s0)
	sw $s1, 392($s0)
	sw $s1, 520($s0)
	jr $ra
	
drawEight:
	lw $s1, textColour
	sw $s1, 0($s0)
	sw $s1, 4($s0)
	sw $s1, 8($s0)
	sw $s1, 128($s0)
	sw $s1, 136($s0)
	sw $s1, 256($s0)
	sw $s1, 260($s0)
	sw $s1, 264($s0)
	sw $s1, 384($s0)
	sw $s1, 392($s0)
	sw $s1, 520($s0)
	sw $s1, 516($s0)
	sw $s1, 512($s0)
	jr $ra
	
drawNine:
	lw $s1, textColour
	sw $s1, 0($s0)
	sw $s1, 4($s0)
	sw $s1, 8($s0)
	sw $s1, 128($s0)
	sw $s1, 136($s0)
	sw $s1, 256($s0)
	sw $s1, 260($s0)
	sw $s1, 264($s0)
	sw $s1, 392($s0)
	sw $s1, 520($s0)
	sw $s1, 516($s0)
	sw $s1, 512($s0)
	jr $ra
#Drawing score at the end of the game	
drawScoreEndGame:
	lw $s1, textColour
	
	#get triple, double, and single digits
	li $s2, 100
	div $t4, $s2
	mflo $s3 #hundredth
	
	li $s2, 10
	mfhi $s4  #tenth
	div $s4, $s2
	mflo $s4
	mfhi $s5  #single digit
	
	jr $ra 



####################################################### GAME OVER #############################################################
	
exit:
	#Paint Background with Lava Color
	jal ColorBackgroundGameOver
	add $s0, $t0, 276
	# Drawing DA3
	jal drawD
	add $s0, $s0, 32	 #moving address to the right
	jal drawA
	add $s0, $s0, 12	 #moving address to the right
	jal draw3
	#Adding Music
	li $v0, 31
	li $a0, 66
	li $a1, 2000
	li $a2, 28
	li $a3, 170
	syscall

	li $v0, 32 # to sleep
	li $a0, 800 # sleep duration in ms
	syscall
	
	li $v0, 31
	li $a0, 68
	syscall
	
	li $v0, 32 # to sleep
	li $a0, 800 # sleep duration in ms
	syscall
	
	li $v0, 31
	li $a0, 69
	syscall
	
	
	
	###############################################
	#Drawing SHADY on the second line and adding Music
	jal drawS_SecondLine
	add $s0, $s0, 16
	jal drawH_SecondLine
	jal drawA_secondLine
	add $s0, $s0, 16
	jal drawD_secondLine
	add $s0, $s0, 16
	jal drawY_secondLine
	
	li $v0, 32 # to sleep
	li $a0, 200 # sleep duration in ms
	syscall
	
	li $v0, 32 # to sleep
	li $a0, 500 # sleep duration in ms
	syscall
	
	li $v0, 31
	li $a0, 69
	syscall
	

		
		
	###########################################
	#Drawing score at the endScreen
	jal drawScoreEndGame
	li $s0, 0
	addi $s0, $t0, 2712
	move $s6, $s3
	jal drawDigit
	addi $s0, $s0, 16
	move $s6, $s4
	jal drawDigit
	addi $s0, $s0, 16
	move $s6, $s5
	jal drawDigit
	li $v0, 10 #end program
	syscall