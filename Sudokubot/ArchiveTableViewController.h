//
//  ArchiveTableViewController.h
//  Sudokubot
//
//  Created by Haoest on 4/12/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArchiveManager.h"
#import "rootViewDelegate.h"

@interface ArchiveTableViewController : UITableViewController {
    
}

@property (nonatomic, retain) NSArray* archiveContents;

+(ArchiveTableViewController*) archiveTableViewControllerFromDefaultArchive;

@property (nonatomic, retain) id<RootViewDelegate> rootViewDelegate;

-(void) reloadDataSource;

@end
