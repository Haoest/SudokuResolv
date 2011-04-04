//
//  SudokubotViewController.h
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SudokubotViewController : UIViewController {

}

@property (nonatomic, retain) IBOutlet UIImageView *MainImageView;
@property (nonatomic, retain) IBOutlet UIButton *btnChange;
@property (nonatomic, retain) IBOutlet UIButton *btnPbm;
-(void) ShowPuzzle;
-(IBAction) btnChange_Click;
-(IBAction) btnPbm_Click;

@end
