Music_CherrygroveCity:
	db	080h
	dw	$ffff & Music_CherrygroveCity_Ch1
	db	001h
	dw	$ffff & Music_CherrygroveCity_Ch2
	db	002h
	dw	$ffff & Music_CherrygroveCity_Ch3
	db	003h
	dw	$ffff & Music_CherrygroveCity_Ch4
	db	004h
	dw	$ffff & Music_CherrygroveCity_Ch5
;----------------------------------------
Music_CherrygroveCity_Ch1:
;----------------------------------------
	db	$da,$00,$98
	db	$db,$03
	db	$e6,$00,$01
	db	$e1,$8,$15
; P1-1
	db	$d8,$c,$b5
	db	$09
	db	$d4,$11
	db	$31
	db	$51
@mainloop:
; P1-2
	db	$a3
	db	$91
	db	$a1
	db	$b1
	db	$a1
	db	$81
	db	$61
; P1-3
	db	$a5
	db	$61
	db	$11
	db	$d5,$b1
	db	$d4,$11
	db	$51
; P1-4
	db	$83
	db	$71
	db	$81
	db	$a1
	db	$81
	db	$61
	db	$51
; P1-5
	db	$85
	db	$51
	db	$11
	db	$d5,$b1
	db	$a1
	db	$d4,$11
; P1-6
	db	$dc,$b7
	db	$d5,$b5
	db	$d4,$35
	db	$b3
; P1-7
	db	$a5
	db	$61
	db	$17
; P1-8
	db	$d5,$b5
	db	$d4,$35
	db	$dc,$b5
	db	$a3
; P1-9
	db	$83
	db	$53
	db	$33
	db	$53
; P1-10
	db	$d5,$b5
	db	$d4,$35
	db	$b3
; P1-11
	db	$a5
	db	$61
	db	$13
	db	$d5,$c3
; P1-12
	db	$b5
	db	$d4,$21
	db	$d5,$b3
	db	$83
; P1-13
	db	$a3
	db	$d4,$13
	db	$d5,$a3
	db	$d4,$13
	db	$fd,0
	dw	$ffff & @mainloop
;----------------------------------------
Music_CherrygroveCity_Ch2:
;----------------------------------------
	db	$db,$03
	db	$e1,$10,$36
; P2-1
	db	$d8,$c,$c3
	db	$d4,$11
	db	$31
	db	$51
	db	$31
	db	$51
	db	$81
	db	$a1
	db	$b1
@mainloop:
; P2-2
	db	$dc,$c6
	db	$d3,$15
	db	$33
	db	$dc,$b3
	db	$31
	db	$11
	db	$d4,$b1
; P2-3
	db	$dc,$c7
	db	$d3,$15
	db	$d4,$a1
	db	$67
; P2-4
	db	$dc,$c6
	db	$b5
	db	$d3,$13
	db	$dc,$b3
	db	$11
	db	$d4,$b1
	db	$a1
; P2-5
	db	$dc,$c7
	db	$b5
	db	$81
	db	$57
; P2-6
	db	$dc,$a0
	db	$35
	db	$65
	db	$d3,$33
; P2-7
	db	$15
	db	$dc,$a5
	db	$d4,$a1
	db	$dc,$c7
	db	$67
; P2-8
	db	$dc,$a0
	db	$35
	db	$65
	db	$d3,$33
; P2-9
	db	$dc,$c7
	db	$1f
; P2-10
	db	$dc,$b5
	db	$d4,$35
	db	$65
	db	$d3,$33
; P2-11
	db	$15
	db	$d4,$a1
	db	$67
; P2-12
	db	$25
	db	$65
	db	$83
; P2-13
	db	$dc,$a0
	db	$67
	db	$dc,$a7
	db	$67
	db	$fd,0
	dw	$ffff & @mainloop
;----------------------------------------
Music_CherrygroveCity_Ch3:
;----------------------------------------
; P3-1
;		init c 25
	db	$d8,$c,$35
	db	$03
	db	$d3,$11
	db	$d4,$b1
	db	$a1
	db	$81
	db	$61
	db	$51
@mainloop:
; P3-2
	db	$dc,$35
	db	$a1
	db	$61
	db	$a1
	db	$dc,$6a
	db	$d3,$13
	db	$dc,$35
	db	$d4,$61
	db	$81
	db	$a1
; P3-3
	db	$a1
	db	$61
	db	$a1
	db	$dc,$6a
	db	$d3,$13
	db	$dc,$35
	db	$d4,$61
	db	$81
	db	$a1
; P3-4
	db	$b1
	db	$81
	db	$b1
	db	$dc,$6a
	db	$d3,$13
	db	$dc,$35
	db	$d4,$61
	db	$81
	db	$a1
; P3-5
	db	$dc,$6a
	db	$b3
	db	$dc,$35
	db	$d3,$11
	db	$d4,$b1
	db	$a1
	db	$81
	db	$61
	db	$51
; P3-6
	db	$31
	db	$dc,$6a
	db	$63
	db	$dc,$35
	db	$b1
	db	$61
	db	$b1
	db	$a1
	db	$81
; P3-7
	db	$61
	db	$dc,$6a
	db	$a3
	db	$dc,$35
	db	$61
	db	$a1
	db	$61
	db	$51
	db	$41
; P3-8
	db	$31
	db	$dc,$6a
	db	$63
	db	$dc,$35
	db	$b1
	db	$61
	db	$b1
	db	$a1
	db	$81
; P3-9
	db	$51
	db	$81
	db	$b1
	db	$d3,$11
	db	$d4,$b1
	db	$a1
	db	$81
	db	$61
; P3-10
	db	$31
	db	$dc,$6a
	db	$63
	db	$dc,$35
	db	$b1
	db	$61
	db	$b1
	db	$a1
	db	$81
; P3-11
	db	$61
	db	$dc,$6a
	db	$a3
	db	$dc,$35
	db	$61
	db	$a1
	db	$61
	db	$51
	db	$41
; P3-12
	db	$21
	db	$dc,$6a
	db	$63
	db	$dc,$35
	db	$b1
	db	$61
	db	$b1
	db	$a1
	db	$81
; P3-13
	db	$61
	db	$a1
	db	$61
	db	$a1
	db	$61
	db	$a1
	db	$61
	db	$a1
	db	$fd,0
	dw	$ffff & @mainloop
;----------------------------------------
Music_CherrygroveCity_Ch4:
;----------------------------------------
	db	$e3,$003
;----------------------------------------
Music_CherrygroveCity_Ch5:
;----------------------------------------
; P4-1
	db	$d8,$c
	db	$0f
@mainloop:
; P4-2
	db	$21
	db	$01
	db	$81
	db	$21
	db	$21
	db	$71
	db	$23
; P4-3
	db	$21
	db	$01
	db	$81
	db	$20
	db	$20
	db	$73
	db	$21
	db	$81
	db	$fd,0
	dw	$ffff & @mainloop

