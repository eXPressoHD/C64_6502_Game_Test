.import source "constants.asm"
.import source "vic2constants.asm"
.var music = LoadSid("Turrican_2-The_Final_Fight.sid")
BasicUpstart2(irqinit)
*=$3000

//Interrupts
irqinit:
sei //spend all interrupt
lda #%01111111 //disable byte 8 for interrupts 
sta INTERRUPT_REG //DC0D Intterupt control status register, 
ora #%00000001
sta RASTER_SPRITE_INT_REG
lda RASTER_LINE_MSB
and #%01111111
sta RASTER_LINE_MSB
lda #0
sta RASTER_LINE
lda #<irq1
sta INTERRUPT_EXECUTION_LOW
lda #>irq1
sta INTERRUPT_EXECUTION_HIGH
cli

start:
lda #music.startSong-1
jsr music.init

sprite:
//sprite 1 adresse auf ersten byte von sprite0 zeigen
lda #200 //sprite auf location 200 setzen (decimal 200) (in accumalator laden)
sta SPRITE_POINTER_0//In adresse des spritepointer 0 (accumalator storen)  speichern (frame 0 des sprites) (Zeigen Sie mit der Zeigeradresse des Sprites auf den Anfang von Byte 1
lda #black
sta SPRITE_MULTICOLOR_3_0 //schwarz in multicolor_3_0 speichern

//Positionierung (decimal)
lda #44 //x pixel
sta SPRITE_0_X
lda #120 //y pixel
sta SPRITE_0_Y

//enable sprite 0
lda #%00000001  // % -> binary (8bit von rechts nach links, wenn erstes byte 1 = sprite visible)
sta SPRITE_ENABLE

//Clearscreen
lda #blue
sta BORDER_COLOR
sta SCREEN_COLOR //ist bereits im accumulator


ldx #0    
loop_text: lda message1,x      
           sta $0590,x      
           lda message2,x      
           sta $05e0,x  
           inx
           cpx #$28
           bne loop_text   
           rts

// jsr CLS//jump to subroutine (clearscreen)
// rts //return from subroutine in diese routine

//speichere x / y register vom accumulator im stack
irq1:
pha
txa
pha
tya
pha
jsr music.play

ack:
dec INTERRUPT_STATUS

//restore vom stack
pla
tay
pla
tax
pla
jmp SYS_IRQ_HANDLER

*=music.location "Music" //memlocation
.fill music.size, music.getData(i)


message1:
    .text "       "
message2:
    .text  "    expresso presents...        "



*=12800
// sprite 0 / singlecolor / color: $01
//64 byte blöcke -> 200 im accumulator 200 * 64 = 12800 -> start des sprites
sprite_0:
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$03
.byte $ff,$c0,$0e,$00,$70,$1e,$00,$78
.byte $3c,$1c,$34,$38,$3e,$04,$40,$3e
.byte $02,$46,$3e,$32,$4f,$1c,$7a,$4f
.byte $00,$7a,$46,$00,$32,$40,$ff,$02
.byte $3f,$24,$fc,$04,$24,$20,$04,$00
.byte $20,$02,$00,$40,$01,$ff,$80,$01