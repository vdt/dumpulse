AVRGCC=avr-gcc
CFLAGS=-g -Os -Wall -Wpedantic -std=c89
PYTEST=py.test-3

all-native: dumpulse.o udpserver dumpulse.so loopbench
clean:
	-rm *.o *.so udpserver diagram.png heartbeat.png health-report.png
all: all-native dumpulse-i386.o dumpulse-attiny88.o dumpulse-atmega328.o diagram.png heartbeat.png health-report.png

test: test-prereqs
	$(PYTEST) test.py
dockertest: test-prereqs
	docker build -t dumpulse .
	docker run dumpulse py.test test.py
test-prereqs: dumpulse.so

dumpulse.o: dumpulse.c dumpulse.h
	$(CC) -fPIC $(CFLAGS) -o $@ -c $<

dumpulse_so.o: dumpulse_so.c dumpulse.h
	$(CC) -fPIC $(CFLAGS) -o $@ -c $<

dumpulse.so: dumpulse_so.o dumpulse.o
	$(CC) -shared $^ -o $@

udpserver: udpserver.o dumpulse.o
loopbench.o: loopbench.c dumpulse.h
loopbench: loopbench.o dumpulse.o
bench: loopbench
	time ./$<

dumpulse-attiny88.o: dumpulse.c dumpulse.h
	$(AVRGCC) -mmcu=attiny88 $(CFLAGS) -c $< -o $@

dumpulse-atmega328.o: dumpulse.c dumpulse.h
	$(AVRGCC) -mmcu=atmega328 $(CFLAGS) -c $< -o $@

dumpulse-i386.o: dumpulse.c dumpulse.h
	$(CC) -m32 $(CFLAGS) -c $< -o $@

%.png: %.dot
	dot -Tpng < $< > $@
