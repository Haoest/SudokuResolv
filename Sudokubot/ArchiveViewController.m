//
//  ArchiveViewController.m
//  Sudokubot
//
//  Created by Haoest on 4/11/11.
//  Copyright 2011 none. All rights reserved.
//

#import "ArchiveViewController.h"
#import "BoardViewController.h"

@interface ArchiveViewController()

@property(nonatomic, retain) IBOutlet UIBarButtonItem *mainMenu;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@property(nonatomic, retain) IBOutlet UIToolbar *topToolBar;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *flexibleSpace;

@end


@implementation ArchiveViewController

@synthesize archiveTableViewController;
@synthesize mainMenu, doneButton, editButton, topToolBar, flexibleSpace;
@dynamic rootViewDelegate;

-(void) setRootViewDelegate:(id<RootViewDelegate>)rootView{
    rootViewDelegate = rootView;
    archiveTableViewController.rootViewDelegate = rootView;
}

-(id<RootViewDelegate>) rootViewDelegate{
    return rootViewDelegate;
}

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
    archiveTableViewController = nil;
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
    [self.mainMenu setTarget:self];
    [self.mainMenu setAction:@selector(backToMainMenu)];
    [self.doneButton setAction:@selector(doneButton_touchdown)];
    [doneButton setTarget:self];
    [self.editButton setAction:@selector(editButton_touchdone)];
    [editButton setTarget:self];
    NSArray* items = [NSArray arrayWithObjects:mainMenu, flexibleSpace, editButton, nil];
    [topToolBar setItems:items];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.mainMenu = nil;
    self.doneButton = nil;
    self.editButton = nil;
    self.topToolBar = nil;
    self.flexibleSpace = nil;
    self.view = nil;
    self.archiveTableViewController = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) refreshArchiveList{
    [self.archiveTableViewController reloadDataSource];
    [self.archiveTableViewController.tableView reloadData];
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
    return [rv autorelease];
}

-(void) backToMainMenu{
    [self.rootViewDelegate showRootView];
}

-(void) doneButton_touchdown{
    NSArray* items = [NSArray arrayWithObjects:mainMenu, flexibleSpace, editButton, nil];
    [topToolBar setItems:items];
    [archiveTableViewController setEditing:false animated:true];
    [archiveTableViewController saveArchive];
}

-(void) editButton_touchdone{
    NSArray* items = [NSArray arrayWithObjects:mainMenu, flexibleSpace, doneButton, nil];
    [topToolBar setItems:items];   
    [archiveTableViewController setEditing:true animated:true];    
}

@end
