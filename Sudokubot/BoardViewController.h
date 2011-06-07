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
    NSString* comments;

}

-(void) refreshBoardWithHints:(int**) hints;
-(void) refreshBoardWithArchiveEntry:(ArchiveEntry*) entry;

- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

//superArchiveView points to the archive view object which creates this board view
@property(nonatomic, assign) id <RootViewDelegate> rootViewDelegate;

@end

