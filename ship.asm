INCLUDE "define.asm"

SECTION "SHIP", ROM0
ship_init::
	ld hl, ship_mem
	ld bc, ship_mem_size
	.loop
	ld a, 0
	ld [hli], a
	dec bc
	ld a, b
	or a, c
	jr nz, .loop
	ret

