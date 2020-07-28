#include <stdio.h>
#include <stdlib.h>

#define MSIZE 8
//8x8 - down=1 / left=2 / up=4 / right=8
char maze[MSIZE][MSIZE];

int bc(int x, int y){
	return (x>=0) && (x<MSIZE) && (y>=0) && (y<MSIZE);
}
int isunvis(int x, int y){
	return bc(x,y) && (maze[x][y] & 16);
}
int anyunvis(int x, int y){
	return isunvis(x-1, y) || isunvis(x+1, y) || isunvis(x, y-1) || isunvis(x, y+1);
}
void generate(int x, int y){
	//fprintf(stderr, "generate(%d, %d);\n", x, y);
	maze[x][y] &= ~16;//Mark as visited
	while(anyunvis(x, y)){
		int loop = 1;
		char rnd = 0;
		while(loop){
			rnd = random() & 3;
			switch(rnd){
				case 0://UP
					if(isunvis(x, y-1)){
						loop = 0;
						maze[x][y]  &= ~4;//Remove top wall
						maze[x][y-1]&= ~1;//Bottom
						generate(x, y-1);
						break;
					}
				case 1://LEFT
					if(isunvis(x-1, y)){
						loop = 0;
						maze[x][y]  &= ~2;//Remove left wall
						maze[x-1][y]&= ~8;//Right
						generate(x-1, y);
						break;
					}
				case 2://RIGHT
					if(isunvis(x+1, y)){
						loop = 0;
						maze[x][y]  &= ~8;//Right
						maze[x+1][y]&= ~2;//Remove left wall
						generate(x+1, y);
						break;
					}
				case 3://DOWN
					if(isunvis(x, y+1)){
						loop = 0;
						maze[x][y]  &= ~1;//Bottom
						maze[x][y+1]&= ~4;//Remove top wall
						generate(x, y+1);
						break;
					}
			}
		}
	}
}
void printData(){
	static int id = 0;
	printf("\n;MazeGen #%02d\nmaze_%02d:",id,id);
	printf("dw\t");
	for(int x=0;x<MSIZE-1;x++) printf("%d,\t", maze[x][0]);
	printf("%d\n", maze[7][0]);
	for(int y=1;y<MSIZE-1;y++){
		printf("\t\tdw\t");
		for(int x=0;x<MSIZE-1;x++) printf("%d,\t", maze[x][y]);
		printf("%d\n", maze[7][y]);
	}
	printf("\t\tdw\t");
	for(int x=0;x<MSIZE-2;x++) printf("%d,\t", maze[x][7]);
	printf("%d\n", maze[6][7]);
	printf("gl%02d:\tdw\t\t\t\t\t\t\t\t",id);
	printf("%d\n", maze[7][7]);
	id++;
}
void printMap(){
	for(int dy=0;dy<MSIZE*3;dy++){
		putchar(';');
		switch(dy%3){
			case 0:
				for(int x=0;x<MSIZE;x++){
					putchar('x');
					putchar((maze[x][dy/3] & 4)?'_':' ');//Top wall
					putchar('x');
					//putchar(' ');
				}
				break;
			case 1:
				for(int x=0;x<MSIZE;x++){
					putchar((maze[x][dy/3] & 2)?'|':' ');//Left wall
					putchar('.');
					putchar((maze[x][dy/3] & 8)?'|':' ');//Right wall
					//putchar(' ');
				}
				break;
			case 2:
				for(int x=0;x<MSIZE;x++){
					putchar('x');
					putchar((maze[x][dy/3] & 1)?'_':' ');//Bottom wall
					putchar('x');
					//putchar(' ');
				}
				break;
		}
		putchar('\n');
	}
}
void reset(){
	for(int y=0;y<MSIZE;y++) for(int x=0;x<MSIZE;x++) maze[x][y] = 1 | 2 | 4 | 8 | 16;//1=down 2=left 4=up 8=right 16=unvisited
}
int main(){
	srandom(0x73656564);
	for(int i=0;i<=7;i++){
		reset();
		maze[0][0] &= ~(1 | 16);//Remove bottom wall and mark as visited
		maze[0][1] &= ~(1|4|16);//Remove top+bottom wall and mark as visited
		maze[0][2] &= ~(4 | 16);//Remove top wall and mark as visited
		generate(0, 2);
		printData();
		printMap();
	}
	return 0;
}
