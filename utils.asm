SECTION "UTIL", ROM0
gbmemset:
	ld d, a
	.memset_loop
	ld a, d
	ld [hli], a
	dec bc
	ld a, b
	or a, c
	jr nz, .memset_loop
	ret

