//
//  cvutil.h
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//

#import <opencv2/core/core.hpp>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//using namespace cv;

@interface cvutil  {
    
}
+(IplImage *) CreateIplImageFromUIImage: (UIImage*) image;
+(UIImage*) CreateUIImageFromIplImage: (IplImage*) image;

+(UIImage*) BlurImage: (UIImage*) image;
+(UIImage*) FindLines: (UIImage*) image;

//void MergeAdjacentLines(vector<Vec2f>* lines)
//bool LineComparator( Vec2f line1,  Vec2f line2)


@end
