;-------------------------------------------------------------------------------
; Updates the sprite XY for the player ship and run the move landscape and 
; radar update routines to reflect the change in land position of the player.
;-------------------------------------------------------------------------------
Player_UpdateShipSprite
        dec shipUpdateCounter
        beq .UpdateShipPosition
        rts
.UpdateShipPosition
        lda #SHIP_UPDATE_RATE
        sta shipUpdateCounter
        lda shipSpriteFrame
        sta SPRPTR0 
        inc SPRMC0
        lda shipY
        sta SPRY0
        lda shipX
        clc
        asl
        sta SPRX0
        bcs .SetShipXMSB
        lda SPRXMSB
        and #SPR_SHIP_MASK_OFF
        sta SPRXMSB
        jmp .CheckShipSpeed
.SetShipXMSB
        lda SPRXMSB
        ora #SPR_SHIP_MASK_ON
        sta SPRXMSB
.CheckShipSpeed
        lda shipSpeed
        cmp #255
        bne .DecreaseShipSpeedCounter
        lda #SHIP_SPEED_RATE
        sta shipSpeedCounter
        rts
.DecreaseShipSpeedCounter
        dec shipSpeedCounter
        beq .ResetShipSpeedCounter
        rts
.ResetShipSpeedCounter
        lda shipSpeed
        sta shipSpeedCounter
        lda shipState
        bne .ExitUpdateShipSprite
        dec landscapePixelCounter
        bne .UpdateLandPosition
        jsr Screen_MoveLandscape
        jsr Screen_MoveCamelRadar
        lda #8
        sta landscapePixelCounter
.UpdateLandPosition
        jsr Game_UpdateLandPosition
.ExitUpdateShipSprite
        rts

;-------------------------------------------------------------------------------
; Routine that runs if the ship has entered the change direction state. This 
; flips the player to the other side of the screen and makes the ship change 
; direction sound effect
;-------------------------------------------------------------------------------
Player_ChangeShipDirection
        lda gameTimer
        cmp #3
        beq .CheckShipState
        rts
.CheckShipState
        lda shipState
        bne .ChangeDirection
        rts
.ChangeDirection
        cmp #SHIP_STATE_TURNING
        beq .ExitChangeDirection
        lda shipDirection
        beq .FaceShipRight
        lda #SHIP_FACE_LEFT
        sta shipDirection
        jmp .ExitChangeDirection
.FaceShipRight
        lda #SHIP_FACE_RIGHT
        sta shipDirection
.ExitChangeDirection
        lda shipState
        cmp #SHIP_STATE_TURN
        bne .UpdateShipState
        lda #144
        sbc shipXOffset
        sta shipXOffset
.UpdateShipState
        lda #SHIP_STATE_TURNING
        sta shipState
        lda shipTurnSoundFlag
        beq .ShipTurnSoundOn
        lda #VOICE_OFF 
        sta VCREG1
        sta shipTurnSoundFlag
        jmp .CheckTurnOffset
.ShipTurnSoundOn
        lda #VOICE_ON_SAW
        sta VCREG1
        sta shipTurnSoundFlag
.CheckTurnOffset
        lda shipXOffset
        cmp #6
        bne .StillTurning
        lda #SHIP_STATE_READY 
        sta shipState
.StillTurning
        lda #SHIP_MOVE_RATE
        sta shipMoveCounter 
        lda #TRUE
        sta decreaseOffsetFlag
        rts

;-------------------------------------------------------------------------------
; Checks the collision register for sprite to sprite collisions. If the player 
; and camel have collided and player/camel collisions are swithced off then the
; player killed flag is set. Ignores collisions between camel, spit and bullet
;-------------------------------------------------------------------------------
Player_CamelCollisionDetection
        lda camelCollision
        beq .ExitCollisionDetection
        lda camelState
        bne .ExitCollisionDetection
.CamelActive
        lda collisionRegister
        AND #SPR_BULLET_MASK_ON
        BNE .ExitCollisionDetection
        lda collisionRegister
        AND #SPR_CAMEL_SPIT_MASK_ON
        BNE .ExitCollisionDetection
        LDA collisionRegister
        AND #SPR_SHIP_MASK_ON
        BEQ .ExitCollisionDetection
        lda #TRUE
        sta playerKilled
.ExitCollisionDetection
        rts

;-------------------------------------------------------------------------------
; Causes the yellow/black banding flash when the player has been hit by camel 
; spit (determined by the status of the damageflashflag). The flashflag counts
; down to zero and alternates between yellow and black on each count of 1
;-------------------------------------------------------------------------------
Player_DamageScreenFlash
        lda damageFlashFlag
        bne .FlashScreen
        rts
.FlashScreen
        dec damageFlashFlag
        lda damageFlashFlag
        and #1
        beq .FlashBlack
        lda #YELLOW
        sta BGCOL0
        jmp .DamageNoise
.FlashBlack
        lda #BLACK
        sta BGCOL0
.DamageNoise
        lda #VOICE_OFF
        sta VCREG2
        lda #VOICE_ON_NOISE
        sta VCREG2
        lda #BLACK
        sta BGCOL0
        rts

;-------------------------------------------------------------------------------
; Changes the ship X offset position. This is what causes the ship to drift back
; towards the edge of the screen (either left or right dependent on ship 
; direction). The ship speed table is used to change the rate of the offset 
; change (i.e. it is non-linear)
;-------------------------------------------------------------------------------
Player_DecreaseShipXOffset
        lda decreaseOffsetFlag
        bne .DecreaseOffset
        rts
.DecreaseOffset
        lda #FALSE
        sta decreaseOffsetFlag
        dec shipXOffset
        bne .SkipResetOffSet
        lda #1
        sta shipXOffset
.SkipResetOffSet
        lda shipDirection
        bne .MoveShipRight
        lda #160
        sbc shipXOffset
        sta shipX
        jmp .SetShipSpeed
.MoveShipRight
        lda #10
        adc shipXOffset
        sta shipX
.SetShipSpeed
        lda shipXOffset
        ldy #3
.DivideXOffsetLoop
        clc
        ror
        dey
        bne .DivideXOffsetLoop
        tax
        lda tbl_shipSpeeds,x
        sta shipSpeed
        rts

;-------------------------------------------------------------------------------
; Runs the explosion animation and associated sound effects whenever the player 
; dies. The 4 explosion sprites move outwards until one of them reaches the
; edge of the screen. Resets the player killed flag
;-------------------------------------------------------------------------------
Player_ShipExplosion
        lda #VOICE_OFF
        sta VCREG1
        sta VCREG2
        sta VCREG3
        lda #SPIT_STATE_INACTIVE
        sta camelSpitState
        lda #1
        sta PWL2
        lda #VOICE_ON_NOISE
        sta VCREG2
        lda #WHITE
        sta SPRCOL0
        lda #FALSE
        sta SPRMCS
        lda #EXPLOSION_FRAME1
        sta SPRPTR0
        ldy #0
.UpdateShipFrameDelay
        dey
        bne .UpdateShipFrameDelay
        ldx #0
.ExplosionFrameUpdateLoop
        stx BDCOL
        ldy #0
.ExplosionFrameDelay 
        dey
        bne .ExplosionFrameDelay
        cpx #160
        bne .SkipUpdateExplosionFrame
        inc SPRPTR0
.SkipUpdateExplosionFrame
        cpx #80
        bne .SkipUpdateExplosionFrame2
        inc SPRPTR0
.SkipUpdateExplosionFrame2
        dex
        bne .ExplosionFrameUpdateLoop
        lda #BLACK
        sta BDCOL
        lda #EXPLOSION_FRAME1
        sta SPRPTR0
        sta SPRPTR1
        sta SPRPTR2
        sta SPRPTR3
        lda #WHITE
        sta SPRCOL1
        sta SPRCOL2
        sta SPRCOL3
        lda #SPR_EXPLOSION_MASK_ON
        sta SPRYEX
        sta SPRXEX
        sta SPREN
        lda shipX
        sta explosionX1
        sta explosionX2
        sta explosionX3
        sta explosionX4
        lda shipY
        sta explosionY1
        sta explosionY2
        sta explosionY3
        sta explosionY4
        lda #EXPLOSION_RATE
        sta explosionCounter
.ExplosionX1Update
        lda explosionX1
        beq .ExplosionX2Update
        inc explosionX1
.ExplosionX2Update
        lda explosionX2
        beq .ExplosionX3Update
        inc explosionX2
.ExplosionX3Update
        lda explosionX3
        beq .ExplosionX4Update
        dec explosionX3
.ExplosionX4Update
        lda explosionX4
        beq .ExplosionY1Update
        dec explosionX4
.ExplosionY1Update
        lda explosionY1
        beq .ExplosionY2Update
        inc explosionY1
.ExplosionY2Update
        lda explosionY2
        beq .ExplosionY3Update
        dec explosionY2
.ExplosionY3Update
        lda explosionY3
        beq .ExplosionY4Update
        inc explosionY3
.ExplosionY4Update
        lda explosionY4
        beq .EnableExplosionSprites
        dec explosionY4
.EnableExplosionSprites
        ldy #0
.ExplosionSpriteDelayLoop
        dey
        bne .ExplosionSpriteDelayLoop
        ldx #2
.CheckNextExplosionY
        lda explosionY1-1,x
        bne .UpdateExplosionSpriteX
        dex
        bne .CheckNextExplosionY
        jmp .ExplosionEnded
.UpdateExplosionSpriteX
        ldx #4
.ExplosionSpriteLoop
        stx zpTemp1
        txa
        clc
        asl
        sta zpTemp2
        lda explosionY1-1,x
        ldx zpTemp2
        sta SPRX0-1,x
        ldx zpTemp1
        lda #1
.SpriteMaskLoop
        asl 
        dex
        bne .SpriteMaskLoop
        ror 
        sta zpTemp3
        ldx zpTemp1
        lda explosionX1-1,x
        clc
        asl
        ldx zpTemp2
        sta SPRX0-2,x
        bcc .ClearExplosionXMSB
        lda SPRXMSB
        ora zpTemp3
        sta SPRXMSB
        jmp .NextExplosionSprite
.ClearExplosionXMSB
        lda zpTemp3
        eor #255
        and SPRXMSB
        sta SPRXMSB
.NextExplosionSprite
        ldx zpTemp1
        dex
        cpx #255
        bne .ExplosionSpriteLoop
        lda #VOICE_OFF
        sta VCREG2
        lda #VOICE_ON_NOISE
        sta VCREG2
        dec explosionCounter
        beq .ExplosionEnded
        jmp .ExplosionX1Update
.ExplosionEnded
        lda #FALSE
        sta SPREN
        sta playerKilled
        rts

;-------------------------------------------------------------------------------
; Checks the number of lives remaining for each player. In a two player game
; this sets the switch player flag if the other player is still alive. Sets
; the game over flag if both players have no lives left
;-------------------------------------------------------------------------------
Player_CheckLives
        lda playerTurn
        cmp #2
        beq .DecreasePlayer2Lives
        dec player1Lives
        lda player2Lives
        bne .SwitchToNextPlayer
        lda player1Lives
        beq .NoLivesLeft
        jmp .ExitCheckLives
.DecreasePlayer2Lives
        dec player2Lives
        lda player1Lives
        bne .SwitchToNextPlayer
        lda player2Lives
        beq .NoLivesLeft
        jmp .ExitCheckLives
.NoLivesLeft
        lda #TRUE
        sta gameOver
        rts
.SwitchToNextPlayer
        lda #TRUE
        sta switchPlayers
.ExitCheckLives
        rts


