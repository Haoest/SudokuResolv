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

@interface PreviewViewController : UIViewController {
    NSMutableArray* gridViews;
    NSMutableArray* gridNumberLabels;
    int selectedGridId;
    int selectedNumpadId;
    UIView* numpadContainer;
    NSMutableArray *numpadImages;
    NSMutableArray *numpadHotRegions;
    int** hints;
}

@property(nonatomic, assign) id<RootViewDelegate> rootViewDelegate;

-(void) loadImageWithSudokuBoard:(UIImage*) img;

@end

