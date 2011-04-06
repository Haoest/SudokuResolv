//
//  SudokubotViewController.m
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//

#import <opencv2/core/core.hpp>
#import "SudokubotViewController.h"
#import "PuzzleParser.hpp"
#import "basicOCR.hpp"
#import "preprocessing.hpp"
#import "solver.hpp"

@implementation SudokubotViewController

@synthesize MainImageView;
@synthesize btnChange;
@synthesize btnPbm;

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) ShowPuzzle{
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"puzzle1.png"]];
    [MainImageView setImage:img];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) btnChange_Click{
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"puzzle1.png"]];
    int board[9][9];
    ParseFromImage(img, board);
    solver *solv = [solver solverWithPartialBoard:board];
    int ** solution = [solv trySolve];
    
    NSMutableString *s =    [NSMutableString  stringWithFormat:@""];
    for(int i=0; i<9; i++){
        for (int j=0; j<9; j++){
            [s appendFormat:@"%d ", solution[i][j]];
        }
        [s appendString:@"\n"];
    }
    NSLog(s);
    int a;
    a = 1;


}

-(IBAction) btnPbm_Click{
    IplImage* ipl = [cvutil LoadPbmAsIplImage:@"500"];
    IplImage processed = preprocessing(ipl, 40, 40);
    IplImage* color = cvCreateImage(cvGetSize(&processed), IPL_DEPTH_8U, 3);
    cvCvtColor(&processed, color, CV_GRAY2BGR);
    UIImage* ui = [cvutil CreateUIImageFromIplImage:color];
    [MainImageView setImage:ui];
}

@end
