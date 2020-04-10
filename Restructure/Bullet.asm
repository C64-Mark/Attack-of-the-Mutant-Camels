;-------------------------------------------------------------------------------
; Moves the bullet if it is active. The bullet counter determines the rate at
; which the update occurs. The routine also checks for collision between
; bullet and camel and generates the bullet sound effects. The score routine 
; is called with ldx=1 point for each hit.
;-------------------------------------------------------------------------------
Bullet_MoveBullet
        dec bulletCounter
        beq .MoveBullet
        rts
.MoveBullet
        lda #BULLET_UPDATE_RATE
        sta bulletCounter
        lda bulletDirection 
        cmp #BULLET_NOT_ACTIVE
        beq .ExitMoveBullet
        cmp #BULLET_DIR_LEFT
        beq .MoveBulletLeft
        inc bulletX
        lda bulletX
        cmp #165
        beq .DisableBulletSprite
        jmp .SetBulletX
.MoveBulletLeft
        dec bulletX
        lda bulletX
        cmp #245
        beq .DisableBulletSprite
.SetBulletX
        lda bulletX 
        asl
        sta SPRX1
        bcs .SetBulletXMSB
        lda SPRXMSB
        and #SPR_BULLET_MASK_OFF
        sta SPRXMSB
        jmp .SetBulletY
.SetBulletXMSB
        lda SPRXMSB
        ora #SPR_BULLET_MASK_ON
        sta SPRXMSB
.SetBulletY
        lda bulletY
        sta SPRY1
        lda collisionRegister
        and #SPRCOL_BULLET_CAMEL
        cmp #SPRCOL_BULLET_CAMELREAR
        beq .BulletHitCamel
        cmp #SPRCOL_BULLET_CAMELHEAD
        beq .BulletHitCamel
        dec bulletSoundFrequency
        lda bulletSoundFrequency
        sta FREH1
        lda #VOICE_OFF
        sta VCREG1
        lda #VOICE_ON_NOISE
        sta VCREG1
.ExitMoveBullet
        rts
.BulletHitCamel
        jsr Bullet_DamageCamelHealth
        ldy #7
        ldx #1
        jsr Score_IncreaseScore
        lda #BULLET_HIT_FREQUENCY
        sta FREH3
        lda #FALSE
        sta collisionRegister
        lda #VOICE_OFF
        sta VCREG3
        lda #VOICE_ON_NOISE
        sta VCREG3
.DisableBulletSprite
        lda #0
        sta SPRY1
        lda SPREN
        and #SPR_BULLET_MASK_OFF
        sta SPREN
        lda #BULLET_NOT_ACTIVE
        sta bulletDirection
        lda #SHIP_MOVE_FREQUENCY
        sta FREH1
        rts

;-------------------------------------------------------------------------------
; Decreases the health of the relevant camel if the bullet collides with it.
; Two bytes are used for camel health. When the major byte decreases this 
; causes a change in the camel colour. Once major health is zero the camel is 
; killed, the score bonus increases (to a max of 6400) and the score routine is 
; called with ldx=current score bonus. The camel dying head animation starts.
;-------------------------------------------------------------------------------
Bullet_DamageCamelHealth
        ldx currentEnemyID
        dec tbl_CamelHealthMinor-1,x
        lda tbl_CamelHealthMinor-1,x
        beq .DecreaseCamelHealthMajor
        rts
.DecreaseCamelHealthMajor
        lda #CAMEL_HEALTH_MINOR
        sta tbl_CamelHealthMinor-1,x
        dec tbl_CamelHealth-1,x
        lda tbl_CamelHealth-1,x
        beq .camelDestroyed
        tay
        lda tbl_CamelColours-1,y
        sta tbl_CamelCurrentColour-1,x
        rts
.camelDestroyed
        lda currentEnemyID
        sta camelKilledID
        ldx scoreBonus
        ldy #5
        jsr Score_IncreaseScore
        lda scoreBonus
        cmp #64
        beq .scoreBonusAtMax
        asl
.scoreBonusAtMax
        sta scoreBonus
        jsr Screen_DisplayPlayerStats
        lda #CAMEL_HEAD_DYING_FRAME1
        sta camelHeadFrame
        lda #CAMEL_STATE_DEAD
        sta camelState
        rts
