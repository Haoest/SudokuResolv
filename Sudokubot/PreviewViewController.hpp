//
//  PreviewViewController.h
//  Sudokubot
//
//  Created by Haoest on 5/28/11.
//  Copyright 2011 none. All rights reserved.
//

#import "rootViewDelegate.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PreviewViewControllerDelegate.h"

@interface PreviewViewController : UIViewController<PreviewViewControllerDelegate> {
    NSMutableArray* gridViews;
    NSMutableArray* gridNumberLabels;
    UIView* lastActiveGridView;
}

@property(nonatomic, retain) IBOutlet UIImageView* previewImage;
@property(nonatomic, retain) IBOutlet UIButton* solveButton;
@property(nonatomic, retain) IBOutlet UIButton* cancelButton;

@property(nonatomic, retain) id<RootViewDelegate> rootViewDelegate;

-(IBAction) solveButton_touchdown;
-(IBAction) cancelButton_touchdown;

-(void) loadImageWithSudokuBoard:(UIImage*) img;

@end
