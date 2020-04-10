;General
BULLET_UPDATE_RATE              = 4
SHIP_UPDATE_RATE                = 8
SHIP_MOVE_RATE                  = 4
SHIP_SPEED_RATE                 = 16
CAMEL_ANIMATION_RATE            = 16
COLLISION_COUNTER_RATE          = 32
STAR_TWINKLE_RATE               = 152
CAMEL_HEALTH_MINOR              = 16
SCORE_FLASH_NUM_COLOURS         = 4
SCORE_TOTAL_DIGITS              = 7
SHIP_FACE_LEFT                  = 0
SHIP_FACE_RIGHT                 = 1
BULLET_NOT_ACTIVE               = 0
BULLET_DIR_LEFT                 = 1
BULLET_DIR_RIGHT                = 2
SPIT_DIRECTION_RIGHT            = 0
SPIT_DIRECTION_LEFT             = 1
HYPERDRIVE_MOVE_RATE            = 96
HYPERDRIVE_PLAYER_UPDATE_RATE   = 128
EXPLOSION_RATE                  = 96

;Sprite Masks
SPR_SHIP_MASK_ON                = %00000001
SPR_SHIP_MASK_OFF               = %11111110
SPR_BULLET_MASK_ON              = %00000010
SPR_BULLET_MASK_OFF             = %11111101
SPR_CAMEL_SPIT_MASK_ON          = %00000100
SPR_CAMEL_SPIT_MASK_OFF         = %11111011
SPR_ROCKET_MASK_ON              = %00000100
SPR_ROCKET_MASK_OFF             = %11111011
SPR_CAMEL_MASK_ON               = %01111000      
SPR_CAMEL_MASK_OFF              = %10000111
SPR_CAMEL_FRONT_MASK_ON         = %01010000 
SPR_CAMEL_FRONT_MASK_OFF        = %10101111 
SPR_CAMEL_REAR_MASK_ON          = %00101000 
SPR_CAMEL_REAR_MASK_OFF         = %11010111      
SPR_AMC_LOGO_MASK_ON            = %00001111
SPR_EXPLOSION_MASK_ON           = %00001111
SPR_RADAR_MASK_ON               = %10000000
SPR_RADAR_MASK_OFF              = %01111111
SPR_SHIP_AND_ROCKET_MASK_ON     = %00000101
SPR_SHIP_AND_RADAR_MASK_ON      = %10000001
SPR_SHIP_AND_BULLET_MASK_ON     = %00000011

;Sprite collisions 
SPRCOL_BULLET_CAMEL             = %01111010
SPRCOL_BULLET_CAMELREAR         = %00001010
SPRCOL_BULLET_CAMELHEAD         = %00010010

;Sprite Pointers
CAMEL_REAR_FRAME                = 192
CAMEL_HEAD_FRAME1               = 193
CAMEL_REAR_LEGS_FRAME1          = 194
CAMEL_REAR_LEGS_FRAME2          = 195
CAMEL_REAR_LEGS_FRAME3          = 196
CAMEL_REAR_LEGS_FRAME4          = 197
CAMEL_FRONT_LEGS_FRAME1         = 198
CAMEL_FRONT_LEGS_FRAME2         = 199
CAMEL_FRONT_LEGS_FRAME3         = 200
CAMEL_FRONT_LEGS_FRAME4         = 201
SHIP_LEFT_FRAME                 = 202
SHIP_RIGHT_FRAME                = 203
BULLET_FRAME                    = 204
CAMEL_SPIT_BOMB_FRAME1          = 205
CAMEL_SPIT_BOMB_FRAME2          = 206
CAMEL_SPIT_BOMB_FRAME3          = 207
CAMEL_SPIT_BOMB_FRAME4          = 208
CAMEL_MARKER_FRAME              = 209
EXPLOSION_FRAME1                = 210
EXPLOSION_FRAME2                = 211
EXPLOSION_FRAME3                = 212
CAMEL_HEAD_DYING_FRAME1         = 213
CAMEL_HEAD_DYING_FRAME2         = 214
CAMEL_SPIT_FRAME1               = 215
CAMEL_SPIT_FRAME2               = 216
CAMEL_HEAD_FRAME2               = 217
CAMEL_HEAD_FRAME3               = 218
ROCKET_FRAME1                   = 219
ROCKET_FRAME2                   = 220
ROCKET_FRAME3                   = 221
ROCKET_FRAME4                   = 222
AMC_LOGO_SPRITE1                = 223
AMC_LOGO_SPRITE2                = 224
AMC_LOGO_SPRITE3                = 225
AMC_LOGO_SPRITE4                = 226

;Key Codes
KEY_F1                          = 4
KEY_F3                          = 5
KEY_F5                          = 6
KEY_NONE                        = 64

;States
GF_STATUS_MENU                  = 0
GF_STATUS_INITGAME              = 1
GF_STATUS_INITLEVEL             = 2
GF_STATUS_CAMEL_ATTACK          = 3
GF_STATUS_HYPERDRIVE            = 4
GF_STATUS_DYING                 = 5
GF_STATUS_GAMEOVER              = 6
FALSE                           = 0
TRUE                            = 1
SHIP_STATE_READY                = 0
SHIP_STATE_TURN                 = 1
SHIP_STATE_TURNING              = 2
CAMEL_STATE_ALIVE               = 0
CAMEL_STATE_DYING               = 128
CAMEL_STATE_DEAD                = 255
SPIT_STATE_INACTIVE             = 0
SPIT_STATE_ACTIVE               = 1
SPIT_STATE_BOMB                 = 2
SPIT_STATE_DISABLED             = 3

;Sound
VOICE_OFF                       = 0
VOICE_ON_TRIANGLE               = 17
VOICE_ON_TRIANGLE_RING          = 21
VOICE_ON_SAW                    = 33
VOICE_ON_NOISE                  = 129
SHIP_MOVE_FREQUENCY             = 25
CAMEL_WALK_FREQUENCY            = 2
BULLET_HIT_FREQUENCY            = 6
SPIT_HIT_FREQUENCY              = 2

;Joystick
JOY_UP                          = 1
JOY_DOWN                        = 2
JOY_LEFT                        = 4
JOY_RIGHT                       = 8
JOY_LEFTRIGHT                   = 12
JOY_FIRE                        = 16

;Chars
CHAR_E                          = 5
CHAR_N                          = 14
CHAR_O                          = 15
CHAR_S                          = 19
CHAR_Y                          = 25
CHAR_SPACE                      = 32
CHAR_CAMEL                      = 36
CHAR_BLOCK                      = 43
CHAR_STAR                       = 46
CHAR_0                          = 48
CHAR_1                          = 49
CHAR_3                          = 51
CHAR_9                          = 57

;Colours
BLACK                           = 0
WHITE                           = 1
RED                             = 2
CYAN                            = 3
PURPLE                          = 4
BLUE                            = 6
YELLOW                          = 7
ORANGE                          = 8
BROWN                           = 9
PINK                            = 10
GREY1                           = 11
LGREEN                          = 13
LBLUE                           = 14
LGREY                           = 15