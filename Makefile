CC = gcc
CFLAGS = -c
PROG = validate

c_validate: validate.c
	$(CC) $(CFLAGS) validate.c

as_validate: validate.S
	$(CC) $(CFLAGS) validate.S

as_analizarTag: analizartag.S
	$(CC) $(CFLAGS) analizartag.S

tp1_orga: main.c
	$(CC) $(CFLAGS) main.c

mips: as_validate as_analizarTag tp1_orga
	$(CC) validate.o analizartag.o main.c -o $(PROG)

c: c_validate tp1_orga
	$(CC) validate.o main.c -o $(PROG)
	
clean:
	rm -rf *.o $(PROG)
