//
//  SudokubotAppDelegate.h
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class SudokubotViewController;

@interface SudokubotAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet SudokubotViewController *viewController;

@end
