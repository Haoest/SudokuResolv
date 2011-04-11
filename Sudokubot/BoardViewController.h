//
//  BoardViewController.h
//  Sudokubot
//
//  Created by Haoest on 4/7/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BoardViewController : UIViewController<UITextFieldDelegate> {

}

@property(nonatomic, retain) IBOutlet UIImageView* imageView;
@property(nonatomic, retain) IBOutlet UIBarButtonItem* saveToArchiveButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem* mainMenuButton;
@property(nonatomic, retain) IBOutlet UITextField *commentTextField;
@property(nonatomic, retain) IBOutlet UIView *contentsView;
@property(nonatomic, retain) IBOutlet UIToolbar *navigationBar;

@property(nonatomic, assign) int** board;
@property(nonatomic, assign) int** solution;

-(void) saveToArchive;

+(BoardViewController*) boardWithImage:(UIImage*) board;
-(void) loadBoard;
-(UIImage*) drawGrids;
-(void) wireupControls;

- (void)textFieldDidBeginEditing:(UITextField *)textField;
//- (void) scrollContentForKeyboard:(UITextField*) textField up:(bool) up;
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

@end

static char archiveFileName[] = "archive.txt";
