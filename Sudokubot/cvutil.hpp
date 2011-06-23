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


@interface cvutil :NSObject {

}

+(IplImage *) CreateIplImageFromUIImage: (UIImage*) image ignoreUIOrientation:(bool) ignoreUIOrientation;
+(UIImage*) CreateUIImageFromIplImage: (IplImage*) image;
+(int**) ReadBoardFromFile:(NSString*) fileName;
+(NSString*) SerializeBoard:(int**)board;
+(int**) DeserializedBoard:(NSString*) board;
+(IplImage*) LoadUIImageAsIplImage: (NSString*) fileName asGrayscale:(BOOL) asGrayscale ignoreOrientation:(bool)ignoreOrientation;

+(int**) loadStringAsBoard: (char[89]) boardAsString;

+(CGFloat) getImageOrientationInDegrees:(UIImage*) img;
+(IplImage*) normalizeSourceImageSize:(IplImage *)sourceImage;
@end


