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
//
//  BoardViewController.h
//  Sudokubot
//
//  Created by Haoest on 4/7/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArchiveEntry.h"
#import "rootViewDelegate.h"

@interface BoardViewController : UIViewController<UITextFieldDelegate> {

}
@property(nonatomic, retain) IBOutlet UIView* contentsView;

-(void) refreshBoardWithHints:(int**) hints;
-(void) refreshBoardWithArchiveEntry:(ArchiveEntry*) entry;

- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

//superArchiveView points to the archive view object which creates this board view
@property(nonatomic, assign) id <RootViewDelegate> rootViewDelegate;

@end

