' BB_PBX Ringer2
' 10/3/2022


start0:
	high C.1
	for  b0 = 1 to 40
	 high C.2
	 pause 25
	 low C.2
	 pause 25
	next b0
	low C.1
	pause 4000
	goto start0
	
start1:
	if PinC.4 = 1 and PinC.3 = 0 then
		resume 0
	else
		suspend 0
		low C.1
		low C.2

	endif
	
	goto start1
