;-------------------------------------------------------------------------------
; If the switch players flag has been set (i.e. one player has died in a two
; player game) then this routine saves the current level stats for that player
; and loads in the current level stats for the other player. This maintains
; state on such things as current sector, camel positions and colours etc.
;-------------------------------------------------------------------------------
InitLevel_SwitchPlayers
        lda switchPlayers
        bne .SwitchPlayers
        rts
.SwitchPlayers
        lda #FALSE
        sta switchPlayers
        lda playerTurn
        cmp #1
        beq .SavePlayer1Stats
.SavePlayer2Stats
        lda #>tbl_Player2TempStats
        sta zpHigh
        lda #<tbl_Player2TempStats
        sta zpLow
        lda #1
        sta playerTurn
        jmp .CopyStatsToTemp
.SavePlayer1Stats
        lda #>tbl_Player1TempStats
        sta zpHigh
        lda #<tbl_Player1TempStats
        sta zpLow
        lda #2
        sta playerTurn
.CopyStatsToTemp
        ldy #32
.CopyStatsToTempLoop
        lda tbl_PlayerStats-1,Y
        sta (zpLow),Y
        dey
        bne .CopyStatsToTempLoop
        ldy #33
        lda camelPositionMinor
        sta (zpLow),Y
        iny
        lda camelPositionMajor
        sta (zpLow),Y
        iny
        lda playerSector
        sta (zpLow),Y
        iny
        lda camelsRemaining
        sta (zpLow),Y
        lda playerTurn
        cmp #2
        beq .FetchPlayer2Stats
.FetchPlayer1Stats
        lda #>tbl_Player1TempStats
        sta zpHigh
        lda #<tbl_Player1TempStats
        sta zpLow
        lda #<SCN_PL1SCORE
        sta scoreScreenLo
        sta scoreColourLo
        jmp .CopyStatsFromTemp
.FetchPlayer2Stats
        lda #>tbl_Player2TempStats
        sta zpHigh
        lda #<tbl_Player2TempStats
        sta zpLow
        lda #<SCN_PL2SCORE
        sta scoreScreenLo
        sta scoreColourLo
.CopyStatsFromTemp
        ldy #32
.CopyStatsFromTempLoop
        lda (zpLow),Y
        sta tbl_PlayerStats-1,Y
        dey
        bne .CopyStatsFromTempLoop
        ldy #33
        lda (zpLow),Y
        sta camelPositionMinor
        iny
        lda (zpLow),Y
        sta camelPositionMajor
        iny
        lda (zpLow),Y
        sta playerSector
        iny
        lda (zpLoW),Y
        sta camelsRemaining 
        rts

;-------------------------------------------------------------------------------
; Initialises the core variables that need to change for the beginning of each
; level such as ship position, camel position, land position etc.
;-------------------------------------------------------------------------------
InitLevel_InitialiseVariables
        lda #SHIP_LEFT_FRAME
        sta shipSpriteFrame
        lda #SHIP_FACE_LEFT
        sta shipDirection
        lda #SHIP_STATE_READY
        sta shipState
        lda #160
        sta shipX
        lda #112
        sta shipY
        lda #1
        sta shipXOffset
        lda #32
        sta shipSpeed
        sta shipSpeedCounter
        lda #SHIP_MOVE_RATE
        sta shipMoveCounter
        lda #SHIP_UPDATE_RATE
        sta shipUpdateCounter
        lda #BULLET_NOT_ACTIVE
        sta bulletDirection
        lda #BULLET_UPDATE_RATE
        sta bulletCounter
        lda #CAMEL_STATE_ALIVE
        sta camelState 
        lda #4
        sta camelAnimationFrame
        lda #CAMEL_HEAD_FRAME1
        sta camelHeadFrame
        lda #CAMEL_ANIMATION_RATE
        sta camelAnimationCounter
        lda #255
        sta currentEnemyID
        lda #SPIT_STATE_INACTIVE
        sta camelSpitState
        lda #CAMEL_SPIT_FRAME1
        sta camelSpitFrame
        lda #1
        sta enemyMoveCounterMinor
        lda #64
        sta enemyMoveCounterMajor
        lda #255
        sta landPositionMinor
        lda #9
        sta landPositionMajor
        lda #4
        sta landPositionCounter
        lda #1
        sta landscapePosition
        lda #8
        sta landscapePixelCounter
        lda #170
        sta camelRadarX
        lda #0
        sta currentStar
        lda #FALSE
        sta collisionRegister
        lda #0
        sta damageFlashFlag
        lda #4
        sta playerHealth
        lda #SCORE_FLASH_NUM_COLOURS
        sta scoreFlashColourIndex
        lda #1
        sta scoreBonus
        lda #FALSE
        sta decreaseOffsetFlag
        lda #1
        sta gameTimer
        rts

;-------------------------------------------------------------------------------
; Initialises the sound registers reading for the various sound effects used in
; the game
;-------------------------------------------------------------------------------
InitLevel_InitialseSound
        lda #VOICE_OFF
        sta VCREG1
        sta VCREG2
        sta VCREG3
        lda #15
        sta SIDVOL
        lda #10
        sta ATDCY1
        sta ATDCY2
        sta ATDCY3
        lda #0
        sta SUREL1
        sta SUREL2 
        sta SUREL3
        lda #CAMEL_WALK_FREQUENCY
        sta FREH2
        rts

;-------------------------------------------------------------------------------
; Uses the player's current sector to load camel stats from tables to set the
; relative difficulty for that sector
;-------------------------------------------------------------------------------
InitLevel_SetDifficulty
        ldx playerSector
        lda tbl_CamelSpeeds,X
        sta camelSpeed
        lda tbl_CamelSpitDelayRates,X
        sta camelSpitDelayCounter
        sta camelSpitDelayRate
        lda tbl_CamelSpitRates,X
        sta camelSpitRateCounter 
        sta camelSpitRate
        lda tbl_RocketMoveRates,X
        sta rocketMoveRate
        lda tbl_CamelSpitBombRates,X
        sta camelSpitBombRateCounter
        sta camelSpitBombRate
        rts

;-------------------------------------------------------------------------------
; Displays the level start message and sound. This routine is skipped if the
; player has just completed a hyperdrive
;-------------------------------------------------------------------------------
InitLevel_StartMessageAndSound
        lda hyperdriveCompleted
        beq .DisplayStartMessage
        lda #FALSE
        sta hyperdriveCompleted
        rts
.DisplayStartMessage
        ldx #SCORE_TOTAL_DIGITS
        lda #WHITE
.SetScoreColourLoop
        sta COL_PL1SCORE,x
        sta COL_PL2SCORE,x
        dex
        bne .SetScoreColourLoop
        ldx #40
        lda #CHAR_SPACE
.ClearCamelRadarLoop
        sta SCN_CAMELRADAR,x
        dex
        bne .ClearCamelRadarLoop
        ldx #11
.DisplayPlayTextLoop
        lda txt_PlayPlayer-1,x
        sta SCN_PLAYTEXT,x
        lda #LBLUE
        sta COL_PLAYTEXT,x
        dex
        bne .DisplayPlayTextLoop
        ldx #15
        lda playerTurn
        cmp #2
        bne .SkipPlayer2Offset
        ldx #18
.SkipPlayer2Offset
        ldy #3
.DisplayPlayerNoTextLoop
        lda txt_PlayPlayer-1,x
        sta SCN_PLAYERTEXT,y
        lda #YELLOW
        sta COL_PLAYERTEXT,y
        dex
        dey
        bne .DisplayPlayerNoTextLoop
        lda #240
        sta zpTemp1
.IntroSoundOuterLoop
        ldx zpTemp1
.IntroSoundInnerLoop
        stx FREH1
        ldy #16
.DecreaseFrequencyLoop
        sta FREL1
        dey
        bne .DecreaseFrequencyLoop
        sty VCREG1
        lda #VOICE_ON_TRIANGLE
        sta VCREG1
        dex
        bne .IntroSoundInnerLoop
        dec zpTemp1
        bne .IntroSoundOuterLoop
        ldx #40
        lda #CHAR_SPACE
.ResetCamelRadarLoop
        sta SCN_CAMELRADAR,X
        dex
        bne .ResetCamelRadarLoop
        lda #SHIP_MOVE_FREQUENCY
        sta FREH1
        rts

;-------------------------------------------------------------------------------
; Initialises all the relevant sprites for the start of each level
;-------------------------------------------------------------------------------
InitLevel_InitialiseSprites
        lda #SHIP_LEFT_FRAME
        sta SPRPTR0
        lda #BULLET_FRAME
        sta SPRPTR1
        lda #CAMEL_SPIT_FRAME1
        sta SPRPTR2
        lda #CAMEL_REAR_FRAME
        sta SPRPTR3
        lda #CAMEL_HEAD_FRAME1
        sta SPRPTR4
        lda #CAMEL_REAR_LEGS_FRAME1
        sta SPRPTR5
        lda #CAMEL_FRONT_LEGS_FRAME1
        sta SPRPTR6
        lda #CAMEL_MARKER_FRAME 
        sta SPRPTR7
        lda shipX
        asl
        sta SPRX0
        lda shipY
        sta SPRY0
        ldx #12
        lda #0
.ClearSpriteXYLoop
        sta SPRY0,x
        dex
        bne .ClearSpriteXYLoop
        lda #132
        sta SPRY3
        sta SPRY4
        lda #174
        sta SPRY5
        sta SPRY6
        lda camelRadarX
        asl
        sta SPRX7
        lda #82
        sta SPRY7
        lda #SPR_SHIP_AND_RADAR_MASK_ON
        sta SPRXMSB
        lda #SPR_CAMEL_MASK_ON
        sta SPRYEX
        sta SPRXEX
        lda #SPR_SHIP_AND_BULLET_MASK_ON
        sta SPRMCS
        lda #WHITE
        sta SPRCOL0
        STA SPRCOL2
        sta SPRCOL7
        lda #YELLOW
        sta SPRMC0
        lda #LBLUE
        sta SPRMC1
        lda #SPR_SHIP_AND_RADAR_MASK_ON
        sta SPREN
        lda SPRCSP
        rts


