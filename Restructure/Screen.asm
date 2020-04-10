;-------------------------------------------------------------------------------
; Clears the screen. If this is called with Y=1 then the routine skips the
; top rows of the screen (i.e. where current score is held)
;-------------------------------------------------------------------------------
Screen_Clear
        ldx #0
.ClearScreenLoop
        lda #CHAR_SPACE
        cpy #1
        beq .SkipScreenHeaderRows
        sta SCREENRAM,X
.SkipScreenHeaderRows
        sta SCREENRAM+$00F0,X
        sta SCREENRAM+$0100,X
        sta SCREENRAM+$0200,X
        sta SCREENRAM+$02F8,X
        lda #WHITE
        sta COLOURRAM,X
        sta COLOURRAM+$0100,X
        sta COLOURRAM+$0200,X
        sta COLOURRAM+$02F8,X
        dex
        bne .ClearScreenLoop
        rts

;-------------------------------------------------------------------------------
; This scrolls the landscape on the screen by setting the char offset position
; when reading the 4 landscape text rows to print to the screen. Each landscape
; text block is 40 chars wide (i.e. the width of the screen). The changing
; offset then determines the start char on the left of the screen 
;-------------------------------------------------------------------------------
Screen_MoveLandscape
        lda shipDirection 
        beq .ShipHeadingLeft
        inc landscapePosition
        lda landscapePosition
        cmp #41
        bne .DisplayLandscape
        lda #1
        jmp .DisplayLandscape
.ShipHeadingLeft
        dec landscapePosition
        lda landscapePosition
        cmp #0
        bne .DisplayLandscape
        lda #40
.DisplayLandscape
        sta landscapePosition
        tax
        ldy #40
.LandscapeDisplayLoop
        lda txt_LandscapeRow1-1,x
        sta SCNROW11-1,y
        lda txt_LandscapeRow2-1,x
        sta SCNROW12-1,y
        lda txt_LandscapeRow3-1,x
        sta SCNROW13-1,y
        lda txt_LandscapeRow4-1,x
        sta SCNROW14-1,y
        lda #ORANGE
        sta COLROW11-1,y
        sta COLROW12-1,y
        sta COLROW13-1,y
        sta COLROW14-1,y
        dex
        cpx #0
        bne .SkipResetLandscapeIndex
        ldx #40
.SkipResetLandscapeIndex
        dey
        bne .LandscapeDisplayLoop
        rts

;-------------------------------------------------------------------------------
; Displays the grey block of land below the mountain landscape
;-------------------------------------------------------------------------------
Screen_DisplayGround
        ldy #0
.DisplayGrounLoop
        lda #CHAR_BLOCK
        sta SCNROW15,y
        sta SCNROW19,y
        lda #GREY1
        sta COLROW15,y
        sta COLROW19,y
        iny
        cpy #160
        bne .DisplayGrounLoop
        rts

;-------------------------------------------------------------------------------
; Plots the stars on the screen determined by the XY locations held in the star
; screen table
;-------------------------------------------------------------------------------
Screen_DisplayStars
        lda #CHAR_STAR
        sta charToPlot
        lda #WHITE
        sta colourToPlot
        ldx #16
.NextStar
        lda tbl_StarScreenX-1,X
        sta zpLow
        lda tbl_StarScreenY-1,X
        sta zpHigh
        stx zpTemp1
        jsr Screen_Plot
        ldx zpTemp1
        dex
        bne .NextStar
        rts

;-------------------------------------------------------------------------------
; A general screen plot routine called with XY screen positions pre-stored in
; the zpHigh/zpLow variable and the char and charcolour stored in charToPlot and 
; colourToPlot. The screen pointer table then uses the XY to calculate the 
; screen position for the relevant char/colour.
;-------------------------------------------------------------------------------
Screen_Plot
        ldx zpHigh
        ldy zpLow
        lda tbl_ScnPointerLo,X
        sta scnPlotLow
        lda tbl_ScnPointerHi,X
        sta scnPlotHigh
        lda charToPlot
        sta (scnPlotLow),Y
        lda scnPlotHigh
        clc
        adc #$D4
        sta scnPlotHigh
        lda colourToPlot
        sta (scnPlotLow),Y
        rts

;-------------------------------------------------------------------------------
; Displays player lives and current sector at the bottom of the screen and the
; current camel bonus score at the top of the screen 
;-------------------------------------------------------------------------------
Screen_DisplayPlayerStats
        ldx #40
.DisplayPlayerStatsLoop
        lda txt_PlayerStats-1,x
        sta SCNROW23-1,x
        lda #YELLOW
        sta COLROW23-1,x
        lda #CHAR_SPACE
        sta SCNROW24-1,x
        dex
        bne .DisplayPlayerStatsLoop
        lda player1Lives
        clc
        adc #CHAR_0
        sta SCN_PL1LIVES
        lda player2Lives
        clc
        adc #CHAR_0
        sta SCN_PL2LIVES
        lda #PURPLE
        sta COL_PL1LIVES
        sta COL_PL2LIVES
        ldx playerSector
.DisplaySectorLoop
        inc SCN_SECTOR+1
        lda SCN_SECTOR+1
        cmp #CHAR_9+1
        bne .SkipSectorHighDigit
        lda #CHAR_0
        sta SCN_SECTOR+1
        inc SCN_SECTOR
.SkipSectorHighDigit
        dex
        bne .DisplaySectorLoop
        lda #CYAN
        sta COL_SECTOR+1
        sta COL_SECTOR
        lda #CHAR_SPACE
        sta SCN_BONUS
        sta SCN_BONUS+1
        lda #CHAR_0
        sta SCN_BONUS+2
        ldy scoreBonus
.DisplayBonusLoop
        ldx #3
.IncreaseBonusCharLoop
        inc SCN_BONUS-1,x
        lda SCN_BONUS-1,x
        cmp #CHAR_9+1
        bne .SkipResetBonusChar
        lda #CHAR_0
        sta SCN_BONUS-1,x
        dex
        beq .SkipResetBonusChar
        lda SCN_BONUS-1,x
        cmp #CHAR_SPACE
        bne .IncreaseBonusCharLoop
        lda #CHAR_0
        sta SCN_BONUS-1,x
        jmp .IncreaseBonusCharLoop
.SkipResetBonusChar
        dey
        bne .DisplayBonusLoop
        rts

;-------------------------------------------------------------------------------
; Displays the camel markers on the radar using the screen plot routine
;-------------------------------------------------------------------------------
Screen_DisplayCamelMarker
        ldx #6
.DisplayCamelMarkerLoop
        lda tbl_CamelHealth-1,X
        cmp #255
        beq .NextCamelMarker
        lda tbl_camelMarkerScreenLo-1,X
        sta zpLow
        lda #4
        sta zpHigh
        lda #CHAR_SPACE
        sta charToPlot
        lda #WHITE
        sta colourToPlot
        stx zpTemp1
        jsr Screen_Plot
        ldx zpTemp1
        inc tbl_camelMarkerScreenLo-1,X
        inc zpLow
        lda #CHAR_CAMEL
        sta charToPlot
        jsr Screen_Plot
        ldx zpTemp1
.NextCamelMarker
        dex
        bne .DisplayCamelMarkerLoop
        rts

;-------------------------------------------------------------------------------
; Rotates through each of the stars setting the next one in the sequence to 
; red and the previous star back to white to create a 'twinkle' effect
;-------------------------------------------------------------------------------
Screen_TwinkleStars
        dec starTwinkleCounter
        beq .TwinkleStars
        rts
.TwinkleStars
        lda #STAR_TWINKLE_RATE
        sta starTwinkleCounter 
        lda #CHAR_STAR
        sta charToPlot
        lda #WHITE
        sta colourToPlot
        ldx currentStar
        lda tbl_StarScreenX,x
        sta zpLow
        lda tbl_StarScreenY,x
        sta zpHigh
        jsr Screen_Plot
        inc currentStar
        lda currentStar
        and #15
        sta currentStar
        tax
        lda tbl_StarScreenX,x
        sta zpLow
        lda tbl_StarScreenY,x
        sta zpHigh
        lda #RED
        sta colourToPlot
        jsr Screen_Plot
        rts

;-------------------------------------------------------------------------------
; Moves the radar grid sprite that shows current player position relative to
; camel position on the radar
;-------------------------------------------------------------------------------
Screen_MoveCamelRadar
        lda #10
        sta camelRadarX
        ldx landPositionMajor
.SetLandPositionLoop
        clc
        lda camelRadarX
        adc #16
        sta camelRadarX
        dex
        bne .SetLandPositionLoop
        lda landPositionMinor
        clc
        ror
        clc
        ror
        clc
        ror
        clc
        ror
        clc
        adc camelRadarX
        clc
        asl
        sta SPRX7
        bcc .ClearCamelRadarXMSB
        lda SPRXMSB
        ora #SPR_RADAR_MASK_ON
        sta SPRXMSB
        jmp .ExitMoveCamelRadar
.ClearCamelRadarXMSB
        lda SPRXMSB
        and #SPR_RADAR_MASK_OFF
        sta SPRXMSB
.ExitMoveCamelRadar
        rts
