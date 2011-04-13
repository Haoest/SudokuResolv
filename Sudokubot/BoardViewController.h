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
@property(nonatomic, retain) IBOutlet UIBarButtonItem* backToArchiveButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem* mainMenuButton;
@property(nonatomic, retain) IBOutlet UITextField *commentTextField;
@property(nonatomic, retain) IBOutlet UIView *contentsView;
@property(nonatomic, retain) IBOutlet UIToolbar *navigationBar;



@property(nonatomic, assign) bool allowSaving;
@property(nonatomic, assign) int** board;
@property(nonatomic, assign) int** solution;

-(void) saveToArchive;
-(void) backToArchiveMenu;
-(void) backToMainMenu;

+(BoardViewController*) boardWithImage:(UIImage*) board;
+(BoardViewController*) boardWithSolution:(int**) solution;

-(void) loadBoard;
-(UIImage*) drawGrids;
-(void) wireupControls;

- (void)textFieldDidBeginEditing:(UITextField *)textField;
//- (void) scrollContentForKeyboard:(UITextField*) textField up:(bool) up;
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

@end

