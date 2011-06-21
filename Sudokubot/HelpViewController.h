//
//  HelpViewController.h
//  Sudokubot
//
//  Created by Haoest on 4/7/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "rootViewDelegate.h"


@interface HelpViewController : UIViewController {
    
}
@property(nonatomic, retain) IBOutlet UISegmentedControl* pagingTabs;
@property(nonatomic, assign) id<RootViewDelegate> rootViewDelegate;

@end
