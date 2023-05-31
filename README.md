# MIPS-Doodle-jump

CSC 312 (Computer Architeture)
MIPS Project
Notre Dame University
Completion date: 13 May 2023 

*Notes: 
1) This project was an assignment done by a group of 2. 
2)"DA3 SHADY" which is in Arabic and it means "Shady is lost", the idea is if "Shady" falls off the platform then he is "lost"

*Story of the Game:
Shady is lost, he needs to find his family. He must jump through all the platforms to reach them.
 Can you help him?
The game is inspired by Fayrouz’s Hit song “Shady” (The refrain of the song is "Da3 Shady")
LINK: https://youtu.be/D7AjOZctfTA


*Bitmap Configuration:
•	Unit width in pixels: 8
•	Unit height in pixels: 8
•	Display width in pixels: 256
•	Display height in pixels: 256
•	Base Address for Display: 0x10008000 ($gp)


*Running The Game:
 Make sure to have the bitmap display connected to MARS with the configuration above along with the Keyboard and Display MMIO simulator.
Playing The Game:
•	Press “D” to move right.
•	Press “A” to move left.

IMPORTANT WARNING: Don’t Hold/Long press A or D because MARS will crash.
•	Don’t fall off the platforms or you’ll fall in the lava which will kill Shady.
•	The platforms get smaller with time.
•	Score will be displayed at the top left while in the game, and the end score will also be displayed at the end, along with the hit line of the song “Da3 Shady” with its music.


How the Work was split:
Difficulty updates with the related procedures were done by both of us.
Anthony Lahoud (Anthonylhd2):
o	Game Score Display
o	Game Score Calculation
o	End score Display
o	End Message Display
o	Background Color
o	End of the program (Death of player)

•	Anthony Nasry Massaad(AnthonyNMassaad):
o	Sprite and its movement
o	Music
o	User Input
o	End Background (Lava)
o	Lava at the bottom of the screen 
o	Platforms
