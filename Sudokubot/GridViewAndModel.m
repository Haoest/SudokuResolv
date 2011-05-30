//
//  GridView.m
//  Sudokubot
//
//  Created by Haoest on 5/30/11.
//  Copyright 2011 none. All rights reserved.
//

#import "GridViewAndModel.h"


@implementation GridViewAndModel

@synthesize hintFromOCR, hintByManualInput, gridId, previewViewControllerDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setAlpha:0.5];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [previewViewControllerDelegate showNumberMenuForGrid:gridId];
}

@end
