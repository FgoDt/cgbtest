SECTION "VBINTRUPT", ROM0[$40]
	call vblank_call
	reti

SECTION "INTRUPT", ROM0[$60]
	reti


SECTION "Header", ROM0[$100]
	nop
	jp main 
	ds $150 - @, 0


SECTION "Main", ROM0[$150]
main:
	di
	call TurnAudioOff
	call TurnLCDOff

	; call 
	ld de, test_tiles
	ld hl, $9000
	ld bc, test_tiles_end - test_tiles
	call load_tiles

	ld de, spaceship_tiles
	ld hl, $8000
	ld bc, spaceship_tiles_end - spaceship_tiles
	call load_tiles

	ld de, update_oam
	ld hl, $FF80
	ld bc, update_oam_end - update_oam
	call load_tiles

	call load_tile_map
	;ld a, %00011011
	;ld [$FF47], a

	; memset oam mem
	ld a, 0
	ld hl, $C000
	ld bc, $100
	call memset

	call init_spaceship

	ld bc, 0
	call update_spaceship_loc

	call $FF80


	;set loc x, y
	ld a, 0
	ld hl, $c100
	ld [hli], a
	ld [hl], a

	call trun_lcd_on

	ld a, %00010001
	ld [$ffff], a

	ei


main_loop:
	jp main_loop

right_press:
	ld hl, $c100
	ld a, [hl]
	inc a
	ld [hl], a
	ret

left_press:
	ld hl, $c100
	ld a, [hl]
	dec a
	ld [hl], a
	ret

up_press:
	ld hl, $c101
	ld a, [hl]
	dec a
	ld [hl], a
	ret

down_press:
	ld hl, $c101
	ld a, [hl]
	inc a
	ld [hl], a
	ret



	
vblank_call:
	ld a, $20
	ld [$ff00], a
	ld a, [$ff00]
	bit 0, a
	call z, right_press 
	ld a, $20
	ld [$ff00], a
	ld a, [$ff00]
	bit 1, a
	call z, left_press
	ld a, [$ff00]

	ld a, $20
	ld [$ff00], a
	ld a, [$ff00]
	bit 2, a
	call z, up_press

	ld a, $20
	ld [$ff00], a
	ld a, [$ff00]
	bit 3, a
	call z, down_press

	ld hl, $c100
	ld a, [hli]
	ld b, a
	ld c, [hl]
	call update_spaceship_loc
	call $FF80

	ret

TurnAudioOff:
	xor a
	ld [$ff26], a
	ret

WaitVBlank:
	ld a, [$FF44]
	cp 144
	jp c, WaitVBlank
	ret

TurnLCDOff:
	call WaitVBlank
	xor a
	ld [$FF40], a
	ret

trun_lcd_on:
	ld a, %10000011
	ld [$FF40], a
	ret

	; de, tiles loc
	; bc, size
	; hl, vmem loc
load_tiles:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, load_tiles
	ret


load_tile_map:
	ld hl, $9800
	ld b, 20
_copy_loop:
	ld a, b
	cp 10
	jp nc,_set_a_one
	ld a, 1
	jp _set
_set_a_one:
	ld a, 0
_set:
	ld [hli], a
	dec b
	jp nz, _copy_loop
	ret

	; hl start loc
	; bc num
	; a val
memset:
	ld d, a
.memset_loop:
	ld a, d
	ld [hli], a
	dec bc
	ld a, b
	or a, c
	jp nz, .memset_loop
	ret


def OAM_MEM_START equ $C000
def spaceship_mem_start equ $C000

	; mem:0 y
	; mem:1 x
	; mem:2 index
	; mem:3 flags
init_spaceship:
	ld hl, spaceship_mem_start
	ld a, 0
	; top left
	ld [hli], a ; y
	ld [hli], a ; x
	ld [hli], a ; index
	ld [hli], a ; flags
	; top right
	ld [hli], a ; y
	ld [hli], a ; x
	ld [hli], a ; index
	ld a, %00100000
	ld [hli], a ; flags
	; bottom left
	ld a, 8
	ld [hli], a ; y
	ld [hli], a ; x
	ld a, 3
	ld [hli], a ; index
	ld a, 0
	ld [hli], a ; flags
	; botom right
	ld a, 8
	ld [hli], a ; y
	ld [hli], a ; x
	ld a, 3
	ld [hli], a ; index
	ld a, %00100000
	ld [hli], a ; flags
	ret

	; b x
	; c y
update_spaceship_loc:
	ld  hl, spaceship_mem_start 

	ld  a, c
	add a, 16
	ld  [hli], a

	ld  a, b
	add a, 8
	ld  [hli], a
	inc hl
	inc hl

	ld  a, c
	add a, 16
	ld  [hli], a

	ld  a, b
	add a, 16
	ld  [hli], a
	inc hl
	inc hl

	ld a, c
	add a, 24
	ld [hli], a
	ld  a, b
	add a, 8
	ld [hli], a
	inc hl
	inc hl

	ld a, c
	add a, 24
	ld [hli], a
	ld  a, b
	add a, 16
	ld [hli], a
	inc hl
	inc hl

	ret



update_oam:
	ld a, HIGH(OAM_MEM_START)
	ldh [$FF46], a
	xor a
	ld a, $40
.wait
	dec a
	jr nz, .wait
	ret
update_oam_end:

joypad_call:
	ld a, $20
	ld [$ff00], a
	ld a, [$ff00]
	ld a, $10
	ld [$ff00], a
	ld a, [$ff00]
	ret





SECTION "Tile Data", ROM0
test_tiles:
	db $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
	db $00,$00, $10,$10, $38,$38, $7C,$7C, $FE,$FE, $7C,$7C, $38,$38, $10,$10
	db $00,$00, $00,$10, $38,$00, $7C,$7C, $FE,$FE, $7C,$7C, $38,$00, $00,$10
	db $00,$00, $02,$02, $05,$05, $12,$12, $28,$28, $10,$10, $44,$44, $55,$55
test_tiles_end:

spaceship_tiles:
	db $01,$01, $01,$01, $03,$03, $03,$03, $07,$07, $07,$07, $0F,$0F, $0F,$0F
	db $80,$80, $80,$80, $c0,$c0, $c0,$c0, $e0,$e0, $e0,$e0, $F0,$F0, $F0,$F0
	db $f8,$f8, $fc,$fc, $e0,$e0, $e0,$e0, $00,$00, $a0,$a0, $80,$80, $00,$00
	db $1f,$1f, $1f,$1f, $07,$07, $07,$07, $00,$00, $05,$05, $01,$01, $00,$00
spaceship_tiles_end:

