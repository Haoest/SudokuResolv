//
//  solver.h
//  Sudokubot
//
//  Created by Haoest on 4/5/11.
//  Copyright 2011 none. All rights reserved.
//
#import <set>
#import <Foundation/Foundation.h>


using namespace std;

@interface solver : NSObject {
    @private 
}
@property (nonatomic) int** board;
           
+(solver*) solverWithPartialBoard: (int[9][9]) partialBoard;

//return null if no solution
-(int**) trySolve;
bool trySolveRecursively(int** currentBoard, set<int> boxSpace[9][9], int boxIndex);
bool isUniqueInRowAndColumn(int ** currentBoard, int boxValue, int boxIndex);
set<int> getBoxSampleSpace(int** currentBoard, int i, int j);
set<int> getBagOfNine();
bool verifySolution(int** currentBoard);
@end
