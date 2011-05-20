//  boardRecognizerTests.h
//  Sudokubot
//
//  Created by Haoest on 5/20/11.
//  Copyright 2011 none. All rights reserved.
//
// opencvContour.cpp : Defines the entry point for the console application.
//

#include "boardRecognizerTests.hpp"
#include "BoardRecognizer.h"
#include <opencv2/imgproc/imgproc_c.h>
#include "cvutil.hpp"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#include <highgui/highgui.hpp>

IplImage *cvLoadImage(char fileName[255]);
void checkResult(int board[][9], int** ocrGuesses);
void checkResult(int **solution, int**ocrGuesses);
int** loadStringAsBoard(char boardAsString[89]);
void testSimple();
void testNoisyRotated();
void testRotated2();
void testRotated345();
void testNoisy();
void testRotated25jpg();
void testRotated5();
void testShaded();
void testShaded_colorfg();
void testShaded_colorfg_noisy();
void testCamera_noisyjpg();
void testCamera_noisypng();
void testCamera_book1_small();
void testCamera_book1();
void testCamera_curl();
void testCamera_doubleshadow();
void testCamera_noisy();
void testCamera_shadow();
void testCamera_verynoisy();
void testCamera_shadow2();
void testIphone_ss1();
void testIphone_ss2();
void testIphone_ss3();

void testCamera_book2jpg();
void testCamera_book2png();
void testCamera_lcd1();
void testCamera_lcd2();
void testCamera_lcd3();
void testCamera_book3_all();
void testCamera_book3_one(char fileName[]);


void OnBlockSizeChange(int pos);
void OnParam1Change(int pos);
IplImage* displayImage = 0;

const int doShowSolution = 1;
int blockSize = 3;
int param1 = 5;

void runAllBoardRecognizerTests(){
	//displayImage = cvLoadImage("blackwhite.png");
	//cvSmooth(displayImage, displayImage, CV_BLUR, 9);
	//CvRect roi = cvRect(0, 25, 200, 25);
	//showImage(displayImage);
	//IplImage *roi = cvCreateImageHeader(cvSize(displayImage->width * 0.5, displayImage->height*0.5), 8, 3);
	//roi->widthStep = displayImage->widthStep;
	//roi->imageData = displayImage->imageData;
	//cvSmooth(roi, roi, CV_GAUSSIAN, 9);
	//showImage(displayImage);
    
	//most of these test are OKAY
	testShaded();
	testIphone_ss2();
	testRotated345();
	testSimple();
	testNoisy();
	testRotated25jpg();
	testCamera_book1_small();
	testCamera_noisy();
	testCamera_verynoisy();
	testCamera_doubleshadow();
    
	testCamera_noisypng();
	testCamera_book1();
	testShaded_colorfg_noisy();
	testShaded_colorfg();
	testCamera_shadow2();
	testCamera_curl();
	testRotated2();
	testIphone_ss1();
	testCamera_book2jpg();
	testCamera_book2png();
	testCamera_book3_all();
    
	////////
	////////if these don't work, it's because it's bad sample; perhaps the board is too small, or boardlines too thin
	//testCamera_shadow(); // this doesn't work because the whole puzzle is not captured. Right-most bord lines are missing
	//testNoisyRotated();
	//testRotated5();
	//testIphone_ss3();
    
	
	//testCamera_lcd1();
	//testCamera_lcd2();
	//testCamera_lcd3();
	//testCamera_book3_one("camera_book3_10.jpg");
    
	getchar();
}


void testCamera_book3_all(){
	char fileName[255];
	for(int i=1; i<11; i++){
		int **solution = loadStringAsBoard("080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030");
		sprintf(fileName, "camera_book3_%d.jpg\0", i);
        NSLog(@"\ntesting %s...\n", fileName);
		IplImage *img = cvLoadImage(fileName);
		int **board = recognizeBoardFromPhoto(img);
		checkResult(solution, board);
		cvReleaseImage(&img);
	}
}

void testCamera_book3_one(char fileName[]){
	printf("\n %s \n", fileName);
	IplImage *img = cvLoadImage(fileName);
	int bg;
	IplImage *boardImg = findSudokuBoard(img, bg);
	int **board = recognizeFromBoard(boardImg, bg);
	int **solution = loadStringAsBoard("080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030");
	checkResult(solution, board);
	cvReleaseImage(&img);
	cvReleaseImage(&boardImg);
}

void testCamera_lcd1(){
	printf("\n testCamera_lcd1 \n");
	IplImage *img = cvLoadImage("camera_lcd1.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("000910560 000000001 073000240 000051008 080000050 400720000 092000870 700000000 051076000");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_lcd2(){
	printf("\n testCamera_lcd2 \n");
	IplImage *img = cvLoadImage("camera_lcd2.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("405800900 060500201 030060708 090000006 050000070 800000030 503090080 602007090 001004605");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_lcd3(){
	printf("\n testCamera_lcd3 \n");
	IplImage *img = cvLoadImage("camera_lcd3.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("608407103 300658000 700030008 940200800 037806940 006009031 100080009 000925004 409701305");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_book2jpg(){
	printf("\n testCamera_book2jpg \n");
	IplImage *img = cvLoadImage("camera_book2_1.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("050609030 210000065 400000007 003941600 000000000 004728500 300000006 160000078 080305020");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_book2png(){
	printf("\n testCamera_book2png \n");
	IplImage *img = cvLoadImage("camera_book2_1.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("050609030 210000065 400000007 003941600 000000000 004728500 300000006 160000078 080305020");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testIphone_ss3(){
	printf("\niphone ss3\n");
	IplImage *img = cvLoadImage("iphone_ss3.png");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("000000700 150408900 640090815 070900008 000184000 800006090 724030081 009607032 001000000");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testIphone_ss2(){
	printf("\niphone ss2\n");
	IplImage *img = cvLoadImage("iphone_ss2.png");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("000000700 150408900 640090815 070900008 000184000 800006090 724030081 009607032 001000000");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testIphone_ss1(){
	printf("\niphone ss1\n");
	IplImage *img = cvLoadImage("iphone_ss1.png");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("040000760 026104000 500003008 000040007 200010900 600300080 000400509 075000040 000058100");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_shadow2(){
	printf("\ntestCamera_shadow2\n");
	IplImage *img = cvLoadImage("camera_shadow2.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("015040790 080070020 200301005 037506140 100708006 026104870 900603007 060010030 051080960");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_verynoisy(){
	printf("\ntestCamera_verynoisy\n");
	IplImage *img = cvLoadImage("camera_verynoisy.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int solution[][9] = {{0,4,9,0,7,0,0,0,0},{0,6,0,4,0,0,3,0,0},{0,0,5,0,0,2,6,0,7},
        {0,9,0,5,8,0,1,0,0},{0,5,0,0,0,0,0,7,0},{0,0,6,0,2,1,0,3,0},
        {6,0,8,7,0,0,4,0,0},{0,0,1,0,0,4,0,8,0},{0,0,0,0,6,0,7,1,0}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_shadow(){
	printf("\ntestCamera_shadow\n");
	IplImage *img = cvLoadImage("camera_shadow.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("080409070 040085103 052000600 204053000 700604009 000910804 001000230 309170080 070302060");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_noisy(){
	printf("\ntestCamera_noisy (jpg)\n");
	IplImage *img = cvLoadImage("camera_noisy.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int solution[][9] = {{0,4,9,0,7,0,0,0,0},{0,6,0,4,0,0,3,0,0},{0,0,5,0,0,2,6,0,7},
        {0,9,0,5,8,0,1,0,0},{0,5,0,0,0,0,0,7,0},{0,0,6,0,2,1,0,3,0},
        {6,0,8,7,0,0,4,0,0},{0,0,1,0,0,4,0,8,0},{0,0,0,0,6,0,7,1,0}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_doubleshadow(){
	printf("\ntestCamera_doubleshadow\n");
	IplImage *img = cvLoadImage("camera_doubleshadow.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("027904350 000000000 004187900 702403809 800000003 405806201 003718400 000000000 048609130");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_curl(){
	printf("\ntestCamera_curl\n");
	IplImage *img = cvLoadImage("camera_curl.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("009005310 460200800 200170090 798320000 050000040 000086973 040061005 002003086 087400100");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_book1(){
	printf("\ntestCamera_book1\n");
	IplImage *img = cvLoadImage("camera_book1.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("409070301 200030004 080402090 503104802 040807030 807305406 010203060 600080007 908050103");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_book1_small(){
	printf("\ntestCamera_book1_small\n");
	IplImage *img = cvLoadImage("camera_book1_small.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int **solution = loadStringAsBoard("409070301 200030004 080402090 503104802 040807030 807305406 010203060 600080007 908050103");
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_noisypng(){
	printf("\ntestCamera_noisy (png)\n");
	IplImage *img = cvLoadImage("camera_noisy.png");
	int **board = recognizeBoardFromPhoto(img);
	int solution[][9] = {{0,4,9,0,7,0,0,0,0},{0,6,0,4,0,0,3,0,0},{0,0,5,0,0,2,6,0,7},
        {0,9,0,5,8,0,1,0,0},{0,5,0,0,0,0,0,7,0},{0,0,6,0,2,1,0,3,0},
        {6,0,8,7,0,0,4,0,0},{0,0,1,0,0,4,0,8,0},{0,0,0,0,6,0,7,1,0}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testCamera_noisyjpg(){
	printf("\ntestCamera_noisy\n");
	IplImage *img = cvLoadImage("camera_noisy.jpg");
	int **board = recognizeBoardFromPhoto(img);
	int solution[][9] = {{0,4,9,0,7,0,0,0,0},{0,6,0,4,0,0,3,0,0},{0,0,5,0,0,2,6,0,7},
        {0,9,0,5,8,0,1,0,0},{0,5,0,0,0,0,0,7,0},{0,0,6,0,2,1,0,3,0},
        {6,0,8,7,0,0,4,0,0},{0,0,1,0,0,4,0,8,0},{0,0,0,0,6,0,7,1,0}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testShaded_colorfg(){
	printf("\nshaded_colorfg\n");
	IplImage *img = cvLoadImage("shaded_colorfg.png");
	int **board = recognizeBoardFromPhoto(img);
	int solution[][9] = {{0,0,4,0,1,8,0,6,0}, {0,5,0,0,9,0,3,8,0}, {0,0,0,3,6,0,0,0,1}, 
        {0,0,8, 0,7,0,0,0,5}, {0,0,7,0,0,0,2,0,0}, {9,0,0,0,2,0,6,0,0},
        {4,0,0,0,3,5,0,0,0}, {0,8,3,0,4,0,0,9,0},{0,7,0,2,8,0,4,0,0}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testShaded_colorfg_noisy(){
	printf("\ntestShaded_colorfg_noisy\n");
	IplImage *img = cvLoadImage("shaded_colorfg_noisy.png");
	int **board = recognizeBoardFromPhoto(img);
	int solution[][9] = {{0,0,4,0,1,8,0,6,0}, {0,5,0,0,9,0,3,8,0}, {0,0,0,3,6,0,0,0,1}, 
        {0,0,8, 0,7,0,0,0,5}, {0,0,7,0,0,0,2,0,0}, {9,0,0,0,2,0,6,0,0},
        {4,0,0,0,3,5,0,0,0}, {0,8,3,0,4,0,0,9,0},{0,7,0,2,8,0,4,0,0}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testShaded(){
	printf("\ntestShaded\n");
	IplImage *img = cvLoadImage("shaded.png");
	int **board = recognizeBoardFromPhoto(img);
	int solution[][9] = {{0,0,0,6,0,0,9,0,8}, {9,3,0,1,5,0,7,0,0}, {0,6,8,3,0,0,0,1,0},
        {0,9,0,2,0,0,8,0,4}, {7,0,0,8,0,3,0,0,6}, {4,0,2,0,0,7,0,5,0},
        {0,4,0,0,0,1,3,2,0}, {0,0,3,0,9,6,0,4,1}, {5,0,7,0,0,2,0,0,0}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testRotated5(){
	printf("\nrotated5\n");
	IplImage *img = cvLoadImage("rotated5.png");
	int **board = recognizeBoardFromPhoto(img);
	int solution[][9] = {{0,2,0,0,0,9,0,6,0}, {1,0,9,0,0,0,0,0,2},{4,6,0,2,0,0,0,0,0},
        {2,9,0,8,0,1,0,0,0}, {0,0,7,0,3,0,5,0,0}, {0,0,0,5,0,4,0,9,7}, 
        {0,0,0,0,0,3,0,2,5}, {9,0,0,0,0,0,7,0,8}, {0,7,0,6,0,0,0,1,0}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testRotated25jpg(){
	printf("\ntestRotated25\n");
	IplImage *img = cvLoadImage("rotated25.jpg");
	int** board = recognizeBoardFromPhoto(img);
	int solution[][9] = {{5,3,0,0,7,0,0,0,0}, {6,0,0,1,9,5,0,0,0}, {0,9,8,0,0,0,0,6,0},
        {8,0,0,0,6,0,0,0,3}, {4,0,0,8,0,3,0,0,1}, {7,0,0,0,2,0,0,0,6},
        {0,6,0,0,0,0,2,8,0}, {0,0,0,4,1,9,0,0,5}, {0,0,0,0,8,0,0,7,9}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testNoisy(){
	printf("\ntestNoisy\n");
	IplImage *img = cvLoadImage("noisy.png");
	int** board = recognizeBoardFromPhoto(img);
	int solution[][9] = {{5,3,0,0,7,0,0,0,0}, {6,0,0,1,9,5,0,0,0}, {0,9,8,0,0,0,0,6,0},
        {8,0,0,0,6,0,0,0,3}, {4,0,0,8,0,3,0,0,1}, {7,0,0,0,2,0,0,0,6},
        {0,6,0,0,0,0,2,8,0}, {0,0,0,4,1,9,0,0,5}, {0,0,0,0,8,0,0,7,9}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testRotated345(){
	printf("\ntestRotated345\n");
	IplImage *img = cvLoadImage("rotated345.png");
	int **board = recognizeBoardFromPhoto(img);
	int solution[][9] = {{5,3,0,0,7,0,0,0,0}, {6,0,0,1,9,5,0,0,0}, {0,9,8,0,0,0,0,6,0},
        {8,0,0,0,6,0,0,0,3}, {4,0,0,8,0,3,0,0,1}, {7,0,0,0,2,0,0,0,6},
        {0,6,0,0,0,0,2,8,0}, {0,0,0,4,1,9,0,0,5}, {0,0,0,0,8,0,0,7,9}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testNoisyRotated(){
	printf("\ntestNoisyRotated\n");
	IplImage *img = cvLoadImage("noisy_rotated.png");
	int **board = recognizeBoardFromPhoto(img);
	int solution[][9] = { {6,0,0,0,4,0,3,0,0}, {9,0,0,0,0,1,0,0,7}, {5,1,0,0,0,0,4,2,9}, 
        {3,0,2,1,0,0,0,4,0}, {0,0,1,0,0,0,5,0,0}, {0,8,0,0,0,2,9,0,6},
        {2,3,7,0,0,0,0,9,4}, {1,0,0,7,0,0,0,0,3}, {0,0,9,0,2,0,0,0,5}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testSimple(){
	printf("\ntestSimple\n");
	IplImage *img = cvLoadImage("simple.png");
	int ** board = recognizeBoardFromPhoto(img);
	int solution[][9] = {{5,3,0,0,7,0,0,0,0}, {6,0,0,1,9,5,0,0,0}, {0,9,8,0,0,0,0,6,0},
        {8,0,0,0,6,0,0,0,3}, {4,0,0,8,0,3,0,0,1}, {7,0,0,0,2,0,0,0,6},
        {0,6,0,0,0,0,2,8,0}, {0,0,0,4,1,9,0,0,5}, {0,0,0,0,8,0,0,7,9}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void testRotated2(){
	printf("\ntestRotated2\n");
	IplImage *img = cvLoadImage("rotated2.png");
	int** board = recognizeBoardFromPhoto(img);
	int solution[][9] = { {0,0,2,0,6,7,0,8,0}, {9,0,0,0,3,0,5,0,6}, {0,7,0,0,0,0,4,0,1}, 
		{0,8,0,0,0,2,0,0,4}, {0,1,0,0,0,0,0,9,0}, {5,0,0,7,0,0,0,3,0}, 
		{4,0,6, 0,0,0,0,1,0}, {7,0,1,0,2,0,0,0,8}, {0,2,0,1,9,0,7,0,0}};
	checkResult(solution, board);
	cvReleaseImage(&img);
}

void checkResult(int **solution, int**ocrGuesses){
	int solution2[9][9];
	for(int i=0; i<9; i++){
		for(int j=0; j<9; j++){
			solution2[i][j] = solution[i][j];
		}
	}
	checkResult(solution2, ocrGuesses);
	for(int i=0; i<9; i++){
		delete solution[i];
	}
	delete solution;
}

void checkResult(int solution[][9], int** ocrGuesses){
	if (!ocrGuesses){
		printf("no solution\n");
		return;
	}
	int wrong[10];
	for (int i=0; i<10; i++){
		wrong[i] = 0;
	}
	int totalWrong = 0;
	int totalRight = 0;
	for(int i=0; i<9; i++){
		for(int j=0; j<9; j++){
			if (solution[i][j] != ocrGuesses[i][j]) {
				wrong[solution[i][j]] += 1;
				totalWrong++;
				if (doShowSolution){
					printf("g(%d)", ocrGuesses[i][j]);
				}
			}else if(solution[i][j] != 0){
				totalRight++;
			}
			
			if (doShowSolution){
				printf("%d\t", solution[i][j]);
			}
		}
		if (doShowSolution){
			printf("\n");
		}
	}
	printf("***************\n");
	for (int i=0; i<10; i++){
		if (wrong[i] > 0){
			printf("guesses %d wrong %d times\n", i, wrong[i]);
		}
	}
	printf("\ttotal mistakes: %d\tAccuracy: %0.1f%%\n", totalWrong, ((double)totalRight)/(totalWrong+totalRight)*100);
	for(int i=0; i<9; i++) delete ocrGuesses[i];
	delete ocrGuesses;
}

int** loadStringAsBoard(char boardAsString[89]){
	int **rv = new int*[9];
	for(int i=0; i<9; i++){
		rv[i] = new int[9];
	}
	int index = 0;
	int stringIndexOffset = 0;
	while(index<81){
		rv[index/9][index%9] = boardAsString[index + stringIndexOffset] - 48;
		index ++;
		if (index%9==0){
			stringIndexOffset ++;
		}
	}
	return rv;
}

IplImage *cvLoadImage(char fileName[255]){
    NSString* fn = [NSString stringWithCString:fileName encoding:NSASCIIStringEncoding];
    return [cvutil LoadUIImageAsIplImage:fn asGrayscale:false];
}
