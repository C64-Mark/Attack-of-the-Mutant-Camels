GameFlow_JumpTableLo            byte <GameFlow_StatusMenu
                                byte <GameFlow_StatusInitGame
                                byte <GameFlow_StatusInitLevel
                                byte <GameFlow_StatusCamelAttack
                                byte <GameFlow_StatusHyperdrive
                                byte <GameFlow_StatusDying
                                byte <GameFlow_StatusGameOver

GameFlow_JumpTableHi            byte >GameFlow_StatusMenu
                                byte >GameFlow_StatusInitGame
                                byte >GameFlow_StatusInitLevel
                                byte >GameFlow_StatusCamelAttack
                                byte >GameFlow_StatusHyperdrive
                                byte >GameFlow_StatusDying
                                byte >GameFlow_StatusGameOver


GameFlow_Update
        ldx gameStatus
        lda GameFLow_JumpTableLo,x
        sta zpLow
        lda GameFLow_JumpTableHi,x
        sta zpHigh
        jmp (zpLow)

;-------------------------------------------------------------------------------
; Displays the title screen
;-------------------------------------------------------------------------------
GameFlow_StatusMenu
        jsr TitleScreen_DisplayTitle
        lda #GF_STATUS_INITGAME
        sta gameStatus
        rts

;-------------------------------------------------------------------------------
; Calls the routines to intialise the start of the game
;-------------------------------------------------------------------------------
GameFlow_StatusInitGame
        jsr Initialise_Game
        jsr IRQ_Initialise
        lda #GF_STATUS_INITLEVEL
        sta gameStatus
        rts

;-------------------------------------------------------------------------------
; Calls the routines to initialise the game each time a level is started
; either after the player has died or the sector has increased
;-------------------------------------------------------------------------------
GameFlow_StatusInitLevel
        jsr InitLevel_SwitchPlayers 
        jsr InitLevel_InitialiseVariables
        jsr InitLevel_InitialseSound 
        jsr Screen_MoveLandscape 
        jsr Screen_DisplayGround 
        jsr Screen_DisplayStars 
        jsr Screen_DisplayPlayerStats 
        jsr InitLevel_SetDifficulty 
        jsr InitLevel_StartMessageAndSound 
        jsr Screen_DisplayCamelMarker
        jsr InitLevel_InitialiseSprites
        lda #GF_STATUS_CAMEL_ATTACK
        sta gameStatus
        rts

;-------------------------------------------------------------------------------
; The main game flow which runs the routines relevant to the player attacking
; the camels. This state is only exited if the player either dies or enters 
; hyperdrive
;-------------------------------------------------------------------------------
GameFlow_StatusCamelAttack
        jsr Game_DecrementTimer
        jsr Game_CheckPause
        jsr Game_CheckSectorDefences
        jsr Screen_TwinkleStars
        jsr Input_CheckInput
        jsr Player_ChangeShipDirection
        jsr Player_DecreaseShipXOffset
        jsr Camel_Move
        jsr Camel_UpdateSprites
        jsr Player_UpdateShipSprite
        jsr Camel_Spit
        jsr Bullet_MoveBullet
        jsr Game_UpdateCollisionRegister
        jsr Player_CamelCollisionDetection
        jsr Player_DamageScreenFlash
        jsr Camel_Dying

        lda hyperdriveEngaged
        beq .CheckDeath
        lda #GF_STATUS_HYPERDRIVE
        sta gameStatus
.CheckDeath
        lda playerKilled
        beq .ExitStatusCamelAttack
        lda #GF_STATUS_DYING
        sta gameStatus
.ExitStatusCamelAttack
        rts

;-------------------------------------------------------------------------------
; Runs the hyperdrive routine. If completed this moves back to the init
; level state. If the player dies, the dying state is entered.
;-------------------------------------------------------------------------------
GameFlow_StatusHyperdrive
        jsr Hyperdrive_EngageHyperdrive
        lda hyperdriveEngaged
        bne .CheckHyperdriveDeath
        lda #GF_STATUS_INITLEVEL
        sta gameStatus
.CheckHyperdriveDeath
        lda playerKilled
        beq .ExitStatusHyperdrive
        lda #GF_STATUS_DYING
        sta gameStatus
.ExitStatusHyperdrive
        rts

;-------------------------------------------------------------------------------
; Runs the routines to animate the ship explosion and checks whether it is
; game over or not
;-------------------------------------------------------------------------------
GameFlow_StatusDying
        jsr Player_ShipExplosion
        jsr Player_CheckLives
        lda gameOver
        bne .GameOver
        lda #GF_STATUS_INITLEVEL
        jmp .ExitStatusDying
.GameOver
        lda #GF_STATUS_GAMEOVER
.ExitStatusDying
        sta gameStatus
        rts

;-------------------------------------------------------------------------------
; All lives are lost so the hi score is checked and the game loops back to the
; menu state
;-------------------------------------------------------------------------------
GameFlow_StatusGameOver
        jsr Score_CheckPlayerScores
        lda #FALSE
        sta gameOver
        lda #GF_STATUS_MENU
        sta gameStatus
        rts
