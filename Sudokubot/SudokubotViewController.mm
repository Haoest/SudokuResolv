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

@implementation SudokubotViewController

@synthesize MainImageView;
@synthesize btnChange;

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
    IplImage* ipl = ParseFromImage(img);
    IplImage *color = cvCreateImage(cvGetSize(ipl), IPL_DEPTH_8U, 3);
    cvCvtColor(ipl, color, CV_GRAY2BGR);
    UIImage *ui = [cvutil CreateUIImageFromIplImage:color];
    
    [MainImageView setImage:ui];

//    basicOCR *ocr = new basicOCR();
//    ocr->test();
//    IplImage *iplimage = [cvutil LoadPbmAsIplImage:@"000"];
//    IplImage *colorImage = [cvutil GetNormalizedImageFromBlackNWhite:iplimage];
//    UIImage* uiimage = [cvutil CreateUIImageFromIplImage:colorImage];
//    cvReleaseImage(&iplimage);
//    cvReleaseImage(&colorImage);
//    [MainImageView setImage:uiimage];

}

@end
