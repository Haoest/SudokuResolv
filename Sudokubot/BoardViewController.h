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
    NSMutableArray* gridLabels;
    UIView* gridView;
}

@property(nonatomic, retain) IBOutlet UIBarButtonItem* backToArchiveButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem* mainMenuButton;
@property(nonatomic, retain) IBOutlet UITextField *commentTextField;
@property(nonatomic, retain) IBOutlet UIToolbar *navigationBar;

//superArchiveView points to the archive view object which creates this board view
@property(nonatomic, retain) id <RootViewDelegate> rootViewDelegate;

@property(nonatomic, assign) int archiveEntryId;
@property(nonatomic, assign) int** hints;
@property(nonatomic, assign) int** solution;
@property(nonatomic, retain) NSString *comments;

-(void) saveToArchive;
-(void) backToArchiveMenu;
-(void) backToMainMenu;

//+(BoardViewController*) boardWithHints:(int**) hints;
//+(BoardViewController*) boardWithArchiveEntry:(ArchiveEntry*) entry;

-(void) refreshBoardWithHints:(int**) hints;
-(void) refreshBoardWithArchiveEntry:(ArchiveEntry*) entry;

-(void) wireupControls;

- (void)textFieldDidBeginEditing:(UITextField *)textField;
//- (void) scrollContentForKeyboard:(UITextField*) textField up:(bool) up;
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;


@end

