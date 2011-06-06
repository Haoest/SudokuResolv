//
//  SudokubotViewController.h
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "rootViewDelegate.h"
#import "BoardViewController.h"
#import "ArchiveViewController.h"
#import "PreviewViewController.hpp"

@interface SudokubotViewController : UIViewController <
    UIImagePickerControllerDelegate, 
UINavigationControllerDelegate, 
RootViewDelegate> {
    
}


@end
