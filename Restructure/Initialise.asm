;-------------------------------------------------------------------------------
; Initialises the game by setting the background and border to black and
; setting the character ram location to $2000
;-------------------------------------------------------------------------------
*=$0900
Initialise
        lda #BLACK
        sta BDCOL
        sta BGCOL0
        lda #%00011000
        sta VMCR
        lda #GF_STATUS_MENU
        sta gameStatus
        rts

;-------------------------------------------------------------------------------
; Initialises the variables for the start of each game, such as player lives,
; various flags, scores and level stats
;-------------------------------------------------------------------------------
Initialise_Game
        lda #FALSE
        sta SPREN
        sta switchPlayers
        sta playerKilled
        sta hyperdriveEngaged
        sta gameOver
        sta hyperdriveCompleted
        lda #5
        sta player1Lives
        sta player2Lives
        lda #1
        sta playerTurn
        lda SCNROW19+14
        cmp #CHAR_1
        beq .OnePlayerOnly
        jmp .BothPlayers
.OnePlayerOnly
        lda #0
        sta player2Lives
.BothPlayers
        lda startSector
        sta playerSector
        lda #FALSE
        sta camelCollision
        lda SCNROW21+31
        cmp #CHAR_SPACE
        beq .SkipCollisionOn
        lda #TRUE
        sta camelCollision
.SkipCollisionOn
        ldy #TRUE
        jsr Screen_Clear
        sta tbl_P2LevelStats+2
        lda #0
        sta tbl_P2LevelStats
        sta tbl_P2LevelStats+1
        sta camelPositionMinor
        sta camelPositionMajor
        lda #6
        sta camelsRemaining
        sta tbl_P2LevelStats+3
        jsr Initialise_ResetGameVariables
        ldx #32
.InitialisePlayer1Stats
        lda tbl_PlayerStats-1,X
        sta tbl_Player2TempStats,x
        dex
        bne .InitialisePlayer1Stats
        lda #<SCN_PL1SCORE
        sta scoreScreenLo
        sta scoreColourLo
        lda #$04
        sta scoreScreenHi
        lda #$D8
        sta scoreColourHi
        rts

;-------------------------------------------------------------------------------
; Resets game variables to the init values
;-------------------------------------------------------------------------------
Initialise_ResetGameVariables
        LDY #8
.InitGameVarsLoop
        LDA tbl_InitCamelMarkerScreenLo-1,Y
        STA tbl_CamelMarkerScreenLo-1,Y
        LDA tbl_InitCamelHealthMinor-1,Y
        STA tbl_CamelHealthMinor-1,Y
        LDA tbl_InitCamelHealth-1,Y
        STA tbl_CamelHealth-1,Y
        LDA #YELLOW
        STA tbl_CamelCurrentColour-1,Y
        DEY
        BNE .InitGameVarsLoop
        rts

