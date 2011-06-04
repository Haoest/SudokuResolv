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
#import "ArchiveViewController.h"
#import "AppConfig.h"
#import "ArchiveEntry.h"
#import <QuartzCore/QuartzCore.h>

@implementation BoardViewController

@synthesize commentTextField, navigationBar;
@synthesize backToArchiveButton, mainMenuButton;
@synthesize hints, solution, archiveEntryId;
@synthesize rootViewDelegate;
@dynamic comments;

-(void) setComments:(NSString *)_comments{
    comments = _comments;
    [self.commentTextField setText:comments];
}

-(NSString*) comments{
    return comments;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.archiveEntryId = -1;
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
    [self wireupControls];
    [self.commentTextField setText:self.comments];
}

-(void) resetFields{
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
    comments = @"";
    [commentTextField setText:@""];
}

-(void) wireupControls{

    [self.backToArchiveButton setTarget:self];
    [self.backToArchiveButton setAction:@selector(backToArchiveMenu)];
    [self.mainMenuButton setTarget:self];
    [self.mainMenuButton setAction:@selector(backToMainMenu)];
    self.commentTextField.delegate = self;
}

-(void) drawGridsView{
    if(gridView==nil){
        gridLabels = [[NSMutableArray alloc] initWithCapacity:81];
        int unitSize = 96;
        int gridSize = 32;
        UIView* main = [[UIView alloc] initWithFrame:CGRectMake(20, 70, 288, 288)];
        [main.layer setBorderWidth:1];
        [main.layer setBorderColor:[[UIColor blackColor] CGColor]];
        for(int i=0; i<9; i++){
            for(int j=0; j<9; j++){
                UILabel *grid = [[UILabel alloc]initWithFrame:CGRectMake(j*gridSize+1, i*gridSize+1, gridSize+1, gridSize+1)];
                [grid.layer setBorderWidth:1];
                [grid.layer setBorderColor:[[UIColor grayColor] CGColor]];
                [main addSubview:grid];
                [gridLabels addObject:grid];
                [grid setTextAlignment:UITextAlignmentCenter];
            }
        }
        for(int i=0; i<3; i++){
            for(int j=0; j<3; j++){
                UIView* unit = [[UIView alloc]initWithFrame:CGRectMake(i*unitSize+1, j*unitSize+1, unitSize, unitSize)];
                [unit.layer setBorderColor:[[UIColor blackColor] CGColor]];
                [unit.layer setBorderWidth:1];
                [main addSubview:unit];
            }
        }
        [self.view addSubview:main];
    }
    for(int i=0; i<81; i++){
        UILabel *grid = [gridLabels objectAtIndex:i];
        [grid setText:[NSString stringWithFormat:@"%d", self.solution[i/9][i%9]]];
        if (self.hints[i/9][i%9] ==0){
            [grid setTextColor:[UIColor blueColor]];
        }else{
            [grid setTextColor:[UIColor blackColor]];            
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.commentTextField resignFirstResponder];
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
        ArchiveEntry* archiveEntry = [ArchiveEntry archiveEntryWithValues:-1
                                                       solutionString:serializedBoard
                                                           hintString:[cvutil SerializeBoard:hints]
                                                     secondsSince1970:[[NSDate date] timeIntervalSince1970]
                                                                 comments:self.comments];
        [arman addEntry:archiveEntry];
        [arman saveArchive];  
    }else{
        int entryId = self.archiveEntryId;
        ArchiveEntry* e = [arman getEntryById:entryId];
        if (e){
            e.comments = self.comments;
            [arman updateEntry:e];
            bool saved = [arman saveArchive];
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
    self.comments = commentTextField.text;
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
    [self resetFields];
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
    [self drawGridsView];
}

-(void) refreshBoardWithArchiveEntry:(ArchiveEntry*) entry{
    [self resetFields];
    self.archiveEntryId = entry.entryId;
    self.solution = [cvutil DeserializedBoard: [entry sudokuSolution] ];
    self.hints = [cvutil DeserializedBoard:[entry sudokuHints]];
    self.comments = entry.comments;
    [commentTextField setText:entry.comments];
    [self drawGridsView];
}

@end
