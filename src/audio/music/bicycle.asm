Music_Bicycle:
	db	060h
	dw	Music_Bicycle_Ch1
	db	001h
	dw	Music_Bicycle_Ch2
	db	002h
	dw	Music_Bicycle_Ch3
	db	003h
	dw	Music_Bicycle_Ch4
;----------------------------------------
Music_Bicycle_Ch1:
;----------------------------------------
	db	$da,$00,$8c
	db	$db,$03
	db	$e6,$00,$01
	db	$e1,$8,$15
; P1-1
	db	$d8,$8c,$b4
	db	$d4,$c5
	db	$a5
	db	$83
; P1-2
	db	$dc,$b0
	db	$a5
	db	$dc,$b6
	db	$a7
	db	$dc,$b2
	db	$71
@mainloop:
	db	$dc,$b2
; P1-3
	db	$81
	db	$81
	db	$51
	db	$51
	db	$70
	db	$50
	db	$41
	db	$31
	db	$31
; P1-4
	db	$51
	db	$51
	db	$11
	db	$11
	db	$d5,$c1
	db	$81
	db	$a1
	db	$c1
; P1-5
	db	$d4,$11
	db	$11
	db	$51
	db	$51
	db	$21
	db	$51
	db	$71
	db	$51
; P1-6
	db	$31
	db	$51
	db	$31
	db	$21
	db	$31
	db	$31
	db	$21
	db	$31
; P1-7
	db	$81
	db	$81
	db	$51
	db	$51
	db	$70
	db	$50
	db	$41
	db	$31
	db	$31
; P1-8
	db	$51
	db	$51
	db	$11
	db	$11
	db	$d5,$c1
	db	$c1
	db	$b1
	db	$c1
; P1-9
	db	$d4,$11
	db	$d5,$c1
	db	$d4,$11
	db	$51
	db	$11
	db	$51
	db	$71
	db	$81
; P1-10
	db	$71
	db	$dc,$82
	db	$71
	db	$dc,$b2
	db	$a1
	db	$81
	db	$71
	db	$81
	db	$91
	db	$a1
; P1-11
	db	$dc,$b6
	db	$c3
	db	$83
	db	$d3,$33
	db	$d4,$83
; P1-12
	db	$a3
	db	$73
	db	$d3,$33
	db	$d4,$73
; P1-13
	db	$83
	db	$53
	db	$d3,$13
	db	$d4,$53
; P1-14
	db	$73
	db	$31
	db	$71
	db	$81
	db	$91
	db	$a3
; P1-15
	db	$d3,$31
	db	$d4,$c1
	db	$81
	db	$c1
	db	$d3,$31
	db	$81
	db	$31
	db	$d4,$c1
; P1-16
	db	$d3,$11
	db	$d4,$a1
	db	$71
	db	$a1
	db	$d3,$11
	db	$71
	db	$11
	db	$d4,$a1
; P1-17
	db	$81
	db	$51
	db	$11
	db	$51
	db	$81
	db	$91
	db	$a1
	db	$c1
; P1-18
	db	$d3,$11
	db	$11
	db	$d4,$a1
	db	$81
	db	$71
	db	$81
	db	$91
	db	$a1
	db	$fd,0
	dw	@mainloop
;----------------------------------------
Music_Bicycle_Ch2:
;----------------------------------------
	db	$db,$02
	db	$e1,$10,$24
; P2-1
	db	$d8,$8c,$c6
	db	$d3,$35
	db	$15
	db	$d4,$c3
; P2-2
	db	$dc,$c2
	db	$d3,$31
	db	$30
	db	$50
	db	$31
	db	$30
	db	$50
	db	$31
	db	$dc,$c3
	db	$11
	db	$d4,$c1
	db	$a1
@mainloop:
; P2-3
	db	$db,$02
	db	$dc,$c3
	db	$d4,$c3
	db	$83
	db	$a3
	db	$73
; P2-4
	db	$dc,$c2
	db	$81
	db	$71
	db	$51
	db	$71
	db	$dc,$c5
	db	$37
; P2-5
	db	$dc,$c4
	db	$53
	db	$83
	db	$dc,$c2
	db	$51
	db	$c1
	db	$a1
	db	$81
; P2-6
	db	$71
	db	$81
	db	$a1
	db	$81
	db	$dc,$c5
	db	$77
; P2-7
	db	$dc,$c3
	db	$c3
	db	$83
	db	$a3
	db	$73
; P2-8
	db	$dc,$c2
	db	$81
	db	$71
	db	$51
	db	$71
	db	$dc,$c5
	db	$37
; P2-9
	db	$dc,$c4
	db	$53
	db	$83
	db	$dc,$c2
	db	$51
	db	$d3,$51
	db	$31
	db	$11
; P2-10
	db	$d4,$c1
	db	$d3,$11
	db	$31
	db	$51
	db	$dc,$c7
	db	$77
; P2-11
	db	$fe
	dw	@sub1
; P2-14
	db	$73
	db	$dc,$c3
	db	$a1
	db	$31
	db	$51
	db	$61
	db	$73
	db	$dc,$c7
; P2-15
	db	$fe
	dw	@sub1
; P2-18
	db	$73
	db	$dc,$c3
	db	$a1
	db	$c1
	db	$a1
	db	$81
	db	$73
	db	$fd,0
	dw	@mainloop
@sub1:
; P2-11
	db	$85
	db	$c5
	db	$83
; P2-12
	db	$75
	db	$a5
	db	$73
; P2-13
	db	$55
	db	$85
	db	$53
	db	$ff
;----------------------------------------
Music_Bicycle_Ch3:
;----------------------------------------
; P3-1
	db	$d8,$c,$20
	db	$0f
; P3-2
	db	$d4,$a1
	db	$d3,$11
	db	$d4,$c1
	db	$d3,$31
	db	$11
	db	$51
	db	$31
	db	$d4,$a0
	db	$00
@mainloop:
; P3-3
	db	$fe
	dw	@sub1
; P3-4
	db	$50
	db	$00
	db	$80
	db	$00
	db	$50
	db	$00
	db	$80
	db	$00
	db	$30
	db	$00
	db	$d5,$c0
	db	$00
	db	$d4,$10
	db	$00
	db	$30
	db	$00
; P3-5
	db	$50
	db	$00
	db	$80
	db	$00
	db	$10
	db	$00
	db	$80
	db	$00
	db	$50
	db	$00
	db	$80
	db	$00
	db	$10
	db	$00
	db	$80
	db	$00
; P3-6
	db	$70
	db	$00
	db	$a0
	db	$00
	db	$30
	db	$00
	db	$a0
	db	$00
	db	$70
	db	$00
	db	$30
	db	$00
	db	$50
	db	$00
	db	$70
	db	$00
; P3-7
	db	$fe
	dw	@sub1
; P3-8
	db	$50
	db	$00
	db	$80
	db	$00
	db	$50
	db	$00
	db	$80
	db	$00
	db	$30
	db	$00
	db	$80
	db	$00
	db	$70
	db	$00
	db	$60
	db	$00
; P3-9
	db	$50
	db	$00
	db	$80
	db	$00
	db	$10
	db	$00
	db	$80
	db	$00
	db	$50
	db	$00
	db	$80
	db	$00
	db	$10
	db	$00
	db	$80
	db	$00
; P3-10
	db	$70
	db	$00
	db	$a0
	db	$00
	db	$30
	db	$00
	db	$a0
	db	$00
	db	$d3,$30
	db	$00
	db	$10
	db	$00
	db	$d4,$c0
	db	$00
	db	$a0
	db	$00
; P3-11
@loop1:
	db	$80
	db	$00
	db	$c0
	db	$00
	db	$30
	db	$00
	db	$c0
	db	$00
	db	$80
	db	$00
	db	$c0
	db	$00
	db	$30
	db	$00
	db	$c0
	db	$00
; P3-12
	db	$70
	db	$00
	db	$a0
	db	$00
	db	$30
	db	$00
	db	$a0
	db	$00
	db	$70
	db	$00
	db	$a0
	db	$00
	db	$30
	db	$00
	db	$a0
	db	$00
; P3-13
	db	$50
	db	$00
	db	$80
	db	$00
	db	$10
	db	$00
	db	$80
	db	$00
	db	$50
	db	$00
	db	$80
	db	$00
	db	$10
	db	$00
	db	$80
	db	$00
; P3-14
	db	$70
	db	$00
	db	$a0
	db	$00
	db	$30
	db	$00
	db	$a0
	db	$00
	db	$70
	db	$00
	db	$d3,$10
	db	$00
	db	$d4,$c0
	db	$00
	db	$a0
	db	$00
	db	$fd,2
	dw	@loop1
	db	$fd,0
	dw	@mainloop
@sub1:
; P3-3
	db	$d4,$80
	db	$00
	db	$c0
	db	$00
	db	$30
	db	$00
	db	$c0
	db	$00
	db	$80
	db	$00
	db	$c0
	db	$00
	db	$30
	db	$00
	db	$c0
	db	$00
	db	$ff
;----------------------------------------
Music_Bicycle_Ch4:
;----------------------------------------
	db	$e3,$000
; P4-1
	db	$d8,$c
	db	$0f
	db	$0f
@mainloop:
	db	$01
@loop1:
; P4-2
	db	$63
	db	$fd,12
	dw	@loop1
; P4-3
	db	$63
	db	$63
	db	$61
	db	$61
	db	$61
	db	$fd,0
	dw	@mainloop

