ASM	= rgbasm
LINK	= rgblink
FIX	= rgbfix

TARGET	= my
OBJS	= ship.o my.o utils.o
ROM	= $(OBJS)
ASM_SRC	= $(OBJS:.o=.asm)

$(TARGET).gb: $(ROM)
	$(LINK) -o $@ $^
	$(FIX) -v -p 0xFF $@

%.o: %.asm
	$(ASM) -o $@ $<

clean:
	rm -f *.o *.gb
