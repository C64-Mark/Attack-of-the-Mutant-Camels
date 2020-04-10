;-------------------------------------------------------------------------------
; Checks the joystick for movement. During hyperdrive this routine only runs the
; up/down move routine using the hyperdrive movement timer. Otherwise the
; game timer is used to determine when the up/down/fire and left/right routines
; are called.
;
; If the fire button is pressed and a bullet is available then the bullet sound
; effect is used and the bullet variables are initialised based on the ship 
; position. Bullet state is disabled during hyperdrive, meaning this part of the
; routine isn't reached.
;
; The left right routine checks current direction of travel and if the move is
; opposite it sets the ship turning state and resets the X offset.
;-------------------------------------------------------------------------------
Input_CheckInput
        lda hyperdriveEngaged
        bne .CheckJoyUpDownFire
        lda gameTimer
        cmp #2
        beq .CheckJoyUpDownFire
        cmp #1
        beq .CheckJoyLeftRight
        rts
.CheckJoyUpDownFire
        lda CIAPRA
        eor #255
        sta InputJoy
        and #JOY_UP
        beq .CheckJoyDown
        dec shipY
        lda shipY
        cmp #96
        bne .ExitCheckJoy
        lda #97
        sta shipY
        jmp .ExitCheckJoy
.CheckJoyDown
        lda InputJoy
        and #JOY_DOWN
        beq .CheckJoyFire
        inc shipY
        lda shipY
        cmp #224
        bne .ExitCheckJoy
        lda #223
        sta shipY
        jmp .ExitCheckJoy
.CheckJoyFire
        lda inputJoy
        and #JOY_FIRE
        bne .FirePressed
        rts
.FirePressed
        lda bulletDirection
        beq .BulletAvailable
        rts
.BulletAvailable
        lda shipX
        sta bulletX
        lda shipY
        sta bulletY
        ldx #BULLET_DIR_LEFT
        lda shipDirection
        bne .SetBulletDirectionRight
        jmp .BulletDirectionSet
.SetBulletDirectionRight
        ldx #BULLET_DIR_RIGHT
.BulletDirectionSet        
        stx bulletDirection
        lda #165
        sta bulletSoundFrequency
        lda SPREN
        ora #SPR_BULLET_MASK_ON
        sta SPREN
.ExitCheckJoy
        rts
.CheckJoyLeftRight
        dec shipMoveCounter 
        bne .ExitCheckJoy
        lda #SHIP_MOVE_RATE
        sta shipMoveCounter 
        lda inputJoy
        and #JOY_LEFTRIGHT
        bne .MoveLeftRight
        lda #TRUE
        sta decreaseOffsetFlag
        rts
.MoveLeftRight
        lda #VOICE_OFF 
        sta VCREG1
        lda #VOICE_ON_NOISE
        sta VCREG1
        lda #JOY_LEFT
        sta inputJoyLR
        lda shipDirection
        beq .JoyLeft
        lda #JOY_RIGHT
        sta inputJoyLR
.JoyLeft
        lda inputJoy
        and inputJoyLR
        BNE .IncreaseShipOffset
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
        CMP #72
        beq .ResetShipOffset
        jmp .SkipResetOffset
.ResetShipOffset
        LDA #71
        STA shipXOffset
        rts




