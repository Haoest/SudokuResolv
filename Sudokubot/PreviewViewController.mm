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
//#import "GridViewAndModel.h"

@implementation PreviewViewController

CGPoint const boardGridOffset = CGPointMake(20, 20);
CGPoint const gridLabelOffset = CGPointMake(0,-8);

@synthesize previewImage, solveButton, cancelButton;
@synthesize rootViewDelegate;

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
        UIView * gv = [gridViews objectAtIndex:i];
        [gv setAlpha:0.5];
        int gridNumber = hints[i/9][i%9];
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
        selectedGridId = -1;
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
            [gridViews addObject: [[UIView alloc] initWithFrame:grid]];
        }
        [self createUIBoardGrids:result.boardArr];
    }else{
        [previewImage setImage:img];
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:@"Sorry, can not find a Sudoku board from the given photo" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
        [solveButton setEnabled:false];
    }
}

-(void) initNumpad{
    numpadContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 149)];
    for(int i=0; i<10; i++){
        UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"numpad_%d", i]]];
        [numpadContainer addSubview:iv];
        [iv setAlpha:0.8];
        [numpadImages addObject:iv];
    }
    numpadHotRegions = [NSArray arrayWithObjects:
                            [NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(60, 120, 30, 30)],
                                [NSValue valueWithCGRect:CGRectMake(69, 104, 15, 15)],
                                [NSValue valueWithCGRect:CGRectMake(71, 94, 10, 10)],
                             nil], // 0
                            [NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(11, 95, 25, 25)],
                                [NSValue valueWithCGRect:CGRectMake(35, 88, 15, 15)],
                                [NSValue valueWithCGRect:CGRectMake(51, 84, 10, 10)],
                             nil], //1
                            [NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(2, 65, 25, 25)],
                                [NSValue valueWithCGRect:CGRectMake(27, 70, 15, 15)],
                                [NSValue valueWithCGRect:CGRectMake(42, 72, 10, 10)],
                             nil], //2
                            [NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(9, 35, 25, 25)],
                                [NSValue valueWithCGRect:CGRectMake(34, 51, 15, 15)],
                                [NSValue valueWithCGRect:CGRectMake(49, 60, 10, 10)],
                             nil], //3
                            [NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(32, 10, 25, 25)],
                                [NSValue valueWithCGRect:CGRectMake(49, 35, 15, 15)],
                                [NSValue valueWithCGRect:CGRectMake(58, 50, 10, 10)],
                             nil], //4
                            [NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(63, 0, 25, 25)],
                                [NSValue valueWithCGRect:CGRectMake(68, 25, 15, 15)],
                                [NSValue valueWithCGRect:CGRectMake(70, 40, 10, 10)],
                             nil], //5
                            [NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(94, 8, 25, 25)],
                                [NSValue valueWithCGRect:CGRectMake(87, 33, 15, 15)],
                                [NSValue valueWithCGRect:CGRectMake(84, 48, 10, 10)],
                             nil], //6
                            [NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(117, 33, 25, 25)],
                                [NSValue valueWithCGRect:CGRectMake(102, 49, 15, 15)],
                                [NSValue valueWithCGRect:CGRectMake(92, 59, 10, 10)],
                             nil],//7
                            [NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(123, 63, 25, 25)],
                                [NSValue valueWithCGRect:CGRectMake(108, 68, 15, 15)],
                                [NSValue valueWithCGRect:CGRectMake(98, 71, 10, 10)],
                             nil],//8
                            [NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(115, 95, 25, 25)],
                                [NSValue valueWithCGRect:CGRectMake(100, 87, 15, 15)],
                                [NSValue valueWithCGRect:CGRectMake(90, 83, 10, 10)],
                             nil]//9
                        ,nil];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initNumpad];
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

-(int) findTouchOverGridViewId:(NSSet*) touches{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    int rv = -1;
    for(int i=0; i<81; i++){
        UIView* v = [gridViews objectAtIndex:i];
        if (CGRectContainsPoint(v.frame, location)){
            rv = i;
            break;
        }
    }
    return rv;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    int gridId = [self findTouchOverGridViewId:touches];
    if (gridId > -1){
        if (selectedGridId != -1){
            [[gridViews objectAtIndex:selectedGridId] setBackgroundColor:[UIColor clearColor]];
        }
        if (selectedGridId != gridId){
            selectedGridId = gridId;
            [[gridViews objectAtIndex:selectedGridId] setBackgroundColor:[UIColor greenColor]];
        }
    }
    [super touchesBegan:touches withEvent:event];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    int gridId = [self findTouchOverGridViewId:touches];
    if (selectedGridId > -1 && selectedGridId != gridId){
        [[gridViews objectAtIndex:selectedGridId] setBackgroundColor:[UIColor clearColor]];
        if(gridId > -1){
            selectedGridId = gridId;
            [[gridViews objectAtIndex:selectedGridId] setBackgroundColor:[UIColor greenColor]];
            [self showNumpadForGrid:selectedGridId];
        }
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{

}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    int gridId = [self findTouchOverGridViewId:touches];
    if (gridId > -1 && gridId != selectedGridId){
        if (selectedGridId > -1){
            [[gridViews objectAtIndex:selectedGridId] setBackgroundColor:[UIColor clearColor]];            
        }
        selectedGridId = gridId;
       [[gridViews objectAtIndex:selectedGridId] setBackgroundColor:[UIColor greenColor]];

    }
    [super touchesMoved:touches withEvent:event];
}

-(IBAction) solveButton_touchdown{
    
}

-(IBAction) cancelButton_touchdown{
    [rootViewDelegate showRootView];
}

-(void) showNumpadForGrid:(int)gridId{
    [self.view addSubview:numpadContainer];
}

@end
