;10 SYS 2061
*=$0801
                        byte $0b, $08, $bf, $07, $9e, $32, $30, $36, $31

;-------------------------------------------------------------------------------
; Init_CopyData
; Copies data from $0900 to $8000. Neither data ever used.
; Called by: SYS 2061
;-------------------------------------------------------------------------------
*=$080D
Start
        LDY #$00
.CopyDataLoop
        LDA GameDataInitial,Y
        STA GameData,Y
        INY
        BNE .CopyDataLoop
        JMP Init_Chars

;===============================================================================
; Data
;===============================================================================
*=$0900
GameDataInitial         byte $09, $80, $bc, $fe, $c3, $c2, $cd, $38
                        byte $30, $8e, $16, $d0, $20, $a3, $fd, $20 
                        byte $50, $fd, $20, $15, $fd, $20, $5b, $ff
                        byte $58, $20, $53, $e4, $20, $bf, $e3, $a2
                        byte $fb, $9a, $4c, $00, $10, $00, $00, $00

;-------------------------------------------------------------------------------
; Init_Chars
; Sets char memory to $2000, screen remains at $0400
; Called by: Start (JMP)
;-------------------------------------------------------------------------------
*=$1000
Init_Chars
        LDA #$D0
        STA zpHi2
        LDA #0
        STA zpLo2
        STA BDCOL
        STA BGCOL0
        LDA #$18
        TAY
        STA (zpLo2),Y ;VMCR (D018)
        JSR Init_ScreenPointerArray

;-------------------------------------------------------------------------------
; Init_Restart
; Programme Loops back here after game over
; Called by: Init_Chars (Drop Thru), Score_CheckPlayerScores (JMP)
;-------------------------------------------------------------------------------
*=$1016
Init_Restart
        JSR Menu_DisplayJMPresents
        JMP InitLevel_InitialisePlayerStats

;-------------------------------------------------------------------------------
; Init_ScreenPointerArray
; Sets up an array to point to the screen, stored in $0340 and $0360
; Called by: Init_Chars (JSR), InitLevel_CheckSectorAndCollisions (Extraneous JSR)
;-------------------------------------------------------------------------------
*=$1020
Init_ScreenPointerArray
        LDA #<SCREENRAM
        STA zpLo
        LDA #>SCREENRAM
        STA zpHi
        LDY #0
.SetScreenPointersLoop
        LDA zpLo
        STA SCREEN_PTR_LO,Y
        LDA zpHi
        STA SCREEN_PTR_HI,Y
        LDA zpLo
        CLC
        ADC #40
        STA zpLo
        LDA zpHi
        ADC #0
        STA zpHi
        INY
        CPY #25
        BNE .SetScreenPointersLoop
        LDX #0
.NextRow
        LDA SCREEN_PTR_LO,X
        STA zpLo
        LDA SCREEN_PTR_HI,X
        STA zpHi
        LDY #0
        LDA #CHAR_SPACE
.ClearRowLoop
        STA (zpLo),Y
        INY
        CPY #40
        BNE .ClearRowLoop
        INX
        CPX #25
        BNE .NextRow
        JMP Menu_DisplayHeader ;DONE

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$101C
        RTS
        NOP
        NOP
        NOP

;===============================================================================
; Data
;===============================================================================
*=$1065
txt_ScreenHeader        text 'score pl. 1 >  hi:  llama   > score pl.2'
                        text '            >               >           '
                        text '0000000     >   $ :  100    >    0000000'
                        text '@@@@@@@@@@@@<@@@@@@@@@@@@@@@<@@@@@@@@@@@'
                        text '   $   $   $   $   $   $                '
                        text '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

gameHiScore = $1078

;-------------------------------------------------------------------------------
; Menu_DisplayHeader
; Displays stat bar at top of screen
; Called by: Init_ScreenPointerArray (JMP)
;-------------------------------------------------------------------------------
*=$1155
Menu_DisplayHeader
        LDY #240
.DisplayHeaderLoop
        LDA txt_ScreenHeader-1,Y
        STA SCREENRAM-1,Y
        LDA #WHITE
        STA COLOURRAM-1,Y
        DEY
        BNE .DisplayHeaderLoop
        RTS

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
        NOP
        NOP

;-------------------------------------------------------------------------------
; Screen_GetPointer
; Uses the screen pointer array to fetch screen address based on an X and Y 
; value stored in zpHi and zpLo before the routine is called
; Called by: Screen_Plot (JSR)
;-------------------------------------------------------------------------------
*=$1168
Screen_GetPointer
        LDX zpHi
        LDY zpLo
        LDA SCREEN_PTR_LO,X
        STA zpLo3
        LDA SCREEN_PTR_HI,X
        STA zpHi3
        RTS

;-------------------------------------------------------------------------------
; Screen_Plot
; Plots a char to the screen and sets its colour. Char is stored in charToPlot
; and colour in colourToPlot before routine is called.
; Called by: Camel_Move (JSR), Camel_Dying (JSR), Screen_DisplayStars (JSR), 
; Screen_TwinkleStars (JSR), Screen_DisplayCamelMarker (JSR)
;-------------------------------------------------------------------------------
*=$1177
Screen_Plot
        JSR Screen_GetPointer
        LDA charToPlot
        STA (zpLo3),Y
        LDA zpHi3
        CLC
        ADC #$D4
        STA zpHi3
        LDA zpHi3
        NOP
        NOP
        STA zpHi3
        LDA colourToPlot
        STA (zpLo3),Y
        RTS

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$1190
        JSR Screen_GetPointer
        LDA (zpLo3),Y
        RTS

;-------------------------------------------------------------------------------
; Screen_DisplayLandscape
; Prints the landscape chars to the screen (mountain backdrop)
; Called by: Game_MoveLandscape (Branch/JMP), InitLevel_InitSprites (JSR)
;-------------------------------------------------------------------------------
*=$1196
Screen_DisplayLandscape
        LDX landscapePosition
        LDY #40
.LandscapeDisplayLoop
        LDA landscapeRow1-1,X
        STA SCNROW11-1,Y
        LDA landscapeRow2-1,X
        STA SCNROW12-1,Y
        LDA landscapeRow3-1,X
        STA SCNROW13-1,Y
        LDA landscapeRow4-1,X
        STA SCNROW14-1,Y
        LDA #ORANGE
        STA COLROW11-1,Y
        STA COLROW12-1,Y
        STA COLROW13-1,Y
        STA COLROW14-1,Y
        DEX
        CPX #0
        BNE .SkipResetLandscapeIndex
        LDX #40
.SkipResetLandscapeIndex
        DEY
        BNE .LandscapeDisplayLoop
        RTS

;-------------------------------------------------------------------------------
; Game_MoveLandscape
; Shifts the background landscape by one char based on landscapePosition variable
; Called by: Game_MoveLandscape (Branch/JMP), InitLevel_InitSprites (JSR)
;-------------------------------------------------------------------------------
*=$11CB
Game_MoveLandscape
        LDA shipDirection 
        BEQ .ShipHeadingLeft
        INC landscapePosition
        LDA landscapePosition
        CMP #41
        BMI Screen_DisplayLandscape
        LDA #1
        STA landscapePosition
        JMP Screen_DisplayLandscape
.ShipHeadingLeft
        DEC landscapePosition
        LDA landscapePosition
        CMP #0
        BNE Screen_DisplayLandscape
        LDA #40
        STA landscapePosition
        JMP Screen_DisplayLandscape

;-------------------------------------------------------------------------------
; Player_UpdateShipPosition
; Updates the ship sprite XY based on values in shipX/Y variables
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$11ED
Player_UpdateShipPosition
        DEC shipMoveCounter
        BEQ .UpdateShipPosition
        RTS
.UpdateShipPosition
        LDA #SHIP_UPDATE_RATE
        STA shipMoveCounter
        NOP
        NOP
        NOP
        NOP
        LDA shipSpriteFrame
        STA SPRPTR0 
        INC SPRMC0
        LDA shipY
        STA SPRY0
        LDA shipX
        CLC
        ASL
        STA SPRX0
        BCS .SetShipXMSB
        LDA SPRXMSB
        AND #SPR_SHIP_MASK_OFF
        STA SPRXMSB
        JMP .ExitUpdateShipPosition
.SetShipXMSB
        LDA SPRXMSB
        ORA #SPR_SHIP_MASK_ON
        STA SPRXMSB
.ExitUpdateShipPosition
        JMP .CheckShipSpeed

;-------------------------------------------------------------------------------
; Game_DecreaseShipSpeedCounter
; Counter linking the marker update to player movement
; Called by: Input_JoyLeftRight (JMP)
;-------------------------------------------------------------------------------
*=$1226
Game_DecreaseShipSpeedCounter
        DEC shipSpeedCounter
        BEQ .ResetShipSpeedCounter
        RTS
.ResetShipSpeedCounter
        LDA shipSpeed
        STA shipSpeedCounter
        JMP Camel_CheckMarkerUpdate

;-------------------------------------------------------------------------------
; Input_CheckInput
; Calls CheckJoy routine when gameTimer hits 2. Skipped by Hyperdrive
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$1232
Input_CheckInput
        LDA gameTimer
        CMP #2
        BEQ Input_CheckJoy
        RTS

;-------------------------------------------------------------------------------
; Input_CheckJoy
; Checks joystick up/down movement and adjusts ship Y variable
; Called by: Input_CheckInput (Branch), Hyperdrive_UpdatePlayer (JSR)
;-------------------------------------------------------------------------------
*=$1239
Input_CheckJoy
        LDA JOY1
        EOR #$FF
        STA InputJoy
        AND #JOY_UP 
        BEQ .CheckJoyDown
        DEC shipY
        LDA shipY
        CMP #96
        BNE .CheckJoyDown
        LDA #97
        STA shipY
.CheckJoyDown
        LDA InputJoy
        AND #JOY_DOWN
        BEQ .ExitCheckJoy
        INC shipY
        LDA shipY
        CMP #224
        BNE .ExitCheckJoy
        LDA #223
        STA shipY
.ExitCheckJoy
        RTS
        NOP ;extraneous

;-------------------------------------------------------------------------------
; Input_JoyLeftRight
; Checks joystick left/right movement and turns ship or increases X offset
; Called by: Input_CheckJoyLeftRight (JMP)
;-------------------------------------------------------------------------------
*=$1264
Input_JoyLeftRight
        STA inputJoyLR
        LDA shipDirection
        BEQ .JoyLeft
        LDA #JOY_RIGHT
        STA inputJoyLR
.JoyLeft
        LDA inputJoy
        AND inputJoyLR
        BNE .IncreaseShipOffset
        LDA inputJoy
        AND #JOY_LEFTRIGHT ;testing left or right
        BNE .UpdateShipFrame
        RTS

                        byte $7A, $12 ;extraneous

.UpdateShipFrame
        LDA #SHIP_STATE_TURN
        STA shipState
        LDA shipSpriteFrame
        CMP #SHIP_LEFT_FRAME
        BEQ .SetShipFrameRight
        LDA #SHIP_LEFT_FRAME
        STA shipSpriteFrame
        RTS
.SetShipFrameRight
        LDA #SHIP_RIGHT_FRAME
        STA shipSpriteFrame
        RTS
.IncreaseShipOffset
        INC shipXOffset
        LDA shipXOffset
        CMP #$48
        BNE Player_SetShipSpeed
        LDA #$47
        STA shipXOffset
*=$12F9
.CheckShipSpeed ;Entry point for Player_UpdateShipPosition
        NOP
        NOP
        NOP
        LDA shipSpeed
        CMP #$FF
        BNE .ExitJoyLeftRight
        LDA #16
        STA shipSpeedCounter
        RTS
.ExitJoyLeftRight
        JMP Game_DecreaseShipSpeedCounter

;-------------------------------------------------------------------------------
; Player_SetShipSpeed
; Sets the ships relative speed based on the offsets in tbl_shipSpeeds
; Called by: Input_JoyLeftRight (Branch), Input_CheckJoyLeftRight (JMP)
;-------------------------------------------------------------------------------
*=$129D
Player_SetShipSpeed
        LDA shipDirection
        BNE .MoveShipRight
        LDA #160
        SBC shipXOffset
        STA shipX
        JMP .SetShipSpeed
.MoveShipRight
        LDA #10
        ADC shipXOffset
        STA shipX
.SetShipSpeed
        LDA shipXOffset
        LDY #3
.DivideXOffsetLoop
        CLC
        ROR
        DEY
        BNE .DivideXOffsetLoop
        TAX
        LDA tbl_shipSpeeds,X
        STA shipSpeed
        RTS

;-------------------------------------------------------------------------------
; Game_DecrementTimer
; Counts down the overall game timer that is used to trigger some routines
; Called by: Game_MainLoop (JSR) 
;-------------------------------------------------------------------------------
*=$12C0
Game_DecrementTimer
        DEC gameTimer
        BEQ .ResetGameTimer
        RTS
.ResetGameTimer
        LDA #8
        STA gameTimer
        RTS

;-------------------------------------------------------------------------------
; Input_CheckJoyLeftRight
; Checks left/right movement and makes ship sound, as well as adjusting offset
; Called by: Game_MainLoop (JSR) 
;-------------------------------------------------------------------------------
*=$12CA
Input_CheckJoyLeftRight
        LDA gameTimer
        CMP #1
        BEQ .CheckJoyLeftRight
.CheckJoyLeftRightExit
        RTS
.CheckJoyLeftRight
        DEC shipOffsetChangeCounter 
        BNE .CheckJoyLeftRightExit
        LDA #4
        STA shipOffsetChangeCounter 
        LDA inputJoy
        AND #JOY_LEFTRIGHT
        BEQ .DecreaseOffset
        LDA #VOICE_OFF 
        STA VCREG1
        LDA #VOICE_ON_NOISE
        STA VCREG1
        LDA #JOY_LEFT
        JMP Input_JoyLeftRight
.DecreaseOffset ;Entry point for Player_TurnShip
        DEC shipXOffset
        BNE .SkipResetOffSet
        LDA #1
        STA shipXOffset
.SkipResetOffSet
        JMP Player_SetShipSpeed

;-------------------------------------------------------------------------------
; Player_ChangeDirection
; Checks for the turning state of the ship, and switches direction as required
; Called by: Game_MainLoop (JSR) 
;-------------------------------------------------------------------------------
*=$130A
Player_ChangeDirection
        LDA gameTimer
        CMP #3
        BEQ .CheckShipState
        RTS
.CheckShipState
        LDA shipState
        BNE .ChangeDirection
        RTS
.ChangeDirection
        CMP #SHIP_STATE_TURNING
        BEQ .ExitChangeDirection
        LDA shipDirection
        BEQ .FaceShipRight
        LDA #SHIP_FACE_LEFT
        STA shipDirection
        JMP .ExitChangeDirection
.FaceShipRight
        LDA #SHIP_FACE_RIGHT
        STA shipDirection
.ExitChangeDirection
        JMP Player_UpdateShipOffset

;-------------------------------------------------------------------------------
; Player_TurnShip
; Triggers the ship turn sound
; Called by: Player_UpdateShipState (JMP)
;-------------------------------------------------------------------------------
*=$132C
Player_TurnShip
        BEQ .ShipTurnSoundOn
        LDA #VOICE_OFF 
        STA VCREG1
        STA shipTurnSoundFlag
        JMP .CheckTurnOffset
.ShipTurnSoundOn
        LDA #VOICE_ON_SAW
        STA VCREG1
        STA shipTurnSoundFlag
.CheckTurnOffset
        LDA shipXOffset
        CMP #6
        BNE .StillTurning
        LDA #SHIP_STATE_READY 
        STA shipState
.StillTurning
        LDA gameTimer ;redundant
        STA gameTimer ;redundant
        LDA #4
        STA shipOffsetChangeCounter 
        JMP .DecreaseOffset ;Input_CheckJoyLeftRight

;-------------------------------------------------------------------------------
; Player_UpdateShipState
; Change ship state to 'turning' state
; Called by: Player_UpdateShipOffset (Branch/JMP)
;-------------------------------------------------------------------------------
*=$1354
Player_UpdateShipState
        LDA #SHIP_STATE_TURNING
        STA shipState
        LDA shipTurnSoundFlag
        JMP Player_TurnShip

;-------------------------------------------------------------------------------
; Player_UpdateShipOffset
; Switches the x offset if the player turns
; Called by: Player_ChangeDirection (JMP)
;-------------------------------------------------------------------------------
*=$135D
Player_UpdateShipOffset
        LDA shipState
        CMP #SHIP_STATE_TURN
        BNE Player_UpdateShipState
        LDA #144
        SBC shipXOffset
        STA shipXOffset
        JMP Player_UpdateShipState

;-------------------------------------------------------------------------------
; Screen_DisplayGround
; Displays the grey block of land beneath the landscape on the screen
; Called by: InitLevel_InitSprites
;-------------------------------------------------------------------------------
*=$136C
Screen_DisplayGround
        LDX #15
.GroundRowLoop
        LDA SCREEN_PTR_LO,X 
        STA zpLo3
        LDA SCREEN_PTR_HI,X
        STA zpHi3
        LDY #0
.GroundColumnLoop
        LDA #CHAR_BLOCK
        STA (zpLo3),Y
        LDA zpHi3
        STA zp02Tmp
        CLC
        ADC #$D4
        STA zpHi3
        LDA #GREY1
        STA (zpLo3),Y
        LDA zp02Tmp
        STA zpHi3
        INY
        CPY #40
        BNE .GroundColumnLoop
        INX
        CPX #23
        BNE .GroundRowLoop
        RTS

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$139A
        DEC zp21Tmp
        BEQ $139F
        RTS

;-------------------------------------------------------------------------------
; Screen_UpdateCamelMarker
; Branching routine to determine direction to move camel radar sprite
; Called by: InitLevel_InitSprites
;-------------------------------------------------------------------------------
*=$139F
Screen_UpdateCamelMarker
        LDA #19
        STA zp21Tmp
        LDA shipDirection
        BEQ Screen_MoveMarkerLeft
        JMP Screen_MoveMarkerRight

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$13AA
                        byte $F0, $F8, $CE, $0E, $D0, $60

;-------------------------------------------------------------------------------
; Screen_MoveMarkerLeft
; Moves the camal radar sprite left
; Called by: Screen_UpdateCamelMarker (Branch)
;-------------------------------------------------------------------------------
*=$13B0
Screen_MoveMarkerLeft
        LDA #19 
        STA zp21Tmp
        DEC camelMarkerX
        LDA camelMarkerX
        CMP #0
        BNE .SetMarkerSpriteX
        LDA #159
        STA camelMarkerX
.SetMarkerSpriteX
        LDA camelMarkerX
        ASL
        STA SPRX7
        BCC .ClearMarkerXMSB
        LDA SPRXMSB
        ORA #SPR_RADAR_MASK_ON
        STA SPRXMSB
        RTS
.ClearMarkerXMSB
        LDA SPRXMSB
        AND #SPR_RADAR_MASK_OFF
        STA SPRXMSB
        RTS

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$13DA
        JSR $139A
        LDX $10
        LDY #$28
        JMP $119A

;-------------------------------------------------------------------------------
; Screen_MoveMarkerRight
; Moves the camal radar sprite right
; Called by: Screen_UpdateCamelMarker (JMP)
;-------------------------------------------------------------------------------
*=$13E4
Screen_MoveMarkerRight
        INC camelMarkerX
        LDA camelMarkerX
        CMP #160
        BNE .SetMarkerSpriteX
        LDA #1
        STA camelMarkerX
        JMP .SetMarkerSpriteX ;DONE

;*******************************************************************************
; NOPs
;*******************************************************************************
*=$13F3
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA

;-------------------------------------------------------------------------------
; InitLevel_InitSprites
; Initialises sprites, sound and variables for the start of a level
; Called by: InitLevel_InitialisePlayerStats (JMP), Player_ExplosionEnded (JMP), 
; Hyperdrive_PrepareForNextSector (JMP)
;-------------------------------------------------------------------------------
*=$1400
InitLevel_InitSprites
        LDA #SPR_SHIP_AND_RADAR_MASK_ON
        STA SPREN
        LDA #1
        STA shipXOffset
        LDA #SHIP_LEFT_FRAME
        STA shipSpriteFrame
        LDA #32
        STA shipSpeed
        STA shipSpeedCounter
        LDA #160
        STA shipX
        LDA #112
        STA shipY
        LDA #SPR_CAMEL_MASK_ON
        STA SPRYEX
        STA SPRXEX
        LDA camelSpeedCounter
        STA camelSpeedCounter
        LDA #YELLOW
        STA SPRMC0
        LDA #LBLUE
        STA SPRMC1
        LDA #WHITE
        STA SPRCOL0
        LDA #SHIP_FACE_LEFT
        STA shipDirection 
        LDA #2
        STA landscapePosition
        LDA #0
        STA SPRDP ;redundant
        LDA #SPR_SHIP_AND_BULLET_MASK_ON
        STA SPRMCS
        JSR Screen_DisplayLandscape
        LDA #1
        STA gameTimer
        STA shipOffsetChangeCounter 
        LDA #VOICE_OFF
        STA VCREG1
        STA VCREG2
        STA ATDCY3 ;error? VCREG3?
        LDA #15
        STA SIDVOL
        LDA #10
        STA ATDCY1
        STA ATDCY2
        LDA #0
        STA SUREL1
        STA SUREL2 
        LDA #25
        STA FREH1
        JSR Screen_DisplayGround
        LDA #159
        STA camelMarkerX
        LDA #82
        STA SPRY8
        LDA #CAMEL_MARKER_FRAME
        STA SPRPTR7
        LDA #WHITE
        STA SPRCOL7
        LDA #10
        STA zp21Tmp ;value overwritten later
        LDA #SHIP_STATE_READY
        STA shipState
        JSR Screen_UpdateCamelMarker
        LDA #132
        STA SPRY3
        STA SPRY4
        LDA #174
        STA SPRY5
        STA SPRY6
        LDA #CAMEL_REAR_FRAME
        STA SPRPTR3
        LDA #CAMEL_HEAD_FRAME1
        STA SPRPTR4
        LDA #CAMEL_REAR_LEGS_FRAME1
        STA SPRPTR5
        LDA #CAMEL_FRONT_LEGS_FRAME1
        STA SPRPTR6
        LDA #255
        STA currentEnemyID
        LDA SPRCBG ;redundant as background collision not used
        LDA #8
        STA camelMarkerUpdateCounter
        LDA #10
        STA zp27Tmp ;initialised but never used
        LDA #4
        STA camelAnimationFrame
        LDA #1
        STA enemyMoveCounterMinor
        LDA #2
        STA FREH2
        LDA #64
        STA enemyMoveCounterMajor
                
                ;lots of NOPs
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        
        JMP InitLevel_InitialseGameVariables

;*******************************************************************************
; NOPs
;*******************************************************************************
*=$14F3
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA

;-------------------------------------------------------------------------------
; Game_MainLoop
; This is the main game loop for the camel attack sequence
; Called by: Self (JMP), InitLevel_InitialseGameVariables (JMP)
;-------------------------------------------------------------------------------
*=$1500
Game_MainLoop
        JSR Player_UpdateShipPosition
        JSR Input_CheckInput
        JSR Game_DecrementTimer
        JSR Input_CheckJoyLeftRight
        JSR Player_ChangeDirection
        JSR Camel_UpdateSprites
        JSR Camel_Move
        JSR Input_CheckJoyFire
        JSR Screen_DecreaseTwinkleCounter
        JSR Camel_Dying
        JSR Camel_UpdateCamelHeadFrame
        JSR Camel_UpdateSpit
        JSR Player_DamageScreenFlash 
        JSR Game_UpdateCollisionRegister
        JSR Player_CamelCollisionDetection
        JSR Game_CheckSectorDefences
        JSR Game_CheckPause
                
                ;bunch of NOPs
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        
        JMP Game_MainLoop

;-------------------------------------------------------------------------------
; Player_DisableExplosionSprites
; Disables the 4 explosion sprites at the end of the player death routine
; Called by: Player_DecreaseExplosionCounter (JMP)
;-------------------------------------------------------------------------------
*=$1563
Player_DisableExplosionSprites
        LDA #SPR_RADAR_MASK_ON
        STA SPREN
        JMP Player_ExplosionEnded

;*******************************************************************************
; The NOP Sea
;*******************************************************************************
*=$156B
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                byte $EA, $EA, $EA, $EA, $EA

;-------------------------------------------------------------------------------
; Camel_UpdateSprites
; Updates the four camel sprites
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$1600
Camel_UpdateSprites
        LDA gameTimer
        CMP #1
        BEQ .UpdateCamelSprites
        RTS
.UpdateCamelSprites
        LDX currentEnemyID
        CPX #255
        BNE .CamelSelected
        RTS
        LDY shipSpriteFrame ;redundant
.CamelSelected
        LDA tbl_CamelCurrentColour-1,X
        STA SPRCOL6
        STA SPRCOL3
        STA SPRCOL4
        STA SPRCOL5
        LDA SPREN
        ORA #SPR_CAMEL_MASK_ON 
        STA SPREN
        byte $AD, $42, $00 ;LDA $0042 [camelX]
        ASL
        STA SPRX4
        STA SPRX6
        BCS .SetCamelFrontXMSB
        LDA SPRXMSB
        AND #SPR_CAMEL_FRONT_MASK_OFF
        STA SPRXMSB
        JMP .UpdateCamelRear
.SetCamelFrontXMSB
        LDA SPRXMSB
        ORA #SPR_CAMEL_FRONT_MASK_ON
        STA SPRXMSB
.UpdateCamelRear
        byte $AD, $42, $00 ;LDA $0042 [camelX]
        SBC #23
        ASL
        STA SPRX3
        STA SPRX5
        BCS .SetCamelRearXMSB
        LDA SPRXMSB
        AND #SPR_CAMEL_REAR_MASK_OFF
        STA SPRXMSB
        RTS
.SetCamelRearXMSB
        LDA SPRXMSB
        ORA #SPR_CAMEL_REAR_MASK_ON
        STA SPRXMSB
        RTS

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$1666
                byte $D0, $29, $D7, $8D, $10, $D0, $60

        LDA SPRXMSB
        ORA #%00101000
        STA SPRXMSB
        RTS
        LDA shipSpeedCounter
        CMP #$01
        BNE .b169e
        LDA shipDirection
        BEQ .b1695
        DEC UnknownData22D0-1,X
        JMP $173E
        CMP #$FF
        BNE .b169e
        STA currentEnemyID
        LDA $D015
        AND #$87
        STA $D015
        RTS
.b1695
        INC UnknownData22D0-1,X
        LDA UnknownData22D0-1,X
        JMP $173E
.b169e
        RTS
                byte $C7, $22

        JMP $1613
        LDA SPRCBG
        AND #%10000000 
        BNE .CamelOnScreen
        RTS
.CamelOnScreen
        LDX #6
.b16ae
        JSR $1982
        STA zpLo
        LDA #$04
        STA zpHi
        STX zp2CTmp 
        JSR $1190
        STA hyperdriveLandscapeMoveCounter
        LDA #160
        STA hyperdriveLandscapeMoveRate
.b16c2
        LDA #CHAR_SPACE
        STA charToPlot
        LDA #WHITE
        STA colourToPlot
        JSR Screen_Plot
        DEC hyperdriveLandscapeMoveRate
        BNE .b16c2
        LDA SPRCBG
        AND #%10000000
        BEQ .b16e3
        LDA hyperdriveLandscapeMoveCounter
        JSR .b16fc
        LDX zp2CTmp 
        DEX
        BNE .b16ae
        RTS
.b16e3
        LDA hyperdriveLandscapeMoveCounter
        JSR .b16fc
        LDX zp2CTmp 
        STX currentEnemyID
        LDA shipDirection
        BEQ .b16f6
        LDA #$D5
        JMP $17F0
        RTS
.b16f6
        LDA #0
        STA UnknownData22D0-1,X
        RTS
.b16fc
        STA $04
        JMP $1177
        DEC camelMarkerUpdateCounter
.b1703
        BEQ .b1703
        RTS
        LDA #$08
        STA camelMarkerUpdateCounter
        JMP Game_MoveLandscape
        LDA shipSpeedCounter
        CMP #$01
        BEQ .b1714
        RTS
.b1714
        LDA shipSpeed
        CMP #$FF
        BNE .b171b
        RTS
.b171b
        JMP $139A

;-------------------------------------------------------------------------------
; Camel_UpdateMarker
; Counts down and resets the camel radar counter, calls the move marker routine
; Called by: Camel_CheckMarkerUpdate (Branch)
;-------------------------------------------------------------------------------
*=$171E
Camel_UpdateMarker
        DEC camelMarkerUpdateCounter
        BNE .ExitUpdateMarker
        JSR Camel_MoveMarker
        LDA #8
        STA camelMarkerUpdateCounter
.ExitUpdateMarker
        JMP Player_UpdateLandPosition

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$172C
                byte $3C, $C9, $FF, $F0, $04, $60


        DEC landPositionMajor
        LDA landPositionMajor
        CMP #$FF
        BNE $1731
        LDA #9
        STA camelPositionMinor
        RTS

                byte $CF, $22

        CMP #$E0
        BEQ .b1746
        RTS
.b1746
        LDA $D01F
        LDA #$FF
        STA currentEnemyID
        JMP $168C

;-------------------------------------------------------------------------------
; Camel_CheckMarkerUpdate
; Calls the camal radar sprite update routine if the player is active
; Called by: Game_DecreaseShipSpeedCounter (JMP)
;-------------------------------------------------------------------------------
*=$1750
Camel_CheckMarkerUpdate
        LDA shipState
        BEQ Camel_UpdateMarker
        RTS

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$1755
        STA $1A,X
        LDA shipState
        BNE .b175e
        JMP $16A4
.b175e
        RTS
        LDA shipOffsetChangeCounter
        CMP #$01
        BEQ $1766
        RTS

;-------------------------------------------------------------------------------
; IRQ_MoveCamelBackLegs
; Interrupt routine to animate camel legs
; Called by: IRQ_Main (JSR)
;-------------------------------------------------------------------------------
*=$1766
IRQ_MoveCamelBackLegs
        JSR IRQ_FlashPlayerScore
        NOP
        INC camelAnimationFrame
        LDA camelAnimationFrame
        CMP #5
        BEQ .ResetBackLegsFrame
        LDA #CAMEL_REAR_LEGS_FRAME1-1
        CLC
        ADC camelAnimationFrame
        STA SPRPTR5
        CLC
        ADC #4
        JMP IRQ_GetCamelHeadFrame
        RTS ;redundant
.ResetBackLegsFrame
        LDA #0
        JMP IRQ_CheckCamelFrameSound

;-------------------------------------------------------------------------------
; IRQ_ResetCamelAnimationFrame
; Sets the camel animation frame and relevant sprite pointers
; Called by: IRQ_CheckCamelFrameSound (JMP)
;-------------------------------------------------------------------------------
*=$1786
IRQ_ResetCamelAnimationFrame
        LDA #VOICE_ON_NOISE
        STA VCREG2
.SetBackLegsFrame
        LDA #CAMEL_REAR_LEGS_FRAME1
        STA SPRPTR5
        LDA #CAMEL_FRONT_LEGS_FRAME1
        JSR IRQ_SetCamelHeadFrame
        LDA #1
        STA camelAnimationFrame
.ExitResetCamelAnimationFrame
        RTS

;-------------------------------------------------------------------------------
; Camel_Move
; Increments the camel position, and updates the camel marker radard
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$179A
Camel_Move
        DEC camelSpeedCounter
        BNE .ExitResetCamelAnimationFrame
        JSR Game_ResetCamelSpeedCounter
        BNE .MoveCamel
        LDA #3
        STA enemyMoveCounterMinor
.MoveCamel
        JSR .MoveCamelMarker
        LDX currentEnemyID
        INC camelPositionMinor
        BNE .SkipCamelPosMajor
        INC camelPositionMajor
        NOP
.SkipCamelPosMajor
        NOP
        JMP Camel_CheckLandPosition
.MoveCamelMarker
        DEC enemyMoveCounterMajor
        BNE .ExitCamelMove
        LDA #64
        STA enemyMoveCounterMajor
        LDX #6
.NextCamelMarkerPosition
        JSR Camel_FetchMarkerPosition
        STA zpLo
        LDA #$04
        STA zpHi
        LDA #CHAR_SPACE
        STA charToPlot
        LDA #WHITE
        STA colourToPlot
        STX zp2CTmp
        JSR Screen_Plot
        LDX zp2CTmp
        INC tbl_camelMarkerScreenLo-1,X
        NOP
        NOP
        NOP
        INC zpLo
        LDA #CHAR_CAMEL
        STA charToPlot
        JSR Screen_Plot
        LDX zp2CTmp
.SelectNextCamelToMove
        DEX
        BNE .NextCamelMarkerPosition
.ExitCamelMove
        RTS

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$17EE
        ROR shipSpeedCounter
        LDA shipXOffset
        CMP #$01
        BEQ .b17fb
        LDA #$D5
        JMP $16F8
.b17fb
        JMP $16F6
        NOP
        NOP

;-------------------------------------------------------------------------------
; Input_CheckJoyFire
; Checks to see if fire button is pressed and if a bullet is available
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$1800
Input_CheckJoyFire
        LDA starTwinkleCounter
        CMP #2
        BEQ .CheckyJoyFire
        RTS
.CheckyJoyFire
        LDA inputJoy
        AND #JOY_FIRE
        BNE .FirePressed
        LDA #0
        STA bulletEnable
        RTS
.FirePressed
        LDA bulletDirection
        BEQ .BulletAvailable
        RTS
.BulletAvailable
        JMP Bullet_RedundantRoutine

;-------------------------------------------------------------------------------
; Bullet_SetDirection
; Switches on the bullet sprite and sets bullet direction to match ship
; Called by: Bullet_SetBulletX (JMP)
;-------------------------------------------------------------------------------
*=$181A
Bullet_SetDirection
        NOP
        JSR Bullet_SetBulletY
        NOP
        LDA #165
        STA bulletSoundFrequency
        LDA #0
        STA bulletEnable
        LDA #BULLET_DIR_LEFT
        STA bulletDirection
        LDA SPREN
        ORA #SPR_BULLET_MASK_ON
        STA SPREN
        LDA shipDirection
        BEQ .ExitSetBulletDirection
        LDA #BULLET_DIR_RIGHT
        STA bulletDirection
.ExitSetBulletDirection
        RTS

;-------------------------------------------------------------------------------
; Bullet_MoveBullet
; Switches on the bullet sprite and sets bullet direction to match ship
; Called by: Screen_TwinkleStars (JMP), Screen_SelectStarToTwinkle (JMP)
;-------------------------------------------------------------------------------
*=$183C
Bullet_MoveBullet
        LDA bulletDirection 
        CMP #BULLET_NOT_ACTIVE
        NOP
        NOP
        BEQ .ExitSetBulletDirection
        LDA bulletDirection
        CMP #BULLET_DIR_LEFT
        BEQ .MoveBulletLeft
        INC bulletX
        LDA bulletX
        CMP #165
        BEQ .DisableBulletSprite
        JMP .SetBulletX
.MoveBulletLeft
        DEC bulletX
        LDA bulletX
        CMP #245
        BEQ .DisableBulletSprite
.SetBulletX
        LDA bulletX 
        ASL
        STA SPRX1
        BCS .SetBulletXMSB
        LDA SPRXMSB
        AND #SPR_BULLET_MASK_OFF
        STA SPRXMSB
        JMP .SetBulletY
.SetBulletXMSB
        LDA SPRXMSB
        ORA #SPR_BULLET_MASK_ON
        STA SPRXMSB
.SetBulletY
        LDA bulletY
        STA SPRY1
        JSR $24E6 ;Error, should go to Bullet_ReadCollisionRegister ($24EA)
        AND #SPRCOL_BULLET_CAMEL
        CMP #SPRCOL_BULLET_CAMELREAR
        BEQ .BulletHitCamel
        CMP #SPRCOL_BULLET_CAMELHEAD
        BEQ .BulletHitCamel
        JSR Bullet_ChangeSoundFrequency
        RTS
.BulletHitCamel
        JSR Score_Add1Point
        JSR Bullet_HitSound
.DisableBulletSprite
        LDA #0
        STA SPRY1
        LDA SPREN
        AND #SPR_BULLET_MASK_OFF
        STA SPREN
        LDA #BULLET_NOT_ACTIVE
        JMP Bullet_Disable

;-------------------------------------------------------------------------------
; Screen_DecreaseTwinkleCounter
; Timer for the rate at which the stars twinkle
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$18A6
Screen_DecreaseTwinkleCounter
        DEC starTwinkleCounter
        BEQ .ResetTwinkleCounter
        RTS
.ResetTwinkleCounter
        LDA #4
        STA starTwinkleCounter 
        JMP Screen_SelectStarToTwinkle

;-------------------------------------------------------------------------------
; Bullet_ChangeSoundFrequency
; Make sound effect for the bullet firing
; Called by: Bullet_MoveBullet (JSR)
;-------------------------------------------------------------------------------
*=$18B2
Bullet_ChangeSoundFrequency
        DEC bulletSoundFrequency
        LDA bulletSoundFrequency
        STA FREH1
        LDA #VOICE_OFF
        STA VCREG1
        LDA #VOICE_ON_NOISE
        STA VCREG1
        RTS

;-------------------------------------------------------------------------------
; Bullet_HitSound
; Make sound effect for the bullet hitting a camel
; Called by: Bullet_MoveBullet (JSR)
;-------------------------------------------------------------------------------
*=$18C4
Bullet_HitSound
        LDA #6
        JSR Bullet_ClearCollisionRegister
        LDA #VOICE_OFF
        STA VCREG3
        LDA #VOICE_ON_NOISE
        STA VCREG3
        NOP ;drops into next routine

;-------------------------------------------------------------------------------
; Bullet_SetBulletY
; Initialises the bullet Y to match the ship Y
; Called by: Bullet_MoveBullet (JSR), Bullet_HitSound (fall through)
;-------------------------------------------------------------------------------
*=$18D4
Bullet_SetBulletY
        LDA shipY
        STA bulletY
        LDA #64
        STA zp21Tmp ;this doesn't appear to do anything
        RTS

;-------------------------------------------------------------------------------
; Bullet_Disable
; Set bullet direction to 'not active', resets frequency 1 high
; Called by: Bullet_MoveBullet (JMP)
;-------------------------------------------------------------------------------
*=$18DD
Bullet_Disable
        STA bulletDirection
        LDA #25
        STA FREH1
        LDA bulletEnable ;extraneous
        STA bulletEnable ;extraneous
.ExitBulletDisable
        RTS

;-------------------------------------------------------------------------------
; Bullet_SetBulletX
; Initialise bullet X to ship X when a bullet is fired
; Called by: Bullet_RedundantRoutine (JMP)
;-------------------------------------------------------------------------------
*=$18E9
Bullet_SetBulletX
        LDA bulletEnable
        BNE .ExitBulletDisable
        LDA shipX
        STA bulletX
        JMP Bullet_SetDirection

;-------------------------------------------------------------------------------
; Camel_DecreaseCamelHealth
; Decreases by 1 the health of the camel that was shot. Changes camel colour
; Called by: Score_Add1Point (JSR)
;-------------------------------------------------------------------------------
*=$18F4
Camel_DecreaseCamelHealth
        LDX currentEnemyID
        DEC tbl_CamelHealthMinor-1,X
        LDA tbl_CamelHealthMinor-1,X
        BEQ .DecreaseCamelHealthMajor
        RTS
.DecreaseCamelHealthMajor
        LDA #16
        STA tbl_CamelHealthMinor-1,X
        DEC tbl_CamelHealth-1,X
        LDA tbl_CamelHealth-1,X
        BEQ .camelDestroyed
        TAY
        LDA tbl_CamelColours-1,Y
        STA tbl_CamelCurrentColour-1,X
        RTS
.camelDestroyed
        LDA currentEnemyID
        JSR Score_AddBonusPoints
        LDA #CAMEL_HEAD_DYING_FRAME1
        STA camelHeadFrame
        LDA #CAMEL_STATE_DEAD
        STA camelState
        RTS

;-------------------------------------------------------------------------------
; Camel_Dying
; Camel dying animation sequence, sound effect and radar marker clear
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$1922
Camel_Dying
        LDA camelState
        BNE .CamelDeathSequence
        RTS
.CamelDeathSequence
        STA FREH1
        LDX camelKilledID
        STA tbl_CamelCurrentColour-1,X
        CMP #CAMEL_STATE_DYING
        BNE .CamelDyingSound
        LDA #CAMEL_HEAD_DYING_FRAME2
        STA camelHeadFrame
.CamelDyingSound
        LDA gameTimer
        CMP #1
        BEQ .CheckCamelDyingState
        LDA #VOICE_OFF
        STA VCREG1
        LDA #VOICE_ON_TRIANGLE_RING
        STA VCREG1
        LDA #CAMEL_STATE_DEAD
        SBC camelState
        STA FREH3
.CamelStillDying
        RTS
.CheckCamelDyingState
        DEC camelState
        BNE .CamelStillDying
        LDA #64
        STA FREH1
        NOP
        NOP
        LDA #YELLOW
        STA tbl_CamelCurrentColour-1,X
        JSR Camel_SetInactive
        STA zpLo
        LDA #4
        STA zpHi
        LDA #CHAR_SPACE
        STA charToPlot
        JSR Screen_Plot
        LDA #255
        STA camelKilledID
        LDA SPREN
        AND #SPR_CAMEL_MASK_OFF
        STA SPREN
        LDA SPRCBG ;extraneous
        JMP Camel_CheckRemainingCamels
        RTS

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$1982
        LDA tbl_CamelHealth-1,X
        BEQ .b198b
        LDA tbl_camelMarkerScreenLo-1,X
        RTS
.b198b
        PLA
        PLA
        JMP $16DF

;-------------------------------------------------------------------------------
; Camel_FetchMarkerPosition
; Fetches the current camel marker screen position
; Called by: Camel_Move (JSR)
;-------------------------------------------------------------------------------
*=$1990
Camel_FetchMarkerPosition
        JSR Camel_CheckActive
        BEQ .CamelNotActive
        LDA tbl_camelMarkerScreenLo-1,X
        RTS
.CamelNotActive
        PLA
        PLA ;pulls the previous JSR from the stack
        JMP .SelectNextCamelToMove

;-------------------------------------------------------------------------------
; Camel_UpdateCamelHeadFrame
; Sets the camel head sprite pointer
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$199E
Camel_UpdateCamelHeadFrame
        LDA gameTimer
        CMP #1
        BEQ .UpdateCamelHeadFrame
        RTS
.UpdateCamelHeadFrame
        LDA camelHeadFrame
        STA SPRPTR4
        RTS

;-------------------------------------------------------------------------------
; Camel_ResetHeadSprite
; Sets the camel head frame back to the first frame
; Called by: Camel_CheckRemainingCamels (JMP)
;-------------------------------------------------------------------------------
*=$19AB
Camel_ResetHeadSprite
        NOP
        NOP
        NOP
        LDA #CAMEL_HEAD_FRAME1
        STA camelHeadFrame
        RTS

;-------------------------------------------------------------------------------
; Player_UpdateLandPosition
; Set that players minor/major land position as the ship moves
; Called by: Camel_UpdateMarker (JMP)
;-------------------------------------------------------------------------------
*=$19B3
Player_UpdateLandPosition
        LDA shipDirection
        CMP #SHIP_FACE_LEFT
        BEQ .DecreaseLandPosition
        INC landPositionMinor
        BNE .GoToExitUpdateLandPosition
        INC landPositionMajor
        LDA landPositionMajor
        CMP #10
        BNE .ExitUpdateLandPosition
        LDA #0
        STA landPositionMajor
.GoToExitUpdateLandPosition
        JMP .ExitUpdateLandPosition
.DecreaseLandPosition
        DEC landPositionMinor
        LDA landPositionMinor
        CMP #255
        BNE .ExitUpdateLandPosition
        DEC landPositionMajor
        LDA landPositionMajor
        CMP #255
        BNE .ExitUpdateLandPosition
        LDA #9
        STA landPositionMajor
.ExitUpdateLandPosition
        JMP Camel_CheckLandPositionDelay

;-------------------------------------------------------------------------------
; Camel_MoveMarker
; Sets the sprite X position for the radar marker
; Called by: Camel_UpdateMarker (JSR)
;-------------------------------------------------------------------------------
*=$19E3
Camel_MoveMarker
        JSR Game_MoveLandscape
        LDA #5
        STA zp40Tmp
        LDX landPositionMajor
.SetLandPositionLoop
        CLC
        LDA zp40Tmp
        ADC #16
        STA zp40Tmp
        DEX
        BNE .SetLandPositionLoop
        LDA landPositionMinor
        CLC
        ROR
        CLC
        ROR
        CLC
        ROR
        CLC
        ROR ;divide by 16
        CLC
        NOP
        CLC
        ADC zp40Tmp
        CLC
        ASL
        STA SPRX7
        BCC .ClearCamMarkerXMSB
        LDA SPRXMSB
        ORA #SPR_RADAR_MASK_ON
        STA SPRXMSB
        JMP .ExitMoveMarker
.ClearCamMarkerXMSB
        LDA SPRXMSB
        AND #SPR_RADAR_MASK_OFF
        STA SPRXMSB
.ExitMoveMarker
        NOP
        NOP
        NOP
        RTS

;-------------------------------------------------------------------------------
; Camel_CheckLandPosition
; Check to see if camel is in range to display on the screen
; Called by: Camel_Move (JMP), Camel_CheckLandPositionDelay (JMP)
;-------------------------------------------------------------------------------
*=$1A23
Camel_CheckLandPosition
        LDY #0
        LDA landPositionMajor
        STA zp40Tmp
        LDA landPositionMinor
        STA zp41Tmp
.ScanForCamelLoop
        LDA zp41Tmp
        CMP camelPositionMinor
        BEQ .CamelInRange
.KeepScanning
        INC zp41Tmp
        BNE .SkipTmpHiByte
        INC zp40Tmp
.SkipTmpHiByte
        INY
        CPY #192
        BNE .ScanForCamelLoop
.NoCamelInRange
        LDA #255
        JMP Camel_TurnOffSprites
        RTS ;redundant
.CamelInRange
        LDA zp40Tmp
        SEC
        SBC camelPositionMajor
        STA currentEnemyID
        LDX currentEnemyID
        JSR Camel_CheckCamelID
        CMP #$FF
        BEQ .KeepScanning
        STY camelX
        RTS

;-------------------------------------------------------------------------------
; Camel_CheckLandPositionDelay
; Timer to determine when to check the camel land position
; Called by: Player_UpdateLandPosition (JMP)
;-------------------------------------------------------------------------------
*=$1A57
Camel_CheckLandPositionDelay
        DEC camelLandPositionCounter
        BEQ .ResetCamelLandPositionCounter
        RTS
.ResetCamelLandPositionCounter
        LDA #3
        STA camelLandPositionCounter
        JMP Camel_CheckLandPosition

;-------------------------------------------------------------------------------
; Camel_TurnOffSprites
; Switch off the camel sprites
; Called by: Camel_CheckLandPosition (JMP)
;-------------------------------------------------------------------------------
*=$1A63
Camel_TurnOffSprites
        STA currentEnemyID
        LDA SPREN
        AND #SPR_CAMEL_MASK_OFF
        STA SPREN
        NOP
        NOP
        RTS

;-------------------------------------------------------------------------------
; Camel_CheckCamelID
; Check if past the max (6) number of camels
; Called by: Camel_CheckLandPosition (JSR)
;-------------------------------------------------------------------------------
*=$1A70
Camel_CheckCamelID
        NOP
        CPX #7
        BPL .CamelOutOfRange
        JMP Camel_CheckCamelPositionMajor
        RTS
.CamelOutOfRange
        PLA
        PLA ;Pull last JSR from the stack
        JMP .NoCamelInRange

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$1A7E
        LDA landPositionMajor
        STA zp40Tmp
        INC zp40Tmp
        NOP
        NOP
        NOP
        NOP
        RTS

;-------------------------------------------------------------------------------
; Camel_CheckCurrentCamelHealth
; If camel is in range, load its current health
; Called by: Camel_CheckCamelPositionMajor (JMP)
;-------------------------------------------------------------------------------
*=$1A89
Camel_CheckCurrentCamelHealth
        CPX #0
        BEQ .CamelOutOfRange
        LDA tbl_CamelHealth-1,X
        RTS

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$1A91
        LDA $3D
        STA $40
        LDX #$10
        LDY #$10
        LDA #$20
        STA $44
        DEC $44
        BNE $1A9D
        DEY
        BNE $1A99
        DEX
        BNE $1A97
        RTS

;-------------------------------------------------------------------------------
; IRQ_Main
; Routine called by interrupt. Used to animate camel, make camel walking noise 
; and flash the current player's score
; Called by: IRQ
;-------------------------------------------------------------------------------
*=$1AA8
IRQ_Main
        DEC camelFrameRate
        BEQ .ResetCamelFrameRate
        JMP krnINTERRUPT
.ResetCamelFrameRate
        LDA #16
        STA camelFrameRate
        JSR IRQ_MoveCamelBackLegs ;DONE
        JMP krnINTERRUPT

;-------------------------------------------------------------------------------
; Camel_SetInactive
; Value of 255 stored in relevant camel health when it dies
; Called by: Camel_Dying (JSR)
;-------------------------------------------------------------------------------
*=$1AB9
Camel_SetInactive
        LDA #255
        STA tbl_CamelHealth-1,X
        LDA tbl_camelMarkerScreenLo-1,X
        RTS
        NOP

;-------------------------------------------------------------------------------
; Camel_CheckActive
; Test if the selected camel is alive
; Called by: Camel_FetchMarkerPosition (JSR)
;-------------------------------------------------------------------------------
*=$1AC3
Camel_CheckActive
        LDA tbl_CamelHealth-1,X
        CMP #$FF
        RTS

;-------------------------------------------------------------------------------
; Camel_CheckCamelPositionMajor
; Check the camel position against the current land position
; Called by: Camel_CheckCamelID (JMP)
;-------------------------------------------------------------------------------
*=$1AC9
Camel_CheckCamelPositionMajor
        LDA landPositionMajor
        CMP camelPositionMajor
        BMI .NoCamel
        JMP Camel_CheckCurrentCamelHealth
.NoCamel
        JMP .NoCamelInRange

;-------------------------------------------------------------------------------
; Screen_DisplayStars
; Plot starts on the screen
; Called by: InitLevel_InitialseGameVariables (JSR)
;-------------------------------------------------------------------------------
*=$1AD5
Screen_DisplayStars
        LDA #CHAR_STAR
        STA charToPlot
        LDA #WHITE
        STA colourToPlot
        LDX #16
.NextStar
        LDA tbl_starScreenX-1,X
        STA zpLo
        LDA tbl_starScreenY-1,X
        STA zpHi
        STX zp40Tmp
        JSR Screen_Plot
        LDX zp40Tmp
        DEX
        BNE .NextStar
        RTS

;-------------------------------------------------------------------------------
; Screen_TwinkleStars
; Sets the current star to white, selects the next star and sets it red
; Called by: Screen_SelectStarToTwinkle (JMP)
;-------------------------------------------------------------------------------
*=$1AF4
Screen_TwinkleStars
        LDA #CHAR_STAR
        STA charToPlot
        LDA #WHITE
        STA colourToPlot
        LDX currentStar
        LDA tbl_starScreenX,X
        STA zpLo
        LDA tbl_starScreenY,X
        STA zpHi
        JSR Screen_Plot
        INC currentStar
        LDA currentStar
        AND #15
        STA currentStar
        TAX
        LDA tbl_starScreenX,X
        STA zpLo
        LDA tbl_starScreenY,X
        STA zpHi
        LDA #RED
        STA colourToPlot
        JSR Screen_Plot
        JMP Bullet_MoveBullet

;-------------------------------------------------------------------------------
; Screen_SelectStarToTwinkle
; Counts down the star twinkle counter and twinkles star if 0
; Called by: Screen_DecreaseTwinkleCounter (JMP)
;-------------------------------------------------------------------------------
*=$1B28
Screen_SelectStarToTwinkle
        JSR Screen_DecreaseCounter
        DEC starTwinkleRate
        BEQ .TwinkleStar
        JMP Bullet_MoveBullet
.TwinkleStar
        LDA #38
        STA starTwinkleRate
        JMP Screen_TwinkleStars

;-------------------------------------------------------------------------------
; Bullet_RedundantRoutine
; Redundant bridging routine with a branch that's always taken
; Called by: Input_CheckJoyFire (JMP)
;-------------------------------------------------------------------------------
*=$1B39
Bullet_RedundantRoutine
        LDA #0
        BEQ .BranchAlwaysTaken
        RTS
.BranchAlwaysTaken
        JMP Bullet_SetBulletX

;-------------------------------------------------------------------------------
; Screen_DecreaseCounter
; Another counter used to set the star twinkle rate
; Called by: Screen_SelectStarToTwinkle (JSR)
;-------------------------------------------------------------------------------
*=$1B41
Screen_DecreaseCounter
        LDA zp21Tmp
        BEQ .ExitDecreaseCounter
        DEC zp21Tmp
.ExitDecreaseCounter
        NOP
        NOP
        RTS

;-------------------------------------------------------------------------------
; IRQ_GetCamelHeadFrame
; Selects the next camel head animation frame
; Called by: IRQ_MoveCamelBackLegs (JMP)
;-------------------------------------------------------------------------------
*=$1B4A
IRQ_GetCamelHeadFrame
        STA SPRPTR6
        LDA camelState
        BEQ .GetCamelHeadFrame
        RTS
.GetCamelHeadFrame
        LDX camelAnimationFrame
        LDA tbl_CamelHeadFrame-1,X
        byte $8D, $38, $00 ;STA $0038 [camelHeadFrame]
        RTS

;-------------------------------------------------------------------------------
; IRQ_SetCamelHeadFrame
; Update the current camel head frame, or reset to the first frame
; Called by: IRQ_ResetCamelAnimationFrame (JSR)
;-------------------------------------------------------------------------------
*=$1B5B
IRQ_SetCamelHeadFrame
        STA SPRPTR6
        LDA camelState
        BEQ .SetCamelHeadFrame
        RTS
.SetCamelHeadFrame
        LDA #CAMEL_HEAD_FRAME1
        STA camelHeadFrame
        RTS

;-------------------------------------------------------------------------------
; Camel_UpdateSpit
; 
; Called by: Game_MainLoop (JSR) 
;-------------------------------------------------------------------------------
*=$1B68
Camel_UpdateSpit
        DEC camelSpitSpeedCounter
        BEQ .UpdateSpit
        RTS
.UpdateSpit
        LDA camelSpitSpeed
        STA camelSpitSpeedCounter
        LDA camelSpitState
        BNE Camel_MoveSpit
        LDA #136
        STA SPRY2
        JMP Camel_SetSpitFrequency
        NOP
        NOP

;-------------------------------------------------------------------------------
; Camel_SetSpitPosition
; Set camel spit direction of travel
; Called by: Camel_SpitSelected (JMP) 
;-------------------------------------------------------------------------------
*=$1B7F
Camel_SetSpitPosition
        ADC #16
        JSR Camel_TestShipSpitXMatch
        NOP
        BPL .SpitDirectionLeft
        LDA #SPIT_DIRECTION_RIGHT
.SetCamelSpitDirection
        STA camelSpitDirection
        JMP .SetSpitActive
.SpitDirectionLeft
        LDA #SPIT_DIRECTION_LEFT
        JMP .SetCamelSpitDirection
.SetSpitActive
        LDA #SPIT_STATE_ACTIVE
        STA camelSpitState
        LDA SPREN
        ORA #SPR_CAMEL_SPIT_MASK_ON 
        JMP Camel_EnableSpitSprite
        RTS

;-------------------------------------------------------------------------------
; Camel_MoveSpit
; Move the camel spit sprite
; Called by: Camel_UpdateSpit (Branch)
;-------------------------------------------------------------------------------
*=$1BA0
Camel_MoveSpit
        LDA camelSpitState
        CMP #SPIT_STATE_BOMB
        BEQ Camel_JumpToSpitSound
.MoveSpitSelectEnemy
        LDA currentEnemyID
        JMP .Here ;extraneous
.Here 
        LDA camelSpitDirection
        CMP #SPIT_DIRECTION_RIGHT
        BNE .SpitLeft
        INC camelSpitX
        INC camelSpitX
.SpitLeft
        DEC camelSpitX
        LDA camelSpitX
        CMP #4
        BEQ .SetSpitInactive
        CMP #176
        BEQ .SetSpitInactive
        JMP .UpdateSpitY
.SetSpitInactive
        LDA #SPIT_STATE_INACTIVE
        STA camelSpitState
        NOP
        NOP
        NOP
        NOP
        JMP Camel_DisableSpitSprite
        RTS
.UpdateSpitY
        DEC camelSpitRateCounter 
        BNE .UpdateSpitX
        LDA camelSpitRate
        STA camelSpitRateCounter 
        LDA SPRY2
        CMP shipY
        BPL .MoveCamelSpitUp
        INC SPRY2
        INC SPRY2
.MoveCamelSpitUp
        DEC SPRY2
.UpdateSpitX
        LDA camelSpitX
        CLC
        ASL
        STA SPRX2
        BCC .ResetCamelSpitXMSB
        LDA SPRXMSB
        ORA #SPR_CAMEL_SPIT_MASK_ON
        STA SPRXMSB
        JMP .UpdateCamelSpitFrame
.ResetCamelSpitXMSB
        LDA SPRXMSB
        AND #SPR_CAMEL_SPIT_MASK_OFF
        STA SPRXMSB
.UpdateCamelSpitFrame
        INC camelSpitFrame
        LDA camelSpitFrame
        CMP #CAMEL_SPIT_BOMB_FRAME4+1
        BNE .CheckSpitNextFrame
        LDA #CAMEL_SPIT_FRAME1
        STA camelSpitFrame
        JMP .ExitMoveCamelSpit
.CheckSpitNextFrame
        CMP #CAMEL_SPIT_FRAME2+1
        BNE .ExitMoveCamelSpit
        LDA #CAMEL_SPIT_BOMB_FRAME4
        STA camelSpitFrame
.ExitMoveCamelSpit
        STA SPRPTR2
        JMP Camel_SpitSoundSetFrequency

;-------------------------------------------------------------------------------
; Camel_JumpToSpitSound
; Bridging routine
; Called by: Camel_MoveSpit (Branch)
;-------------------------------------------------------------------------------
*=$1C21
Camel_JumpToSpitSound
        JMP Camel_SpitSound

;-------------------------------------------------------------------------------
; Camel_SpitSelected
; Enables spit if a camel is active
; Called by: Camel_RandomiseSpit (Branch)
;-------------------------------------------------------------------------------
*=$1C24
Camel_SpitSelected
        LDA currentEnemyID
        CMP #$FF
        BNE .EnemyActive
        RTS
.EnemyActive
        LDA camelX
        JMP Camel_SetSpitPosition

;-------------------------------------------------------------------------------
; Camel_DisableSpitSprite
; Disables the camel spit sprite
; Called by: Camel_MoveSpit (JMP)
;-------------------------------------------------------------------------------
*=$1C30
Camel_DisableSpitSprite
        LDA SPREN
        AND #SPR_CAMEL_SPIT_MASK_OFF
        JMP Camel_DisableSpitNoise
        RTS

;-------------------------------------------------------------------------------
; Camel_RandomiseSpit
; Uses the system TI value to generate a pseudo-random number 
; Called by: Camel_SetSpitFrequency (JMP) 
;-------------------------------------------------------------------------------
*=$1C39
Camel_RandomiseSpit
        byte $AD, $A2, $00 ;LDA $00A2 [sysTI_A2]
        AND #$FF
        CMP #2
        BMI Camel_SpitSelected
        RTS

;-------------------------------------------------------------------------------
; Camel_TestForSpitBomb
; Checks if the next spit should be a spit bomb (based on counter)
; Called by: Camel_EnableSpitSprite (JMP) 
;-------------------------------------------------------------------------------
*=$1C43
Camel_TestForSpitBomb
        DEC camelSpitBombRateCounter
        BEQ .SpitBombEnable
        RTS
.SpitBombEnable
        LDA #SPIT_STATE_BOMB
        STA camelSpitState
        LDA camelSpitBombRate
        STA camelSpitBombRateCounter
        LDA #0
        STA zp54Redundant ;never used
        STA zp53Redundant ;never used
        RTS

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$1C57
        JMP Camel_SpitSound
        NOP
        BPL .MoveSpitLeft
        INC camelSpitX
        INC camelSpitX
.MoveSpitLeft
        DEC camelSpitX
        LDA SPRY2
        CMP shipY
        BPL .MoveSpitDown
        INC SPRY2
        INC SPRY2
.MoveSpitDown
        DEC SPRY2
        INC zp54Redundant
        LDA zp54Redundant
        AND #$03
        STA zp54Redundant
        TAX
        LDA tbl_CamelBombSpriteFrames,X
        STA SPRPTR2
        LDA camelSpitX
        CLC
        ASL
        STA SPRX2
        BCC .ClearSpitXMSB
        LDA SPRXMSB
        ORA #%00000100
        STA SPRXMSB
        JMP .b1c9e
.ClearSpitXMSB
        LDA SPRXMSB
        AND #%11111011
        STA SPRXMSB
.b1c9e
        JSR $1D29
        DEC zp53Redundant
        BEQ .b1ca6
        RTS
.b1ca6
        LDA #SPIT_STATE_INACTIVE
        STA camelSpitState
        JMP $1C30

;===============================================================================
; Data
;===============================================================================
*=$1CAD
tbl_CamelBombSpriteFrames       byte $cd, $ce, $cf, $ce

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$1CB1
        NOP
        NOP

;-------------------------------------------------------------------------------
; Camel_EnableSpitSprite
; Secondary part of code to enable the spit sprite
; Called by: Camel_SetSpitPosition (JMP) 
;-------------------------------------------------------------------------------
*=$1CB3
Camel_EnableSpitSprite
        STA SPREN
        JMP Camel_TestForSpitBomb

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$1CB9
        DEC zp5ARedundant
        BEQ $1D1E
        LDA zp5ARedundant
        STA zp5ARedundant
        RTS

;-------------------------------------------------------------------------------
; IRQ_CheckCamelFrameSound
; Resets the camel movement sound
; Called by: IRQ_MoveCamelBackLegs (JMP) 
;-------------------------------------------------------------------------------
*=$1CC2
IRQ_CheckCamelFrameSound
        LDA camelSpitState
        BNE .SkipCamelSound
        LDA zp5CRedundant ;always 0
        BNE .SkipCamelSound
        LDA #VOICE_OFF
        STA VCREG2
        JMP IRQ_ResetCamelAnimationFrame
.SkipCamelSound
        JMP .SetBackLegsFrame

;-------------------------------------------------------------------------------
; Camel_SetSpitFrequency
; Resets the spit sound frequency variable
; Called by: Camel_UpdateSpit (JMP) 
;-------------------------------------------------------------------------------
*=$1CD5
Camel_SetSpitFrequency
        LDA #144
        STA camelSpitSoundFrequency
        JMP Camel_RandomiseSpit

;-------------------------------------------------------------------------------
; Camel_SpitSoundSetFrequency
; Generates the camel spit sound and decreases the frequency value
; Called by: Camel_MoveSpit (JMP) 
;-------------------------------------------------------------------------------
*=$1CDC
Camel_SpitSoundSetFrequency
        DEC camelSpitSoundFrequency
        NOP
        NOP
        NOP
        NOP
        LDA camelSpitSoundFrequency
        STA FREH2
        LDA #VOICE_OFF
        STA VCREG2
        LDA #VOICE_ON_SAW
        STA VCREG2
        JMP Camel_SpitHomeOnShip

;-------------------------------------------------------------------------------
; Camel_DisableSpitNoise
; Switches off the spit sound
; Called by: Camel_DisableSpitSprite (JMP) 
;-------------------------------------------------------------------------------
*=$1CF4
Camel_DisableSpitNoise
        STA SPREN
        LDA #VOICE_OFF
        STA VCREG2
        LDA #2
        JMP Camel_DisableSpitNoiseB

;-------------------------------------------------------------------------------
; Camel_SpitSound
; Generates a variation in the frequency of the camel spit sound
; Called by: Camel_JumpToSpitSound (JMP) 
;-------------------------------------------------------------------------------
*=$1D01
Camel_SpitSound
        LDA camelSpitSoundFrequency
        ADC #87
        STA camelSpitSoundFrequency
        LDA #VOICE_OFF
        STA VCREG2
        LDA #VOICE_ON_SAW
        STA VCREG2
        LDA camelSpitSoundFrequency
        STA FREH2
        NOP
        LDA #1
        STA camelSpitRateCounter
        JMP .MoveSpitSelectEnemy

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$1D1E
        LDA #$03
        STA zp5ARedundant
        JMP $1C57

;-------------------------------------------------------------------------------
; Camel_DisableSpitNoiseB
; Resets frequency of voice 2
; Called by: Camel_DisableSpitNoise (JMP)
;-------------------------------------------------------------------------------
*=$1D25
Camel_DisableSpitNoiseB
        STA FREH2
        RTS

;-------------------------------------------------------------------------------
; Camel_SpitHomeOnShip
; Calculation to home the camel spit onto the current ship position
; Called by: Camel_SpitSoundSetFrequency (JMP) 
;-------------------------------------------------------------------------------
*=$1D29
Camel_SpitHomeOnShip
        LDA camelState
        BEQ .TrackToShipX
        RTS
        CMP #5                  ;code never reached
        BEQ .TrackToShipX       ;code never reached
        RTS                     ;code never reached
.TrackToShipX
        LDA shipX
        CLC
        SBC camelSpitX
        STA camelSpitShipDifference
        AND #128
        BEQ .ShipToRight
        LDA #255 ;i.e. mod
        SBC camelSpitShipDifference
        STA camelSpitShipDifference
.ShipToRight
        LDA camelSpitShipDifference
        CMP #9
        BMI .HomeOnShipY
        RTS
.HomeOnShipY
        LDA shipY
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        CLC
        SBC #3
        STA camelSpitShipDifference
        LDX #6
.SpitShipCollisionLoop
        LDA SPRY2
        CMP camelSpitShipDifference
        BEQ .ContactWithShip
        INC camelSpitShipDifference
        DEX
        BNE .SpitShipCollisionLoop
        RTS
.ContactWithShip ;alter this to get rid of collisions
        LDA #2
        STA FREH2
        LDA #VOICE_OFF
        STA VCREG2
        LDA #VOICE_ON_NOISE
        STA VCREG2
        LDA SPREN
        AND #SPR_CAMEL_SPIT_MASK_OFF
        STA SPREN
        LDA camelSpitState
        CMP #SPIT_STATE_ACTIVE
        BNE .SpitBombCollision
        NOP
        DEC playerHealth
        BNE .ExitSpitHomeOnShip
.SpitBombCollision
        JMP Player_ShipExplosion
.ExitSpitHomeOnShip
        LDA #128
        JMP Camel_DisableSpit

;-------------------------------------------------------------------------------
; Player_DamageScreenFlash
; Creates the yellow/black banded screen flash when the player is hit
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$1D92
Player_DamageScreenFlash
        LDA damageFlashFlag
        BNE .FlashScreen
        RTS
.FlashScreen
        DEC damageFlashFlag
        LDA damageFlashFlag
        AND #1
        BEQ .FlashBlack
        LDA #YELLOW
        STA BGCOL0
        JMP .DamageNoise
.FlashBlack
        LDA #BLACK
        STA BGCOL0
.DamageNoise
        LDA #VOICE_OFF
        STA VCREG2
        LDA #VOICE_ON_NOISE
        STA VCREG2
        RTS

;-------------------------------------------------------------------------------
; Camel_DisableSpit
; Sets the spit state to inactive
; Called by: Camel_SpitHomeOnShip (JMP)
;-------------------------------------------------------------------------------
*=$1DB7
Camel_DisableSpit
        STA damageFlashFlag
        LDA #SPIT_STATE_INACTIVE
        STA camelSpitState
        RTS

;-------------------------------------------------------------------------------
; Player_ShipExplosion
; Generates the ship explosion animation and associated sound
; Called by: Camel_SpitHomeOnShip (JMP), Hyperdrive_InitialiseLevel (JMP),
; Player_CamelCollisionDetection (JMP)
;-------------------------------------------------------------------------------
*=$1DBE
Player_ShipExplosion
        LDA #VOICE_OFF
        STA VCREG1
        STA VCREG2
        STA VCREG3
        LDA #SPIT_STATE_BOMB
        STA camelSpitState
        LDA #1
        STA PWL2
        LDA #VOICE_ON_NOISE
        STA VCREG2
        LDA #WHITE
        STA SPRCOL0
        LDA #FALSE
        STA SPRMCS
        LDA #EXPLOSION_FRAME1
        JSR Player_UpdateShipFrame
        LDX #0
.ExplosionFrameUpdateLoop
        STX BDCOL
        LDY #0
.ExplosionFrameDelay ;.b1ded
        DEY
        BNE .ExplosionFrameDelay
        CPX #160
        BNE .SkipUpdateExplosionFrame
        INC SPRPTR0
.SkipUpdateExplosionFrame
        CPX #80
        BNE .SkipUpdateExplosionFrame2
        INC SPRPTR0
.SkipUpdateExplosionFrame2
        DEX
        BNE .ExplosionFrameUpdateLoop
        JMP .NextLine
.NextLine
        STA SPRPTR0
        LDA #SPR_CAMEL_AND_SHIP_MASK_ON 
        STA SPRXEX
        STA SPRYEX
        LDA #BLACK
        STA BDCOL
        LDA #SPR_SHIP_AND_RADAR_MASK_ON
        JSR Player_EnableExplosionSprites
        LDA shipX
        STA explosionX1
        STA explosionX2
        STA explosionX3
        STA explosionX4
        LDA shipY
        STA explosionY1
        STA explosionY2
        STA explosionY3
        STA explosionY4
.ExplosionX1Update
        LDA explosionX1
        BEQ .ExplosionX2Update
        INC explosionX1
.ExplosionX2Update
        LDA explosionX2
        BEQ .ExplosionX3Update
        INC explosionX2
.ExplosionX3Update
        LDA explosionX3
        BEQ .ExplosionX4Update
        DEC explosionX3
.ExplosionX4Update
        LDA explosionX4
        BEQ .ExplosionY1Update
        DEC explosionX4
.ExplosionY1Update
        LDA explosionY1
        BEQ .ExplosionY2Update
        INC explosionY1
.ExplosionY2Update
        LDA explosionY2
        BEQ .ExplosionY3Update
        DEC explosionY2
.ExplosionY3Update
        LDA explosionY3
        BEQ .ExplosionY4Update
        INC explosionY3
.ExplosionY4Update
        LDA explosionY4
        BEQ .EnableExplosionSprites
        DEC explosionY4
.EnableExplosionSprites
        LDY #0
.ExplosionSpriteDelayLoop
        DEY
        BNE .ExplosionSpriteDelayLoop
        LDA #EXPLOSION_FRAME1 
        STA SPRPTR1
        STA SPRPTR2
        STA SPRPTR3
        LDA #WHITE
        STA SPRCOL1
        STA SPRCOL2
        STA SPRCOL3
        LDA #SPR_EXPLOSION_MASK_ON
        STA SPRYEX
        STA SPRXEX
        STA SPREN
        LDX #2
.CheckNextExplosionY
        byte $BD, $43, $00 ;LDA $0043,X [explosionY1-1]
        BNE .UpdateExplosionSpriteX
        DEX
        BNE .CheckNextExplosionY
        JMP Player_ExplosionEnded
.UpdateExplosionSpriteX
        LDX #4
.ExplosionSpriteLoop
        STX zp04Tmp
        TXA
        CLC
        ASL
        STA zp05Tmp
        byte $BD, $43, $00 ;LDA $0043,X [explosionY1-1]
        LDX zp05Tmp
        STA SPRX0-1,X
        LDX zp04Tmp
        LDA #1
.SpriteMaskLoop
        ASL 
        DEX
        BNE .SpriteMaskLoop
        ROR 
        STA zp06Tmp
        LDX zp04Tmp
        byte $BD, $3F, $00 ;LDA $003F,X [explosionX1-1]
        CLC
        ASL
        LDX zp05Tmp
        STA SPRX0-2,X
        BCC .ClearExplosionXMSB
        LDA SPRXMSB
        ORA zp06Tmp
        STA SPRXMSB
        JMP .NextExplosionSprite
.ClearExplosionXMSB
        LDA zp06Tmp
        EOR #$FF
        AND SPRXMSB
        STA SPRXMSB
.NextExplosionSprite
        LDX zp04Tmp
        DEX
        CPX #$FF
        BNE .ExplosionSpriteLoop
        LDA #VOICE_OFF
        STA VCREG2
        LDA #VOICE_ON_NOISE
        STA VCREG2
        JMP Player_DecreaseExplosionCounter

;-------------------------------------------------------------------------------
; Player_UpdateShipFrame
; Updates sprite pointer 0 with the current ship frame
; Called by: Player_ShipExplosion (JSR) 
;-------------------------------------------------------------------------------
*=$1EE3 
Player_UpdateShipFrame
        STA SPRPTR0
        LDY #0
.UpdateShipFrameDelay
        DEY
        BNE .UpdateShipFrameDelay
        RTS

;-------------------------------------------------------------------------------
; Player_EnableExplosionSprites
; Enable the explosion sprite and reset the explosion counter
; Called by: Player_ShipExplosion (JSR)
;-------------------------------------------------------------------------------
*=$1EEC
Player_EnableExplosionSprites
        STA SPREN
        LDA #96
        STA explosionCounter
        RTS 

;-------------------------------------------------------------------------------
; Player_DecreaseExplosionCounter
; Decrease the counter for the explosion (0=finished)
; Called by: Player_ShipExplosion (JMP) 
;-------------------------------------------------------------------------------
*=$1EF4
Player_DecreaseExplosionCounter
        DEC explosionCounter
        BEQ .ExplosionComplete
        JMP .ExplosionX1Update
.ExplosionComplete
        JMP Player_DisableExplosionSprites

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$1EFE
        byte $15, $D0

;-------------------------------------------------------------------------------
; InitLevel_InitialseGameVariables
; Initialise variables at the start of a level
; Called by: InitLevel_InitSprites (JMP)
;-------------------------------------------------------------------------------
*=$1F00
InitLevel_InitialseGameVariables
        LDA #BULLET_NOT_ACTIVE
        STA bulletEnable
        STA bulletDirection
        LDA #BULLET_FRAME
        STA SPRPTR1
        LDA #10
        STA ATDCY3
        LDA #0
        STA SUREL3
        STA camelState
        LDA #CAMEL_HEAD_FRAME1
        STA camelHeadFrame
        LDA #255
        STA landPositionMinor
        LDA #9
        STA landPositionMajor
        LDA #0
        STA zpFFRedundant       ;never used
        STA zpFFRedundant       ;never used
        LDA #4
        STA camelLandPositionCounter
        LDA #0
        STA zpFFRedundant       ;never used
        SEI
        LDA #<IRQ_Main
        STA sysIntVectorLo_0314
        LDA #>IRQ_Main
        STA sysIntVectorHi_0315
        CLI
        LDA #CAMEL_FRAME_RATE
        STA camelFrameRate
        JSR Screen_DisplayStars
        LDA #0
        STA currentStar
        LDA #TWINKLE_RATE
        STA starTwinkleRate
        LDA #0
        STA zp21Tmp
        LDA #CAMEL_SPIT_SPEED
        STA camelSpitSpeedCounter
        STA camelSpitSpeed
        LDA #CAMEL_SPIT_RATE
        STA camelSpitRateCounter
        STA camelSpitRate
        LDA #CAMEL_SPIT_BOMB_RATE
        STA camelSpitBombRateCounter
        STA camelSpitBombRate
        LDA #SPIT_STATE_INACTIVE
        STA camelSpitState
        LDA #CAMEL_SPIT_BOMB_FRAME4
        STA camelSpitFrame
        LDA #WHITE
        STA SPRCOL2
        STA zp5ARedundant       ;never used
        LDA #0
        STA zp5CRedundant       ;never used
        STA damageFlashFlag
        LDA #4
        STA playerHealth
        STA scoreColourCounter
        STA scoreScreenHi
        LDA #BLACK
        STA BGCOL0
        NOP
        LDA #$D8
        STA scoreColourHi
        LDA SPRCSP
        LDA #1
        STA scoreBonus
        LDA camelsRemaining ;redundant
        STA camelsRemaining ;redundant
        LDA #ROCKET_MOVE_RATE
        STA rocketMoveRate
        LDA #CAMEL_SPEED
        STA camelSpeed
        LDA bottomRowFlag
        BEQ .SkipClearBottomRows
        JSR Screen_ClearBottomRows
.SkipClearBottomRows
        LDA #BOTTOM_ROWS_DO_CLEAR
        STA bottomRowFlag
        JSR Screen_DisplayCamelBonus
        JSR InitLevel_SetDifficulty
        LDA camelCollision ;redundant
        STA camelCollision ;redundant
        LDA #25
        STA FREH1
        LDA #FALSE
        STA collisionRegister
                
                        ; a bunch of NOPs
                        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                        byte $EA, $EA, $EA, $EA, $EA, $EA

        JMP Game_MainLoop

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$1FF3
UnknownData1FF3         byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
                        byte $EA, $EA, $EA, $EA, $EA

;===============================================================================
; Data
;===============================================================================
*=$2000 ; 64 chars only
CHARS
                        incbin "charsAMC.cst", 0, 63

*=$2200

landscapeRow1           byte $20, $20, $20, $20, $20, $1b, $23, $23
                        byte $20, $20, $20, $20, $20, $20, $20, $20
                        byte $20, $20, $20, $20, $20, $20, $20, $20
                        byte $20, $20, $20, $20, $20, $20, $20, $20
                        byte $20, $20, $1d, $1e, $20, $20, $20, $20

landscapeRow2           byte $20, $20, $20, $20, $1b, $1d, $2b, $2b
                        byte $1e, $23, $1c, $20, $20, $20, $20, $20
                        byte $20, $20, $20, $20, $20, $20, $20, $20
                        byte $20, $20, $1b, $23, $1c, $1b, $1f, $1d
                        byte $23, $1d, $2b, $2b, $1e, $20, $20, $20

landscapeRow3           byte $20, $20, $1b, $23, $1d, $2b, $2b, $2b
                        byte $2b, $2b, $2b, $1e, $20, $20, $20, $20
                        byte $20, $20, $1d, $1e, $20, $20, $20, $20
                        byte $20, $1b, $1d, $2b, $1e, $1d, $2b, $2b
                        byte $2b, $2b, $2b, $2b, $2b, $1e, $20, $20

landscapeRow4           byte $1f, $1f, $1d, $2b, $2b, $2b, $2b, $2b
                        byte $2b, $2b, $2b, $2b, $1e, $23, $1f, $1f
                        byte $1f, $1d, $2b, $2b, $1e, $1f, $1f, $1f
                        byte $1f, $1d, $2b, $2b, $2b, $2b, $2b, $2b
                        byte $2b, $2b, $2b, $2b, $2b, $2b, $1e, $1f

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$22A0
UnknownData22A0         byte $13, $19, $13, $33, $32, $37, $36, $38

;===============================================================================
; Data
;===============================================================================
*=$22A8
tbl_shipSpeeds          byte $ff, $0a, $08, $06, $04, $02, $01, $01
                        byte $01, $01, $01, $01, $01, $01, $01, $01

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$22B8
UnknownData22B8         byte $20, $20, $20, $20, $20, $20, $20, $20
                        byte $20, $20, $20, $20, $20, $20, $20, $20

;===============================================================================
; Data
;===============================================================================
*=$22C8
tbl_PlayerStats
tbl_CamelCurrentColour  byte $07, $07, $07, $07, $07, $07, $07, $07

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$22D0
UnknownData22D0         byte $00, $00, $00, $00, $00, $00, $00, $00

;===============================================================================
; Data
;===============================================================================
*=$22D8
tbl_camelMarkerScreenLo byte $07, $0b, $0f, $13, $17, $1b, $1b, $1c

*=$22E0
tbl_CamelHealthMinor    byte $10, $10, $10, $10, $10, $10, $10, $10

*=$22E8
tbl_CamelHealth         byte $06, $06, $06, $06, $06, $06, $06, $06


;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$22F0
UnknownData22F0         byte $00, $00, $00, $00, $00, $00, $00, $00
                        byte $ff, $ff, $00, $00, $ff, $ff, $00, $ff

;===============================================================================
; Data
;===============================================================================
*=$2300
tbl_starScreenX         byte $04, $07, $12, $09, $07, $15, $18, $0c
                        byte $23, $13, $19, $04, $20, $22, $01, $25

*=$2310
tbl_starScreenY         byte $06, $06, $07, $08, $09, $0a, $07, $09
                        byte $09, $08, $08, $07, $09, $06, $09, $07

*=$2320
tbl_CamelHeadFrame      byte $02, $d9, $da, $d9

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$2324
                        byte $ff, $ff, $ff, $00, $ff, $ff, $ff, $ff
                        byte $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
                        byte $ff, $ff, $ff, $ff, $fd, $ff, $ff, $ff
                        byte $ff, $ff, $ff, $ff, $00, $00, $00, $00
                        byte $00, $00, $00, $00, $00, $00, $00, $00
                        byte $00, $00, $00, $00, $00, $00, $00, $00
                        byte $00, $00, $00, $00, $00, $00, $02, $03
                        byte $02, $00, $00, $00, $00, $00, $00, $00
                        byte $00, $00, $00, $00, $00, $00, $00, $00
                        byte $00, $00, $00, $00, $00, $00, $00, $00
                        byte $00, $00, $00, $00, $00, $00, $00, $02
                        byte $00, $00, $00, $00, $00, $00, $ff, $00
                        byte $ff, $ff, $ff, $00, $ff, $ff, $ff, $ff
                        byte $ff, $ff, $ff, $ff, $fb, $ff, $04, $ff
                        byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
                        byte $18, $ff, $e7, $00, $ff, $00, $ff, $ff
                        byte $ff, $ff, $ff, $00, $ff, $ff, $ff, $ff
                        byte $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
                        byte $ff, $ff, $ff, $ff, $ff, $ff, $01, $02
                        byte $02, $ff, $00, $4a, $00, $00, $00, $00
                        byte $01, $00, $07, $07, $00, $00, $01, $00
                        byte $00, $00, $25, $00, $00, $00, $00, $00
                        byte $00, $00, $00, $00, $00, $00, $00, $00
                        byte $00, $00, $b3, $00, $00, $00, $00, $00
                        byte $00, $00, $ff, $00, $00, $00, $00, $00
                        byte $00, $00, $00, $00, $00, $00, $00, $00
                        byte $00, $00, $00, $00, $00, $00, $00, $00
                        byte $00, $00, $00, $00

;-------------------------------------------------------------------------------
; InitLevel_InitialiseCamelStats
; Copies over the init stats for the camels at the beginning of each level
; Called by: InitLevel_InitialisePlayerStatsD (JMP), Camel_ResetCamelPosition (JSR) 
;-------------------------------------------------------------------------------
*=$2400
InitLevel_InitialiseCamelStats
        LDY #8
.InitCamelStatsLoop
        LDA tbl_InitCamelMarkerScreenLo-1,Y
        STA tbl_camelMarkerScreenLo-1,Y
        LDA tbl_InitCamelHealthMinor-1,Y
        STA tbl_CamelHealthMinor-1,Y
        LDA tbl_InitCamelHealth-1,Y
        STA tbl_CamelHealth-1,Y
        JMP InitLevel_InitialiseCamelColour
        RTS

;===============================================================================
; Data
;===============================================================================
*=$2418
tbl_InitCamelMarkerScreenLo     byte $03, $07, $0B, $0F, $13, $17, $1B, $1C
*=$2420
tbl_InitCamelHealthMinor        byte $10, $10, $10, $10, $10, $10, $10, $10 
*=$2428
tbl_InitCamelHealth             byte $06, $06, $06, $06, $06, $06, $06, $06
*=$2430
tbl_CamelColours                byte $ff, LGREEN, RED, BLUE, LGREY, BROWN, YELLOW, YELLOW

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$2438
UnknownData2438                 byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

;-------------------------------------------------------------------------------
; InitLevel_InitialiseCamelColour
; Sets the init colour for all camels to yellow
; Called by: InitLevel_InitialiseCamelStats (JMP)
;-------------------------------------------------------------------------------
*=$2440
InitLevel_InitialiseCamelColour
        LDA #YELLOW
        STA tbl_CamelCurrentColour-1,Y
        DEY
        BNE .InitCamelStatsLoop
        RTS

;-------------------------------------------------------------------------------
; IRQ_FlashPlayerScore
; Routine to flash the score of the active players
; Called by: IRQ_MoveCamelBackLegs (JSR)
;-------------------------------------------------------------------------------
*=$2449
IRQ_FlashPlayerScore
        DEC scoreColourCounter
        BNE .SelectScoreColour
        LDA #4
        STA scoreColourCounter
.SelectScoreColour
        LDX scoreColourCounter
        LDA tbl_scoreFlashColours-1,X
        LDY #7
.ScoreColourLoop
        STA (ScoreColourLo),Y
        DEY
        BNE .ScoreColourLoop
        RTS

;===============================================================================
; Data
;===============================================================================
*=$245E
tbl_scoreFlashColours   byte LBLUE, YELLOW, PINK, WHITE

;-------------------------------------------------------------------------------
; Score_IncreaseScore
; Adds 1 to the current score. Called with Y=no. of digits, x=multiplier
; Called by: Score_Add1Point (JMP), Score_AddBonusPoints (JSR)
;-------------------------------------------------------------------------------
        NOP
*=$2463
Score_IncreaseScore
        STY zp07Tmp
.NextScoreDigit
        LDA (scoreScreenLo),Y
        CLC
        ADC #1
        STA (scoreScreenLo),Y
        CMP #CHAR_9+1
        BNE .NextMultiplier
        LDA #CHAR_0
        STA (scoreScreenLo),Y
        DEY
        BNE .NextScoreDigit
.NextMultiplier
        LDY zp07Tmp
        DEX
        BNE Score_IncreaseScore
        RTS

;-------------------------------------------------------------------------------
; Score_Add1Point
; Calls the score increase routine with a single point for a camel hit
; Called by: Bullet_MoveBullet (JSR)
;-------------------------------------------------------------------------------
*=$247D
Score_Add1Point
        JSR Camel_DecreaseCamelHealth
        LDY #7 ;last digit
        LDX #1 ;add 1
        JMP Score_IncreaseScore

;-------------------------------------------------------------------------------
; Score_AddBonusPoints
; Adds the current bonus points once the level is complete
; Called by: Camel_DecreaseCamelHealth (JSR)
;-------------------------------------------------------------------------------
*=$2487
Score_AddBonusPoints
        byte $8D, $46, $00 ;STA $0046 [camelKilledID]
        TXA
        PHA
        LDA scoreBonus
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        TAX
        LDY #5 ;digit 5
        JSR Score_IncreaseScore
        LDA scoreBonus
        CMP #64
        BEQ .scoreBonusAtMax
        ASL
.scoreBonusAtMax
        STA scoreBonus
        JSR Screen_DisplayCamelBonus
        PLA
        TAX
        RTS

;-------------------------------------------------------------------------------
; Screen_DisplayCamelBonus
; Display the current camel end of level bonus on the screen
; Called by: InitLevel_InitialseGameVariables (JSR), Score_AddBonusPoints (JSR)
;-------------------------------------------------------------------------------
*=$24AA
Screen_DisplayCamelBonus
        LDA #CHAR_SPACE
        STA SCN_BONUS
        STA SCN_BONUS+1
        LDA #CHAR_0
        STA SCN_BONUS+2
        LDY scoreBonus
.DisplayBonusLoop
        LDX #3
.IncreaseBonusCharLoop
        INC SCN_BONUS-1,X
        LDA SCN_BONUS-1,X
        CMP #CHAR_9+1
        BNE .SkipResetBonusChar
        LDA #CHAR_0
        STA SCN_BONUS-1,X
        DEX
        BEQ .SkipResetBonusChar
        LDA SCN_BONUS-1,X
        CMP #CHAR_SPACE
        BNE .IncreaseBonusCharLoop
        LDA #CHAR_0
        STA SCN_BONUS-1,X
        JMP .IncreaseBonusCharLoop
.SkipResetBonusChar
        DEY
        BNE .DisplayBonusLoop
        RTS

;-------------------------------------------------------------------------------
; Camel_CheckRemainingCamels
; Check to see if all camels are dead
; Called by: Camel_Dying (JMP)
;-------------------------------------------------------------------------------
*=$24E0
Camel_CheckRemainingCamels
        DEC camelsRemaining
        BEQ .LevelCleared
        JMP Camel_ResetHeadSprite
.LevelCleared
        JMP Player_NextSector

;-------------------------------------------------------------------------------
; Bullet_ReadCollisionRegister
; Redundant routine which essentially does LDA collisionRegister
; Called by: Bullet_MoveBullet (JSR)
;-------------------------------------------------------------------------------
*=$24EA
Bullet_ReadCollisionRegister
        NOP
        byte $AD, $95, $00 ;LDA $0095 [collisionRegister]
        STA collisionRegister
        AND #0
        BNE .ClearRegisterExit
        LDA collisionRegister
.ClearRegisterExit
        RTS

;-------------------------------------------------------------------------------
; Player_UpdateShipSprite
; Updates the X and Y values for the ship sprite
; Called by: Hyperdrive_EngageHyperdrive (JSR), Hyperdrive_UpdatePlayer (JSR),
; Hyperdrive_MoveLandscape (JMP), Hyperdrive_Finishing (JMP)
;-------------------------------------------------------------------------------
*=$24F7
Player_UpdateShipSprite       
        LDA shipY
        STA SPRY0
        LDA shipX
        ASL
        STA SPRX0
        BCC .ResetShipXMSB
        LDA SPRXMSB
        ORA #SPR_SHIP_MASK_ON
        STA SPRXMSB
        RTS
.ResetShipXMSB
        LDA SPRXMSB
        AND #SPR_SHIP_MASK_OFF
        STA SPRXMSB
        RTS

;-------------------------------------------------------------------------------
; Hyperdrive_EngageHyperdrive
; Initialise the hyperdrive stage of the game, including the hyperdrive sound
; Called by: Camel_ResetCamelsRemaining (JMP)
;-------------------------------------------------------------------------------
*=$2516
Hyperdrive_EngageHyperdrive
        LDA #VOICE_OFF
        STA VCREG1
        STA VCREG2
        STA VCREG3
        LDA #SPIT_STATE_DISABLED
        STA camelSpitState 
        LDA #160
        STA shipX
        LDA shipY
        STA shipY
        JSR Hyperdrive_ResetShipSpriteFrame
        NOP
        JSR Player_UpdateShipSprite
        LDX #32
.HyperdriveTextLoop
        LDA txt_HyperdriveEngaging-1,X
        STA SCNROW24+2,X
        LDA #WHITE
        STA COLROW24+2,X
        DEX
        BNE .HyperdriveTextLoop
        LDX #32
.HyperdriveSoundLoopMajor
        LDA #0
        STA zp07Tmp
        STA zp08Tmp
.HyperdriveSoundLoopMinor
        LDA zp08Tmp
        STA FREL1
        LDA zp07Tmp
        STA FREH1
        LDA #VOICE_OFF
        STA VCREG1
        LDA #VOICE_ON_SAW
        STA VCREG1
        LDA zp08Tmp
        CLC
        ADC #48
        STA zp08Tmp
        LDA zp07Tmp
        ADC #0
        STA zp07Tmp
        STA BDCOL
        CMP #255
        BNE .HyperdriveSoundLoopMinor
        DEX
        BNE .HyperdriveSoundLoopMajor
        JMP Hyperdrive_InitialiseLevel

;===============================================================================
; Data
;===============================================================================
*=$257A
txt_HyperdriveEngaging  text 'trans sector hyperdrive engaging'

;-------------------------------------------------------------------------------
; Hyperdrive_ResetShipSprite
; Enable ship and rocket sprite for hyperdrive
; Called by: Hyperdrive_ResetShipSpriteFrame (JMP)
;-------------------------------------------------------------------------------
*=$259A
Hyperdrive_ResetShipSprite
        LDA #YELLOW
        STA SPRMC0
        LDA #SPR_SHIP_AND_ROCKET_MASK_ON
        STA SPREN
        RTS

;-------------------------------------------------------------------------------
; Hyperdrive_InitialiseLevel
; Main hyperdrive game loop and init routine
; Called by: Hyperdrive_EngageHyperdrive (JMP)
;-------------------------------------------------------------------------------
*=$25A5
Hyperdrive_InitialiseLevel
        LDA #BLACK
        STA BDCOL
        STA VCREG1
        LDA SPRCSP
        LDA #SHIP_FACE_LEFT
        STA shipDirection
        LDA #HYPERDRIVE_UPDATE_PLAYER_RATE
        STA hyperdriveUpdatePlayerCounter
        STA hyperdriveUpdatePlayerRate
        LDA #16
        STA currentEnemyID
        JSR Hyperdrive_InitialiseRocket
        NOP
        NOP
.MainHyperdriveLoop
        JSR Hyperdrive_UpdatePlayer
        JSR Hyperdrive_MoveLandscape
        JSR Hyperdrive_MoveRocket
        LDA SPRCSP
        BEQ .NoCollisionWithRocket
        JMP Player_ShipExplosion
.NoCollisionWithRocket
        LDA shipX
        CMP #64
        BEQ .ReachedLevelEnd
        JMP .MainHyperdriveLoop
.ReachedLevelEnd
        JMP Hyperdrive_ClearRocketSprite

;-------------------------------------------------------------------------------
; Hyperdrive_UpdatePlayer
; Gets player input and moves the ship during hyperdrive
; Called by: Hyperdrive_InitialiseLevel (JSR)
;-------------------------------------------------------------------------------
*=$25E0
Hyperdrive_UpdatePlayer
        DEC hyperdriveUpdatePlayerCounter
        BEQ .UpdatePlayer
        RTS
.UpdatePlayer
        LDA hyperdriveUpdatePlayerRate
        STA hyperdriveUpdatePlayerCounter
        LDA shipX
        JSR Player_UpdateShipSprite
        JSR Input_CheckJoy
        LDA #161
        SBC shipX
        STA FREH1
        LDA #VOICE_OFF
        STA VCREG1
        LDA #VOICE_ON_NOISE
        STA VCREG1
        NOP
        NOP
        NOP
        NOP
        RTS

;-------------------------------------------------------------------------------
; Hyperdrive_MoveLandscape
; Moves landscape during hyperdrive (speed changes)
; Called by: Hyperdrive_InitialiseLevel (JSR)
;-------------------------------------------------------------------------------
*=$2607
Hyperdrive_MoveLandscape
        DEC hyperdriveShipMoveCounter
        BEQ .CheckLandscapeMoveCounter
        RTS
.CheckLandscapeMoveCounter
        LDA currentEnemyID
        STA hyperdriveShipMoveCounter
        DEC hyperdriveLandscapeMoveCounter
        BEQ .MoveLandscape
        RTS
.MoveLandscape
        LDA hyperdriveLandscapeMoveRate
        STA hyperdriveLandscapeMoveCounter
        JSR Game_MoveLandscape
        DEC shipX
        DEC hyperdriveLandscapeMoveRate
        JMP Player_UpdateShipSprite

;-------------------------------------------------------------------------------
; Hyperdrive_InitialiseCounters
; Sets up the counters for the hyperdrive stage
; Called by: Hyperdrive_InitialiseRocket (JMP)
;-------------------------------------------------------------------------------
*=$2623
Hyperdrive_InitialiseCounters
        LDA #HYPERDRIVE_LANDSCAPE_RATE
        STA hyperdriveLandscapeMoveCounter
        STA hyperdriveLandscapeMoveRate
        LDA #HYPERDRIVE_SHIP_RATE
        STA hyperdriveShipMoveCounter
        RTS

;-------------------------------------------------------------------------------
; Hyperdrive_AnimateShip
; Animates the ship as it enter hyperdrive
; Called by: Hyperdrive_ClearRocketSprite (JMP)
;-------------------------------------------------------------------------------
*=$262E
Hyperdrive_AnimateShip
        LDA #SPR_SHIP_MASK_ON
        STA SPRXEX
        LDA shipX
        CMP #224
        BEQ .ExitAnimateShip
        LDA #1
        STA hyperdriveLandscapeMoveRate
        LDA shipX
        STA SPRMC0
        ADC #8
        STA SPRMC1
        LDA RASTER
        STA FREH2
        LDA #VOICE_OFF
        STA VCREG2
        LDA #VOICE_ON_SAW
        STA VCREG2
        JSR Hyperdrive_DecreaseShipX
        JMP Hyperdrive_ClearRocketSprite
.ExitAnimateShip
        JMP Hyperdrive_Jumping

;-------------------------------------------------------------------------------
; Hyperdrive_DecreaseShipX
; Moves the ship to the left edge of the screen
; Called by: Hyperdrive_AnimateShip (JSR)
;-------------------------------------------------------------------------------
*=$2660
Hyperdrive_DecreaseShipX
        LDA hyperdriveShipMoveCounter
        CMP #1
        BNE .HyperdriveUpdateLandscape
        DEC shipX
.HyperdriveUpdateLandscape
        JSR Game_MoveLandscape
        JMP Hyperdrive_MoveLandscape

;-------------------------------------------------------------------------------
; Hyperdrive_Jumping
; Starts the end sequence of hyperdrive
; Called by: Hyperdrive_AnimateShip (JMP)
;-------------------------------------------------------------------------------
*=$266E
Hyperdrive_Jumping
        LDA #VOICE_OFF
        STA VCREG2
        LDY #32 ;redundant
        LDX #0
.BlackWhiteScreenFlashLoop
        TXA
        AND #1
        STA BDCOL
        EOR #1
        STA BGCOL0
        JSR .LandscapeUpdate
        STA FREH1
        LDA #VOICE_OFF
        STA VCREG1
        LDA #VOICE_ON_NOISE
        STA VCREG1
        DEX
        BNE .BlackWhiteScreenFlashLoop
        NOP
        NOP
        NOP        
        LDA #BLACK
        STA BDCOL
        STA BGCOL0
        JMP Hyperdrive_ResetShipY
.LandscapeUpdate
        TXA
        PHA
        JSR Game_MoveLandscape
        PLA
        TAX
        LDA RASTER ;used as pseudo-random number
        RTS

;-------------------------------------------------------------------------------
; Hyperdrive_Finishing
; Clears the hyperdrive message and resets the sound
; Called by: Hyperdrive_ResetShipY (JMP)
;-------------------------------------------------------------------------------
*=$26AE
Hyperdrive_Finishing
        LDA #SPR_CAMEL_MASK_ON
        STA SPRYEX
        STA SPRXEX
        LDX #32
        LDA #CHAR_SPACE
.ClearHyperdriveMessageLoop
        STA SCNROW24+2,X
        DEX
        BNE .ClearHyperdriveMessageLoop
        LDA #LBLUE
        STA SPRMC1
        LDA #0
        STA hyperdriveUpdatePlayerCounter
        STA hyperdriveUpdatePlayerRate 
.ShipHyperdriveSoundLoop
        LDA hyperdriveUpdatePlayerCounter
        STA shipX
        STA FREH1
        ADC #128
        STA FREH2
        LDA #VOICE_OFF
        STA VCREG1
        STA VCREG2
        LDA #VOICE_ON_SAW
        STA VCREG1
        STA VCREG2
        JSR .FlashShipSpriteColour
        INC hyperdriveUpdatePlayerCounter
        LDA hyperdriveUpdatePlayerCounter
        CMP #160
        BNE .ShipHyperdriveSoundLoop
        INC hyperdriveUpdatePlayerRate
        LDA hyperdriveUpdatePlayerRate 
        CMP #160
        BEQ .EndHyperdrive
        LDA hyperdriveUpdatePlayerRate
        STA hyperdriveUpdatePlayerCounter
        JMP .ShipHyperdriveSoundLoop
.EndHyperdrive
        JMP .ExitHyperdriveFinishing
.FlashShipSpriteColour
        INC SPRMC0
        JMP Player_UpdateShipSprite
.ExitHyperdriveFinishing
        LDA #VOICE_OFF
        STA VCREG1
        STA VCREG2
        JMP Hyperdrive_Ended

;-------------------------------------------------------------------------------
; Hyperdrive_InitialiseRocket
; Sets up the rocket sprite for the hyperdrive sequence
; Called by: Hyperdrive_InitialiseLevel (JSR)
;-------------------------------------------------------------------------------
*=$2715
Hyperdrive_InitialiseRocket
        LDA #240
        STA rocketX
        LDA #SPR_ROCKET_MASK_ON 
        STA SPRXEX
        LDA rocketMoveRate
        STA enemyMoveCounterMajor
        LDA #7
        STA enemyMoveCounterMinor
        LDA #7
        STA landPositionMajor
        JMP Hyperdrive_InitialiseCounters

;-------------------------------------------------------------------------------
; Hyperdrive_MoveRocket
; Moves the rocket in relation to the player ship position
; Called by: Hyperdrive_InitialiseLevel (JSR)
;-------------------------------------------------------------------------------
*=$272D
Hyperdrive_MoveRocket
        DEC enemyMoveCounterMajor
        BEQ .MoveRocket
        RTS
.MoveRocket
        LDA rocketMoveRate
        STA enemyMoveCounterMajor
        LDA rocketX
        CMP #240
        BNE .IncreaseRocketX
        LDA shipY
        SBC #16
        STA SPRY2
        LDA RASTER ;used to generate pseudo-random number
        AND #31
        CLC
        ADC SPRY2
        STA SPRY2
.IncreaseRocketX
        INC rocketX
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        LDA rocketX
        ASL
        STA SPRX2
        BCC .ClearRocketXMSB
        LDA SPRXMSB
        ORA #SPR_ROCKET_MASK_ON
        STA SPRXMSB
        JMP .SetRocketSpriteFrame
.ClearRocketXMSB
        LDA SPRXMSB
        AND #SPR_ROCKET_MASK_OFF
        STA SPRXMSB
.SetRocketSpriteFrame
        LDX enemyMoveCounterMinor
        LDA tbl_rocketFrames-1,X
        STA SPRPTR2
        DEC landPositionMajor
        BEQ Hyperdrive_SetRocketHoming
.ExitMoveRocket
        RTS

;-------------------------------------------------------------------------------
; Hyperdrive_DecreaseCounter
; Decrease the counter for hyperdrive enemy movement
; Called by: Hyperdrive_SetRocketHoming (JMP)
;-------------------------------------------------------------------------------
*=$2781
Hyperdrive_DecreaseCounter
        LDA #7
        STA landPositionMajor
        DEC enemyMoveCounterMinor
        BNE .ExitMoveRocket
        LDA #7
        STA enemyMoveCounterMinor
        RTS

;===============================================================================
; Data
;===============================================================================
*=$278E
tbl_rocketFrames        byte $db, $dc, $dd, $de, $dd, $dc, $db

;-------------------------------------------------------------------------------
; Hyperdrive_SetRocketHoming
; Home rocket in on player Y position
; Called by: Hyperdrive_MoveRocket (Branch)
;-------------------------------------------------------------------------------
*=$2795
Hyperdrive_SetRocketHoming
        LDA SPRY2
        CMP shipY
        BPL .MoveRocketUp
        INC SPRY2
        INC SPRY2
.MoveRocketUp
        DEC SPRY2
        JMP Hyperdrive_DecreaseCounter

;-------------------------------------------------------------------------------
; Hyperdrive_ClearRocketSprite
; Switch off the rocket sprite
; Called by: Hyperdrive_InitialiseLevel (JMP), Hyperdrive_AnimateShip (JMP)
;-------------------------------------------------------------------------------
*=$27A8
Hyperdrive_ClearRocketSprite
        LDA #SPR_SHIP_MASK_ON 
        STA SPREN
        JMP Hyperdrive_AnimateShip

;-------------------------------------------------------------------------------
; Hyperdrive_ResetShipSpriteFrame
; Reset the current ship frame
; Called by: Hyperdrive_EngageHyperdrive (JSR)
;-------------------------------------------------------------------------------
*=$27B0
Hyperdrive_ResetShipSpriteFrame
        STA SPREN ;erroneous store, corrected after
        LDA #SHIP_LEFT_FRAME
        STA shipSpriteFrame
        STA SPRPTR0
        JMP Hyperdrive_ResetShipSprite

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$27BD
        DEC $6B
        BEQ Game_ResetCamelSpeedCounter
        RTS

;-------------------------------------------------------------------------------
; Game_ResetCamelSpeedCounter
; Reset the camel speed counter
; Called by: Camel_Move (JSR)
;-------------------------------------------------------------------------------
*=$27C2
Game_ResetCamelSpeedCounter
        LDA camelSpeed
        STA camelSpeedCounter
        DEC enemyMoveCounterMinor
        RTS

;-------------------------------------------------------------------------------
; Camel_TestShipSpitXMatch
; Calculate the X difference between the camel spit and the player's ship
; Called by: Camel_SetSpitPosition (JSR)
;-------------------------------------------------------------------------------
*=$27C9
Camel_TestShipSpitXMatch
        STA camelSpitX 
        LDA shipX
        CLC
        ROR
        STA zp07Tmp
        LDA camelSpitX 
        CLC
        ROR
        CMP zp07Tmp
        RTS

;-------------------------------------------------------------------------------
; InitLevel_InitialisePlayerStats
; Copies player stats into a temporary area, for 2 player mode/player switch
; Called by: Init_Restart (JMP) 
;-------------------------------------------------------------------------------
*=$27D8
InitLevel_InitialisePlayerStats
        LDA player2Lives
        CLC
        ADC #0
        STA player2Lives ;redundant
        NOP
        LDA playerTurn
        STA playerTurn ;redundant
        LDA playerSector
        STA playerSector ;redundant
        STA P1_LEVELSTATS+3 ;sector
        LDA #0
        STA P1_LEVELSTATS+1 ;camel position minor
        STA P1_LEVELSTATS+2 ;camel position major
        JSR InitLevel_InitialisePlayerStatsB
        LDX #48
.InitialisePlayer1Stats
        LDA tbl_PlayerStats-1,X 
        STA PLAYER1STATS,X
        DEX
        BNE .InitialisePlayer1Stats
        NOP
        NOP
        NOP
        JMP InitLevel_InitSprites

;-------------------------------------------------------------------------------
; Player_LoseLife
; Routine to decrease player lives after ship explosion
; Called by: Player_CheckLives (JMP)
;-------------------------------------------------------------------------------
*=$2807
Player_LoseLife
        LDA playerTurn
        CMP #2  ;game initialises with player 2 with 1/6 lives and calls this routine
        BEQ .DecreasePlayer2Lives
        LDA player1Lives
        BEQ .DecreasePlayer2Lives
        DEC player1Lives
        LDA #2
        STA playerTurn
        JMP .Player2Selected
.DecreasePlayer2Lives
        DEC player2Lives
        JMP InitLevel_InitialseGameVariablesB

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$281F
        JMP ($05D0) ;not actually reached
.b2822
        JMP .b2822
        DEC player2Lives

;-------------------------------------------------------------------------------
; InitLevel_InitialseGameVariablesB
; Copies back out the stored level data when play switches between players
; Called by: Player_LoseLife (JMP)
;-------------------------------------------------------------------------------
*=$2827
InitLevel_InitialseGameVariablesB
        LDA #1
        STA playerTurn
.Player2Selected
        LDA #>PLAYER1STATS
        STA zpHi5
        LDA #<PLAYER1STATS
        STA zpLo5
        LDA playerTurn
        CMP #1
        BNE .SkipPlayer2StatOffset
        INC zpHi5
.SkipPlayer2StatOffset
        LDY #48
.InitialisePlayerStatsLoop
        LDA tbl_PlayerStats-1,Y
        STA (zpLo5),Y
        DEY
        BNE .InitialisePlayerStatsLoop
        LDY #49
        LDA camelPositionMinor
        STA (zpLo5),Y
        INY
        LDA camelPositionMajor
        STA (zpLo5),Y
        INY
        LDA playerSector
        STA (zpLo5),Y
        JSR Init_StoreCamelsRemaining
        LDA playerTurn
        CMP #2
        BEQ .SetPlayer2ScreenOffset
        LDA #>PLAYER1STATS
        STA zpHi5
        LDA #<SCN_PL1SCORE
        STA scoreScreenLo
        STA scoreColourLo
        JMP .CopyPlayerInitStats
.SetPlayer2ScreenOffset
        LDA #>PLAYER2STATS
        STA zpHi5
        LDA #<SCN_PL2SCORE
        STA scoreScreenLo
        STA scoreColourLo
.CopyPlayerInitStats
        LDY #48
.CopyInitStatsLoop
        LDA (zpLo5),Y
        STA tbl_PlayerStats-1,Y
        DEY
        BNE .CopyInitStatsLoop
        LDY #49
        LDA (zpLo5),Y
        STA camelPositionMinor
        INY
        LDA (zpLo5),Y
        STA camelPositionMajor
        INY
        LDA (zpLo5),Y
        STA playerSector
        JSR Init_ReadCamelsRemaining
.PrepareToStart
        JSR InitLevel_PrepareToStart
        RTS

;-------------------------------------------------------------------------------
; InitLevel_InitialisePlayerStatsD
; Continuation of routine to initialise level stats
; Called by: InitLevel_InitialisePlayerStatsC (JMP)
;-------------------------------------------------------------------------------
*=$2896
InitLevel_InitialisePlayerStatsD
        LDA #6
        STA camelsRemaining
        STA P1_LEVELSTATS+4
        JMP InitLevel_InitialiseCamelStats

;-------------------------------------------------------------------------------
; Init_StoreCamelsRemaining
; Continuation of routine to store players stats in temporary location
; Called by: InitLevel_InitialseGameVariablesB (JSR)
;-------------------------------------------------------------------------------
*=$28A0
Init_StoreCamelsRemaining
        INY
        LDA camelsRemaining
        STA (zpLo5),Y
        RTS

;-------------------------------------------------------------------------------
; Init_ReadCamelsRemaining
; Continuation of routine to recover player stats from temporary location
; Called by: InitLevel_InitialseGameVariablesB (JSR) 
;-------------------------------------------------------------------------------
*=$28A6
Init_ReadCamelsRemaining
        INY
        LDA (zpLo5),Y
        STA camelsRemaining
        RTS

;-------------------------------------------------------------------------------
; Player_ExplosionEnded
; End of the player explosion routine
; Called by: Player_DisableExplosionSprites (JMP), Player_ShipExplosion (JMP)
;-------------------------------------------------------------------------------
*=$28AC
Player_ExplosionEnded
        LDX #$F6
        TXS ;redundant - possibly used to alter a JSR?
        NOP
        NOP
        NOP
        NOP
        JMP InitLevel_InitSprites

;-------------------------------------------------------------------------------
; InitLevel_PrepareToStart
; Displays level start message and plays intro sound
; Called by: InitLevel_InitialseGameVariablesB (JSR)
;-------------------------------------------------------------------------------
*=$28B6
InitLevel_PrepareToStart
        LDX #7
        LDA #WHITE
.SetScoreColourLoop
        STA COL_PL1SCORE,X
        STA COL_PL2SCORE,X
        DEX
        BNE .SetScoreColourLoop
        LDX #40
        LDA #CHAR_SPACE
.ClearCamelRadarLoop
        STA SCN_CAMELRADAR,X
        DEX
        BNE .ClearCamelRadarLoop
        LDX #11
.DisplayPlayTextLoop
        LDA txt_PlayPlayer-1,X
        STA SCN_PLAYTEXT,X
        LDA #LBLUE
        STA COL_PLAYTEXT,X
        DEX
        BNE .DisplayPlayTextLoop
        LDX #13
        LDA playerTurn
        CMP #2
        BNE .SkipPlayer2Offset
        LDX #16
.SkipPlayer2Offset
        LDY #3
.DisplayPlayerNoTextLoop
        LDA txt_PlayPlayer-1,X
        STA SCN_PLAYERTEXT,Y
        LDA #YELLOW
        STA COL_PLAYERTEXT,Y
        INX
        DEY
        BNE .DisplayPlayerNoTextLoop
        LDA #240
        STA zp07Tmp
.IntroSoundOuterLoop
        LDX zp07Tmp
.IntroSoundInnerLoop
        STX FREH1
        LDY #16
.DecreaseFrequencyLoop
        STA FREL1
        DEY
        BNE .DecreaseFrequencyLoop
        STY VCREG1
        LDA #VOICE_ON_TRIANGLE
        STA VCREG1
        DEX
        BNE .IntroSoundInnerLoop
        DEC zp07Tmp
        BNE .IntroSoundOuterLoop
        LDX #40
        LDA #CHAR_SPACE
.ResetCamelRadarLoop
        STA SCN_CAMELRADAR,X
        DEX
        BNE .ResetCamelRadarLoop
        LDX #6
        JMP Screen_DisplayCamelMarker

;===============================================================================
; Data
;===============================================================================
*=$2927
txt_PlayPlayer          text 'play player enoowt'

;-------------------------------------------------------------------------------
; InitLevel_InitialisePlayerStatsB
; Continuation of initialisation routine
; Called by: InitLevel_InitialisePlayerStats (JSR)
;-------------------------------------------------------------------------------
*=$2939
InitLevel_InitialisePlayerStatsB
        STA camelPositionMinor
        STA camelPositionMajor
        JMP Sound_InitFrequency3

;-------------------------------------------------------------------------------
; Screen_DisplayCamelMarker
; Displays the camel markers on the screen radar
; Called by: InitLevel_PrepareToStart (JMP), Camel_ResetCamelPosition (JSR)
;-------------------------------------------------------------------------------
*=$2940
Screen_DisplayCamelMarker
        LDX #6
.DisplayCamelMarkerLoop
        LDA tbl_CamelHealth-1,X
        CMP #$FF
        BEQ .NextCamelMarker
        JSR .SetCamelMarkerScreenLo
        NOP
        STA zpHi
        LDA #CHAR_CAMEL
        STA charToPlot
        LDA #WHITE
        STA colourToPlot
        STX zp2CTmp
        JSR Screen_Plot
        LDX zp2CTmp
.NextCamelMarker
        DEX
        BNE .DisplayCamelMarkerLoop
        RTS
.SetCamelMarkerScreenLo
        LDA tbl_camelMarkerScreenLo-1,X
        STA zpLo
        LDA #4
        RTS

;-------------------------------------------------------------------------------
; InitLevel_InitialisePlayerStatsC
; Continuation of initialisation routine
; Called by: Sound_InitFrequency3 (JMP)
;-------------------------------------------------------------------------------
*=$296A
InitLevel_InitialisePlayerStatsC
        LDA #BOTTOM_ROWS_DO_CLEAR
        STA bottomRowFlag
        JMP InitLevel_InitialisePlayerStatsD ;DONE

;-------------------------------------------------------------------------------
; Screen_ClearBottomRows
; Clears rows 23 and 24 of the screen
; Called by: InitLevel_InitialseGameVariables (JSR)
;-------------------------------------------------------------------------------
*=$2971
Screen_ClearBottomRows
        LDA #CHAR_SPACE
        LDX #80
.ClearRowsLoop
        STA SCNROW23-1,X
        DEX
        BNE .ClearRowsLoop
        JMP Player_CheckLives ;DONE

;-------------------------------------------------------------------------------
; Player_NextSector
; Move to the next sector (max = 31)
; Called by: Camel_CheckRemainingCamels (JMP)
;-------------------------------------------------------------------------------
*=$297E
Player_NextSector
        INC playerSector
        LDA playerSector
        CMP #32
        BNE .ExitNextSector
        DEC playerSector
.ExitNextSector
        JMP Camel_ResetCamelPosition

;-------------------------------------------------------------------------------
; Hyperdrive_Ended
; Hyperdrive ends
; Called by: Hyperdrive_Finishing (JMP)
;-------------------------------------------------------------------------------
*=$298B
Hyperdrive_Ended
        LDX #$F6
        TXS ;redundant - possibly used to overwrite a JSR?
        LDA #BOTTOM_ROWS_DONT_CLEAR
        STA bottomRowFlag
        JMP Hyperdrive_PrepareForNextSector

;-------------------------------------------------------------------------------
; Camel_ResetCamelPosition
; Reset the camel positions and call the display routine at the start of a level
; Called by: Player_NextSector (JMP)
;-------------------------------------------------------------------------------
*=$2995
Camel_ResetCamelPosition
        JSR InitLevel_InitialiseCamelStats
        LDA #0
        STA camelPositionMinor
        STA camelPositionMajor
        JSR Screen_DisplayCamelMarker
        JMP Camel_ResetCamelsRemaining

;-------------------------------------------------------------------------------
; Hyperdrive_PrepareForNextSector
; Reset variables for next level
; Called by: Hyperdrive_Ended
;-------------------------------------------------------------------------------
*=$29A4
Hyperdrive_PrepareForNextSector
        LDA #0
        STA camelPositionMinor
        STA camelPositionMajor
        NOP
        NOP
        NOP
        LDA #BOTTOM_ROWS_DONT_CLEAR
        STA bottomRowFlag
        JMP InitLevel_InitSprites

;-------------------------------------------------------------------------------
; Camel_ResetCamelsRemaining
; Set number of camels remaining to 6 at start of level
; Called by: Camel_ResetCamelPosition (JMP)
;-------------------------------------------------------------------------------
*=$29B4
Camel_ResetCamelsRemaining
        LDA #6
        STA camelsRemaining
        JMP Hyperdrive_EngageHyperdrive

;-------------------------------------------------------------------------------
; InitLevel_SetDifficulty
; Loads in difficulty stats from tables based on sector number
; Called by: InitLevel_InitialseGameVariables (JSR)
;-------------------------------------------------------------------------------
*=$29BB
InitLevel_SetDifficulty
        LDX playerSector
        LDA tbl_CamelSpeeds,X
        STA camelSpeed
        LDA tbl_CamelSpitSpeeds,X
        STA camelSpitSpeedCounter
        STA camelSpitSpeed
        LDA tbl_CamelSpitRates,X
        STA camelSpitRateCounter 
        STA camelSpitRate
        LDA tbl_RocketMoveRates,X
        STA rocketMoveRate
        LDA tbl_CamelSpitBombRates,X
        STA camelSpitBombRateCounter
        STA camelSpitBombRate
        LDX #40
.DisplayPlayerStatsLoop
        LDA txt_PlayerStats-1,X
        STA SCNROW23-1,X
        LDA #YELLOW
        STA COLROW23-1,X
        DEX
        BNE .DisplayPlayerStatsLoop
        JMP Screen_UpdatePlayerStats

;===============================================================================
; Data
;===============================================================================
*=$29EF
txt_PlayerStats         text 'jets            sector 00         jets  '

;-------------------------------------------------------------------------------
; Screen_UpdatePlayerStats
; Refresh lives and current sector on the screen
; Called by: InitLevel_SetDifficulty (JMP)
;-------------------------------------------------------------------------------
*=$2A17
Screen_UpdatePlayerStats
        LDA player1Lives
        CLC
        ADC #CHAR_0
        STA SCN_PL1LIVES
        LDA player2Lives
        CLC
        ADC #CHAR_0
        STA SCN_PL2LIVES
        LDA #PURPLE
        STA COL_PL1LIVES
        STA COL_PL2LIVES
        LDX playerSector
.DisplaySectorLoop
        INC SCN_SECTOR+1
        LDA SCN_SECTOR+1
        CMP #CHAR_9+1
        BNE .SkipSectorHighDigit
        LDA #CHAR_0
        STA SCN_SECTOR+1
        INC SCN_SECTOR
.SkipSectorHighDigit
        DEX
        BNE .DisplaySectorLoop
        LDA #CYAN
        STA COL_SECTOR+1
        STA COL_SECTOR
        RTS
        NOP

;===============================================================================
; Data
;===============================================================================
*=$2A50
tbl_CamelSpeeds         byte $80, $80, $70, $60, $50, $80, $70, $60
                        byte $50, $70, $70, $70, $70, $60, $60, $60
                        byte $60, $60, $5a, $58, $58, $58, $58, $58
                        byte $58, $56, $54, $52, $50, $4e, $4c, $4a

*=$2A70
tbl_CamelSpitSpeeds     byte $10, $10, $0e, $0c, $0a, $10, $0e, $0c
                        byte $0a, $0e, $0e, $0e, $0e, $0c, $0c, $0c
                        byte $0c, $0a, $0a, $0a, $0a, $09, $09, $09
                        byte $09, $08, $08, $08, $08, $08, $08, $08

*=$2A90
tbl_CamelSpitRates      byte $03, $03, $03, $03, $03, $02, $02, $02
                        byte $02, $01, $01, $01, $01, $03, $03, $03
                        byte $03, $02, $02, $02, $02, $01, $01, $01
                        byte $01, $01, $01, $01, $01, $01, $01, $01

*=$2AB0
tbl_RocketMoveRates     byte $40, $40, $3e, $38, $36, $34, $32, $30
                        byte $2e, $2d, $2c, $2b, $2a, $29, $28, $27
                        byte $26, $26, $25, $25, $24, $24, $23, $23
                        byte $22, $22, $21, $21, $20, $20, $20, $20

*=$2AD0
tbl_CamelSpitBombRates  byte $07, $07, $07, $07, $07, $07, $07, $07
                        byte $07, $06, $06, $06, $05, $04, $03, $03
                        byte $03, $03, $03, $03, $02, $02, $01, $03
                        byte $03, $02, $02, $01, $01, $01, $01, $01

;-------------------------------------------------------------------------------
; Player_CheckLives
; Check number of lives left, if none go to the hi score routine
; Called by: Screen_ClearBottomRows (JMP)
;-------------------------------------------------------------------------------
*=$2AF0
Player_CheckLives
        LDA player1Lives
        BEQ .NoLivesLeft
        LDA player2Lives
        BEQ .NoLivesLeft
        JMP Player_LoseLife
.NoLivesLeft
        LDA player1Lives
        CMP player2Lives
        BNE .DecreasePlayerLives
.GameOver
        JMP Score_CheckPlayerScores
.DecreasePlayerLives
        LDA playerTurn
        CMP #2
        BEQ .Player2Lives
        DEC player1Lives
        INC player2Lives
.Player2Lives
        DEC player2Lives
        LDA player1Lives
        CMP player2Lives
        BEQ .GameOver
        JMP .PrepareToStart

;-------------------------------------------------------------------------------
; Player_CamelCollisionDetection
; CHeck collision between player and camel (where this is switched on)
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$2B19
Player_CamelCollisionDetection
        byte $AD, $95, $00 ;LDA $0095 [collisionRegister]
        STA collisionRegister
        LDA camelState
        BEQ .CamelActive
.ExitCollisionDetection
        RTS
.CamelActive
        byte $AD, $95, $00 ;LDA $0095 [collisionRegister]
        AND #SPR_BULLET_MASK_ON
        BNE .ExitCollisionDetection
        LDA collisionRegister
        AND #SPR_CAMEL_SPIT_MASK_ON
        BNE .ExitCollisionDetection
        LDA camelCollision
        BEQ .ExitCollisionDetection
        LDA collisionRegister
        AND #SPR_SHIP_MASK_ON
        BEQ .ExitCollisionDetection
        JMP Player_ShipExplosion

;-------------------------------------------------------------------------------
; Screen_ClearScreen
; Clears the screen and sets the char colour to white
; Called by: Menu_DisplayJMPresents (JSR), InitLevel_CheckSectorAndCollisions (JSR)
;-------------------------------------------------------------------------------
*=$2B3D
Screen_ClearScreen
        LDX #0
.ClearScreenLoop
        LDA #CHAR_SPACE
        STA SCREENRAM+$00F0,X
        STA SCREENRAM+$0100,X
        STA SCREENRAM+$0200,X
        STA SCREENRAM+$0300,X
        LDA #WHITE
        STA COLOURRAM,X
        STA COLOURRAM+$0100,X
        STA COLOURRAM+$0200,X
        STA COLOURRAM+$0300,X
        DEX
        BNE .ClearScreenLoop
        RTS

;-------------------------------------------------------------------------------
; Menu_DisplayJMPresents
; Print 'Jeff Minter Presents'
; Called by: Init_Restart (JSR)
;-------------------------------------------------------------------------------
*=$2B5F
Menu_DisplayJMPresents
        JSR Screen_ClearScreen
        LDX #20
.DisplayJMPresentsLoop
        LDA txt_JMPresents-1,X
        STA SCNROW8+9,X
        DEX
        BNE .DisplayJMPresentsLoop
        JMP Menu_DisplayIntroScreen

;===============================================================================
; Data
;===============================================================================
*=$2B70
txt_JMPresents          text 'jeff minter presents'

;-------------------------------------------------------------------------------
; Menu_DisplayIntroScreen
; Animates AMC sprites and prints rest of intro text onto the screen
; Called by: Menu_DisplayJMPresents (JMP)
;-------------------------------------------------------------------------------
*=$2B84
Menu_DisplayIntroScreen
        LDA #FALSE
        STA SPREN
        LDA #SPR_AMC_LOGO_MASK_ON 
        STA SPRYEX
        STA SPRXEX
        LDA #FALSE
        STA SPRMCS
        STA SPRXMSB
        LDA #64
        STA camelSpitState ;redundant
        LDA #YELLOW
        STA SPRCOL0
        STA SPRCOL1     
        STA SPRCOL2
        STA SPRCOL3
        LDA #0
        STA SPRY0
        STA SPRY1
        STA SPRY2
        STA SPRY3
        LDA #148
        STA SPRX0
        STA SPRX2
        LDA #192
        STA SPRX1
        STA SPRX3
        LDA #AMC_LOGO_SPRITE1
        STA SPRPTR0
        LDA #AMC_LOGO_SPRITE2
        STA SPRPTR1
        LDA #AMC_LOGO_SPRITE3
        STA SPRPTR2
        LDA #AMC_LOGO_SPRITE4
        STA SPRPTR3
        LDA #SPR_AMC_LOGO_MASK_ON 
        STA SPREN
.AMCSpriteMoveLoop
        LDY #16
.IntroDelayLoopOuter
        LDX #0
.IntroDelayLoopInner
        DEX
        BNE .IntroDelayLoopInner
        DEY
        BNE .IntroDelayLoopOuter
        INC SPRY0
        INC SPRY1
        DEC SPRY2
        DEC SPRY3
        LDA SPRY0
        CMP SPRY2
        BNE .AMCSpriteMoveLoop
        LDX #32
.DisplayIntroTextLoop
        LDA txt_AMC-1,X
        STA SCNROW15+4,X
        LDA txt_GridRunner-1,X
        STA SCNROW17+4,X
        LDA txt_Players-1,X
        STA SCNROW19+4,X
        LDA txt_ColCamels-1,X
        STA SCNROW21+4,X
        LDA txt_PressFire-1,X
        STA SCNROW23+4,X
        DEX
        BNE .DisplayIntroTextLoop
        LDA #1
        STA startSector
        LDA #FALSE
        STA camelCollision
        JMP Menu_OptionSelect
        NOP
        NOP

;===============================================================================
; Data
;===============================================================================
*=$2C30
txt_Players             text 'players: 1   start at sector: 01'
txt_AMC                 text '  attack of the mutant camels   '
txt_ColCamels           text ' collisions with camels:   no   '
txt_GridRunner          text ' from the creator of gridrunner '
txt_PressFire           text '  press fire to start the game  '

;*******************************************************************************
; Redundant/Orphaned Code
;*******************************************************************************
*=$2CD0
                        byte $20, $20, $20, $20, $20, $20, $20, $20

;-------------------------------------------------------------------------------
; Menu_OptionsSelect
; Checks for input and changes options on intro screen
; Called by: Menu_DisplayIntroScreen (JMP)
;-------------------------------------------------------------------------------
*=$2CD8
Menu_OptionSelect
        LDA sysKeyCode_C5
        CMP #KEY_F1
        BNE .CheckF3Pressed
        JMP Menu_SelectPlayers
.CheckF3Pressed
        CMP #KEY_F3
        BNE .CheckF5Pressed
        JMP Menu_SelectSector
.CheckF5Pressed
        CMP #KEY_F5
        BNE .IntroWaitFire
        JMP Menu_SelectCollisions
.IntroWaitFire
        LDA JOY1
        CMP #JOY1_FIRE 
        BNE .NoFire
        JMP InitLevel_ResetSpriteIO
.NoFire
        NOP
        NOP
        NOP
        JMP Menu_OptionSelect
        NOP

;-------------------------------------------------------------------------------
; Menu_SelectPlayers
; Allows the player to switch between 1 and 2 players on intro screen
; Called by: Menu_OptionSelect (JMP)
;-------------------------------------------------------------------------------
*=$2D00
Menu_SelectPlayers
        INC SCNROW19+14
        LDA SCNROW19+14
        CMP #CHAR_3
        BNE .SkipResetPlayers
        LDA #CHAR_1
.SkipResetPlayers
        STA SCNROW19+14
.IntroWaitKey
        LDA sysKeyCode_C5
        CMP #KEY_NONE
        BNE .IntroWaitKey
        JMP .IntroWaitFire

;-------------------------------------------------------------------------------
; Menu_SelectSector
; Allows the player to change start sector on the intro screen
; Called by: Menu_OptionSelect (JMP)
;-------------------------------------------------------------------------------
*=$2D18
Menu_SelectSector
        INC startSector
        LDA startSector
        CMP #32
        BEQ .SelectSectorReset
        NOP
        NOP
.UpdateSector
        LDA #CHAR_0
        STA SCNROW19+35
        STA SCNROW19+36
        LDX startSector
.ChangeSectorLoop
        INC SCNROW19+36
        LDA SCNROW19+36
        CMP #CHAR_9+1
        BNE .NextSector
        LDA #CHAR_0
        STA SCNROW19+36
        INC SCNROW19+35
.NextSector
        DEX
        BNE .ChangeSectorLoop
        JMP .IntroWaitKey ;DONE
.SelectSectorReset
        LDA #1
        STA startSector
        JMP .UpdateSector ;DONE

;-------------------------------------------------------------------------------
; Menu_SelectCollisions
; Allows the player to select collisions on/off on the menu
; Called by: Menu_OptionSelect (JMP)
;-------------------------------------------------------------------------------
*=$2D4B
Menu_SelectCollisions
        LDA SCNROW21+31
        CMP #CHAR_SPACE
        BEQ .SetCollisionsYes
        LDA #CHAR_SPACE
        STA SCNROW21+31
        LDA #CHAR_N
        STA SCNROW21+32
        LDA #CHAR_O
        STA SCNROW21+33
        JMP .IntroWaitKey ;DONE
.SetCollisionsYes
        LDA #CHAR_Y
        STA SCNROW21+31
        LDA #CHAR_E
        STA SCNROW21+32
        LDA #CHAR_S
        STA SCNROW21+33
        JMP .IntroWaitKey ;DONE

;-------------------------------------------------------------------------------
; InitLevel_ResetLives
; Sets lives for Player 1 & 2 (note player 2 lives altered later on)
; Called by: InitLevel_ResetSpriteIO (JMP)
;-------------------------------------------------------------------------------
*=$2D76
InitLevel_ResetLives
        LDA #5
        STA player1Lives
        STA player2Lives
        JSR InitLevel_CheckNumberOfPlayers ;DONE
        JMP InitLevel_CheckSectorAndCollisions ;DONE


*=$2D82
                        byte $04, $A9, $00, $85, $6D

;-------------------------------------------------------------------------------
; InitLevel_CheckSectorAndCollisions
; Initialise starting sector and camel collision on/off
; Called by: InitLevel_ResetLives (JMP)
;-------------------------------------------------------------------------------
*=$2D87
InitLevel_CheckSectorAndCollisions
        LDA startSector
        STA playerSector
        LDA #COLLISIONS_OFF
        STA camelCollision
        LDA SCNROW21+31
        CMP #CHAR_SPACE ; i.e. {space}NO
        BEQ .SkipCollisionOn
        LDA #COLLISIONS_ON
        STA camelCollision
.SkipCollisionOn
        JSR Screen_ClearScreen
        JSR Init_ScreenPointerArray ;duplicate routine call
        RTS

;-------------------------------------------------------------------------------
; InitLevel_CheckNumberOfPlayers
; Reduce lives of player 2 if player one player selected
; Called by: InitLevel_ResetLives (JSR)
;-------------------------------------------------------------------------------
*=$2DA1
InitLevel_CheckNumberOfPlayers
        LDA #6
        STA player2Lives
        LDA #2
        STA playerTurn
        LDA SCNROW19+14 ;no. of players selected
        CMP #CHAR_1
        BEQ .OnePlayerOnly
        RTS
.OnePlayerOnly
        LDA #1
        STA player2Lives ;this gets decreased to 0 as part of the init routine
        RTS

;-------------------------------------------------------------------------------
; InitLevel_ResetSpriteIO
; Sets sprite IO registers to zero
; Called by: Menu_OptionSelect (JMP)
;-------------------------------------------------------------------------------
*=$2DB6
InitLevel_ResetSpriteIO
        LDX #16
.ResetSpritesLoop
        LDA #0
        STA SPRX0-1,X
        DEX
        BNE .ResetSpritesLoop
        LDA #0
        STA SPREN
        JMP InitLevel_ResetLives

;-------------------------------------------------------------------------------
; Game_UpdateCollisionRegister
; Stores the current status of the sprite to sprite collision register
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$2DC8
Game_UpdateCollisionRegister
        DEC collisionCounter
        BEQ .UpdateCollisionRegister
        RTS
.UpdateCollisionRegister
        LDA #32
        STA collisionCounter
        LDA SPRCSP
        STA collisionRegister
        RTS

;-------------------------------------------------------------------------------
; Score_CheckHiScore
; Checks if either player has a score higher than the current hi score
; Called by: Score_CheckPlayerScores (JSR)
;-------------------------------------------------------------------------------
*=$2DD7
Score_CheckHiScore
        LDY #1
.CheckHiScoreLoop
        LDA (zpLo4),Y
        CMP gameHiScore-1,Y
        BEQ .CheckNextDigit
        BPL .SaveHiScore
        BNE .ExitCheckHiScore
.CheckNextDigit
        INY
        CPY #8
        BNE .CheckHiScoreLoop
.ExitCheckHiScore
        RTS
.SaveHiScore
        LDY #1
.SaveHiScoreLoop
        LDA (zpLo4),Y
        STA gameHiScore-1,Y
        STA SCN_HISCORE,Y
        JMP Score_CheckHiScoreB
        RTS

;-------------------------------------------------------------------------------
; Score_CheckPlayerScores
; Routine to call the hi score check for each player
; Called by: Player_CheckLives (JMP)
;-------------------------------------------------------------------------------
*=$2DF8
Score_CheckPlayerScores
        LDA #>SCN_PL1SCORE
        STA zpHi4
        LDA #<SCN_PL1SCORE
        STA zpLo4
        JSR Score_CheckHiScore
        LDA #<SCN_PL2SCORE
        STA zpLo4
        JSR Score_CheckHiScore
        JMP Init_Restart

;-------------------------------------------------------------------------------
; Score_CheckHiScoreB
; Continuation of hi score checking routine
; Called by: Score_CheckHiScore (JMP)
;-------------------------------------------------------------------------------
*=$2E0D
Score_CheckHiScoreB
        INY
        CPY #8
        BNE .SaveHiScoreLoop
        RTS

;-------------------------------------------------------------------------------
; Game_CheckSectorDefences
; Checks to see if sector defences are breached (is camel marker at edge of screen)
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$2E13
Game_CheckSectorDefences
        LDA SCN_CAMELRADAR+39
        CMP #CHAR_CAMEL
        BEQ .SectorDefencesBreached
        RTS
.SectorDefencesBreached
        LDA playerTurn
        CMP #2
        BEQ .UpdatePlayer2Lives
        LDA #1
        STA player1Lives
        JMP .DisplaySectorDefencesText
.UpdatePlayer2Lives
        LDA #1
        STA player2Lives
.DisplaySectorDefencesText
        LDX #26
.SectorDefenceTextLoop
        LDA txt_SectorDefences-1,X
        STA SCNROW24+5,X
        LDA #CYAN
        STA COLROW24+5,X
        DEX
        BNE .SectorDefenceTextLoop
        LDY #0
.FlashColoursOuterLoop
        LDX #BLACK
.FlashColoursLoop
        STX BDCOL
        STX BGCOL0
        STX FREH1
        LDA #VOICE_OFF
        STA VCREG1
        LDA #VOICE_ON_NOISE
        STA VCREG1
        DEX
        BNE .FlashColoursLoop
        DEY
        BNE .FlashColoursOuterLoop
        NOP
        NOP
        NOP
        JMP Game_ResetScreenColours

;===============================================================================
; Data
;===============================================================================
*=$2E5F
txt_SectorDefences      text 'sector defences penetrated'

;-------------------------------------------------------------------------------
; Game_ResetScreenColours
; Resets screen colours before calling ship explosion routine
; Called by: Game_CheckSectorDefences (JMP)
;-------------------------------------------------------------------------------
*=$2E79
Game_ResetScreenColours
        LDA #BLACK
        STA BDCOL
        STA BGCOL0
        JMP Player_ShipExplosion

;-------------------------------------------------------------------------------
; Sound_InitFrequency3
; Continuation of level initialisation routine
; Called by: InitLevel_InitialisePlayerStatsB
;-------------------------------------------------------------------------------
*=$2E84
Sound_InitFrequency3
        LDA #138
        STA FREH3
        JMP InitLevel_InitialisePlayerStatsC

;-------------------------------------------------------------------------------
; Hyperdrive_ResetShipY
; Resets ship Y at end of the hyperdrive routine
; Called by: Hyperdrive_Jumping (JMP)
;-------------------------------------------------------------------------------
*=$2E8C
Hyperdrive_ResetShipY
        LDA #112
        STA shipY
        JMP Hyperdrive_Finishing

;-------------------------------------------------------------------------------
; Bullet_ClearCollisionRegister
; 
; Called by: Bullet_HitSound (JSR)
;-------------------------------------------------------------------------------
*=$2E93
Bullet_ClearCollisionRegister
        STA FREH3
        LDA #FALSE
        STA collisionRegister
.ClearCollisionRegister
        RTS

;-------------------------------------------------------------------------------
; Game_Pause
; Routine to pause/unpause the game
; Called by: Game_CheckPause (Branch)
;-------------------------------------------------------------------------------
*=$2E9B
Game_Pause
        LDA sysKeyCode_C5
        CMP #KEY_F1
        BNE .ClearCollisionRegister
        LDA #WHITE
        STA BDCOL
        STA BGCOL0
.WaitForKey
        LDA sysKeyCode_C5
        CMP #KEY_NONE
        BNE .WaitForKey
.CheckUnpause
        LDA sysKeyCode_C5
        CMP #KEY_F1
        BNE .CheckUnpause
        LDA #BLACK
        STA BDCOL
        STA BGCOL0
.WaitForKey2
        LDA sysKeyCode_C5
        CMP #KEY_NONE
        BNE .WaitForKey2
        RTS

;-------------------------------------------------------------------------------
; Game_CheckPause
; Checks if commodore key is pressed to pause the game
; Called by: Game_MainLoop (JSR)
;-------------------------------------------------------------------------------
*=$2EC4
Game_CheckPause
        LDA sysShiftKeyIndicator_028D
        CMP #2 ;commodore key
        BEQ Game_Pause
        RTS

;*******************************************************************************
; NOPsville
;*******************************************************************************
*=$2ECC
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA
        byte $EA, $EA, $EA, $EA

;===============================================================================
; Data
;===============================================================================
*=$3000
        incbin "spritesAMC.spt", 1, 35, true

PLAYER1STATS            = $38C0
P1_LEVELSTATS           = $38F0
P1_SECTOR               = $38F3
PLAYER2STATS            = $39C0
GameData                = $8000 ;redundant
        

