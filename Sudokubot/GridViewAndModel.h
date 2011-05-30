//
//  GridView.h
//  Sudokubot
//
//  Created by Haoest on 5/30/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreviewViewControllerDelegate.h"

@interface GridViewAndModel : UIView {

}

@property(nonatomic, assign) int gridId;
@property(nonatomic, assign) int hintFromOCR;
@property(nonatomic, assign) int hintByManualInput;

@property(nonatomic, retain) id<PreviewViewControllerDelegate> previewViewControllerDelegate;

@end
