//
//  cvutil.h
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//

#import <opencv2/core/core.hpp>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

using namespace cv;

@interface cvutil :NSObject {

}
+(IplImage *) CreateIplImageFromUIImage: (UIImage*) image;
+(UIImage*) CreateUIImageFromIplImage: (IplImage*) image;

+(UIImage*) BlurImage: (UIImage*) image;
+(UIImage*) FindLines: (UIImage*) image;

void MergeAdjacentLines(vector<Vec2f>* lines);
bool CompareLineByTheta( Vec2f line1,  Vec2f line2);
bool CompareLineByRho(Vec2f line1, Vec2f line2);
void SplitIntoHorizontalAndVeriticalLines(vector<Vec2f>* allLines, vector<Vec2f>* horizontalLines, vector<Vec2f>* verticalLines);
void drawLines(Mat *mat, vector<Vec2f> *lines);
@end
