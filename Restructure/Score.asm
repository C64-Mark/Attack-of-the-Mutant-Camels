;-------------------------------------------------------------------------------
; Calls the hi score check routine for each player
;-------------------------------------------------------------------------------
Score_CheckPlayerScores
        lda #>SCN_PL1SCORE
        sta zpHigh
        lda #<SCN_PL1SCORE
        sta zpLow
        jsr Score_CheckHiScore
        lda #<SCN_PL2SCORE
        sta zpLow
        jsr Score_CheckHiScore
        rts

;-------------------------------------------------------------------------------
; Checks players score against the hiscore and updates this if the player 
; score is greater
;-------------------------------------------------------------------------------
Score_CheckHiScore
        ldy #1
.CheckHiScoreLoop
        lda (zpLow),Y
        cmp gameHiScore-1,Y
        beq .CheckNextDigit
        bpl .SaveHiScore
        bne .ExitCheckHiScore
.CheckNextDigit
        iny
        cpy #8
        bne .CheckHiScoreLoop
.ExitCheckHiScore
        rts
.SaveHiScore
        ldy #1
.SaveHiScoreLoop
        lda (zpLow),Y
        sta gameHiScore-1,Y
        sta SCN_HISCORE,Y
        iny
        cpy #8
        bne .SaveHiScoreLoop
        rts

;-------------------------------------------------------------------------------
; Loops that adds 1 point to the score for each multiplier. The routine is 
; called from other routines that set Y as the starting digit (i.e. this is the 
; 7th digit for a single point increase, or 5th digit for a bonus score increase)
; The x register holds the multiplier (i.e. for the score bonus where more than
; 1 point is added)
;-------------------------------------------------------------------------------
Score_IncreaseScore
        sty zpTemp1
.NextScoreDigit
        lda (scoreScreenLo),Y
        clc
        adc #1
        sta (scoreScreenLo),Y
        cmp #CHAR_9+1
        bne .NextMultiplier
        lda #CHAR_0
        sta (scoreScreenLo),Y
        dey
        bne .NextScoreDigit
.NextMultiplier
        ldy zpTemp1
        dex
        bne Score_IncreaseScore
        rts

