'PICAXE Basic bb_pbx_ringer.xml


symbol varA = w0

main:
	do
  	do while pinC.4 = 1
    	high C.1
    	do
      	toggle C.2
      	pause 50
      	let varA = varA + 1
    	loop until varA = 40
    	low C.1
    	pause 4000
    	let varA = 0
  	loop
	loop
	stop
