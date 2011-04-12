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
#import "BoardViewController.h"
#import "ArchiveViewController.h"

@implementation SudokubotViewController

@synthesize MainImageView;
@synthesize btnCaptureFromCamera;
@synthesize btnOpenFromPhotoLibrary;
@synthesize btnOpenFromClipboard;
@synthesize btnArchive;
@synthesize btnHelp;

@synthesize imagePicker;


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

-(IBAction) btnHelp_touchDown{

}

-(IBAction) btnOpenFromClipboard_touchDown{

}

-(IBAction) btnArchive_touchDown{
    ArchiveViewController* archive = [ArchiveViewController archiveViewControllerFromDefaultArchive];
    [self.view addSubview:archive.view];
}

-(IBAction) btnCaptureFromCamera_touchDown{
    
}
         
         
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    UIImage* img = [info valueForKey:UIImagePickerControllerOriginalImage];
    BoardViewController* boardViewController = [BoardViewController boardWithImage:img];
    [self.view addSubview: boardViewController.view];
    
}
 
 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}         
@end
