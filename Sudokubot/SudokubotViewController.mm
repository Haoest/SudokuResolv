//
//  SudokubotViewController.m
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//

#import <opencv2/core/core.hpp>
#import "SudokubotViewController.h"
#import "boardRecognizer.h"
#import "basicOCR.hpp"
#import "preprocessing.h"
#import "solver.hpp"
#import "AppConfig.h"


@implementation SudokubotViewController

@synthesize MainImageView;
@synthesize btnCaptureFromCamera;
@synthesize btnOpenFromPhotoLibrary;
@synthesize btnOpenFromClipboard;
@synthesize btnArchive;
@synthesize btnHelp;
@synthesize imagePicker;

@synthesize rootView;
@synthesize boardViewController, archiveViewController;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [btnCaptureFromCamera setEnabled:NO];
        [btnCaptureFromCamera setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }
    rootView = self.view;
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

- (IBAction) btnOpenFromPhotoLibrary_touchDown{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:imagePicker animated:NO];
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reevaluateClipboardButton];
}

- (void) reevaluateClipboardButton{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    UIImage *img = pb.image;
    static UIColor* originalColor;
    if (!img){
        [btnOpenFromClipboard setEnabled:NO];
        originalColor = btnOpenFromClipboard.currentTitleColor;
        [btnOpenFromClipboard setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }
    else{
        if (originalColor){
            [btnOpenFromClipboard setTitleColor:originalColor forState:UIControlStateNormal];
        }
        [btnOpenFromClipboard setEnabled:YES];
    }
}

-(IBAction) btnHelp_touchDown{

}

-(IBAction) btnOpenFromClipboard_touchDown{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    UIImage *board = pb.image;
    if (board){
        BoardViewController *boardViewController = [BoardViewController boardWithImage:board];
        [self.view addSubview:boardViewController.view];
    }
}

-(IBAction) btnArchive_touchDown{
    [self showArchiveView];
}

-(IBAction) btnCaptureFromCamera_touchDown{
    
}
         
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    UIImage* img = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self showBoardViewWithImageAsBoard:img];
}
 
 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) showBoardView{
    
}

-(void) showArchiveView{
    if (self.archiveViewController){
        [self removeSubviews];
    }else{
        ArchiveViewController* c = [ArchiveViewController archiveViewControllerFromDefaultArchive];
        c.rootViewDelegate = self;
        self.archiveViewController = c;
        
    }
    [self.view addSubview:self.archiveViewController.view];
}

-(void) refreshArchiveView{
    if (self.archiveViewController){
        [self.archiveViewController refreshArchiveList];
    }
}

-(void) showBoardViewWithEntry:(ArchiveEntry *)entry{
    if (self.boardViewController){
        [self.boardViewController refreshBoardWithArchiveEntry:entry];
        [self removeSubviews];
    }else{
        BoardViewController *c = [BoardViewController boardWithArchiveEntry:entry];
        self.boardViewController = c;
        c.rootViewDelegate = self;
    }
    [self.view addSubview: self.boardViewController.view];
}

-(void) showRootView{
    [self removeSubviews];
}

-(void) showBoardViewWithImageAsBoard:(UIImage *)board{
    if (self.boardViewController){
        [self.boardViewController refreshBoardWithPuzzle:board];
        [self removeSubviews];
    }else{
        BoardViewController *c = [BoardViewController boardWithImage:board];
        self.boardViewController = c;
        c.rootViewDelegate = self;
    }
    [self.view addSubview: self.boardViewController.view];
}

-(void) removeSubviews{
    [self.boardViewController.view removeFromSuperview];
    [self.archiveViewController.view removeFromSuperview];
}
@end
