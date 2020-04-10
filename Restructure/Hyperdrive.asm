;-------------------------------------------------------------------------------
; This routine runs the hyperdrive stage of the game. The ship and rocket are
; initialised and the hypderive engaging message is displayed. Routines are 
; called to move the ship, rocket and landscape. These routines loop until 
; either the ship reaches the end stage of hyperdrive (shipX=64) or there is 
; a collision between the ship and the rocket (using the sprite to sprite
; collision register.
;
; At the end of hyperdrive the routine runs the ship hyperdrive animation and
; the associated sound effects before setting the hyperdrive completed flag.
;-------------------------------------------------------------------------------
Hyperdrive_EngageHyperdrive
        lda #VOICE_OFF
        sta VCREG1
        sta VCREG2
        sta VCREG3
        lda #SPIT_STATE_DISABLED
        sta camelSpitState 
        lda #160
        sta shipX
        lda #SHIP_LEFT_FRAME
        sta shipSpriteFrame
        sta SPRPTR0
        lda #YELLOW
        sta SPRMC0
        lda #SPR_SHIP_AND_ROCKET_MASK_ON
        sta SPREN        
        jsr Hyperdrive_UpdateShipSprite
        ldx #40
.HyperdriveTextLoop
        lda txt_HyperdriveEngaging-1,x
        sta SCNROW4-1,x
        lda #WHITE
        sta COLROW4-1,x
        dex
        bne .HyperdriveTextLoop
        ldx #32
.HyperdriveSoundLoopMajor
        lda #0
        sta zpTemp1
        sta zpTemp2
.HyperdriveSoundLoopMinor
        lda zpTemp2
        sta FREL1
        lda zpTemp1
        sta FREH1
        lda #VOICE_OFF
        sta VCREG1
        lda #VOICE_ON_SAW
        sta VCREG1
        lda zpTemp2
        clc
        adc #48
        sta zpTemp2
        lda zpTemp1
        adc #0
        sta zpTemp1
        sta BDCOL
        cmp #255
        bne .HyperdriveSoundLoopMinor
        dex
        bne .HyperdriveSoundLoopMajor
        lda #BLACK
        sta BDCOL
        sta VCREG1
        lda SPRCSP
        lda #SHIP_FACE_LEFT
        sta shipDirection
        lda #HYPERDRIVE_PLAYER_UPDATE_RATE
        sta hyperdriveUpdatePlayerCounter
        sta hyperdriveUpdatePlayerRate
        lda #16
        sta currentEnemyID
        lda #240
        sta rocketX
        lda #SPR_ROCKET_MASK_ON
        sta SPRXEX
        lda rocketMoveRate
        sta enemyMoveCounterMajor
        lda #7
        sta enemyMoveCounterMinor
        lda #7
        sta landPositionMajor
        lda #HYPERDRIVE_MOVE_RATE
        sta hyperdriveLandscapeMoveCounter
        sta hyperdriveLandscapeMoveRate
        lda #16
        sta hyperdriveLandscapeMoveMinor
.MainHyperdriveLoop
        jsr Hyperdrive_UpdatePlayer
        jsr Hyperdrive_MoveLandscape
        jsr Hyperdrive_UpdateShipSprite
        jsr Hyperdrive_MoveRocket
        lda SPRCSP
        beq .NoCollisionWithRocket
        lda #TRUE
        sta playerKilled
        lda #FALSE
        sta hyperdriveEngaged
        rts
.NoCollisionWithRocket
        lda shipX
        cmp #64
        beq .ReachedLevelEnd
        jmp .MainHyperdriveLoop
.ReachedLevelEnd
        lda #SPR_SHIP_MASK_ON
        sta SPREN
        sta SPRXEX
        lda shipX
        cmp #224
        beq .ExitAnimateShip
        lda #1
        sta hyperdriveLandscapeMoveRate
        lda shipX
        sta SPRMC0
        adc #8
        sta SPRMC1
        lda RASTER
        sta FREH2
        lda #VOICE_OFF
        sta VCREG2
        lda #VOICE_ON_SAW
        sta VCREG2
        lda hyperdriveLandscapeMoveMinor
        cmp #1
        bne .HyperdriveUpdateLandscape
        dec shipX
.HyperdriveUpdateLandscape
        jsr Screen_MoveLandscape
        jsr Hyperdrive_MoveLandscape
        jsr Hyperdrive_UpdateShipSprite
        jmp .ReachedLevelEnd
.ExitAnimateShip
        lda #VOICE_OFF
        sta VCREG2
        LDX #0
.BlackWhiteScreenFlashLoop
        txa
        and #1
        sta BDCOL
        eor #1
        sta BGCOL0
        stx zpTemp1
        jsr Screen_MoveLandscape
        ldx zpTemp1
        lda RASTER
        sta FREH1
        lda #VOICE_OFF
        sta VCREG1
        lda #VOICE_ON_NOISE
        sta VCREG1
        dex
        bne .BlackWhiteScreenFlashLoop       
        lda #BLACK
        sta BDCOL
        sta BGCOL0
        lda #112
        sta shipY
        lda #LBLUE
        sta SPRMC1
        lda #0
        sta zpTemp1
        sta zpTemp2
.ShipHyperdriveSoundLoop
        lda zpTemp1
        sta shipX
        sta FREH1
        adc #128
        sta FREH2
        lda #VOICE_OFF
        sta VCREG1
        sta VCREG2
        lda #VOICE_ON_SAW
        sta VCREG1
        sta VCREG2
        inc SPRMC0
        jsr Hyperdrive_UpdateShipSprite
        inc zpTemp1
        lda zpTemp1
        cmp #160
        bne .ShipHyperdriveSoundLoop
        inc zpTemp2
        lda zpTemp2
        cmp #160
        beq .EndHyperdrive
        lda zpTemp2
        sta zpTemp1
        jmp .ShipHyperdriveSoundLoop
.EndHyperdrive
        lda #VOICE_OFF
        sta VCREG1
        sta VCREG2
        lda #0
        sta camelPositionMinor
        sta camelPositionMajor
        ldx #40
.HyperdriveClearTextLoop
        lda #CHAR_SPACE
        sta SCNROW4-1,X
        dex
        bne .HyperdriveClearTextLoop
        lda #SHIP_MOVE_FREQUENCY
        sta FREH1
        lda #FALSE
        sta hyperdriveEngaged
        lda #TRUE
        sta hyperdriveCompleted
        rts


Hyperdrive_UpdatePlayer
        dec hyperdriveUpdatePlayerCounter
        beq .UpdatePlayer
        rts
.UpdatePlayer
        lda hyperdriveUpdatePlayerRate
        sta hyperdriveUpdatePlayerCounter
        jsr Hyperdrive_UpdateShipSprite
        jsr Input_CheckInput
        lda #161
        sbc shipX
        sta FREH1
        lda #VOICE_OFF
        sta VCREG1
        lda #VOICE_ON_NOISE
        sta VCREG1
        rts

;-------------------------------------------------------------------------------
; Updates the ship's XY sprite registers
;-------------------------------------------------------------------------------
Hyperdrive_UpdateShipSprite       
        lda shipY
        sta SPRY0
        lda shipX
        asl
        sta SPRX0
        bcc .ResetShipXMSB
        lda SPRXMSB
        ora #SPR_SHIP_MASK_ON
        sta SPRXMSB
        rts
.ResetShipXMSB
        lda SPRXMSB
        and #SPR_SHIP_MASK_OFF
        sta SPRXMSB
        rts

;-------------------------------------------------------------------------------
; Calls the move landscape routine, but based on the hyperdrive landscape
; counter. This moves the landscape much faster than in the standard camel 
; attack level.
;-------------------------------------------------------------------------------
Hyperdrive_MoveLandscape
        dec hyperdriveLandscapeMoveMinor
        beq .CheckLandscapeMoveCounter
        rts
.CheckLandscapeMoveCounter
        lda #16
        sta hyperdriveLandscapeMoveMinor
        dec hyperdriveLandscapeMoveCounter
        beq .MoveLandscape
        rts
.MoveLandscape
        lda hyperdriveLandscapeMoveRate
        sta hyperdriveLandscapeMoveCounter
        jsr Screen_MoveLandscape
        dec shipX
        dec hyperdriveLandscapeMoveRate
        rts

;-------------------------------------------------------------------------------
; Changes the rocket position. It's X position increases until it leaves the 
; screen on the right. It's Y position is intially determined by the player
; ship position, using the raster to create a pseudo-random number so that the
; set Y position is +/- 16 of the ship Y.
;
; As the routine moves the rocket the Y position homes on the ship Y and the
; sprite frames rotate using the rocket frames table.
;-------------------------------------------------------------------------------
Hyperdrive_MoveRocket
        dec enemyMoveCounterMajor
        beq .MoveRocket
        rts
.MoveRocket
        lda rocketMoveRate
        sta enemyMoveCounterMajor
        lda rocketX
        cmp #240
        bne .IncreaseRocketX
        lda shipY
        sbc #16
        sta SPRY2
        lda RASTER
        and #31
        clc
        adc SPRY2
        sta SPRY2
.IncreaseRocketX
        inc rocketX
        lda rocketX
        asl
        sta SPRX2
        bcc .ClearRocketXMSB
        lda SPRXMSB
        ora #SPR_ROCKET_MASK_ON
        sta SPRXMSB
        jmp .SetRocketSpriteFrame
.ClearRocketXMSB
        lda SPRXMSB
        and #SPR_ROCKET_MASK_OFF
        sta SPRXMSB
.SetRocketSpriteFrame
        ldx enemyMoveCounterMinor
        lda tbl_rocketFrames-1,x
        sta SPRPTR2
        dec landPositionMajor
        beq .SetRocketHoming
.ExitMoveRocket
        rts
.SetRocketHoming
        lda SPRY2
        cmp shipY
        bpl .MoveRocketUp
        inc SPRY2
        inc SPRY2
.MoveRocketUp
        dec SPRY2
        lda #7
        sta landPositionMajor
        dec enemyMoveCounterMinor
        bne .ExitMoveRocket
        lda #7
        sta enemyMoveCounterMinor
        rts
