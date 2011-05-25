//
//  BoardViewController.m
//  Sudokubot
//
//  Created by Haoest on 4/7/11.
//  Copyright 2011 none. All rights reserved.
//

#import <opencv2/core/core.hpp>
#import "cvutil.hpp"
#import "solver.hpp"
#import "boardRecognizer.h"
#import "BoardViewController.h"
#import "ArchiveViewController.h"
#import "AppConfig.h"
#import "ArchiveEntry.h"

@implementation BoardViewController

@synthesize imageView, commentTextField, contentsView, navigationBar;
@synthesize backToArchiveButton, mainMenuButton;
@synthesize board, solution, comments, archiveEntryId;
@synthesize rootViewDelegate;

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
    [self loadBoard];
    [self wireupControls];
    [self.commentTextField setText:self.comments];
}

-(void) loadBoard{
    [imageView setImage:[self drawGrids]];
}

-(void) wireupControls{

    [self.backToArchiveButton setTarget:self];
    [self.backToArchiveButton setAction:@selector(backToArchiveMenu)];
    [self.mainMenuButton setTarget:self];
    [self.mainMenuButton setAction:@selector(backToMainMenu)];
    self.commentTextField.delegate = self;
}

-(UIImage*) drawGrids{
    IplImage* img = cvCreateImage(cvSize(288, 288), IPL_DEPTH_8U, 3);
    cvSet(img, CV_RGB(255, 255, 255));
    int max=287, size = 30;
    int index = 0;
    for (int i=0; i<=9; i++){
        cvLine(img, cvPoint(0, index+1), cvPoint(max, index+1), cvScalar(0,0,0));
        cvLine(img, cvPoint(index+1, 0), cvPoint(index+1, max), cvScalar(0,0,0));
        if (i%3 == 0){
            cvLine(img, cvPoint(0, index), cvPoint(max, index), cvScalar(0,0,0));            
            cvLine(img, cvPoint(0, index+2), cvPoint(max, index+2), cvScalar(0,0,0));     
            cvLine(img, cvPoint(index, 0), cvPoint(index, max), cvScalar(0,0,0));
            cvLine(img, cvPoint(index+2, 0), cvPoint(index+2, max), cvScalar(0,0,0));
            index+=2;
        }
        index += size+1;
        
    }
    CvFont font;
    cvInitFont(&font, CV_FONT_VECTOR0, 0.7, 0.7);
    for(int i=0; i<9; i++){
        for(int j=0; j<9; j++){
            char *number = new char[2];
            number[0] = (char) self.solution[i][j]+48;
            number[1] = 0;
            CvScalar color = cvScalar(0,0,0);
            if (self.board && self.board[i][j] != 0){
                color = cvScalar(255,0,0);
            }
            cvPutText(img, number, cvPoint(j*32+10, i*31+25), &font, color);
        }
    }
    UIImage* rv = [cvutil CreateUIImageFromIplImage:img];
    cvReleaseImage(&img);
    return rv;
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

+(BoardViewController*) boardWithImage:(UIImage*) boardAsImage{
    BoardViewController *rv = [[BoardViewController alloc] initWithNibName:@"BoardViewController" bundle:nil];
    IplImage *boardIpl = [cvutil CreateIplImageFromUIImage:boardAsImage];
    recognizerResultPack recog = recognizeBoardFromPhoto(boardIpl);
    rv.board = recog.boardArr;
    cvReleaseImage(&boardIpl);
    rv.solution = [[solver solverWithHints:rv.board] trySolve];
    return rv;
}

+(BoardViewController*) boardWithArchiveEntry:(ArchiveEntry *)entry{
    BoardViewController *rv = [[BoardViewController alloc] initWithNibName:@"BoardViewController" bundle:nil];
    rv.archiveEntryId = entry.entryId;
    rv.solution = [cvutil DeserializedBoard: [entry sudokuSolution] ];
    rv.board = [cvutil DeserializedBoard:[entry sudokuHints]];
    [rv.commentTextField setText:entry.comments];
    return rv;
}

-(void) saveToArchive{
    NSString* serializedBoard = [cvutil SerializeBoard: self.solution];
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    if(self.archiveEntryId == -1){
        ArchiveEntry* archiveEntry = [ArchiveEntry archiveEntryWithValues:-1
                                                       solutionString:serializedBoard
                                                           hintString:[cvutil SerializeBoard:board]
                                                     secondsSince1970:[[NSDate date] timeIntervalSince1970]
                                                                 comments:commentTextField.text];
        [arman addEntry:archiveEntry];
        [arman saveArchive];  
    }else{
        ArchiveEntry* e = [arman getEntryById:self.archiveEntryId];
        if (!e){
            e.comments = commentTextField.text;
            [arman updateEntry:e];
            [arman saveArchive];
        }
    }
    [arman release];
    ArchiveViewController* archieveViewController = [ArchiveViewController archiveViewControllerFromDefaultArchive];
    UIView* superview = self.view.superview;
    [self.view removeFromSuperview];
    [superview addSubview:archieveViewController.view];
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
    self.contentsView.frame = CGRectOffset(self.contentsView.frame, 0, movement);
    [UIView commitAnimations];
}


-(void) refreshBoardWithPuzzle:(UIImage*) imageBoard{
    IplImage *boardIpl = [cvutil CreateIplImageFromUIImage:imageBoard];
    recognizerResultPack recog = recognizeBoardFromPhoto(boardIpl);
    self.board = recog.boardArr;
    cvReleaseImage(&boardIpl);
    self.solution = [[solver solverWithHints:self.board] trySolve];
    self.archiveEntryId = -1;
    self.commentTextField.text = @"";
    [imageView setImage:[self drawGrids]];
}

-(void) refreshBoardWithArchiveEntry:(ArchiveEntry*) entry{
    
}

@end
