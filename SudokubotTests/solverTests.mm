//
//  SudokubotTests.m
//  SudokubotTests
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//

#import "solverTests.hpp"
#import "BoardViewController.h"
#import "AppConfig.h"
#import "boardRecognizer.h"
#import "cvutil.hpp"

//using namespace std;

@implementation solverTests

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

-(void) testGetBoxSampleSpace{
    int** board = [cvutil loadStringAsBoard:"530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"];
    solver *s = [solver solverWithHints:board];
    STAssertTrue(isUniqueInRowColumnUnit(board, 1, 2), @"0 2");
    STAssertFalse(isUniqueInRowColumnUnit(board, 1, 4), @"0 3");
    STAssertTrue(isUniqueInRowColumnUnit(board, 1, 18), @"");
    STAssertFalse(isUniqueInRowColumnUnit(board, 6, 28), @"");
    STAssertFalse(isUniqueInRowColumnUnit(board, 9, 28),@"");
    STAssertFalse(isUniqueInRowColumnUnit(board, 8, 28),@"");
    STAssertFalse(isUniqueInRowColumnUnit(board, 3, 28), @"");
}

-(void) testSolveOneBoard{
    int** hints = [cvutil loadStringAsBoard:"530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"];
    solver *s = [solver solverWithHints:hints];
    int** solution = [s trySolve];
    STAssertTrue(solution!=0, @"this board should be solvable");
    STAssertTrue([solver verifySolution:solution], @"invalid solution");
    NSLog([NSString stringWithFormat:@"testSolveOneBoard solution is: %@", [cvutil SerializeBoard:solution]]);
    for(int i=0; i<9; i++) delete hints[i];
    delete hints;
    [solver release];
}

-(void) testSolver{
    boardRecognizerTests t;
    int verificaitonCount = 0;
    for(list<testPack*>::iterator it = t.tests.begin(); it!=t.tests.end(); it++){
        int** hints = [cvutil loadStringAsBoard:(*it)->hints];
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


@end

