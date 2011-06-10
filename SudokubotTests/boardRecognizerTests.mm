//  boardRecognizerTests.h
//  Sudokubot
//
//  Created by Haoest on 5/20/11.
//  Copyright 2011 none. All rights reserved.
//
// opencvContour.cpp : Defines the entry point for the console application.
//
//
//
#include <opencv2/imgproc/imgproc_c.h>
#include "boardRecognizerTests.hpp"
#include "BoardRecognizer.h"
#include "cvutil.hpp"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@implementation BoardRecognizerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


-(void) testRunAllBoardRecognizerTests{
	    boardRecognizerTests t; t.runAll();
}

-(void) testReadBoard{
    IplImage *img = [cvutil LoadUIImageAsIplImage:@"puzzle1.png" asGrayscale:false];
    recognizerResultPack recog;
    recog = recognizeBoardFromPhoto(img);
    int** actualBoard = [cvutil loadStringAsBoard:"530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"];
    for(int i=0; i<9; i++){
        for(int j=0; j<9; j++){
            STAssertTrue(recog.boardArr[i][j] == actualBoard[i][j], @"%d %d", i, j);
        }
    }
}

@end


IplImage *cvLoadImage(char fileName[255]);
void checkResult(int board[][9], recognizerResultPack recog);
void checkResult(int **solution, recognizerResultPack recog);

const int doShowSolution = 0;

void checkResult(int **solution, recognizerResultPack recog){
	int solution2[9][9];
	for(int i=0; i<9; i++){
		for(int j=0; j<9; j++){
			solution2[i][j] = solution[i][j];
		}
	}
	checkResult(solution2, recog);
}

void checkResult(int solution[][9], recognizerResultPack recog){
	if (!recog.boardArr){
		printf("no solution\n");
		return;
	}
	int wrong[10];
	for (int i=0; i<10; i++){
		wrong[i] = 0;
	}
    int** ocrGuesses = recog.boardArr;
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
	printf("\ttotal mistakes: %d\tAccuracy: %0.1f%%\n\n", totalWrong, ((double)totalRight)/(totalWrong+totalRight)*100);
}


IplImage *cvLoadImage(char fileName[255]){
    NSString* fn = [NSString stringWithCString:fileName encoding:NSASCIIStringEncoding];
    return [cvutil LoadUIImageAsIplImage:fn asGrayscale:false];
}

testPack::testPack(char InputFile[50], char boardHintAsString[89]){
    for(int i=0; i<50; i++){
        inputFile[i] = InputFile[i];
    }
    for(int i=0; i<89; i++){
        hints[i] = boardHintAsString[i];
    }
}

boardRecognizerTests::boardRecognizerTests(){
    tests.push_back(new testPack("camera_book2_1.jpg",      "050609030 210000065 400000007 003941600 000000000 004728500 300000006 160000078 080305020"));
    tests.push_back(new testPack("iphone_ss3.png",          "000000700 150408900 640090815 070900008 000184000 800006090 724030081 009607032 001000000"));
    tests.push_back(new testPack("iphone_ss2.png",          "000000700 150408900 640090815 070900008 000184000 800006090 724030081 009607032 001000000"));
    tests.push_back(new testPack("iphone_ss1.png",          "040000760 026104000 500003008 000040007 200010900 600300080 000400509 075000040 000058100"));    
    tests.push_back(new testPack("camera_lcd1.jpg",         "000910560 000000001 073000240 000051008 080000050 400720000 092000870 700000000 051076000"));
    tests.push_back(new testPack("camera_lcd2.jpg",         "405800900 060500201 030060708 090000006 050000070 800000030 503090080 602007090 001004605"));
    tests.push_back(new testPack("camera_lcd3.jpg",         "608407103 300658000 700030008 940200800 037806940 006009031 100080009 000925004 409701305"));
    tests.push_back(new testPack("camera_book2_1.jpg",      "050609030 210000065 400000007 003941600 000000000 004728500 300000006 160000078 080305020"));
    tests.push_back(new testPack("camera_book2_1.jpg",      "050609030 210000065 400000007 003941600 000000000 004728500 300000006 160000078 080305020"));
    tests.push_back(new testPack("camera_shadow2.jpg",      "015040790 080070020 200301005 037506140 100708006 026104870 900603007 060010030 051080960"));
    tests.push_back(new testPack("camera_verynoisy.jpg",    "049070000 060400300 005002607 090580100 050000070 006021030 608700400 001004080 000060710"));
    tests.push_back(new testPack("camera_shadow.jpg",       "080409070 040085103 052000600 204053000 700604009 000910804 001000230 309170080 070302060"));
    tests.push_back(new testPack("camera_noisy.jpg",        "049070000 060400300 005002607 090580100 050000070 006021030 608700400 001004080 000060710"));
    tests.push_back(new testPack("camera_doubleshadow.jpg", "027904350 000000000 004187900 702403809 800000003 405806201 003718400 000000000 048609130"));
    tests.push_back(new testPack("camera_curl.jpg",         "009005310 460200800 200170090 798320000 050000040 000086973 040061005 002003086 087400100"));
    tests.push_back(new testPack("camera_book1.jpg",        "409070301 200030004 080402090 503104802 040807030 807305406 010203060 600080007 908050103"));
    tests.push_back(new testPack("camera_book1_small.jpg",  "409070301 200030004 080402090 503104802 040807030 807305406 010203060 600080007 908050103"));
    tests.push_back(new testPack("camera_noisy.png",        "049070000 060400300 005002607 090580100 050000070 006021030 608700400 001004080 000060710"));
    tests.push_back(new testPack("shaded_colorfg.png",      "004018060 050090380 000360001 008070005 007000200 900020600 400035000 083040090 070280400"));
    tests.push_back(new testPack("shaded_colorfg_noisy.png","004018060 050090380 000360001 008070005 007000200 900020600 400035000 083040090 070280400"));
    tests.push_back(new testPack("shaded.png",              "000600908 930150700 068300010 090200804 700803006 402007050 040001320 003096041 507002000"));
    tests.push_back(new testPack("rotated5.png",            "020009060 109000002 460200000 290801000 007030500 000504097 000003025 900000708 070600010"));
    tests.push_back(new testPack("rotated25.jpg",           "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"));
    tests.push_back(new testPack("noisy.png",               "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"));
    tests.push_back(new testPack("rotated345.png",          "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"));
    tests.push_back(new testPack("noisy_rotated.png",       "600040300 900001007 510000429 302100040 001000500 080002906 237000094 100700003 009020005"));
    tests.push_back(new testPack("simple.png",              "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"));
    tests.push_back(new testPack("rotated2.png",            "002067080 900030506 070000401 080002004 010000090 500700030 406000010 701020008 020190700"));
    
    tests.push_back(new testPack("camera_book3_1.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"));
    tests.push_back(new testPack("camera_book3_2.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"));
    tests.push_back(new testPack("camera_book3_3.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"));
    tests.push_back(new testPack("camera_book3_4.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"));
    tests.push_back(new testPack("camera_book3_5.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"));
    tests.push_back(new testPack("camera_book3_6.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"));
    tests.push_back(new testPack("camera_book3_7.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"));
    tests.push_back(new testPack("camera_book3_8.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"));
    tests.push_back(new testPack("camera_book3_9.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"));
    tests.push_back(new testPack("camera_book3_10.jpg",     "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"));
    
    tests.push_back(new testPack("book_lowlight_1.jpg",     "000050000 050402080 003807400 024108690 100060004 095304810 009703200 070209060 000010000"));
	tests.push_back(new testPack("news_flash_1.jpg",	    "070041800 806007001 000062070 030000250 609000308 085000040 050470000 900200507 001590030"));
	tests.push_back(new testPack("news_flash_2.jpg",	    "070041800 806007001 000062070 030000250 609000308 085000040 050470000 900200507 001590030"));
	tests.push_back(new testPack("news_flash_3.jpg",	    "070041800 806007001 000062070 030000250 609000308 085000040 050470000 900200507 001590030"));
	tests.push_back(new testPack("news_lowlight_1.jpg",	    "070041800 806007001 000062070 030000250 609000308 085000040 050470000 900200507 001590030"));
	tests.push_back(new testPack("news_lowlight_2.jpg",	    "070041800 806007001 000062070 030000250 609000308 085000040 050470000 900200507 001590030"));
	tests.push_back(new testPack("news_lowlight_3.jpg",	    "070041800 806007001 000062070 030000250 609000308 085000040 050470000 900200507 001590030"));
}

boardRecognizerTests::~boardRecognizerTests(){
    for(list<testPack*>::iterator it = tests.begin(); it != tests.end(); it++){
        delete (*it);
    }
}

void boardRecognizerTests::runAll(){
    list<testPack*>::iterator it;
    for(it = tests.begin(); it!= tests.end(); it++){
        IplImage *img = cvLoadImage( (*it)->inputFile );
        recognizerResultPack res = recognizeBoardFromPhoto(img);
        int** hints = [cvutil loadStringAsBoard:(*it)->hints];
        printf("testing %s...", (*it)->inputFile);
        checkResult(hints, res);
        cvReleaseImage(&img);
        for(int i=0; i<9; i++) delete hints[i];
        delete hints;
    }
}


