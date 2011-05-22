//
//  SudokubotTests.m
//  SudokubotTests
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//



#import "SudokubotTests.hpp"
#import "BoardViewController.h"
#import "AppConfig.h"
#import "boardRecognizer.h"
#import "cvutil.hpp"

//using namespace std;

@implementation SudokubotTests

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

-(void) testUploadPhotoToPhone{
 
}

- (void)testSet
{
    set<int> a;
    a.insert(1);
    a.insert(2);
    a.insert(3);
    STAssertTrue(a.size()==3, @"size");
    set<int> b;
    b = a;
    STAssertTrue(b.size()==3, @"b size");
    b.erase(b.find(3));
    STAssertTrue(a.size()==3, @"a size");
    STAssertTrue(b.size()==2, @"b size");
}

-(void) testReadBoard{
//    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"puzzle1.png"]];
    IplImage *img = [cvutil LoadUIImageAsIplImage:@"puzzle1.png" asGrayscale:false];
    recognizerResultPack recog;
    recog = recognizeBoardFromPhoto(img);
    int ** actualBoard = getBoard();
    for(int i=0; i<9; i++){
        for(int j=0; j<9; j++){
            STAssertTrue(recog.boardArr[i][j] == actualBoard[i][j], @"%d %d", i, j);
        }
    }
}

-(void) testGetBoxSampleSpace{
    int** board = getBoard();
    solver *s = [solver solverWithHints:board];
    STAssertTrue(isUniqueInRowColumnUnit(board, 1, 2), @"0 2");
    STAssertFalse(isUniqueInRowColumnUnit(board, 1, 4), @"0 3");
    STAssertTrue(isUniqueInRowColumnUnit(board, 1, 18), @"");
    STAssertFalse(isUniqueInRowColumnUnit(board, 6, 28), @"");
    STAssertFalse(isUniqueInRowColumnUnit(board, 9, 28),@"");
    STAssertFalse(isUniqueInRowColumnUnit(board, 8, 28),@"");
    STAssertFalse(isUniqueInRowColumnUnit(board, 3, 28), @"");
}

-(void) testSaveBoardToArchive{
    NSString *aFileName = [NSString stringWithCString:archiveFileName encoding:NSASCIIStringEncoding];
    NSString *commentText = [NSString stringWithFormat:@"this is the best game ever"];
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:aFileName];
    if (fileHandler != Nil){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:aFileName error:Nil];
    }
    return ;
    fileHandler = [NSFileHandle fileHandleForReadingAtPath:aFileName];
    STAssertNil(fileHandler, @"%@ should not be present", archiveFileName);
    BoardViewController* boardViewController = [BoardViewController boardWithImage:[UIImage imageNamed:@"puzzle1.png"]];
    STAssertEquals([boardViewController.commentTextField text], commentText, @"comment should be set");
    [boardViewController saveToArchive];
    NSString* archiveContent = [NSString stringWithContentsOfFile:aFileName encoding:NSUTF8StringEncoding error:Nil];
    STAssertTrue([archiveContent length] > 0, @"archive file should not be empty");
    
    solver* s = [solver solverWithImage:[UIImage imageNamed:@"puzzle1.png"]];
    NSString *solution = [cvutil SerializeBoard:[s trySolve]];
    STAssertTrue([archiveContent rangeOfString:solution].length >0, @"archive file should contain serialized representation of the borad");
}

-(void) testSolver{
    boardRecognizerTests t;
    int verificaitonCount = 0;
    for(list<testPack*>::iterator it = t.tests.begin(); it!=t.tests.end(); it++){
        int** hints = loadStringAsBoard((*it)->hints);
        solver *s = [solver solverWithHints:hints];
        int ** solution = [s trySolve];
        if (solution){
            bool isSolved = [solver verifySolution:solution];
            STAssertTrue(isSolved, [NSString stringWithFormat:@"testSolver: solver made a mistake for test %s", (*it)->inputFile]);    
            if (isSolved){
                verificaitonCount ++;
            }
        }else{
            NSLog([NSString stringWithFormat:@"testSolver: %s has no solution", (*it)->inputFile]);
        }
        
        for(int i=0; i<9; i++){
            delete hints[i];
        }
        delete hints;        
        [s release];
    }
    NSLog([NSString stringWithFormat:@"testSolver: %d solutions tested, %d verified", t.tests.size(), verificaitonCount]);
}

-(void) testRunAllBoardRecognizerTests{
    boardRecognizerTests t;
    t.runAll();
}

int** getBoard(){
    int **a;
    a = new int*[9];
    for(int i=0; i<9; i++){
        a[i] = new int[9];
    }
    for (int i=0; i<9; i++){
        for(int j=0; j<9; j++){
            a[i][j] = 0;
        }
    }
    NSString *s = [NSString stringWithFormat:@"530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"];
    NSArray *rawBoard = [s componentsSeparatedByString:@" "];
    for(int i=0; i<9; i++){
        NSString *line = [rawBoard objectAtIndex:i];
        for(int j=0; j<9; j++){
            a[i][j] = ((int) [line characterAtIndex:j]) - 48;
        }
    }
    return a;
}

@end
