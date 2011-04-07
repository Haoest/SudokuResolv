//
//  SudokubotTests.m
//  SudokubotTests
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//



#import "SudokubotTests.hpp"


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
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"puzzle1.png"]];
    int detectedBoard[9][9];
    ParseFromImage(img, detectedBoard);
    int ** actualBoard = getBoard();
    for(int i=0; i<9; i++){
        for(int j=0; j<9; j++){
            STAssertTrue(detectedBoard[i][j] == actualBoard[i][j], @"%d %d", i, j);
        }
    }
}

-(void) testGetBoxSampleSpace{
    int** board = getBoard();
    int a[9][9];
    for (int i=0; i<9; i++){
        for(int j=0; j<9; j++){
            a[i][j] = board[i][j];
        }
    }
    solver *s = [solver solverWithPartialBoard:a];
    STAssertTrue(isUniqueInRowAndColumn(board, 1, 2), @"0 2");
    STAssertFalse(isUniqueInRowAndColumn(board, 1, 4), @"0 3");
    STAssertTrue(isUniqueInRowAndColumn(board, 1, 18), @"");
    STAssertFalse(isUniqueInRowAndColumn(board, 6, 28), @"");
    STAssertFalse(isUniqueInRowAndColumn(board, 9, 28),@"");
    STAssertFalse(isUniqueInRowAndColumn(board, 8, 28),@"");
    STAssertFalse(isUniqueInRowAndColumn(board, 3, 28), @"");
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
