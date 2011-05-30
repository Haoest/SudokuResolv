//
//  RootViewManaging.h
//  Sudokubot
//
//  Created by Haoest on 5/25/11.
//  Copyright 2011 none. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ArchiveEntry.h"
#import <UIKit/UIKit.h>

@protocol RootViewDelegate <NSObject>

@property(nonatomic, retain) UIView* rootView;

-(void) showBoardView;
-(void) showBoardViewWithImageAsBoard:(UIImage*) board;
-(void) showBoardViewWithEntry: (ArchiveEntry*) entry;
-(void) showArchiveView;
-(void) refreshArchiveView;
-(void) showRootView;

@end


