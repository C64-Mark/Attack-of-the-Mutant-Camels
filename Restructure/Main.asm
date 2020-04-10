*=$0801
        byte $0b, $08, $bf, $07, $9e, $32, $30, $36, $31


*=$080D
Start
        jsr Initialise

GameLoop
        jsr GameFlow_Update
        jmp GameLoop

