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
#import "AppConfig.h"
#import "solver.hpp"

@interface PreviewViewController()

@property(nonatomic, retain) IBOutlet UIImageView* previewImage;
@property(nonatomic, retain) IBOutlet UIButton* solveButton;
@property(nonatomic, retain) IBOutlet UIButton* cancelButton;
@property(nonatomic, retain) IBOutlet UIView* busyViewTop;
@property(nonatomic, retain) IBOutlet UIView* busyViewBottom;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView* busyIndicator;

-(IBAction) solveButton_touchdown;
-(IBAction) cancelButton_touchdown;
-(void) resetFields;

-(void) boardRecognizingThread:(UIImage*) img;


@end



@implementation PreviewViewController

CGPoint const boardGridOffset = CGPointMake(20, 20);
CGPoint const gridLabelOffset = CGPointMake(0,-8);

@synthesize previewImage, solveButton, cancelButton;
@synthesize rootViewDelegate;
@synthesize busyViewTop, busyIndicator, busyViewBottom;

- (void)dealloc
{
    [self resetFields];
    [numpadImages removeAllObjects];
    [numpadImages release];
    [numpadContainer release];
    [numpadHotRegions removeAllObjects];
    [numpadHotRegions release];
    previewImage = nil;
    solveButton = nil;
    cancelButton = nil;  
    busyViewBottom = nil;
    busyViewTop = nil;
    busyIndicator = nil;
    self.view = nil;
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

-(void) resetFields{
    [numpadContainer setHidden:true];
    if (selectedNumpadId > -1){
        [[numpadImages objectAtIndex:selectedNumpadId] setAlpha:[AppConfig numpad_normal_alpha]];
    }
    selectedGridId = -1;
    selectedNumpadId = -1;
    [previewImage setAlpha:1];
    if (gridNumberLabels){
        for(UILabel *lbl in gridNumberLabels){
            [lbl removeFromSuperview];
        }
        [gridNumberLabels removeAllObjects];
        [gridNumberLabels release];
    }
    gridNumberLabels = nil;
    if (gridViews){
        for(UIView* v in gridViews){
            [v removeFromSuperview];
        }
        [gridViews removeAllObjects];
        [gridViews release];
    }
    gridViews = nil;
    if (hints){
        for(int i=0; i<9; i++){
            delete hints[i];
        }
        delete hints;
    }
    hints = nil;
    [solveButton setEnabled:true];
}

-(void) createUIBoardGrids{
    UIFont *labelFont = [UIFont fontWithName:@"Courier New" size:16];
    gridNumberLabels = [[NSMutableArray alloc]initWithCapacity:81];
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
        [self.view addSubview:lbl];
        if (gridNumber>0){
            [lbl setText:[NSString stringWithFormat:@"%d", gridNumber]];
        }
        [gridNumberLabels addObject:lbl];
        [lbl release];
    }
}

-(void) loadImageWithSudokuBoard:(UIImage*) img{
    [previewImage setImage:img];
    if (!busyViewTop){
        busyViewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        [busyViewTop setBackgroundColor:[UIColor blackColor]];
        [busyViewTop setAlpha:0.5];
        [self.view addSubview:busyViewTop];
        busyViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, 320, 320, 140)];
        [busyViewBottom setBackgroundColor:[UIColor blackColor]];
        busyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [busyIndicator startAnimating];
        [busyIndicator setCenter:CGPointMake(busyViewBottom.frame.size.width/2, busyViewBottom.frame.size.height/2)];
        [busyViewBottom addSubview:busyIndicator];
        [self.view addSubview:busyViewBottom];
    }else{
        [self.view bringSubviewToFront:busyViewTop];
        [self.view bringSubviewToFront:busyViewBottom];
        [busyViewTop setHidden:false];
        [busyIndicator startAnimating];
        [busyViewBottom setHidden:false];
    }

    NSThread* recognizerThread = [[[NSThread alloc] initWithTarget:self selector:@selector(boardRecognizingThread:) object:img] autorelease];
    [recognizerThread start];
}

-(void) boardRecognizingThread:(UIImage*) img{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    IplImage* ipl = [cvutil CreateIplImageFromUIImage:img ignoreUIOrientation:false];
    recognizerResultPack result = recognizeBoardFromPhoto(ipl);
    cvReleaseImage(&ipl);
    [self resetFields];
    if (result.success){
        UIImage* board = [cvutil CreateUIImageFromIplImage:result.boardGray];
        [previewImage setImage:board];
        [solveButton setEnabled:true];
        CGFloat HRatio = previewImage.frame.size.width / result.boardGray->width;
        CGFloat VRatio = previewImage.frame.size.height / result.boardGray->height;
        gridViews = [[NSMutableArray alloc] initWithCapacity:81];
        for(int i=0; i<81; i++){
            CvRect r = result.grids[i];
            CGRect grid = CGRectMake(r.x *HRatio + boardGridOffset.x , r.y*VRatio+boardGridOffset.y, r.width*HRatio, r.height*VRatio);
            UIView* v = [[UIView alloc] initWithFrame:grid];
            [gridViews addObject: v];
            [v release];
        }
        hints = new int*[9];
        for(int i=0; i<9; i++){
            hints[i] = new int[9];
            for(int j=0; j<9; j++){
                hints[i][j] = result.boardArr[i][j];
            }
        }
        [self createUIBoardGrids];
        result.destroy();
    }else{
        [previewImage setImage:img];
        UIAlertView *alert =[[[UIAlertView alloc] initWithTitle:@"" message:@"Sorry, can not find a Sudoku board from this photo. See Help for tips on how to take pictures for better recognition." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] autorelease];
        [alert show];
        [solveButton setEnabled:false];
    }
    [busyViewBottom setHidden:true];
    [busyViewTop setHidden:true];
    [busyIndicator stopAnimating];
    [pool release];
}

-(void) initNumpad{
    numpadContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    numpadImages = [[NSMutableArray alloc] initWithCapacity:10];
    for(int i=0; i<10; i++){
        UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"numpad_%d", i]]];
        [iv setFrame:CGRectMake(0, 0, 250, 250)];
        [numpadContainer addSubview:iv];
        [numpadImages addObject:iv];
    }
    for(int i=0; i<10; i++){
        [[numpadImages objectAtIndex:i] setAlpha:[AppConfig numpad_normal_alpha]];
    }
    int regions[10][3][4] = {
        {{60, 120, 30, 30}, {69,104,15,15}, {71, 94, 10, 10}},
        {{11, 95, 25, 25}, {35, 88, 15, 15}, {51, 84, 10, 10}},
        {{2, 65, 25, 25},{27, 70, 15, 15},{42, 72, 10, 10}},
        {{9, 35, 25, 25},{34, 51, 15, 15},{49, 60, 10, 10}},
        {{32, 10, 25, 25},{49, 35, 15, 15},{58, 50, 10, 10}},
        {{63, 0, 25, 25},{68, 25, 15, 15},{70, 40, 10, 10}},
        {{94, 8, 25, 25},{87, 33, 15, 15},{84, 48, 10, 10}},
        {{117, 33, 25, 25},{102, 49, 15, 15},{92, 59, 10, 10}},
        {{123, 63, 25, 25},{108, 68, 15, 15},{98, 71, 10, 10}},
        {{115, 95, 25, 25},{100, 87, 15, 15},{90, 83, 10, 10}}
    };
    numpadHotRegions = [[NSMutableArray alloc] initWithCapacity:10];
    float hotRegionCoordModifier = 1.0F / 150 * 250; // numPadImages had original size of 150x150, now they have been 
                                                // blown up to 250x250, the hot regions coordinates have to be 
                                                // multiplied by the same modifier
    for(int i=0; i<10; i++){
        NSMutableArray *regionsForOneNumber = [[NSMutableArray alloc] initWithCapacity:3];
        [numpadHotRegions addObject:regionsForOneNumber];
        for(int j=0; j<3; j++){
            int x = regions[i][j][0] * hotRegionCoordModifier;
            int y = regions[i][j][1] * hotRegionCoordModifier;
            int width = regions[i][j][2] * hotRegionCoordModifier;
            int height = regions[i][j][3] * hotRegionCoordModifier;
            UIView* v = [[UIView alloc] initWithFrame:CGRectMake(x,y,width, height)];
            [regionsForOneNumber addObject:v];
            [numpadContainer addSubview:v];
        }
    }
    [self.view addSubview:numpadContainer];
    [numpadContainer setHidden:true];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initNumpad];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) showNumpadForGrid:(int)gridId{
    [numpadContainer setHidden:false];
    UIView* grid = [gridViews objectAtIndex:gridId];
    CGFloat midx = CGRectGetMidX(grid.frame);
    CGFloat midy = CGRectGetMidY(grid.frame);
    midx = MAX(numpadContainer.frame.size.width/2, midx);
    midy = MAX(numpadContainer.frame.size.height/2, midy);
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    midx = MIN(midx, screenFrame.size.width - numpadContainer.frame.size.width/2);
    numpadContainer.center = CGPointMake(midx, midy);
    [numpadContainer setNeedsDisplay];
    [previewImage setAlpha:[AppConfig previewImage_faded_alpha] ];
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

-(int) findTouchOverNumpadId:(NSSet*) touches{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:numpadContainer];
    for(int i=0; i<10; i++){
        NSMutableArray* pad = [numpadHotRegions objectAtIndex:i];
        for(int j=0; j<3; j++){
            UIView* region = [pad objectAtIndex:j];
            //NSLog([NSString stringWithFormat:@"%f %f %f %f", region.frame.origin.x, region.frame.origin.y, region.frame.size.width, region.frame.size.height]);
            if (CGRectContainsPoint(region.frame, location)){
                return i;
            }
        }
    }
    return -1;
}

-(void) resetGridStates{
    [numpadContainer setHidden:true];
    [previewImage setAlpha:1];
    if (selectedGridId > -1){
        [[gridViews objectAtIndex:selectedGridId] setBackgroundColor:[UIColor clearColor]];
    }
    if (selectedNumpadId > -1){
        [[numpadImages objectAtIndex:selectedNumpadId] setAlpha:[AppConfig numpad_normal_alpha]];
    }
    selectedNumpadId = -1;
    selectedGridId = -1;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([numpadContainer isHidden]){
        int gridId = [self findTouchOverGridViewId:touches];
        if (selectedGridId != -1){
            [[gridViews objectAtIndex:selectedGridId] setBackgroundColor:[UIColor clearColor]];
            selectedGridId = -1;
        }
        if (gridId > -1){
            if (selectedGridId != gridId){
                selectedGridId = gridId;
                [[gridViews objectAtIndex:selectedGridId] setBackgroundColor:[UIColor greenColor]];
            }
        }        
    }else{
        int numpadId = [self findTouchOverNumpadId:touches];
        if (selectedNumpadId > -1 && numpadId != selectedNumpadId){
            UIImageView* lastPad = [numpadImages objectAtIndex:selectedNumpadId];
            [lastPad setAlpha:[AppConfig numpad_normal_alpha]];
        }
        if (numpadId > -1){
            selectedNumpadId = numpadId;
            UIImageView* selectedPad = [numpadImages objectAtIndex:numpadId];
            [selectedPad setAlpha:[AppConfig numpad_highlight_alpha]];  
        }
    }
    [super touchesBegan:touches withEvent:event];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([numpadContainer isHidden]){
        int gridId = [self findTouchOverGridViewId:touches];
        if(gridId > -1){
            [[gridViews objectAtIndex:gridId] setBackgroundColor:[UIColor greenColor]];
            [self showNumpadForGrid:gridId];
            [self.view bringSubviewToFront:numpadContainer];
            selectedGridId = gridId;
        }
    }else{
        int numpadId = [self findTouchOverNumpadId:touches];
        if (numpadId> -1){
            hints[selectedGridId/9][selectedGridId%9] = numpadId;
            NSString *newHint = numpadId == 0 ? @"" : [NSString stringWithFormat:@"%d", numpadId];
            [[gridNumberLabels objectAtIndex:selectedGridId] setText:newHint];
        }
        [self resetGridStates];
    }
    [super touchesEnded:touches withEvent:event];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self resetGridStates];
    [super touchesCancelled:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([numpadContainer isHidden]){
        int gridId = [self findTouchOverGridViewId:touches];
        if (gridId > -1 && gridId != selectedGridId){
            if (selectedGridId > -1){
                [[gridViews objectAtIndex:selectedGridId] setBackgroundColor:[UIColor clearColor]];            
            }
            selectedGridId = gridId;
           [[gridViews objectAtIndex:selectedGridId] setBackgroundColor:[UIColor greenColor]];

        }        
    }else{
        int numpadId = [self findTouchOverNumpadId:touches];
        if (numpadId > -1 && numpadId != selectedNumpadId){
            if (selectedNumpadId > -1){
                UIImageView* lastPad = [numpadImages objectAtIndex:selectedNumpadId];
                [lastPad setAlpha:[AppConfig numpad_normal_alpha]];
            }
            selectedNumpadId = numpadId;
            UIImageView* selectedPad = [numpadImages objectAtIndex:numpadId];
            [selectedPad setAlpha:[AppConfig numpad_highlight_alpha]];
        }
    }
    [super touchesMoved:touches withEvent:event];
}

-(IBAction) solveButton_touchdown{
    if ([solver verifyHints:hints]){
        [rootViewDelegate showBoardViewWithHints:hints];
    }else{
        UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"The given hints appear to be invalid, please check each row, column, and unit for duplicative numbers." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
}

-(IBAction) cancelButton_touchdown{
    [rootViewDelegate showRootView];
}


@end
