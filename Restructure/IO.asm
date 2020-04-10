;*** VIC ***
SPRX0           = $D000 ;Sprite 0 x-position
SPRY0           = $D001 ;Sprite 0 y-position
SPRX1           = $D002 ;Sprite 1 x-position
SPRY1           = $D003 ;Sprite 1 y-position
SPRX2           = $D004
SPRY2           = $D005
SPRX3           = $D006
SPRY3           = $D007
SPRX4           = $D008
SPRY4           = $D009
SPRX5           = $D00A
SPRY5           = $D00B
SPRX6           = $D00C
SPRY6           = $D00D
SPRX7           = $D00E
SPRY7           = $D00F
SPRXMSB         = $D010 ;Sprite x most significant bit
VCR1            = $D011 ;VIC Control Register 1
RASTER          = $D012 ;Raster
LPX             = $D013 ;Light-pen x-position
LPY             = $D014 ;Light-pen y-position
SPREN           = $D015 ;Sprite display enable
VCR2            = $D016 ;VIC Control Register 2
SPRYEX          = $D017 ;Sprite Y vertical expand
VMCR            = $D018 ;VIC Memory Control Register
VICINT          = $D019 ;VIC Interrupt Flag Register
IRQMR           = $D01A ;IRQ Mask Register
SPRDP           = $D01B ;Sprite/data priority
SPRMCS          = $D01C ;Sprite multi-colour select
SPRXEX          = $D01D ;Sprite X horizontal expand
SPRCSP          = $D01E ;Sprite to sprite collision
SPRCBG          = $D01F ;Sprite to background collision
BDCOL           = $D020 ;Screen border colour
BGCOL0          = $D021 ;Screen background colour 1
BGCOL1          = $D022 ;Screen background colour 2
BGCOL2          = $D023 ;Screen background colour 3
BGCOL3          = $D024 ;Screen background colour 4
SPRMC0          = $D025 ;Sprite multi-colour register 1
SPRMC1          = $D026 ;Sprite multi-colour register 2
SPRCOL0         = $D027 ;Sprite 0 colour
SPRCOL1         = $D028 ;Sprite 1 colour
SPRCOL2         = $D029 ;Sprite 2 colour
SPRCOL3         = $D02A ;Sprite 3 colour
SPRCOL4         = $D02B ;Sprite 4 colour
SPRCOL5         = $D02C ;Sprite 4 colour
SPRCOL6         = $D02D ;Sprite 4 colour
SPRCOL7         = $D02E ;Sprite 4 colour

;*** SID ***
FREL1           = $D400 ;V1 frequency low-byte
FREH1           = $D401 ;V1 frequency high-byte
PWL1            = $D402 ;V1 pulse waveform low-byte
PWH1            = $D403 ;V1 pulse waveform high-byte
VCREG1          = $D404 ;V1 control register
ATDCY1          = $D405 ;V1 attack/decay
SUREL1          = $D406 ;V1 sustain/release
FREL2           = $D407 ;V2 frequency low-byte
FREH2           = $D408 ;V2 frequency high-byte
PWL2            = $D409 ;V2 pulse waveform low-byte
PWH2            = $D40A ;V2 pulse waveform high-byte
VCREG2          = $D40B ;V2 control register
ATDCY2          = $D40C ;V2 attack/decay
SUREL2          = $D40D ;V2 sustain/release
FREL3           = $D40E ;V3 frequency low-byte
FREH3           = $D40F ;V3 frequency high-byte
PWL3            = $D410 ;V3 pulse waveform low-byte
PWH3            = $D411 ;V3 pulse waveform high-byte
VCREG3          = $D412 ;V3 control register
ATDCY3          = $D413 ;V3 attack/decay
SUREL3          = $D414 ;V3 sustain/release
SIDVOL          = $D418 ;Volume
SIDRAND         = $D41B ;Oscillator 3 random number generator
      
COLOURRAM       = $D800

CIAPRA          = $DC00 ;CIA port A
CIAPRB          = $DC01 ;CIA port B
DDRA            = $DC02 ;Data direction register port A
DDRB            = $DC03 ;Data direction register port B


JOY1            = $DC11

;-------------------------------------------------------------------------------
; KERNAL ROM $E000-$FFFF
;-------------------------------------------------------------------------------

krnINTERRUPT    = $EA31
krnCHROUT       = $FFD2