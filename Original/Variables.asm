;-------------------------------------------------------------------------------
; Zeropage Game Variables
;-------------------------------------------------------------------------------
zp02Tmp                                 = $02
zpLo                                    = $02
zpHi                                    = $03
charToPlot                              = $04
colourToPlot                            = $05
zp04Tmp                                 = $04
zp05Tmp                                 = $05
zpLo4                                   = $05
zpHi4                                   = $06
zp06Tmp                                 = $06
zpLo2                                   = $06
zpHi2                                   = $07
startSector                             = $07
zp07Tmp                                 = $07
zpLo5                                   = $07
zpHi5                                   = $08
zp08Tmp                                 = $08
zpLo3                                   = $08
zpHi3                                   = $09

landscapePosition                       = $10
shipDirection                           = $11
shipMoveCounter                         = $13
shipXOffset                             = $14
shipSpeed                               = $15
shipSpriteFrame                         = $16
shipSpeedCounter                        = $17
shipX                                   = $18
shipY                                   = $19
inputJoy                                = $1A
inputJoyLR                              = $1B
shipState                               = $1C
gameTimer                               = $1D
shipOffsetChangeCounter                 = $1E
shipTurnSoundFlag                       = $1F

camelMarkerX                            = $20
explosionCounter                        = $20
hyperdriveUpdatePlayerCounter           = $20
hyperdriveUpdatePlayerRate              = $21
zp21Tmp                                 = $21
hyperdriveShipMoveCounter               = $22
currentEnemyID                          = $23
hyperdriveLandscapeMoveCounter          = $24
hyperdriveLandscapeMoveRate             = $25
camelMarkerUpdateCounter                = $26
zp27Tmp                                 = $27
camelSpeedCounter                       = $28
camelSpeed                              = $2B
zp2CTmp                                 = $2C
camelAnimationFrame                     = $2D
enemyMoveCounterMinor                   = $2E
enemyMoveCounterMajor                   = $2F

bulletEnable                            = $30
bulletDirection                         = $31
bulletX                                 = $32
bulletY                                 = $33
starTwinkleCounter                      = $34
bulletSoundFrequency                    = $36
camelHeadFrame                          = $38
camelState                              = $3A
landPositionMinor                       = $3C
landPositionMajor                       = $3D
camelPositionMinor                      = $3E
camelPositionMajor                      = $3F

rocketX                                 = $40
zp40Tmp                                 = $40
zp41Tmp                                 = $41
camelX                                  = $42
camelLandPositionCounter                = $43
camelFrameRate                          = $45
camelKilledID                           = $46
currentStar                             = $47
starTwinkleRate                         = $48

explosionX1                             = $40
explosionX2                             = $41
explosionX3                             = $42
explosionX4                             = $43
explosionY1                             = $44
explosionY2                             = $45
explosionY3                             = $46
explosionY4                             = $47

camelSpitSoundFrequency                 = $51
camelSpitRate                           = $52
zp53Redundant                           = $53
zp54Redundant                           = $54
camelSpitState                          = $55
camelSpitX                              = $56
camelSpitFrame                          = $57
camelSpitBombRate                       = $58
camelSpitDirection                      = $59
zp5ARedundant                           = $5A
camelSpitBombRateCounter                = $5B
zp5CRedundant                           = $5C
camelSpitSpeedCounter                   = $5D
camelSpitSpeed                          = $5E
camelSpitRateCounter                    = $5F

camelSpitShipDifference                 = $60
playerHealth                            = $61
damageFlashFlag                         = $62
scoreColourCounter                      = $63
scoreScreenLo                           = $64
scoreScreenHi                           = $65
scoreColourLo                           = $66
scoreColourHi                           = $67
scoreBonus                              = $68
camelsRemaining                         = $69
rocketMoveRate                          = $6A
player1Lives                            = $6C
player2Lives                            = $6D
playerTurn                              = $6E
playerSector                            = $6F

bottomRowFlag                           = $70
collisionRegister                       = $95
camelCollision                          = $FD
collisionCounter                        = $FE
zpFFRedundant                           = $FF

SCREEN_PTR_LO                           = $0340
SCREEN_PTR_HI                           = $0360

;System Variables
sysTI_A2                                = $A2
sysKeyCode_C5                           = $C5
sysShiftKeyIndicator_028D               = $028D
sysIntVectorLo_0314                     = $0314
sysIntVectorHi_0315                     = $0315

