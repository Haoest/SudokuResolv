//
//  BoardViewController.m
//  Sudokubot
//
//  Created by Haoest on 4/7/11.
//  Copyright 2011 none. All rights reserved.
//

#import "cvutil.hpp"
#import "solver.hpp"
#import "BoardViewController.h"
#import "ArchiveManager.h"
#import "AppConfig.h"
#import "ArchiveEntry.h"
#import <QuartzCore/QuartzCore.h>

@interface BoardViewController()

@property(nonatomic, retain) IBOutlet UIBarButtonItem* backToArchiveButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem* mainMenuButton;
@property(nonatomic, retain) IBOutlet UITextField *commentTextField;
@property(nonatomic, retain) IBOutlet UIToolbar *navigationBar;


@property(nonatomic, assign) int archiveEntryId;
@property(nonatomic, assign) int** hints;
@property(nonatomic, assign) int** solution;
@property(nonatomic, retain) UIView* boardViewContainer;

@property(nonatomic, retain) NSMutableArray* gridLabels;
@property(nonatomic, retain) NSMutableArray* unitFrames;

-(void) saveToArchive;
-(void) backToArchiveMenu;
-(void) backToMainMenu;
-(void) wireupControls;
-(void) resetData;

@end



@implementation BoardViewController

@synthesize commentTextField, navigationBar, boardViewContainer, contentsView;
@synthesize backToArchiveButton, mainMenuButton;
@synthesize hints, solution, archiveEntryId;
@synthesize rootViewDelegate;
@synthesize gridLabels, unitFrames;
 
- (void)dealloc
{
    [self resetData];
    [super dealloc];
}

- (void)viewDidUnload
{
    [gridLabels removeAllObjects];
    self.gridLabels = nil;
    [unitFrames removeAllObjects];
    self.unitFrames = nil;
    self.boardViewContainer = nil;
    self.commentTextField = nil;
    self.backToArchiveButton = nil;
    self.mainMenuButton = nil;
    self.navigationBar = nil;
    self.unitFrames = nil;
    self.view = nil;
    [super viewDidUnload];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        self.archiveEntryId = -1;
    }
    return self;
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
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.contentsView.bounds;
    gradient.colors = [NSArray arrayWithObjects: 
                       (id)[[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1] CGColor],
                       (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.7 alpha:1] CGColor], nil];
    [self.contentsView.layer insertSublayer:gradient atIndex:0];
    
    [super viewDidLoad];
    [self wireupControls];
}

-(void) resetData{
    archiveEntryId = -1;
    if(self.hints){
        for(int i=0; i<9; i++){
            delete self.hints[i];
        }
        delete self.hints;
        self.hints = 0;
    }
    if(self.solution){
        for(int i=0; i<9; i++){
            delete self.solution[i];
        }
        delete self.solution;
        self.solution = 0;
    }
}

-(void) wireupControls{

    [self.backToArchiveButton setTarget:self];
    [self.backToArchiveButton setAction:@selector(backToArchiveMenu)];
    [self.mainMenuButton setTarget:self];
    [self.mainMenuButton setAction:@selector(backToMainMenu)];
    self.commentTextField.delegate = self;
}

-(void) drawGridsView{
    if(boardViewContainer==nil){
        gridLabels = [[NSMutableArray alloc] initWithCapacity:81];
        unitFrames = [[NSMutableArray alloc]initWithCapacity:9];
        int unitSize = 96;
        int gridSize = 32;
        boardViewContainer = [[UIView alloc] initWithFrame:CGRectMake(20, 70, 288, 288)];
        [self.boardViewContainer.layer setBorderWidth:1];
        [self.boardViewContainer.layer setBorderColor:[[UIColor blackColor] CGColor]];
        for(int i=0; i<9; i++){
            for(int j=0; j<9; j++){
                UILabel *grid = [[UILabel alloc]initWithFrame:CGRectMake(j*gridSize+1, i*gridSize+1, gridSize+1, gridSize+1)];
                [grid.layer setBorderWidth:1];
                [grid.layer setBorderColor:[[UIColor grayColor] CGColor]];
                [self.boardViewContainer addSubview:grid];
                [gridLabels addObject:grid];
                [grid setTextAlignment:UITextAlignmentCenter];
                [grid release];
            }
        }
        for(int i=0; i<3; i++){
            for(int j=0; j<3; j++){
                UIView* unit = [[UIView alloc]initWithFrame:CGRectMake(i*unitSize+1, j*unitSize+1, unitSize, unitSize)];
                [unit.layer setBorderColor:[[UIColor blackColor] CGColor]];
                [unit.layer setBorderWidth:1];
                [self.boardViewContainer addSubview:unit];
                [self.unitFrames addObject:unit];
                [unit release];
            }
        }
        [self.view addSubview:self.boardViewContainer];
    }
    for(int i=0; i<81; i++){
        UILabel *grid = [gridLabels objectAtIndex:i];
        [grid setText:[NSString stringWithFormat:@"%d", self.solution[i/9][i%9]]];
        if (self.hints[i/9][i%9] ==0){
            [grid setTextColor:[UIColor blackColor]];
        }else{
            [grid setTextColor:[UIColor redColor]];            
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) saveToArchive{
    NSString* serializedBoard = [cvutil SerializeBoard: self.solution];
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    if(self.archiveEntryId == -1){
        ArchiveEntry* archiveEntry = [[ArchiveEntry alloc] initWithValues:-1
                                                       solutionString:serializedBoard
                                                           hintString:[cvutil SerializeBoard:hints]
                                                     secondsSince1970:[[NSDate date] timeIntervalSince1970]
                                                                 comments:self.commentTextField.text];
        int newId = [arman addEntry:archiveEntry];
        [archiveEntry release];
        if([arman saveArchive]){
            self.archiveEntryId = newId;
        }
    }else{
        int entryId = self.archiveEntryId;
        ArchiveEntry* e = [arman getEntryById:entryId];
        if (e){
            e.comments = self.commentTextField.text;
            [arman updateEntry:e];
            [arman saveArchive];
        }
    }
    [self.rootViewDelegate refreshArchiveView];
    [arman release];
}

-(void) backToArchiveMenu{
    [self.rootViewDelegate showArchiveView];
}

-(void) backToMainMenu{
    [self.rootViewDelegate showRootView];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField:textField up:YES];
    [self.view bringSubviewToFront:navigationBar];
}

-(void) textFieldDidEndEditing:(UITextField *)textField{
    [self animateTextField:textField up:NO];
    [self saveToArchive];
}

- (BOOL)textFieldShouldReturn:(UITextField *) textField{
    [textField resignFirstResponder];
    return NO;
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 200; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement = (up ? -movementDistance : movementDistance);
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(void) refreshBoardWithHints:(int**) _hints{
    [self resetData];
    self.commentTextField.text = @"";
    self.hints = new int*[9];
    for(int i=0; i<9; i++){
        self.hints[i] = new int[9];
    }
    for(int i=0; i<9; i++){
        for(int j=0; j<9; j++){
            self.hints[i][j] = _hints[i][j];
        }
    }
    solver* sol = [solver solverWithHints:self.hints];
    self.solution = [sol trySolve];
    if (self.solution){
        [self drawGridsView];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This puzzle has solution or something went wrong. Sorry!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    
    [sol release];
}

-(void) refreshBoardWithArchiveEntry:(ArchiveEntry*) entry{
    [self resetData];
    self.archiveEntryId = entry.entryId;
    self.solution = [cvutil DeserializedBoard: [entry sudokuSolution] ];
    self.hints = [cvutil DeserializedBoard:[entry sudokuHints]];
    self.commentTextField.text = entry.comments;
    [self drawGridsView];
}

@end
