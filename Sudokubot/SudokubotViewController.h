//
//  SudokubotViewController.h
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ViewDelegates.h"
#import "BoardViewController.h"
#import "ArchiveViewController.h"


@interface SudokubotViewController : UIViewController <
    UIImagePickerControllerDelegate, 
UINavigationControllerDelegate, 
RootViewDelegate> {

}

@property (nonatomic, retain) IBOutlet UIImageView *MainImageView;

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

- (void) reevaluateClipboardButton;

@property(nonatomic, retain) BoardViewController* boardViewController;
@property(nonatomic, retain) ArchiveViewController* archiveViewController;

-(void) removeSubviews;
@end
