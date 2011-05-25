//
//  ArchiveViewController.h
//  Sudokubot
//
//  Created by Haoest on 4/11/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArchiveTableViewController.h"
#import "ViewDelegates.h"
//#import "SudokubotViewController.h"

@interface ArchiveViewController : UIViewController {
    
}

@property(nonatomic, retain) IBOutlet UIBarButtonItem *mainMenu;

@property(nonatomic, retain) ArchiveTableViewController* archiveTableViewController;
@property(nonatomic, retain) id<RootViewDelegate> rootViewDelegate;

+(ArchiveViewController*) archiveViewControllerFromDefaultArchive;

-(void) backToMainMenu;

@end
