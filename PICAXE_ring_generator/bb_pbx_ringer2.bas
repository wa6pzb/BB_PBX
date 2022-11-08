' PICAXE Ring Generator
' 10/17/2022 Interrupt Version

setint OR %00001000,%00011000

main:
	high C.1
	for  b0 = 1 to 40
	 high C.2
	 pause 25
	 low C.2
	 pause 25
	next b0
	low C.1
	pause 4000
goto main

interrupt:
	low C.1
	low C.2
	if pinC.4 = 0 or pinC.3 = 1 then interrupt
	pause 50
	setint OR %00001000,%00011000
	high C.1
	return
