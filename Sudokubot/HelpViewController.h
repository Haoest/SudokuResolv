//
//  HelpViewController.h
//  Sudokubot
//
//  Created by Haoest on 4/7/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "rootViewDelegate.h"


@interface HelpViewController : UIViewController <UIWebViewDelegate> {
    
}
@property(nonatomic, retain) IBOutlet UISegmentedControl* pagingTabs;
@property(nonatomic, retain) IBOutlet UIWebView* webView;
@property(nonatomic, retain) IBOutlet UIButton* solveButton;


@property(nonatomic, assign) id<RootViewDelegate> rootViewDelegate;

-(IBAction) solveButton_tap;

@end
