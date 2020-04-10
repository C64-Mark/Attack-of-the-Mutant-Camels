;-------------------------------------------------------------------------------
; Checks to see if a camel should appear on screen. If it does it sets the 
; colour of the current camel and the relevant XY position and enables the 
; 4 sprites that make up the Camel.
;-------------------------------------------------------------------------------
Camel_UpdateSprites
        lda gameTimer
        cmp #1
        beq .UpdateCamelSprites
        rts
.UpdateCamelSprites
        ldx currentEnemyID
        cpx #255
        bne .CamelSelected
        rts
.CamelSelected
        lda tbl_CamelCurrentColour-1,x
        sta SPRCOL6
        sta SPRCOL3
        sta SPRCOL4
        sta SPRCOL5
        lda SPREN
        ora #SPR_CAMEL_MASK_ON
        sta SPREN
        lda camelX
        asl
        sta SPRX4
        sta SPRX6
        bcs .SetCamelFrontXMSB
        lda SPRXMSB
        and #SPR_CAMEL_FRONT_MASK_OFF
        sta SPRXMSB
        jmp .UpdateCamelRear
.SetCamelFrontXMSB
        lda SPRXMSB
        ora #SPR_CAMEL_FRONT_MASK_ON
        sta SPRXMSB
.UpdateCamelRear
        lda camelX
        sbc #23
        asl
        sta SPRX3
        sta SPRX5
        bcs .SetCamelRearXMSB
        lda SPRXMSB
        and #SPR_CAMEL_REAR_MASK_OFF
        sta SPRXMSB
        jmp .UpdateCamelHeadFrame
.SetCamelRearXMSB
        lda SPRXMSB
        ora #SPR_CAMEL_REAR_MASK_ON
        sta SPRXMSB
.UpdateCamelHeadFrame
        lda camelHeadFrame
        sta SPRPTR4
        rts

;-------------------------------------------------------------------------------
; Updates the land position of the camels. A two byte counter is used to set the
; rate at which this occurs. The camel marker routine is called to update the
; radar to reflect the move. This routine calls the check land position routine
; to check if a camel should now appear on screen.
;-------------------------------------------------------------------------------
Camel_Move
        dec camelSpeedCounter
        beq .ResetCamelSpeedCounter
        rts
.ResetCamelSpeedCounter
        lda camelSpeed
        sta camelSpeedCounter
        dec enemyMoveCounterMinor
        bne .MoveCamel
        lda #3
        sta enemyMoveCounterMinor
.MoveCamel
        dec enemyMoveCounterMajor
        bne .ExitCamelMove
        lda #64
        sta enemyMoveCounterMajor
        jsr Screen_DisplayCamelMarker
.ExitCamelMove
        ldx currentEnemyID
        inc camelPositionMinor
        bne .SkipCamelPosMajor
        inc camelPositionMajor
.SkipCamelPosMajor
        jsr Game_CheckLandPosition
        rts

;-------------------------------------------------------------------------------
; Performs the camel dying animation (head movement, colour flash) with the 
; associated sound effect. Once the camel is dead it's health is set at 255.
; The camel radar is updated to remove the camel and the number of camels
; remaining is tested. If zero, the sector is increased and the hyperdrive
; flag is set.
;-------------------------------------------------------------------------------
Camel_Dying
        lda camelState
        bne .CamelDeathSequence
        rts
.CamelDeathSequence
        sta FREH1
        ldx camelKilledID
        sta tbl_CamelCurrentColour-1,x
        cmp #CAMEL_STATE_DYING
        bne .CamelDyingSound
        lda #CAMEL_HEAD_DYING_FRAME2
        sta camelHeadFrame
.CamelDyingSound
        lda gameTimer
        cmp #1
        beq .CheckCamelDyingState
        lda #VOICE_OFF
        sta VCREG1
        lda #VOICE_ON_TRIANGLE_RING
        sta VCREG1
        lda #CAMEL_STATE_DEAD
        sbc camelState
        sta FREH3
.CamelStillDying
        rts
.CheckCamelDyingState
        dec camelState
        bne .CamelStillDying
        lda #64
        sta FREH1
        lda #YELLOW
        sta tbl_CamelCurrentColour-1,x
        lda #255
        sta tbl_CamelHealth-1,x
        sta camelKilledID
        lda tbl_camelMarkerScreenLo-1,x
        sta zpLow
        lda #4
        sta zpHigh
        lda #CHAR_SPACE
        sta charToPlot
        jsr Screen_Plot
        lda SPREN
        and #SPR_CAMEL_MASK_OFF
        sta SPREN
        lda #CAMEL_HEAD_FRAME1
        sta camelHeadFrame
        dec camelsRemaining
        beq .LevelCleared
        rts
.LevelCleared
        inc playerSector
        lda playerSector
        cmp #32
        bne .ExitNextSector
        dec playerSector
.ExitNextSector
        jsr Initialise_ResetGameVariables
        lda #0
        sta camelPositionMinor
        sta camelPositionMajor
        jsr Screen_DisplayCamelMarker
        lda #6
        sta camelsRemaining
        lda #TRUE
        sta hyperdriveEngaged
        rts

;-------------------------------------------------------------------------------
; Tests if spit is enabled (i.e. in hyperdrive this is disabled) and then uses
; the relevant counters to determine if the camel is ready to spit. The TI
; system variable is utilised to alse determine the spit rate for the camel.
; The Y of the spit is fixed at camel head height and X follows the position of
; the camel. This is compared to the ship X position to determine the direction
; (i.e. left/right) of the spit. The spit bomb counter is used to determine if 
; the next spit should be a 'bomb' or not. This is the spit that kills the 
; player instantly.
;
; If a spit is already active, this routine will move the spit, homing in on 
; the ship. The ship x will continue to determine the direction of the spit.
; When the spit is within 9 Xpos of the ship the routine then checks to see if 
; the spit is +/- 3 Ypos and this determins if a collision has occurred. If a 
; collision occurs then either the player health decreases by 1, or in the case
; of a spit 'bomb' the player is killed. The player hit flash flag is set.
;-------------------------------------------------------------------------------
Camel_Spit
        lda camelSpitState
        cmp #SPIT_STATE_DISABLED
        beq .ExitSpit
        dec camelSpitDelayCounter
        beq .UpdateSpit
.ExitSpit
        rts
.UpdateSpit
        lda camelSpitDelayRate
        sta camelSpitDelayCounter
        lda camelSpitState
        bne .CheckSpitBomb
        lda #136
        sta SPRY2
        lda #144
        sta camelSpitSoundFrequency
Camel_RandomiseSpit
        lda sysTI_A2
        cmp #2
        bmi .SpitSelected
        rts
.SpitSelected
        lda currentEnemyID
        cmp #255
        bne .EnemyActive
        rts
.EnemyActive
        lda camelX
        adc #16
        sta camelSpitX 
        lda shipX
        clc
        ror
        sta zpTemp1
        lda camelSpitX 
        clc
        ror
        cmp zpTemp1
        bpl .SpitDirectionLeft
        lda #SPIT_DIRECTION_RIGHT
        jmp .SetSpitActive
.SpitDirectionLeft
        lda #SPIT_DIRECTION_LEFT
.SetSpitActive
        sta camelSpitDirection
        lda #SPIT_STATE_ACTIVE
        sta camelSpitState
        lda SPREN
        ora #SPR_CAMEL_SPIT_MASK_ON
        sta SPREN
        lda #CAMEL_SPIT_FRAME1
        sta camelSpitFrame
        dec camelSpitBombRateCounter
        beq .SpitBombEnable
        rts
.SpitBombEnable
        lda #SPIT_STATE_BOMB
        sta camelSpitState
        lda camelSpitBombRate
        sta camelSpitBombRateCounter
        lda #CAMEL_SPIT_BOMB_FRAME1
        sta camelSpitFrame
        rts
.CheckSpitBomb
        lda camelSpitState
        cmp #SPIT_STATE_BOMB
        bne .CheckSpitDirection
        lda camelSpitSoundFrequency
        adc #87
        sta camelSpitSoundFrequency
        sta FREH2
        lda #VOICE_OFF
        sta VCREG2
        lda #VOICE_ON_SAW
        sta VCREG2
        lda #1
        sta camelSpitRateCounter
.CheckSpitDirection
        lda camelSpitDirection
        bne .SpitLeft
        inc camelSpitX
        inc camelSpitX
.SpitLeft
        dec camelSpitX
        lda camelSpitX
        cmp #4
        beq .SetSpitInactive
        cmp #176
        beq .SetSpitInactive
        jmp .UpdateSpitY
.SetSpitInactive
        lda #SPIT_STATE_INACTIVE
        sta camelSpitState
        lda SPREN
        and #SPR_CAMEL_SPIT_MASK_OFF
        sta SPREN
        lda #VOICE_OFF
        sta VCREG2
        lda #CAMEL_WALK_FREQUENCY
        sta FREH2
        rts
.UpdateSpitY
        dec camelSpitRateCounter 
        bne .UpdateSpitX
        lda camelSpitRate
        sta camelSpitRateCounter 
        lda SPRY2
        cmp shipY
        bpl .MoveCamelSpitUp
        inc SPRY2
        inc SPRY2
.MoveCamelSpitUp
        dec SPRY2
.UpdateSpitX
        lda camelSpitX
        clc
        asl
        sta SPRX2
        bcc .ResetCamelSpitXMSB
        lda SPRXMSB
        ora #SPR_CAMEL_SPIT_MASK_ON
        sta SPRXMSB
        jmp .UpdateCamelSpitFrame
.ResetCamelSpitXMSB
        lda SPRXMSB
        and #SPR_CAMEL_SPIT_MASK_OFF
        sta SPRXMSB
.UpdateCamelSpitFrame
        inc camelSpitFrame
        lda camelSpitFrame
        cmp #CAMEL_SPIT_BOMB_FRAME4+1
        bne .CheckSpitFrame
        lda #CAMEL_SPIT_BOMB_FRAME1
        sta camelSpitFrame
        jmp .MakeSpitSound
.CheckSpitFrame
        cmp #CAMEL_SPIT_FRAME2+1
        bne .MakeSpitSound
        lda #CAMEL_SPIT_FRAME1
        sta camelSpitFrame
.MakeSpitSound
        sta SPRPTR2
        dec camelSpitSoundFrequency
        lda camelSpitSoundFrequency
        sta FREH2
        lda #VOICE_OFF
        sta VCREG2
        lda #VOICE_ON_SAW
        sta VCREG2
        lda camelState
        beq .TrackToShipX
        rts
.TrackToShipX
        lda shipX
        clc
        sbc camelSpitX
        sta camelSpitShipDifference
        and #128
        beq .ShipToRight
        lda #255
        sbc camelSpitShipDifference
        sta camelSpitShipDifference
.ShipToRight
        lda camelSpitShipDifference
        cmp #9
        bmi .HomeOnShipY
        rts
.HomeOnShipY
        lda shipY
        clc
        sbc #3
        sta camelSpitShipDifference
        ldx #6
.SpitShipCollisionLoop
        lda SPRY2
        cmp camelSpitShipDifference
        beq .ContactWithShip
        inc camelSpitShipDifference
        dex
        bne .SpitShipCollisionLoop
        rts
.ContactWithShip
        lda #SPIT_HIT_FREQUENCY
        sta FREH2
        lda #VOICE_OFF
        sta VCREG2
        lda #VOICE_ON_NOISE
        sta VCREG2
        lda SPREN
        and #SPR_CAMEL_SPIT_MASK_OFF
        sta SPREN
        lda camelSpitState
        cmp #SPIT_STATE_ACTIVE
        bne .SpitBombCollision
        dec playerHealth
        bne .ExitCamelSpit
.SpitBombCollision
        lda #TRUE
        sta playerKilled
        rts
.ExitCamelSpit
        lda #128
        sta damageFlashFlag
        lda #SPIT_STATE_INACTIVE
        sta camelSpitState
        rts


