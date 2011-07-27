//
//Copyright 2011 Haoest
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

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


