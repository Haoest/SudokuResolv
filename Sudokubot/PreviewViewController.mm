//
//  PreviewViewController.m
//  Sudokubot
//
//  Created by Haoest on 5/28/11.
//  Copyright 2011 none. All rights reserved.
//

#import "boardRecognizer.h"
#import "cvutil.hpp"
#import "PreviewViewController.hpp"
#import "GridViewAndModel.h"

@implementation PreviewViewController

CGPoint const boardGridOffset = CGPointMake(20, 20);
CGPoint const gridLabelOffset = CGPointMake(0,-8);

@synthesize previewImage, solveButton, cancelButton;
@synthesize rootViewDelegate;

-(void) setbgcolor{
    [self.view setBackgroundColor:[UIColor redColor]];
}

-(void) createUIBoardGrids:(int**) hints{
    UIFont *labelFont = [UIFont fontWithName:@"Courier New" size:16];
    if (gridNumberLabels){
        for(UILabel *lbl in gridNumberLabels){
            [lbl removeFromSuperview];
            [lbl release];
        }
        [gridNumberLabels release];
    }
    gridNumberLabels = [[NSMutableArray alloc]initWithCapacity:81/2];
    for(int i=0; i<81; i++){
        GridViewAndModel * gv = [gridViews objectAtIndex:i];
        int gridNumber = hints[i/9][i%9];
        gv.gridId = i;
        gv.hintFromOCR = gridNumber;
        gv.hintByManualInput = 0;
        gv.previewViewControllerDelegate = self;
        [self.view addSubview:gv];
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(gv.frame.origin.x+gridLabelOffset.x, 
                                                                 gv.frame.origin.y+gridLabelOffset.y, 
                                                                 gv.frame.size.width, 
                                                                 gv.frame.size.height)];
        lbl.frame.origin.x += gridLabelOffset.x;
        lbl.frame.origin.y += gridLabelOffset.y;
        lbl.frame.origin.y = 0;
        [lbl setTextColor:[UIColor redColor]];
        [lbl setTextAlignment:UITextAlignmentRight];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setFont:labelFont];
        [gridViews addObject:gv];
        [self.view addSubview:lbl];
        if (gridNumber>0){
            [lbl setText:[NSString stringWithFormat:@"%d", gridNumber]];
        }
        
    }
    
}

-(void) loadImageWithSudokuBoard:(UIImage*) img{
    IplImage* ipl = [cvutil CreateIplImageFromUIImage:img];
    recognizerResultPack result = recognizeBoardFromPhoto(ipl);
    cvReleaseImage(&ipl);
    if (result.success){
        UIImage* board = [cvutil CreateUIImageFromIplImage:result.boardGray];
        [previewImage setImage:board];
        [solveButton setEnabled:true];
        CGFloat HRatio = previewImage.frame.size.width / result.boardGray->width;
        CGFloat VRatio = previewImage.frame.size.height / result.boardGray->height;
        if (gridViews){
            for(UIView* v in gridViews){
                [v removeFromSuperview];
                [v release];
            }
            [gridViews release];
        }
        gridViews = [[NSMutableArray alloc] initWithCapacity:81];
        for(int i=0; i<81; i++){
            CvRect r = result.grids[i];
            CGRect grid = CGRectMake(r.x *HRatio + boardGridOffset.x , r.y*VRatio+boardGridOffset.y, r.width*HRatio, r.height*VRatio);
            [gridViews addObject: [[GridViewAndModel alloc] initWithFrame:grid]];
        }
        [self createUIBoardGrids:result.boardArr];
    }else{
        [previewImage setImage:img];
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:@"Sorry, can not find a Sudoku board from the given photo" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
        [solveButton setEnabled:false];
    }
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
    // Do any additional setup after loading the view from its nib.
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

//-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    UITouch *touch = [touches anyObject];
//    lastActiveGridView = touch.view;
//    [lastActiveGridView setBackgroundColor:[UIColor greenColor]];
//}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [lastActiveGridView setBackgroundColor:[UIColor clearColor]];
    lastActiveGridView = 0;
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [lastActiveGridView setBackgroundColor:[UIColor clearColor]];
    lastActiveGridView = 0;
}

-(IBAction) solveButton_touchdown{
    
}

-(IBAction) cancelButton_touchdown{
    [rootViewDelegate showRootView];
}

-(void) showNumberMenuForGrid:(int)gridId{
    GridViewAndModel *gv = [gridViews objectAtIndex:gridId];
    lastActiveGridView = gv;
    [gv setBackgroundColor:[UIColor greenColor]];
}

@end
