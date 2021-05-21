ReanchorBGMap_NoOAMUpdate::
	call DelayFrame
	ldh a, [hOAMUpdate]
	push af

	ld a, $1
	ldh [hOAMUpdate], a
	ldh a, [hBGMapMode]
	push af
	xor a
	ldh [hBGMapMode], a

	call .ReanchorBGMap

	pop af
	ldh [hBGMapMode], a
	pop af
	ldh [hOAMUpdate], a

	ld hl, wVramState
	set 6, [hl]
	ret

.ReanchorBGMap:
	xor a
	ldh [hLCDCPointer], a
	ldh [hBGMapMode], a
	ld a, $90
	ldh [hWY], a
	call OverworldTextModeSwitch
	ld a, HIGH(vBGMap1)
	call .LoadBGMapAddrIntoHRAM
	call _OpenAndCloseMenu_HDMATransferTilemapAndAttrmap
	farcall LoadOW_BGPal7
	farcall ApplyPals
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	xor a
	ldh [hBGMapMode], a
	ldh [hWY], a
	farcall FillBGMap0WithBlack ; no need to farcall
	ld a, HIGH(vBGMap0)
	call .LoadBGMapAddrIntoHRAM
	xor a ; LOW(vBGMap0)
	ld [wBGMapAnchor], a
	ld a, HIGH(vBGMap0)
	ld [wBGMapAnchor + 1], a
	xor a
	ldh [hSCX], a
	ldh [hSCY], a
	call ApplyBGMapAnchorToObjects
	ret

.LoadBGMapAddrIntoHRAM:
	ldh [hBGMapAddress + 1], a
	xor a
	ldh [hBGMapAddress], a
	ret

LoadFonts_NoOAMUpdate::
	ldh a, [hOAMUpdate]
	push af
	ld a, $1
	ldh [hOAMUpdate], a

	call .LoadGFX

	pop af
	ldh [hOAMUpdate], a
	ret

.LoadGFX:
	call LoadFontsExtra
	ld a, $90
	ldh [hWY], a
	call SafeUpdateSprites
	call LoadStandardFont
	ret

FillBGMap0WithBlack::
        nop
        ldh a, [hBlackOutBGMapThird]
        and a ; 0
        ret z

        dec a ; 1
        jr z, .one
        dec a ; 2
        jr z, .two
        ; 3

BG_THIRD_HEIGHT EQU (BG_MAP_HEIGHT - SCREEN_HEIGHT) / 2

; Black out the 18 BG Map rows right of the screen area
        ld a, 2
        ldh [hBlackOutBGMapThird], a
        ld hl, hBGMapAddress
        ld a, [hli]
        ld h, [hl]
        ld l, a
        ld de, SCREEN_WIDTH
        add hl, de
        ld b, SCREEN_HEIGHT
        ld a, "■"
.loop1
rept BG_MAP_WIDTH - SCREEN_WIDTH
        ld [hli], a
endr
        add hl, de
        dec b
        jr nz, .loop1
        ret

.two
; Black out the top 7 BG Map rows below the screen area
        ld a, 1
        ld de, BG_MAP_WIDTH * SCREEN_HEIGHT
        jr .go

.one
; Black out the bottom 7 BG Map rows below the screen area
        xor a
        ld de, BG_MAP_WIDTH * (SCREEN_HEIGHT + BG_THIRD_HEIGHT)

.go
        ldh [hBlackOutBGMapThird], a
        ld hl, hBGMapAddress
        ld a, [hli]
        ld h, [hl]
        ld l, a
        add hl, de
        ld b, BG_THIRD_HEIGHT * 2
        ld a, "■"
.loop2
rept BG_MAP_WIDTH / 2
        ld [hli], a
endr
        dec b
        jr nz, .loop2
        ret
