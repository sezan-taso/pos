default:
	make img

ipl.bin: ipl.s Makefile
	../z_tools/nask.exe ipl.s ipl.bin ipl.lst

os.img: ipl.bin Makefile
	../z_tools/edimg.exe imgin:../z_tools/fdimg0at.tek wbinimg src:ipl.bin len:512 from:0 to:0 imgout:os.img

img:
	make os.img

run:
	run
