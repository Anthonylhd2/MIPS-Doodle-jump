# MIPS-Doodle-jump

CSC 312 (Computer Architeture): <br />
MIPS Project <br />
Notre Dame University <br />
Completion date: 13 May 2023 <br />
<br />
Notes:<br /> 
1) This project was an assignment done by a group of 2. <br />
2)"DA3 SHADY" which is in Arabic and it means "Shady is lost", the idea is if "Shady" falls off the platform then he is "lost"<br />
<br />
*Story of the Game:<br />
Shady is lost, he needs to find his family. He must jump through all the platforms to reach them.<br />
 Can you help him?<br />
The game is inspired by Fayrouz’s Hit song “Shady” (The refrain of the song is "Da3 Shady")<br />
LINK: https://youtu.be/D7AjOZctfTA<br />
<br />

*Bitmap Configuration:<br />
•	Unit width in pixels: 8<br />
•	Unit height in pixels: 8<br />
•	Display width in pixels: 256<br />
•	Display height in pixels: 256<br />
•	Base Address for Display: 0x10008000 ($gp)<br />


*Running The Game:<br />
 Make sure to have the bitmap display connected to MARS with the configuration above along with the Keyboard and Display MMIO simulator.<br />
Playing The Game:<br />
•	Press “D” to move right.<br />
•	Press “A” to move left.<br />
<br />
IMPORTANT WARNING: Don’t Hold/Long press A or D because MARS will crash.<br />
•	Don’t fall off the platforms or you’ll fall in the lava which will kill Shady.<br />
•	The platforms get smaller with time.<br />
•	Score will be displayed at the top left while in the game, and the end score will also be displayed at the end, along with the hit line of the song “Da3 Shady” with its music.<br />


How the Work was split:<br />
Difficulty updates with the related procedures were done by both of us.<br />
Anthony Lahoud (Anthonylhd2):<br />
o	Game Score Display<br />
o	Game Score Calculation<br />
o	End score Display<br />
o	End Message Display<br />
o	Background Color<br />
o	End of the program (Death of player)<br />

•	Anthony Nasry Massaad(AnthonyNMassaad):<br />
o	Sprite and its movement<br />
o	Music<br />
o	User Input<br />
o	End Background (Lava)<br />
o	Lava at the bottom of the screen<br /> 
o	Platforms<br />
