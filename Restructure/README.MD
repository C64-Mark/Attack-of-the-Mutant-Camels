# Attack of the Mutant Camels (Restructure)  
*(c) Jeff Minter, LlamaSoft*  

This is a restructure of the original, keeping the gameplay exactly the same as the original with the following code changes:  

* All fragmented routines joined back together into coherent singular routines  
* Redundancy and orphaned code removed  
* Zeropage variable space rationalised and re-organised  
* Minor bug fixes to code  
* "spit bomb" sprite animation added back in (it seemed an error in the code stopped this sprite from showing as it should)
* Joystick switched to port 2
* Pause is now just F1, no need to press Commodore key alongside this
* Some code simplification
* Some overlapping routines rationalised into single routines
* Gameflow implemented  

Code tweaks have led to the overall game running slightly faster, so the various in-game timers should probably be tweaked to bring the speed more in line with the original
