;-------------------------------------------------------------------------------
; This overall game timer determines the rate at which certain routines run.
; It continually counts down from 8 to 0.
;-------------------------------------------------------------------------------
Game_DecrementTimer
        dec gameTimer
        beq .ResetGameTimer
        rts
.ResetGameTimer
        lda #8
        sta gameTimer
        rts

;-------------------------------------------------------------------------------
; Checks to see if F1 is pressed during the game and causes the game to pause.
; In pause mode the IRQ is switched off (i.e. no camel move noise or animation)
; and the border colour is set to white. F1 unpauses the came and resets the 
; IRQ and border colour.
;-------------------------------------------------------------------------------
Game_CheckPause
        lda sysKeyCode_C5
        cmp #KEY_F1
        bne .GamePauseExit
        lda #WHITE
        sta BDCOL
        jsr IRQ_Reset
.WaitForKey
        lda sysKeyCode_C5
        cmp #KEY_NONE
        bne .WaitForKey
.CheckUnpause
        lda sysKeyCode_C5
        cmp #KEY_F1
        bne .CheckUnpause
        lda #BLACK
        sta BDCOL
        jsr IRQ_Initialise
.WaitForKey2
        lda sysKeyCode_C5
        cmp #KEY_NONE
        bne .WaitForKey2
.GamePauseExit
        rts

;-------------------------------------------------------------------------------
; Checks the camel radar to see if there is a camel char at the far right char
; or the radar. If so the relevant player has their lives set to 1 and the 
; player killed flag set (so that the death routine then reduces the number of
; lives to zero and triggers a game over).
;
; The routine flashes the screen and border and displays the defences breached
; message along with triggering the relevant sound effect.
;-------------------------------------------------------------------------------
Game_CheckSectorDefences
        lda SCN_CAMELRADAR+39
        cmp #CHAR_CAMEL
        beq .SectorDefencesBreached
        rts
.SectorDefencesBreached
        lda playerTurn
        cmp #2
        beq .UpdatePlayer2Lives
        lda #1
        sta player1Lives
        jmp .DisplaySectorDefencesText
.UpdatePlayer2Lives
        lda #1
        sta player2Lives
.DisplaySectorDefencesText
        ldx #26
.SectorDefenceTextLoop
        lda txt_SectorDefences-1,x
        sta SCNROW24+5,x
        lda #CYAN
        sta COLROW24+5,x
        dex
        bne .SectorDefenceTextLoop
        ldy #0
.FlashColoursOuterLoop
        ldx #BLACK
.FlashColoursLoop
        stx BDCOL
        stx BGCOL0
        stx FREH1
        lda #VOICE_OFF
        sta VCREG1
        lda #VOICE_ON_NOISE
        sta VCREG1
        dex
        bne .FlashColoursLoop
        dey
        bne .FlashColoursOuterLoop
        lda #BLACK
        sta BDCOL
        sta BGCOL0
        lda #TRUE
        sta playerKilled
        rts

;-------------------------------------------------------------------------------
; Stores the sprite to sprite collision register in a variable each time the 
; collision timer reaches zero.
;-------------------------------------------------------------------------------
Game_UpdateCollisionRegister
        dec collisionCounter
        beq .UpdateCollisionRegister
        rts
.UpdateCollisionRegister
        lda #COLLISION_COUNTER_RATE
        sta collisionCounter
        lda SPRCSP
        sta collisionRegister
        rts

;-------------------------------------------------------------------------------
; Moves the player's land position each time the ship moves left/right. This
; is a two byte variable and when it changes it modifies a third variable
; which counts the change. When this changes to zero the check land position 
; routine is called to check if a camel should appear
;-------------------------------------------------------------------------------
Game_UpdateLandPosition
        lda shipDirection
        cmp #SHIP_FACE_LEFT
        beq .DecreaseLandPosition
        inc landPositionMinor
        bne .ExitUpdateLandPosition
        inc landPositionMajor
        lda landPositionMajor
        cmp #10
        bne .ExitUpdateLandPosition
        lda #0
        sta landPositionMajor
        jmp .ExitUpdateLandPosition
.DecreaseLandPosition
        dec landPositionMinor
        lda landPositionMinor
        cmp #255
        bne .ExitUpdateLandPosition
        dec landPositionMajor
        lda landPositionMajor
        cmp #255
        bne .ExitUpdateLandPosition
        lda #9
        sta landPositionMajor
.ExitUpdateLandPosition
        dec landPositionCounter
        beq .ResetLandPositionCounter
        rts
.ResetLandPositionCounter
        lda #3
        sta landPositionCounter
        jsr Game_CheckLandPosition
        rts

;-------------------------------------------------------------------------------
; Compares the current land position with the camel land position and also
; checks if the relevant camel is active (i.e. it hasn't already been killed)
; If a camel is in range and active, then it's X position is updated to reflect
; that it is on screen.
;-------------------------------------------------------------------------------
Game_CheckLandPosition
        ldy #0
        lda landPositionMajor
        sta zpTemp1
        lda landPositionMinor
        sta zpTemp2
.ScanForCamelLoop
        lda zpTemp2
        cmp camelPositionMinor
        beq .CamelInRange
.KeepScanning
        inc zpTemp2
        bne .SkipTmpHiByte
        inc zpTemp1
.SkipTmpHiByte
        iny
        cpy #192
        bne .ScanForCamelLoop
.NoCamelInRange
        lda #255
        sta currentEnemyID
        lda SPREN
        and #SPR_CAMEL_MASK_OFF
        sta SPREN
        rts
.CamelInRange
        lda zpTemp1
        sec
        sbc camelPositionMajor
        sta currentEnemyID
        ldx currentEnemyID
        cpx #7
        bpl .NoCamelInRange
        lda landPositionMajor
        cmp camelPositionMajor
        bmi .NoCamelInRange
        cpx #0
        beq .NoCamelInRange
        lda tbl_CamelHealth-1,x
        cmp #255
        beq .KeepScanning
        sty camelX
        rts


