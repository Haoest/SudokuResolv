//
//  PreviewViewControllerDelegate.h
//  Sudokubot
//
//  Created by Haoest on 5/30/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PreviewViewControllerDelegate <NSObject>

-(void) showNumberMenuForGrid: (int) gridId;

@end
 