//
//  solver.h
//  Sudokubot
//
//  Created by Haoest on 4/5/11.
//  Copyright 2011 none. All rights reserved.
//

#import <set>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

using namespace std;

@interface solver : NSObject {
    @private 
}
@property (nonatomic) int** board;
           
+(solver*) solverWithHints: (int**) hints;


+(bool) verifySolution: (int**) completedBoard;
+(bool) verifyHints:(int**) hints;

//return null if no solution
-(int**) trySolve;

@end
