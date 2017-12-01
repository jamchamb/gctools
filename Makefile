CFLAGS=-g -Wall -Werror
CXXFLAGS=-g -Wall -Werror -std=c++14
EXECUTABLES=afsdump gcmdump gsldump gvmdump pae2gvm

all: $(EXECUTABLES) prs sms

afsdump: afsdump.c
	gcc $(CFLAGS) -o afsdump afsdump.c

gcmdump: gcmdump.cc
	g++ $(CXXFLAGS) -o gcmdump gcmdump.cc -lphosg

gsldump: gsldump.c
	gcc $(CFLAGS) -o gsldump gsldump.c

gvmdump: gvmdump.c
	gcc $(CFLAGS) -o gvmdump gvmdump.c

pae2gvm: pae2gvm.c
	gcc $(CFLAGS) -o pae2gvm pae2gvm.c prs/prs.c prs/data_log.c

sms:
	cd sms && make && cd ..

prs:
	cd prs && make && cd ..

install: all
	cd prs && make install && cd ..
	cp $(EXECUTABLES) /usr/bin/

clean:
	-rm -rf *.o $(EXECUTABLES) *.dSYM
	cd prs && make clean && cd ..
	cd sms && make clean && cd ..

.PHONY: clean prs sms
