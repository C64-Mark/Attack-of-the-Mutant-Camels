;Zeropage variables

zpLow                           = $02 
zpHigh                          = $03
scnPlotLow                      = $04
scnPlotHigh                     = $05
zpTemp1                         = $06
zpTemp2                         = $07
zpTemp3                         = $08
gameStatus                      = $09
gameTimer                       = $0A
charToPlot                      = $0B
colourToPlot                    = $0C
startSector                     = $0D
playerSector                    = $0E
playerHealth                    = $0F
damageFlashFlag                 = $10
player1Lives                    = $11
player2Lives                    = $12
playerKilled                    = $13 
gameOver                        = $14
playerTurn                      = $15
switchPlayers                   = $16
collisionRegister               = $17
collisionCounter                = $18
currentEnemyID                  = $19

shipState                       = $20
shipSpriteFrame                 = $21
shipDirection                   = $22
shipX                           = $23
shipY                           = $24
shipXOffset                     = $25
shipSpeed                       = $26
shipSpeedCounter                = $27
shipMoveCounter                 = $28
shipUpdateCounter               = $29
shipTurnSoundFlag               = $2A
bulletDirection                 = $2B
bulletX                         = $2C
bulletY                         = $2D
bulletCounter                   = $2E
bulletSoundFrequency            = $2F

landscapePosition               = $30
landPositionCounter             = $31
landPositionMinor               = $32
landPositionMajor               = $33
landscapePixelCounter           = $34
currentStar                     = $35
starTwinkleCounter              = $36
hyperdriveEngaged               = $37
hyperdriveCompleted             = $38
hyperdriveUpdatePlayerCounter   = $39
hyperdriveUpdatePlayerRate      = $3A
hyperdriveLandscapeMoveMinor    = $3B
hyperdriveLandscapeMoveCounter  = $3C
hyperdriveLandscapeMoveRate     = $3D

camelState                      = $40
camelX                          = $41
camelRadarX                     = $42
camelAnimationCounter           = $43
camelAnimationFrame             = $44
camelHeadFrame                  = $45
camelKilledID                   = $46
camelCollision                  = $47
camelsRemaining                 = $48
camelSpeedCounter               = $49
camelSpeed                      = $4A
camelPositionMinor              = $4B
camelPositionMajor              = $4C
camelSpitState                  = $4D
camelSpitX                      = $4E
camelSpitFrame                  = $4F
camelSpitDirection              = $50
camelSpitDelayCounter           = $51
camelSpitDelayRate              = $52
camelSpitRateCounter            = $53
camelSpitRate                   = $54
camelSpitSoundFrequency         = $55
camelSpitBombRateCounter        = $56
camelSpitBombRate               = $57
camelSpitShipDifference         = $58
enemyMoveCounterMinor           = $59
enemyMoveCounterMajor           = $5A
rocketMoveRate                  = $5B
rocketX                         = $5C

scoreBonus                      = $60
scoreFlashColourIndex           = $61
scoreScreenLo                   = $62
scoreScreenHi                   = $63
scoreColourLo                   = $64
scoreColourHi                   = $65
explosionCounter                = $66
explosionX1                     = $67
explosionX2                     = $68
explosionX3                     = $69
explosionX4                     = $6A
explosionY1                     = $6B
explosionY2                     = $6C
explosionY3                     = $6D
explosionY4                     = $6E

inputJoy                        = $70
inputJoyLR                      = $71
decreaseOffsetFlag              = $72


;System
sysTI_A2                        = $A2
sysKeyCode_C5                   = $C5
sysIntVectorLo_0314             = $0314
sysIntVectorHi_0315             = $0315


;Screen & Sprite Pointers
SCREENRAM                       = $0400

SCNROW4                         = $04A0
SCNROW8                         = $0540
SCNROW11                        = $05B8
SCNROW12                        = $05E0
SCNROW13                        = $0608
SCNROW14                        = $0630
SCNROW15                        = $0658
SCNROW17                        = $06A8
SCNROW19                        = $06F8
SCNROW21                        = $0748
SCNROW23                        = $0798
SCNROW24                        = $07C0

SCN_HISCORE                     = $0412
SCN_PL1SCORE                    = $044F
SCN_BONUS                       = $0463
SCN_PL2SCORE                    = $0470

SCN_CAMELRADAR                  = $049F
SCN_PLAYTEXT                    = $04AB
SCN_PLAYERTEXT                  = $04B8

SCN_PL1LIVES                    = $079D
SCN_PL2LIVES                    = $07BF
SCN_SECTOR                      = $07AF

SPRPTR0                         = $07F8
SPRPTR1                         = $07F9
SPRPTR2                         = $07FA
SPRPTR3                         = $07FB
SPRPTR4                         = $07FC
SPRPTR5                         = $07FD
SPRPTR6                         = $07FE
SPRPTR7                         = $07FF

*=$2000
CHARS
        incbin "charsAMC.cst", 0, 63


;DATA TABLES
*=$2200
tbl_ScnPointerLo                byte $00, $28, $50, $78, $a0, $c8, $f0, $18
                                byte $40, $68, $90, $b8, $e0, $08, $30, $58
                                byte $80, $a8, $d0, $f8, $20, $48, $70, $98, $c0

tbl_ScnPointerHi                byte $04, $04, $04, $04, $04, $04, $04, $05
                                byte $05, $05, $05, $05, $05, $06, $06, $06
                                byte $06, $06, $06, $06, $07, $07, $07, $07, $07


tbl_PlayerStats
tbl_CamelCurrentColour          byte $00, $00, $00, $00, $00, $00, $00, $00
tbl_CamelMarkerScreenLo         byte $00, $00, $00, $00, $00, $00, $00, $00
tbl_CamelHealthMinor            byte $00, $00, $00, $00, $00, $00, $00, $00
tbl_CamelHealth                 byte $00, $00, $00, $00, $00, $00, $00, $00

;tbl_InitCamelMarkerScreenLo     byte $03, $07, $0B, $0F, $13, $17, $1B, $1C
tbl_InitCamelMarkerScreenLo     byte $02, $06, $0A, $0E, $12, $16, $1A, $1B
tbl_InitCamelHealthMinor        byte $10, $10, $10, $10, $10, $10, $10, $10 
tbl_InitCamelHealth             byte $06, $06, $06, $06, $06, $06, $06, $06

tbl_Player1TempStats            byte $ff
                                byte $00, $00, $00, $00, $00, $00, $00, $00
                                byte $00, $00, $00, $00, $00, $00, $00, $00
                                byte $00, $00, $00, $00, $00, $00, $00, $00
                                byte $00, $00, $00, $00, $00, $00, $00, $00
tbl_P1LevelStats                byte $00, $00, $00, $00
;camelpos minor, camelpos major, sector, camels remaining

tbl_Player2TempStats            byte $ff
                                byte $00, $00, $00, $00, $00, $00, $00, $00
                                byte $00, $00, $00, $00, $00, $00, $00, $00
                                byte $00, $00, $00, $00, $00, $00, $00, $00
                                byte $00, $00, $00, $00, $00, $00, $00, $00
tbl_P2LevelStats                byte $00, $00, $00, $00


tbl_CamelSpeeds                 byte $80, $80, $70, $60, $50, $80, $70, $60
                                byte $50, $70, $70, $70, $70, $60, $60, $60
                                byte $60, $60, $5a, $58, $58, $58, $58, $58
                                byte $58, $56, $54, $52, $50, $4e, $4c, $4a

tbl_CamelSpitDelayRates         byte $10, $10, $0e, $0c, $0a, $10, $0e, $0c
                                byte $0a, $0e, $0e, $0e, $0e, $0c, $0c, $0c
                                byte $0c, $0a, $0a, $0a, $0a, $09, $09, $09
                                byte $09, $08, $08, $08, $08, $08, $08, $08

tbl_CamelSpitRates              byte $03, $03, $03, $03, $03, $02, $02, $02
                                byte $02, $01, $01, $01, $01, $03, $03, $03
                                byte $03, $02, $02, $02, $02, $01, $01, $01
                                byte $01, $01, $01, $01, $01, $01, $01, $01

tbl_RocketMoveRates             byte $40, $40, $3e, $38, $36, $34, $32, $30
                                byte $2e, $2d, $2c, $2b, $2a, $29, $28, $27
                                byte $26, $26, $25, $25, $24, $24, $23, $23
                                byte $22, $22, $21, $21, $20, $20, $20, $20

tbl_CamelSpitBombRates          byte $07, $07, $07, $07, $07, $07, $07, $07
                                byte $07, $06, $06, $06, $05, $04, $03, $03
                                byte $03, $03, $03, $03, $02, $02, $01, $03
                                byte $03, $02, $02, $01, $01, $01, $01, $01

tbl_ShipSpeeds                  byte $ff, $0a, $08, $06, $04, $02, $01, $01
                                byte $01, $01, $01, $01, $01, $01, $01, $01

tbl_StarScreenX                 byte $04, $07, $12, $09, $07, $15, $18, $0c
                                byte $23, $13, $19, $04, $20, $22, $01, $25

tbl_StarScreenY                 byte $06, $06, $07, $08, $09, $0a, $07, $09
                                byte $09, $08, $08, $07, $09, $06, $09, $07

tbl_CamelHeadFrame              byte CAMEL_HEAD_FRAME1, CAMEL_HEAD_FRAME2, CAMEL_HEAD_FRAME3, CAMEL_HEAD_FRAME2
tbl_CamelColours                byte $ff, LGREEN, RED, BLUE, LGREY, BROWN, YELLOW, YELLOW
tbl_ScoreFlashColours           byte LBLUE, YELLOW, PINK, WHITE
tbl_RocketFrames                byte ROCKET_FRAME1, ROCKET_FRAME2, ROCKET_FRAME3, ROCKET_FRAME4
                                byte ROCKET_FRAME3, ROCKET_FRAME2, ROCKET_FRAME1


;SCREEN TEXT

txt_ScreenHeader                text 'score pl. 1 >  hi:  llama   > score pl.2'
                                text '            >               >           '
                                text '0000000     >   $ :  100    >    0000000'
                                text '@@@@@@@@@@@@<@@@@@@@@@@@@@@@<@@@@@@@@@@@'
                                text '   $   $   $   $   $   $                '
                                text '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

gameHiScore = txt_ScreenHeader + 19

txt_JMPresents                  text 'jeff minter presents'
txt_AMC                         text '  attack of the mutant camels   '
txt_GridRunner                  text ' from the creator of gridrunner '
txt_Players                     text 'players: 1   start at sector: 01'
txt_ColCamels                   text ' collisions with camels:   no   '
txt_PressFire                   text '  press fire to start the game  '
txt_PlayPlayer                  text 'play player onetwo'
txt_PlayerStats                 text 'jets            sector 00         jets  '
txt_SectorDefences              text 'sector defences penetrated'
txt_HyperdriveEngaging          text '    trans sector hyperdrive engaging    '

txt_LandscapeRow1               byte $20, $20, $20, $20, $20, $1b, $23, $23
                                byte $20, $20, $20, $20, $20, $20, $20, $20
                                byte $20, $20, $20, $20, $20, $20, $20, $20
                                byte $20, $20, $20, $20, $20, $20, $20, $20
                                byte $20, $20, $1d, $1e, $20, $20, $20, $20

txt_LandscapeRow2               byte $20, $20, $20, $20, $1b, $1d, $2b, $2b
                                byte $1e, $23, $1c, $20, $20, $20, $20, $20
                                byte $20, $20, $20, $20, $20, $20, $20, $20
                                byte $20, $20, $1b, $23, $1c, $1b, $1f, $1d
                                byte $23, $1d, $2b, $2b, $1e, $20, $20, $20

txt_LandscapeRow3               byte $20, $20, $1b, $23, $1d, $2b, $2b, $2b
                                byte $2b, $2b, $2b, $1e, $20, $20, $20, $20
                                byte $20, $20, $1d, $1e, $20, $20, $20, $20
                                byte $20, $1b, $1d, $2b, $1e, $1d, $2b, $2b
                                byte $2b, $2b, $2b, $2b, $2b, $1e, $20, $20

txt_LandscapeRow4               byte $1f, $1f, $1d, $2b, $2b, $2b, $2b, $2b
                                byte $2b, $2b, $2b, $2b, $1e, $23, $1f, $1f
                                byte $1f, $1d, $2b, $2b, $1e, $1f, $1f, $1f
                                byte $1f, $1d, $2b, $2b, $2b, $2b, $2b, $2b
                                byte $2b, $2b, $2b, $2b, $2b, $2b, $1e, $1f


*=$3000
        incbin "spritesAMC.spt", 1, 35, true


;Screen colour
COL_PL1SCORE                    = $D84F
COL_PL2SCORE                    = $D870
COL_PLAYTEXT                    = $D8AB
COL_PLAYERTEXT                  = $D8B8
COL_PL1LIVES                    = $DB9D
COL_PL2LIVES                    = $DBBF
COL_SECTOR                      = $DBAF

COLROW4                         = $D8A0
COLROW11                        = $D9B8
COLROW12                        = $D9E0
COLROW13                        = $DA08
COLROW14                        = $DA30
COLROW15                        = $DA58
COLROW19                        = $DAF8
COLROW23                        = $DB98
COLROW24                        = $DBC0