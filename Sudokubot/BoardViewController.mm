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
#import "PuzzleParser.hpp"
#import "BoardViewController.h"


@implementation BoardViewController



@synthesize imageView, saveToArchiveButton, mainMenuButton, commentTextField;
@synthesize board, solution, comments;

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
    [self loadBoard];
    [self wireupControls];

    // Do any additional setup after loading the view from its nib.
}

-(void) loadBoard{
    [imageView setImage:[self drawGrids]];
}

-(void) wireupControls{
    [self.saveToArchiveButton setTarget:self];
    [self.saveToArchiveButton setAction:@selector(saveToArchive)];
    [commentTextField setPlaceholder:@"Enter comment here"];

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
            CvScalar color = Scalar(0,0,0);
            if (self.board[i][j] != 0){
                color = Scalar(255,0,0);
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

+(BoardViewController*) boardWithImage:(UIImage*) boardAsImage{
    BoardViewController *rv = [[[BoardViewController alloc] initWithNibName:@"BoardViewController" bundle:nil] autorelease];
    rv.board = ParseFromImage(boardAsImage);
    rv.solution = [[solver solverWithPartialBoard:rv.board] trySolve];
    return rv;
}

-(void) saveToArchive{
    NSString *serializedString = [cvutil SerializeBoard:solution];
    NSString *archiveEntry;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    archiveEntry = [NSString stringWithFormat:@"%@\t%@\n", [formatter stringFromDate:[NSDate date]], serializedString];
    [formatter release];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:archiveFileName];
    if (fileHandle == Nil){
        NSFileManager* fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:archiveFileName 
                    contents:[archiveEntry dataUsingEncoding:NSUTF8StringEncoding] 
                    attributes:Nil];
    }else{
        [fileHandle writeData:[archiveEntry dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
}


@end
