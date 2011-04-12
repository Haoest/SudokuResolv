//
//  ArchiveViewController.m
//  Sudokubot
//
//  Created by Haoest on 4/11/11.
//  Copyright 2011 none. All rights reserved.
//

#import "ArchiveViewController.h"
#import "BoardViewController.h"

@implementation ArchiveViewController
@synthesize archiveTableViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

+(ArchiveViewController*) archiveViewControllerFromDefaultArchive{
    ArchiveViewController* rv = [[ArchiveViewController alloc] initWithNibName:@"ArchiveViewController" bundle:Nil];
    rv.archiveTableViewController = [ArchiveTableViewController archiveTableViewControllerFromDefaultArchive];
    rv.archiveTableViewController.view.frame = CGRectMake(0, 44, 328, 416);
    [rv.view addSubview:rv.archiveTableViewController.view];
    return rv;
}

@end
