//
//  ArchiveTableViewController.h
//  Sudokubot
//
//  Created by Haoest on 4/12/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArchiveManager.h"

@interface ArchiveTableViewController : UITableViewController {
    ArchiveManager* archiveManager;
}

@property (nonatomic, retain) NSArray* archiveContents;

+(ArchiveTableViewController*) archiveTableViewControllerFromDefaultArchive;

@end
