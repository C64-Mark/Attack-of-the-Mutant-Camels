;-------------------------------------------------------------------------------
; Initialises the IRQ routine
;-------------------------------------------------------------------------------
IRQ_Initialise
        sei
        lda #<IRQ_Main
        sta sysIntVectorLo_0314
        lda #>IRQ_Main
        sta sysIntVectorHi_0315
        cli
        rts

;-------------------------------------------------------------------------------
; Resets the IRQ routine so that the camel movement sound doesn't happen during
; the menu or hyperdrive state
;-------------------------------------------------------------------------------
IRQ_Reset
        sei
        lda #<krnINTERRUPT
        sta sysIntVectorLo_0314
        lda #>krnINTERRUPT
        sta sysIntVectorHi_0315
        cli
        rts

;-------------------------------------------------------------------------------
; Calls the two IRQ routines to flash the player score and animate the camel
; using the camel animation counter
;-------------------------------------------------------------------------------
IRQ_Main
        dec camelAnimationCounter
        beq .ResetCamelAnimationCounter
        jmp krnINTERRUPT
.ResetCamelAnimationCounter
        lda #CAMEL_ANIMATION_RATE
        sta camelAnimationCounter
        jsr IRQ_FlashPlayerScore
        jsr IRQ_AnimateCamel
        jmp krnINTERRUPT

;-------------------------------------------------------------------------------
; Increments the sprite frames for the camel legs and head which causes the 
; camel to 'walk' and the head to move up and down. This also generates the 
; camel 'walk' sound effect
;-------------------------------------------------------------------------------
IRQ_AnimateCamel
        inc camelAnimationFrame
        lda camelAnimationFrame
        cmp #5
        beq .CamelWalkingSound
        lda #CAMEL_REAR_LEGS_FRAME1-1
        clc
        adc camelAnimationFrame
        sta SPRPTR5
        clc
        adc #4
        sta SPRPTR6
        lda camelState
        beq .GetCamelHeadFrame
        rts
.GetCamelHeadFrame
        ldx camelAnimationFrame
        lda tbl_CamelHeadFrame-1,X
        sta camelHeadFrame
        rts 
.CamelWalkingSound
        lda camelSpitState
        bne .ResetBackLegsFrame
        lda #VOICE_OFF
        sta VCREG2
        lda #VOICE_ON_NOISE
        sta VCREG2
.ResetBackLegsFrame
        lda #CAMEL_REAR_LEGS_FRAME1
        sta SPRPTR5
        lda #CAMEL_FRONT_LEGS_FRAME1
        sta SPRPTR6
        lda camelState
        beq .SetCamelHeadFrame
        jmp .ResetAnimationFrame
.SetCamelHeadFrame
        lda #CAMEL_HEAD_FRAME1
        sta camelHeadFrame
.ResetAnimationFrame
        lda #1
        sta camelAnimationFrame
        rts

;-------------------------------------------------------------------------------
; Flashes the score of the player, rotating through the colours in the score 
; flash table. The relevant colour ram address is set during the switch 
; player routine (or sticks on P1 score for one player)
;-------------------------------------------------------------------------------
IRQ_FlashPlayerScore
        dec scoreFlashColourIndex
        bne .SelectScoreColour
        lda #SCORE_FLASH_NUM_COLOURS
        sta scoreFlashColourIndex
.SelectScoreColour
        ldx scoreFlashColourIndex
        lda tbl_ScoreFlashColours-1,x
        ldy #SCORE_TOTAL_DIGITS
.ScoreColourLoop
        sta (ScoreColourLo),y
        dey
        bne .ScoreColourLoop
        rts

