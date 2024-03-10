SFX_LevelUp:
	db	085h
	dw	SFX_LevelUp_Ch6
	db	006h
	dw	SFX_LevelUp_Ch7
	db	007h
	dw	SFX_LevelUp_Ch8
	db	008h
	dw	SFX_LevelUp_Ch9
	db	009h
	dw	SFX_LevelUp_Ch10
;----------------------------------------
SFX_LevelUp_Ch6:
;----------------------------------------
	db	$df
	db	$da,$00,$78
;	db	$e5,$77
	db	$db,$02
;		vib 6 26
; P1-2
	db	$d8,$88,$b1
	db	$d4,$c1
	db	$c1
	db	$c1
	db	$dc,$b3
	db	$d3,$9b
	db	$ff
;----------------------------------------
SFX_LevelUp_Ch7:
;----------------------------------------
	db	$df
; P2-2
;		vib 8 27
	db	$db,$02
	db	$d8,$88,$c1
	db	$d3,$51
	db	$51
	db	$51
	db	$dc,$c3
	db	$cb
	db	$ff
;----------------------------------------
SFX_LevelUp_Ch8:
;----------------------------------------
	db	$df
; P3-2
	db	$d8,$8,$25
	db	$d3,$90
	db	$00
	db	$90
	db	$00
	db	$90
	db	$00
	db	$dc,$35
	db	$d2,$57
	db	$03
	db	$ff
;----------------------------------------
SFX_LevelUp_Ch9:
;----------------------------------------
	db	$df
	db	$f0,$04
; P4-1
	db	$d8,$c
	db	$1b
	db	$ff
;----------------------------------------
SFX_LevelUp_Ch10:
;----------------------------------------
	db	$df
; P5-1
	db	$d8,$c
	db	$1b
	db	$ff
SFX_Item:
	db	085h
	dw	SFX_Item_Ch6
	db	006h
	dw	SFX_Item_Ch7
	db	007h
	dw	SFX_Item_Ch8
	db	008h
	dw	SFX_Item_Ch9
	db	009h
	dw	SFX_Item_Ch10
;----------------------------------------
SFX_Item_Ch6:
;----------------------------------------
	db	$df
	db	$da,$00,$6c
;	db	$e5,$77
	db	$e1,$8,$27
	db	$db,$02
; P1-2
	db	$d8,$88,$b2
	db	$d3,$15
	db	$11
	db	$61
	db	$11
	db	$83
	db	$83
	db	$83
; P1-3
	db	$6b
	db	$0b
	db	$ff
;----------------------------------------
SFX_Item_Ch7:
;----------------------------------------
	db	$df
	db	$e1,$8,$27
	db	$db,$02
; P2-2
	db	$d8,$88,$c3
	db	$d3,$a5
	db	$a1
	db	$a1
	db	$a1
	db	$b3
	db	$b3
	db	$b3
; P2-3
	db	$ab
	db	$0b
	db	$ff
;----------------------------------------
SFX_Item_Ch8:
;----------------------------------------
	db	$df
; P3-2
	db	$d8,$8,$25
	db	$d3,$63
	db	$01
	db	$60
	db	$00
	db	$60
	db	$00
	db	$60
	db	$00
	db	$41
	db	$01
	db	$41
	db	$01
	db	$51
	db	$01
; P3-3
	db	$dc,$35
	db	$69
	db	$0d
	db	$ff
;----------------------------------------
SFX_Item_Ch9:
;----------------------------------------
	db	$df
	db	$f0,$04
; P4-2
	db	$d8,$c
	db	$1f
; P4-3
	db	$0f
	db	$ff
;----------------------------------------
SFX_Item_Ch10:
;----------------------------------------
	db	$df
; P4-2
	db	$d8,$c
	db	$1f
; P4-3
	db	$0f
	db	$ff
SFX_Evolution:
	db	085h
	dw	SFX_Evolution_Ch6
	db	006h
	dw	SFX_Evolution_Ch7
	db	007h
	dw	SFX_Evolution_Ch8
	db	008h
	dw	SFX_Evolution_Ch9
	db	009h
	dw	SFX_Evolution_Ch10
;----------------------------------------
SFX_Evolution_Ch6:
;----------------------------------------
	db	$df
	db	$da,$00,$70
	db	$e1,$8,$27
	db	$db,$02
; P1-2
	db	$d8,$88,$b3
	db	$d3,$15
	db	$d4,$a5
	db	$6b
; P1-3
;		speed 00 78
	db	$dc,$b1
	db	$d3,$41
	db	$41
	db	$41
	db	$41
	db	$41
	db	$81
	db	$dc,$b3
	db	$6b
; P1-4
	db	$ff
;----------------------------------------
SFX_Evolution_Ch7:
;----------------------------------------
	db	$df
	db	$db,$02
	db	$e1,$8,$27
; P2-2
	db	$d8,$88,$c3
	db	$d3,$a5
	db	$65
	db	$1b
; P2-3
	db	$dc,$c1
	db	$b1
	db	$b1
	db	$b1
	db	$81
	db	$81
	db	$b1
	db	$dc,$c3
	db	$ab
; P2-4
	db	$ff
;----------------------------------------
SFX_Evolution_Ch8:
;----------------------------------------
	db	$df
; P3-2
	db	$d8,$8,$81
	db	$d4,$1b
	db	$dc,$3f
	db	$15
	db	$dc,$15
	db	$d5,$a1
	db	$d4,$11
	db	$61
; P3-3
	db	$dc,$3f
	db	$85
	db	$b5
	db	$a8
	db	$02
; P3-4
	db	$ff
;----------------------------------------
SFX_Evolution_Ch9:
;----------------------------------------
	db	$df
	db	$f0,$04
; P4-2
	db	$d8,$c
	db	$1f
; P4-3
	db	$0f
; P4-4
	db	$ff
;----------------------------------------
SFX_Evolution_Ch10:
;----------------------------------------
	db	$df
; P4-2
	db	$d8,$c
	db	$1f
; P4-3
	db	$0f
; P4-4
	db	$ff
Sfx_DexFanfare2049:
	db	085h
	dw	Sfx_DexFanfare2049_Ch6
	db	006h
	dw	Sfx_DexFanfare2049_Ch7
	db	007h
	dw	Sfx_DexFanfare2049_Ch8
	db	008h
	dw	Sfx_DexFanfare2049_Ch9
	db	009h
	dw	Sfx_DexFanfare2049_Ch10
;----------------------------------------
Sfx_DexFanfare2049_Ch6:
;----------------------------------------
	db	$df
	db	$da,$00,$68
	db	$db,$02
; P1-2
	db	$d8,$8c,$88
	db	$d4,$a3
	db	$01
	db	$a0
	db	$00
	db	$b3
	db	$01
	db	$b0
	db	$00
; P1-3
	db	$d3,$11
	db	$01
	db	$d4,$b1
	db	$01
	db	$a1
	db	$05
; P1-4
	db	$ff
;----------------------------------------
Sfx_DexFanfare2049_Ch7:
;----------------------------------------
	db	$df
	db	$db,$02
; P2-2
	db	$d8,$8c,$c1
	db	$d2,$61
	db	$51
	db	$31
	db	$11
	db	$d3,$b1
	db	$d2,$11
	db	$31
	db	$51
; P2-3
	db	$63
	db	$83
	db	$67
; P2-4
	db	$ff
;----------------------------------------
Sfx_DexFanfare2049_Ch8:
;----------------------------------------
	db	$df
; P3-1
	db	$d8,$c,$7f
; P3-2
	db	$d3,$63
	db	$01
	db	$60
	db	$00
	db	$63
	db	$01
	db	$60
	db	$00
; P3-3
	db	$a1
	db	$01
	db	$51
	db	$01
	db	$61
	db	$05
; P3-4
	db	$ff
;----------------------------------------
Sfx_DexFanfare2049_Ch9:
;----------------------------------------
	db	$df
	db	$f0,$04
; P4-2
	db	$d8,$c
	db	$1f
; P4-3
	db	$0f
; P4-4
	db	$ff
;----------------------------------------
Sfx_DexFanfare2049_Ch10:
;----------------------------------------
	db	$df
; P4-2
	db	$d8,$c
	db	$1f
; P4-3
	db	$0f
; P4-4
	db	$ff

