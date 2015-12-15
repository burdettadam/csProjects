#include <mpi.h> //http://www.hpc.cam.ac.uk/using-clusters/compiling-and-development/parallel-programming-mpi-example
#include <openssl/sha.h>
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <math.h>
#include <stdlib.h>
#define WORKTAG     1
#define DIETAG     2
////////////////////////////////////////////////////////////////////////////////
static const int WIDTH_HEIGHT = 28000;
static const int HUE_PER_ITERATION = 5;
static const bool DRAW_ON_KEY = true;
unsigned char *image = NULL;
////////////////////////////////////////////////////////////////////////////////

class State {
    public:
        double centerX;
        double centerY;
        double zoom;
        int maxIterations;
        int w;
        int h;
        State() {
            centerX = -1.186340599860225;
            centerY = -0.303652988644423;
            zoom = 6800;
            maxIterations = 100;
            w = WIDTH_HEIGHT;
            h = WIDTH_HEIGHT;
        }
        void moveY(int change) {
            centerY += change / zoom;
        }
        void moveX(int change) {
            centerX += change / zoom;
        }
        void zoomBy(double r) {
            zoom *= r;
        }
        void addIterations(int i) {
            maxIterations += i;
        }
};

////////////////////////////////////////////////////////////////////////////////
/* Return the correct time in seconds, using a double precision number.       */

double When()
{
    struct timeval tp;
    gettimeofday(&tp, NULL);
    return ((double) tp.tv_sec + (double) tp.tv_usec * 1e-6);
}
 
float iterationsToEscape(double x, double y, int maxIterations) {
    double tempa;
    double a = 0;
    double b = 0;
    for (int i = 0 ; i < maxIterations ; i++) {
        tempa = a*a - b*b + x;
        b = 2*a*b + y;
        a = tempa;
        if (a*a+b*b > 64) {
            // return i; // discrete
            return i - log(sqrt(a*a+b*b))/log(8); //continuous
        }
    }
    return -1;
}

int hue2rgb(float t){
    while (t>360) {
        t -= 360;
    }
    if (t < 60) return 255.0*t/60.0;
    if (t < 180) return 255.0;
    if (t < 240) return 255.0 * (4.0 - t/60.0);
    return 0;
}

void writeImage(unsigned char *img, int w, int h) {
    long long filesize = 54 + 3*(long long)w*(long long)h;
    //int filesize = 54 + 3*w*h;
    unsigned char bmpfileheader[14] = {'B','M', 0,0,0,0, 0,0, 0,0, 54,0,0,0};
    unsigned char bmpinfoheader[40] = {40,0,0,0, 0,0,0,0, 0,0,0,0, 1,0, 24,0};
    unsigned char bmppad[3] = {0,0,0};

    bmpfileheader[ 2] = (unsigned char)(filesize    );
    bmpfileheader[ 3] = (unsigned char)(filesize>> 8);
    bmpfileheader[ 4] = (unsigned char)(filesize>>16);
    bmpfileheader[ 5] = (unsigned char)(filesize>>24);

    bmpinfoheader[ 4] = (unsigned char)(       w    );
    bmpinfoheader[ 5] = (unsigned char)(       w>> 8);
    bmpinfoheader[ 6] = (unsigned char)(       w>>16);
    bmpinfoheader[ 7] = (unsigned char)(       w>>24);
    bmpinfoheader[ 8] = (unsigned char)(       h    );
    bmpinfoheader[ 9] = (unsigned char)(       h>> 8);
    bmpinfoheader[10] = (unsigned char)(       h>>16);
    bmpinfoheader[11] = (unsigned char)(       h>>24);

    FILE *f;
    f = fopen("temp.bmp","wb");
    fwrite(bmpfileheader,1,14,f);
    fwrite(bmpinfoheader,1,40,f);
    for (int i=0; i<h; i++) {
        //fwrite(img+(w*(h-i-1)*3),3,w,f);
        long long offset = ((long long)w*(h-i-1)*3);
        fwrite(img+offset,3,w,f);
        fwrite(bmppad,1,(4-(w*3)%4)%4,f);
    }
    fclose(f);
}

void master(int ntasks ,int  range )
{
	int	 rank, x = 0, y = 0 ,rx,ry;
	unsigned char *img;
	double       result=0;
	MPI_Status     status;
    double imgSize = (3*(long long)WIDTH_HEIGHT*(long long)WIDTH_HEIGHT);
	if (img) free(img);
    img = (unsigned char *)malloc(imgSize);
/*
* Seed the slaves.
*/
	for (rank = 1; rank < ntasks; ++rank) {
		MPI_Send(&x,1,MPI_INT, rank, WORKTAG, MPI_COMM_WORLD);
		MPI_Send(&y,1,MPI_INT, rank, WORKTAG, MPI_COMM_WORLD);
		x += range; /* get_work block  */;
		if(x == WIDTH_HEIGHT ){  // I dont check the y
			y += range;
			x = 0;
		}
	}
	if (image) free(image);   
	image = (unsigned char *)malloc(3*(long long)WIDTH_HEIGHT*(long long)WIDTH_HEIGHT);

/*
* Receive a result from any slave and dispatch a new nonce
* request nonce requests have been exhausted.
*/
 	//nonce += range; /* get_next_nonce_request */ // I dont think we need this
	double start = When();
	while (y < WIDTH_HEIGHT) {       /* valid new work request */
		MPI_Recv(img, imgSize, MPI_UNSIGNED_CHAR, MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &status);       /* received message info */
		MPI_Recv(&rx, 1, MPI_INT, status.MPI_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
		MPI_Recv(&ry, 1, MPI_INT, status.MPI_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &status);

		MPI_Send(&x, 1, MPI_INT, status.MPI_SOURCE, WORKTAG, MPI_COMM_WORLD);
		MPI_Send(&y, 1, MPI_INT, status.MPI_SOURCE, WORKTAG, MPI_COMM_WORLD);
	    for (int px=rx; px< rx + range; px++) {
	        for (int py=ry; py< ry + range; py++) {
	            long long  loc = ((long long)px+(long long)py*(long long)WIDTH_HEIGHT)*3;
	            image[loc+2] = img[loc+2] ;
	            image[loc+1] = img[loc+1] ;
	            image[loc+0] = img[loc+0] ;
	        }
	    }


		x += range; /* get next work block */
		if(x == WIDTH_HEIGHT ){ 
			y += range;
			x = 0;
		}
	}
/*
* Receive results for outstanding requests.
*/
	for (rank = 1; rank < ntasks; ++rank) {
		MPI_Recv(img, imgSize, MPI_UNSIGNED_CHAR, MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &status);       /* received message info */
		MPI_Recv(&rx, 1, MPI_INT, status.MPI_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
		MPI_Recv(&ry, 1, MPI_INT, status.MPI_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
		for (int px=rx; px< rx + range; px++) {
	        for (int py=ry; py< ry + range; py++) {
	            long long  loc = ((long long)px+(long long)py*(long long)WIDTH_HEIGHT)*3;
	            image[loc+2] = img[loc+2] ;
	            image[loc+1] = img[loc+1] ;
	            image[loc+0] = img[loc+0] ;
	        }
	    }
		printf("received process : %d\n", status.MPI_SOURCE);
	}
/*
* Tell all the slaves to exit.
*/
	for (rank = 1; rank < ntasks; ++rank) {
		MPI_Send(0, 0, MPI_INT, rank, DIETAG, MPI_COMM_WORLD);
		MPI_Send(0, 0, MPI_INT, rank, DIETAG, MPI_COMM_WORLD);

		//printf("sent die to : %d\n", rank);
	}
    printf("time ran in  = %f\n",(When() - start) );
    writeImage(image, WIDTH_HEIGHT, WIDTH_HEIGHT);
	return;
}

void slave(int range) // create image 
{
	double result=1;
	State state;
	int w = state.w;
    int h = state.h;
    int x,y;
    if (w > WIDTH_HEIGHT) w = WIDTH_HEIGHT;
    if (h > WIDTH_HEIGHT) h = WIDTH_HEIGHT;
    double imgSize = (3*(long long)w*(long long)h);
    unsigned char *img = NULL, r, g, b;
 	if (img) free(img);
    img = (unsigned char *)malloc(imgSize);
 	
    double xs[WIDTH_HEIGHT], ys[WIDTH_HEIGHT]; 
	MPI_Status status;

	for (;;) {
		MPI_Recv(&x, 1, MPI_INT, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
		MPI_Recv(&y, 1, MPI_INT, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
/*
* Check the tag of the received message.
*/		//printf("x: %d, y: %d\n", x , y );
		if (status.MPI_TAG == DIETAG) {
			return;
		}
		//int diff = (iproc * range);
		for (int px =x; px < x + range ; px++) {
        	xs[px] = (px - w/2)/state.zoom + state.centerX;
    	}
    	for (int py =y; py < y + range ; py++) {
        	ys[py] = (py - h/2)/state.zoom + state.centerY;
    	}

	    for (int px=x; px< x + range; px++) {
	        for (int py=y; py< y + range; py++) {
			//	printf("x: %d, y: %d\n", px , py );
	            r = g = b = 0;
	            float iterations = iterationsToEscape(xs[px], ys[py], state.maxIterations);
	            if (iterations != -1) {
	                float h = HUE_PER_ITERATION * iterations;
	                r = hue2rgb(h + 120);
	                g = hue2rgb(h);
	                b = hue2rgb(h + 240);
	            }
	            long long  loc = ((long long)px+(long long)py*(long long)w)*3;
	            img[loc+2] = (unsigned char)(r);
	            img[loc+1] = (unsigned char)(g);
	            img[loc+0] = (unsigned char)(b);
	        }
	    }
		result = 1 /* do the nonce */;
		MPI_Send(img, imgSize, MPI_UNSIGNED_CHAR, 0, 0, MPI_COMM_WORLD);
		MPI_Send(&x, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
		MPI_Send(&y, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
	}
}
int main(int argc, char *argv[])
{


	int myrank;
	MPI_Init(&argc, &argv);   /* initialize MPI */
	MPI_Comm_rank(MPI_COMM_WORLD , &myrank);      /* process rank, 0 thru N-1 */
	int	ntasks, range;
	MPI_Comm_size(
	MPI_COMM_WORLD, &ntasks);          /* #processes in application */
	//printf("WIDTH_HEIGHT : %d\n", WIDTH_HEIGHT);
	range = WIDTH_HEIGHT / ( 1 * ntasks); 
	//printf("range : %d \n", range);

	if (myrank == 0) {
		master(ntasks,range);
	} else {
		slave(range);
	}
	MPI_Finalize();       /* cleanup MPI */
}
