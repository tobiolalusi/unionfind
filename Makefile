CC = gcc
CFLAGS = -g -O0 -m64 -no-pie -Wall -Wextra -Wpedantic

.PHONY: all

uf: uf.S getint.S uf_utils.c uf.c

clean:
	rm uf

