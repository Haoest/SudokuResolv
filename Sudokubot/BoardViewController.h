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
@property(nonatomic, retain) IBOutlet UIBarButtonItem* saveToArchiveButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem* mainMenuButton;
@property(nonatomic, retain) IBOutlet UITextField *commentTextField;

@property(nonatomic, assign) int** board;
@property(nonatomic, assign) int** solution;

@property(nonatomic, retain) NSString *comments;


-(void) saveToArchive;

+(BoardViewController*) boardWithImage:(UIImage*) board;
-(void) loadBoard;
-(UIImage*) drawGrids;
-(void) wireupControls;

@end

static NSString *archiveFileName = [NSString stringWithString:@"archive.txt"];
