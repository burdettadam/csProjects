MPI_HOME        = /users/faculty/snell/mpich
MPI_INCL        = $(MPI_HOME)/include
MPI_LIB         = $(MPI_HOME)/lib

SRC   			= lab3.c
TARGET     		= lab3

CC         		= $(MPI_HOME)/bin/mpicc
CFLAGS			= -O -I$(MPI_INCL)
LFLAGS     		= -L$(MPI_LIB) -lm -lmpich

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET)

pi: pi.c
	$(CC) $(CFLAGS) pi.c -o pi

next: next.c
	$(CC) $(CFLAGS) next.c -o next

run: $(TARGET)
	./$(TARGET) -p4pg $(TARGET).cfg

clean:
		/bin/rm -f  *.o