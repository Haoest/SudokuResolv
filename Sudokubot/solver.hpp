//
//Copyright 2011 Haoest
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

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
