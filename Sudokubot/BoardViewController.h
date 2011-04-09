//
//  BoardViewController.h
//  Sudokubot
//
//  Created by Haoest on 4/7/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BoardViewController : UIViewController {

}
@property(nonatomic, retain) IBOutlet UIImageView* imageView;

@property(nonatomic, assign) int** board;
@property(nonatomic, assign) int** solution;

+(BoardViewController*) boardWithImage:(UIImage*) board;
-(void) loadBoard;
-(UIImage*) drawGrids;


@end
