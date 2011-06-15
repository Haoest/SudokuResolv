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
#import "cvutil.hpp"

@interface SudokubotViewController ()

- (void) removeSubviews;

@property (nonatomic, retain) IBOutlet UIButton *btnCaptureFromCamera;
@property (nonatomic, retain) IBOutlet UIButton *btnOpenFromPhotoLibrary;
@property (nonatomic, retain) IBOutlet UIButton *btnOpenFromClipboard;
@property (nonatomic, retain) IBOutlet UIButton *btnArchive;
@property (nonatomic, retain) IBOutlet UIButton *btnHelp;
@property (nonatomic, retain) UIImagePickerController *imagePicker;

-(IBAction) btnCaptureFromCamera_touchDown;
-(IBAction) btnOpenFromPhotoLibrary_touchDown;
-(IBAction) btnOpenFromClipboard_touchDown;
-(IBAction) btnArchive_touchDown;
-(IBAction) btnHelp_touchDown;

@property(nonatomic, retain) BoardViewController* boardViewController;
@property(nonatomic, retain) ArchiveViewController* archiveViewController;
@property(nonatomic, retain) PreviewViewController* previewViewController;

-(void) showPreview: (UIImage*) imageWithSudokuBoard;

@end



@implementation SudokubotViewController

@synthesize btnCaptureFromCamera;
@synthesize btnOpenFromPhotoLibrary;
@synthesize btnOpenFromClipboard;
@synthesize btnArchive;
@synthesize btnHelp;
@synthesize imagePicker;

@synthesize boardViewController, archiveViewController, previewViewController;

- (void)dealloc
{
    self.boardViewController = nil;
    self.archiveViewController = nil;
    self.previewViewController = nil;
    self.imagePicker = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [self removeSubviews];
    self.boardViewController = nil;
    self.archiveViewController = nil;
    self.previewViewController = nil;
    self.imagePicker = nil;
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [btnCaptureFromCamera setEnabled:NO];
        [btnCaptureFromCamera setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.btnHelp = nil;
    self.btnCaptureFromCamera = nil;
    self.btnOpenFromClipboard = nil;
    self.btnOpenFromPhotoLibrary = nil;
    self.btnArchive = nil;
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
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
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
        [self showPreview:board];
    }else{
        UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Clipboard doesn't appear to have image data" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
}

-(IBAction) btnArchive_touchDown{
    [self showArchiveView];
}

-(IBAction) btnCaptureFromCamera_touchDown{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = true;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:imagePicker animated:NO];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    UIImage* img = [info valueForKey:UIImagePickerControllerEditedImage];
    int width = img.size.width;
    int height = img.size.height;
    self.imagePicker = nil;
    [self showPreview:img];
}
 
 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) showPreview: (UIImage*) imageWithSudokuBoard{
    if (!self.previewViewController){
        self.previewViewController = [[PreviewViewController alloc] initWithNibName:@"PreviewViewController" bundle:nil];
        self.previewViewController.rootViewDelegate = self;
    }
    [self.view addSubview: previewViewController.view];
    [self.previewViewController loadImageWithSudokuBoard:imageWithSudokuBoard];
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
    [self.archiveViewController refreshArchiveList];
}

-(void) showBoardViewWithEntry:(ArchiveEntry *)entry{
    if (self.boardViewController){
        [self removeSubviews];
    }else{
        BoardViewController *c = [[BoardViewController alloc] initWithNibName:nil bundle:nil];
        self.boardViewController = c;
        c.rootViewDelegate = self;
    }
    [self.boardViewController refreshBoardWithArchiveEntry:entry];
    [self.view addSubview: self.boardViewController.view];
}

-(void) showRootView{
    [self removeSubviews];
    [self reevaluateClipboardButton];
}

-(void) showBoardViewWithHints:(int**) hints{
    if (self.boardViewController){
        [self removeSubviews];
    }else{
        BoardViewController *c = [[BoardViewController alloc] initWithNibName:nil bundle:nil];
        self.boardViewController = c;
        c.rootViewDelegate = self;
    }
    [self.boardViewController refreshBoardWithHints:hints];    
    [self.view addSubview: self.boardViewController.view];
}

-(void) removeSubviews{
    [self.boardViewController.view removeFromSuperview];
    [self.archiveViewController.view removeFromSuperview];
    [self.previewViewController.view removeFromSuperview];
}

@end
