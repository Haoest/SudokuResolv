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
//  cvutil.hpp
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Ported to the OpenCV 4 C++ API (cv::Mat + UIImageToMat) in 2026.
//

#import <opencv2/core.hpp>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface cvutil : NSObject

// Returns an RGBA (CV_8UC4) Mat with the UIImage's EXIF orientation baked in.
+ (cv::Mat)MatFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromMat:(const cv::Mat &)mat;
// Loads a bundled image by name (searches the main bundle, then all loaded
// bundles so unit-test resources resolve too).
+ (cv::Mat)LoadUIImageAsMat:(NSString *)fileName asGrayscale:(BOOL)asGrayscale;

+ (int **)ReadBoardFromFile:(NSString *)fileName;
+ (NSString *)SerializeBoard:(int **)board;
+ (int **)DeserializedBoard:(NSString *)board;
+ (int **)loadStringAsBoard:(const char *)boardAsString;

@end
