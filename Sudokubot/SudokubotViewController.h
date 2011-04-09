//
//  SudokubotViewController.h
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SudokubotViewController : UIViewController <
    UIImagePickerControllerDelegate, 
    UINavigationControllerDelegate> {
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

@end
