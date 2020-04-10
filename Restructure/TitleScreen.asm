;-------------------------------------------------------------------------------
; Displays the title screen and animates the AMC logo that meets in the middle
; of the screen. Waits for input from the user which is either the function
; keys to change options, or the fire button to start the game
;-------------------------------------------------------------------------------
TitleScreen_DisplayTitle
        jsr IRQ_Reset
        ldy #0
        jsr Screen_Clear
        ldy #240
.DisplayHeaderLoop
        lda txt_ScreenHeader-1,y
        sta SCREENRAM-1,y
        lda #WHITE
        sta COLOURRAM-1,y
        dey
        bne .DisplayHeaderLoop
        ldx #20
.DisplayJMPresentsLoop
        lda txt_JMPresents-1,x
        sta SCNROW8+9,x
        dex
        bne .DisplayJMPresentsLoop
        lda #SPR_AMC_LOGO_MASK_ON
        sta SPRYEX
        sta SPRXEX
        lda #0
        sta SPRMCS
        sta SPRXMSB
        lda #YELLOW
        sta SPRCOL0
        sta SPRCOL1
        sta SPRCOL2
        sta SPRCOL3
        lda #0
        sta SPRY0
        sta SPRY1
        sta SPRY2
        sta SPRY3
        lda #148
        sta SPRX0
        sta SPRX2
        lda #192
        sta SPRX1
        sta SPRX3
        lda #AMC_LOGO_SPRITE1
        sta SPRPTR0
        lda #AMC_LOGO_SPRITE2
        sta SPRPTR1
        lda #AMC_LOGO_SPRITE3
        sta SPRPTR2
        lda #AMC_LOGO_SPRITE4
        sta SPRPTR3
        lda #SPR_AMC_LOGO_MASK_ON
        sta SPREN
.AMCSpriteMoveLoop
        ldy #16
.IntroDelayLoopOuter
        ldx #0
.IntroDelayLoopInner
        dex
        bne .IntroDelayLoopInner
        dey
        bne .IntroDelayLoopOuter
        inc SPRY0
        inc SPRY1
        dec SPRY2
        dec SPRY3
        lda SPRY0
        cmp SPRY2
        bne .AMCSpriteMoveLoop
        ldx #32
.DisplayIntroTextLoop
        lda txt_AMC-1,x
        sta SCNROW15+4,x
        lda txt_GridRunner-1,x
        sta SCNROW17+4,x
        lda txt_Players-1,x
        sta SCNROW19+4,x
        lda txt_ColCamels-1,x
        sta SCNROW21+4,x
        lda txt_PressFire-1,x
        sta SCNROW23+4,x
        dex
        bne .DisplayIntroTextLoop
        lda #1
        sta startSector
.TitleOptionSelect
        lda sysKeyCode_C5
        cmp #KEY_F1
        bne .CheckF3Pressed
        jsr TitleScreen_SelectPlayers
.CheckF3Pressed
        cmp #KEY_F3
        bne .CheckF5Pressed
        jsr TitleScreen_SelectStartSector
.CheckF5Pressed
        cmp #KEY_F5
        bne .IntroWaitFire
        jsr TitleScreen_SelectCamelCollisions
.IntroWaitFire
        lda CIAPRA
        and #JOY_FIRE
        bne .TitleOptionSelect
        rts

;-------------------------------------------------------------------------------
; Changes number of players between 1 and 2 if F1 is pressed
;-------------------------------------------------------------------------------
TitleScreen_SelectPlayers
        inc SCNROW19+14
        lda SCNROW19+14
        cmp #CHAR_3
        bne .SkipResetPlayers
        lda #CHAR_1
.SkipResetPlayers
        sta SCNROW19+14
.KeyDebounce
        lda sysKeyCode_C5
        cmp #KEY_NONE
        bne .KeyDebounce
        rts

;-------------------------------------------------------------------------------
; Increments the start sector (max 31) if F3 is pressed
;-------------------------------------------------------------------------------
TitleScreen_SelectStartSector
        inc startSector
        lda startSector
        cmp #32
        beq .SelectSectorReset
.UpdateSector
        lda #CHAR_0
        sta SCNROW19+35
        sta SCNROW19+36
        ldx startSector
.ChangeSectorLoop
        inc SCNROW19+36
        lda SCNROW19+36
        cmp #CHAR_9+1
        bne .NextSectorDigit
        lda #CHAR_0
        sta SCNROW19+36
        inc SCNROW19+35
.NextSectorDigit
        dex
        bne .ChangeSectorLoop
        jmp .KeyDebounce
.SelectSectorReset
        lda #1
        sta startSector
        jmp .UpdateSector

;-------------------------------------------------------------------------------
; Sets player/camel collisions on/off if F5 is pressed
;-------------------------------------------------------------------------------
TitleScreen_SelectCamelCollisions
        lda SCNROW21+31
        cmp #CHAR_SPACE
        beq .SetCollisionsYes
        lda #CHAR_SPACE
        sta SCNROW21+31
        lda #CHAR_N
        sta SCNROW21+32
        lda #CHAR_O
        sta SCNROW21+33
        jmp .KeyDebounce
.SetCollisionsYes
        lda #CHAR_Y
        sta SCNROW21+31
        lda #CHAR_E
        sta SCNROW21+32
        lda #CHAR_S
        sta SCNROW21+33
        jmp .KeyDebounce
