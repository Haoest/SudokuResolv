//
//  SudokubotAppDelegate.h
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

@class SudokubotViewController;

#define SharedAdBannerView ((SudokubotAppDelegate *)[[UIApplication sharedApplication] delegate]).adBannerView

@interface SudokubotAppDelegate : NSObject <UIApplicationDelegate, ADBannerViewDelegate> {
    ADBannerView *adBannerView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SudokubotViewController *viewController;
@property(nonatomic, retain) ADBannerView* adBannerView;

@end
